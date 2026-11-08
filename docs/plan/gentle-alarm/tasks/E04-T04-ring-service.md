---
id: E04-T04
title: RingService en primer plano que ejecuta la máquina de estados
epic: E04
status: done
depends_on: [E04-T01, E04-T03, E02-T05]
requirements: [RF-20, RF-25]
size: M
---

# E04-T04 · RingService en primer plano que ejecuta la máquina de estados

## Objetivo
`RingService` es un servicio en primer plano que ejecuta una `RingSessionMachine`, aplica sus efectos (audio, vibración, notificaciones y fin), programa sus plazos, persiste la sesión, ofrece acciones en la notificación y publica el estado a los oyentes.

## Contexto
- ADR-06: `android:foregroundServiceType="systemExempted"`, con los permisos `FOREGROUND_SERVICE` y `FOREGROUND_SERVICE_SYSTEM_EXEMPTED`.
- Intent de arranque: `com.migdlp.gentlealarm.START_SESSION` con los extras `alarmId`, `ringAtEpochMs`, `preview` y `request` (String JSON de `RingRequest`). Esta tarea crea `data class RingRequest(val config: SessionConfig, val soundId: String, val customSoundUri: String?, val maxVolumePercent: Int, val sunriseMinutes: Int, val rampMinutes: Int, val quietSunrise: Boolean)` con `toJson()` y `fromJson()` (en `ring/RingRequest.kt`, con un test de ida y vuelta en `RingRequestTest.kt`). La construcción desde la alarma la hace `RingLauncher` (E04-T05); en esta tarea el servicio sólo la recibe y la usa: tiempos con `RingTimings.normal(sunriseMinutes, rampMinutes)` (o `preview()` si `config.isPreview`), sonido con `SoundResolver.resolve(soundId, customSoundUri, canRead)` y volumen con `maxVolumePercent`. `quietSunrise` lo usa E04-T05.
- Acciones de la notificación: `ACTION_SNOOZE` → `Snooze`; `ACTION_DISMISS` → `SwipeDismiss`, `ConfirmAwake` y `FinishGreeting` seguidos (apagar por completo desde la notificación).
- Canal `ring` (`IMPORTANCE_HIGH`, sin sonido propio ni vibración del canal, `setBypassDnd(true)`). Notificación `CATEGORY_ALARM`, `ongoing`, `fullScreenIntent` a `RingActivity` (la crea E04-T06; aquí se referencia por nombre de clase con `Intent(this, RingActivity::class.java)` y, para compilar antes de E04-T06, se crea `RingActivity` vacía que extiende `FlutterActivity`).
- Textos (`strings.xml`): `channel_ring_name` «Alarma sonando» / «Ringing alarm»; `ring_title_sunrise` «Amaneciendo · suena a las %1$s» / «Sunrise · rings at %1$s»; `ring_title_ringing` «Buenos días · %1$s» / «Good morning · %1$s»; `ring_title_snoozed` «Un ratito más · vuelve a las %1$s» / «A little longer · back at %1$s»; `action_dismiss` «Apagar» / «Turn off»; `action_snooze` «Un ratito más» / «A little longer».
- Wakelock parcial `gentlealarm:session` con un límite de 2 h, adquirido en `onStartCommand` y liberado al terminar.
- Persistencia: tras cada `StateChanged`, `store.saveSession(machine.snapshot().toJson())`. Si el sistema reinicia el servicio (`START_STICKY`, intent null), se restaura con `RingSessionMachine.restore` a partir de `active_session`; si no hay instantánea, `stopSelf()`.
- Bus: `object RingSessionBus { val listeners; fun publish(s: SessionSnapshot?); fun current(): SessionSnapshot? }` para que `RingChannel` (E04-T06) reciba los cambios. Publica `null` al terminar.
- Plazos: tras cada evento, `handler.removeCallbacksAndMessages(TOKEN)` y, si `nextDeadlineMs()` no es null, `handler.postAtTime({ dispatch(Tick) }, TOKEN, uptimeFor(deadline))`.
- `EndSession`: `player.release()`, `vibrator.stop()`, `store.clearSession()`, `RingSessionBus.publish(null)`, la llamada `RingLauncher.onSessionEnded(context, alarmId, reason, ringAt)` (stub que E04-T05 implementa), `stopForeground(STOP_FOREGROUND_REMOVE)` y `stopSelf()`.
- `ShowMissedNotification` → `store.get(alarmId)`; si existe, `MissedNotifier(context).notify(spec, ringAt)` (E02-T05); si ya no existe, no se notifica.

