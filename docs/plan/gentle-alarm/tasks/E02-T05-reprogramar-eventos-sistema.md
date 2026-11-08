---
id: E02-T05
title: Reprogramar tras reinicio, actualización o cambio de hora y gestionar perdidas
epic: E02
status: todo
depends_on: [E02-T04]
requirements: [RF-41, RF-42]
size: M
---

# E02-T05 · Reprogramar tras reinicio, actualización o cambio de hora y gestionar perdidas

## Objetivo
Tras un reinicio (incluso sin desbloquear), una actualización de la app o un cambio de hora o zona, todas las alarmas activadas quedan reprogramadas. Una ocurrencia pasada hace 30 min o menos empieza ya, y una más antigua deja la notificación «Alarma no atendida».

## Contexto
- Eventos: `android.intent.action.BOOT_COMPLETED`, `android.intent.action.LOCKED_BOOT_COMPLETED`, `android.intent.action.MY_PACKAGE_REPLACED`, `android.intent.action.TIME_SET` y `android.intent.action.TIMEZONE_CHANGED`.
- `missedBootWindowMs = 1 800 000` (RF-42).
- Una ocurrencia está pendiente si `enabled && scheduledRingAtEpochMs != null && scheduledRingAtEpochMs <= now`.
- `RingLauncher.onFire(context, alarmId, ringAt)` existe (stub de E02-T04). Con un `ringAt` pasado, E04-T04 empieza directamente en Ringing.
- Texto de la notificación de perdida (canal `missed`, importancia DEFAULT): título `Alarma no atendida · {HH:mm}` y cuerpo `No te hemos querido despertar a gritos. ¿Todo bien?` (es). En inglés: `Missed alarm · {HH:mm}` y `We didn't want to shout you awake. All good?`. En `strings.xml`: `missed_title` (con `%1$s`), `missed_body` y `channel_missed_name` = «Alarmas no atendidas» / «Missed alarms».
- Una alarma de una sola vez (weekdays vacío) perdida se desactiva (`enabled = false`) además de notificarse.

## Archivos
- Crear: `android/app/src/main/kotlin/com/migdlp/gentlealarm/alarm/BootRecovery.kt` (lógica pura), `alarm/SystemEventsReceiver.kt`, `alarm/MissedNotifier.kt` y `android/app/src/test/kotlin/com/migdlp/gentlealarm/alarm/BootRecoveryTest.kt`
- Modificar: `AndroidManifest.xml`, `res/values/strings.xml` y `res/values-en/strings.xml`

## Pasos
1. RED: `BootRecoveryTest` para `BootRecovery.decide(specs: List<AlarmSpec>, nowMs: Long): List<RecoveryAction>` con `sealed class RecoveryAction { data class FireNow(val alarmId: String, val ringAt: Long); data class NotifyMissed(val alarmId: String, val ringAt: Long) }`.
2. Implementa `decide`: para cada pendiente, si `now − ringAt <= 1 800 000` → `FireNow`; si no → `NotifyMissed`. Si hay más de un `FireNow`, sólo se conserva el de `ringAt` más reciente y los demás pasan a `NotifyMissed` (una sola sesión, RF-44).
3. `MissedNotifier(context).notify(spec, ringAt)`: crea el canal `missed` si no existe y publica la notificación con id `("missed" + alarmId).hashCode()`; al tocarla abre `MainActivity`.
4. `SystemEventsReceiver.onReceive`: `goAsync()`; `store = AlarmStore.from(context)`; ejecuta las acciones (`FireNow` → `RingLauncher.onFire`; `NotifyMissed` → `MissedNotifier` y, si es de una sola vez, `store.upsert(spec.copy(enabled = false))`); después `AlarmScheduler.from(context).rescheduleAll()`; `pendingResult.finish()`.
5. Manifest: `RECEIVE_BOOT_COMPLETED` y `<receiver android:name=".alarm.SystemEventsReceiver" android:exported="true" android:directBootAware="true">` con un `intent-filter` para las 5 acciones.
6. GREEN.

## Casos límite a cubrir
| Caso | Esperado |
|---|---|
| Ninguna pendiente | lista vacía |
| Una pendiente hace 10 min | `FireNow` |
| Una pendiente hace exactamente 30 min | `FireNow` |
| Una pendiente hace 31 min | `NotifyMissed` |
| Dos pendientes hace 5 y 20 min | `FireNow` (la de 5 min) y `NotifyMissed` (la de 20) |
| Alarma desactivada con `scheduledRingAtEpochMs` pasado | ignorada |

## Criterios de aceptación
- [ ] Los 6 casos tienen un test que pasa.
- [ ] El manifest registra `SystemEventsReceiver` con las 5 acciones y `directBootAware="true"`.
- [ ] La prueba manual de reinicio con alarmas reales se hace en E09-T02 (escenario 3); aquí no se exige.

## Verificación
```bash
cd android && ./gradlew testDebugUnitTest --tests "*BootRecoveryTest*"
flutter build apk --debug
```

## Fuera de alcance
- El sonido de la sesión (E04).

## Si te bloqueas
- Si `LOCKED_BOOT_COMPLETED` no llega en el emulador, prueba con `adb shell am broadcast -a android.intent.action.LOCKED_BOOT_COMPLETED -p com.migdlp.gentlealarm` y anótalo.