## Archivos
- Crear: `android/app/src/main/kotlin/com/migdlp/gentlealarm/ring/RingService.kt`, `ring/RingRequest.kt`, `ring/RingNotifications.kt`, `ring/RingSessionBus.kt` y `ring/RingActivity.kt` (vacía, si aún no existe)
- Modificar: `AndroidManifest.xml` (`<service android:name=".ring.RingService" android:foregroundServiceType="systemExempted" android:exported="false"/>` y los permisos) y los dos `strings.xml`
- Crear: `android/app/src/test/kotlin/com/migdlp/gentlealarm/ring/EffectDispatcherTest.kt` y `ring/RingRequestTest.kt`

## Pasos
1. Extrae `class EffectDispatcher(private val audio: AudioPort, private val vib: VibrationPort, private val notifier: SessionNotifierPort)` con `fun apply(effects: List<Effect>, snapshot: SessionSnapshot)`; los puertos son interfaces implementadas por `AlarmAudioPlayer`, `GentleVibrator` y `RingNotifications`. RED: con puertos falsos, comprueba que `StartSound` llama a `audio.start`, `StopSound(2000)` a `audio.stop(2000)`, `StartVibration` a `vib.start`, `ShowMissedNotification` a `notifier.missed` y `StateChanged` a `notifier.update(snapshot)`.
2. GREEN de `EffectDispatcher`.
3. Implementa `RingService` siguiendo el contexto: `onStartCommand` → `startForeground(id = 4242, notif, FOREGROUND_SERVICE_TYPE_SYSTEM_EXEMPTED)` en API 34+ (sin tipo en < 34) antes de 5 s; crea la máquina y llama a `start(now)`.
4. Si llega un segundo `START_SESSION` con una sesión ya activa, ignóralo aquí (la absorción la decide `RingLauncher` en E04-T05 antes de llamar al servicio).
5. Prueba manual provisional: lanza el servicio con `adb shell am start-foreground-service -n com.migdlp.gentlealarm/.ring.RingService -a com.migdlp.gentlealarm.START_SESSION --es request '<RingRequest JSON con skipSunrise true y rampMinutes 1>'`. Comprueba que suena al 0 % y sube, que «Un ratito más» desde la notificación pospone y que «Apagar» lo para y restaura el volumen de alarma del sistema.

## Criterios de aceptación
- [ ] `EffectDispatcherTest` y `RingRequestTest` pasan.
- [ ] La prueba manual del paso 5 se ha hecho (anotada), incluido que el volumen del sistema queda restaurado.
- [ ] Con No molestar activado, suena (RF-84).
- [ ] Una llamada entrante durante el sonido lo pausa y al colgar vuelve con una rampa de 30 s (RF-26), comprobado con el emulador (`adb emu gsm call 600123456`).

## Verificación
```bash
cd android && ./gradlew testDebugUnitTest --tests "*EffectDispatcherTest*" --tests "*RingRequestTest*"
flutter build apk --debug
```

## Fuera de alcance
- Decidir cuándo y cómo se inicia la sesión (E04-T05) y la UI de Flutter (E04-T06).

## Si te bloqueas
- Si `startForeground` lanza `ForegroundServiceStartNotAllowedException` o `InvalidForegroundServiceTypeException` en API 34+, aplica el plan B de ADR-06 (`mediaPlayback`), anótalo y repórtalo en el resumen.

## Notas de implementación
- RingService (FGS systemExempted, wakelock 2 h, persistencia/restauración, plazos con postAtTime, acciones Apagar/Posponer), RingNotifications, RingSessionBus, RingRequest, EffectDispatcher con puertos y RingActivity vacía; manifest y strings es/en. Extra: ACTION_EVENT (intent con extra event) para que E04-T06 reenvíe gestos. EffectDispatcherTest y RingRequestTest OK; APK compila. PENDIENTE (requiere emulador/dispositivo): prueba manual del paso 5, No molestar y llamada entrante.
