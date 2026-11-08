---
id: E04-T05
title: RingLauncher que inicia y cierra sesiones (absorción, batería baja, móvil en uso)
epic: E04
status: done
depends_on: [E04-T04]
requirements: [RF-06, RF-15, RF-16, RF-44, RF-45, RF-81, RF-82, RF-83]
size: M
---

# E04-T05 · RingLauncher que inicia y cierra sesiones (absorción, batería baja, móvil en uso)

## Objetivo
Cuando AlarmManager dispara, `RingLauncher` decide si la sesión empieza con amanecer, sin amanecer, sólo con notificación, aplazada o absorbida; al terminar la sesión, reprograma o desactiva la alarma.

## Contexto
- `RingLauncher.onFire(context, alarmId, ringAt)` y `RingLauncher.onSessionEnded(context, alarmId, reason, ringAt)` existen como stubs (E02-T04 y E04-T04). Esta tarea los implementa.
- Decisión pura `LaunchDecision.decide(input): Launch`, con `input = (spec: AlarmSpec?, ringAt, now, sessionActive: Boolean, batteryPct: Int, charging: Boolean, userUnlocked: Boolean, interactive: Boolean)`:
| Condición (en este orden) | Resultado |
|---|---|
| spec es null o `!enabled` | `Ignore` |
| sessionActive y ringAt > now | `DeferToRingTime` (RF-45: se reprograma el disparo exactamente en T) |
| sessionActive y ringAt ≤ now | `Absorb` (RF-44 y RF-81) |
| ringAt ≤ now (disparo en T o tardío) | `Start(skipSunrise = true)` |
| !userUnlocked | `Start(skipSunrise = true)` (ADR-13) |
| batteryPct ≤ 10 y !charging | `Start(skipSunrise = true)` (RF-15) |
| interactive y userUnlocked | `Start(skipSunrise = false, quietSunrise = true)` (RF-16) |
| en otro caso | `Start(skipSunrise = false)` |
- `quietSunrise = true`: el servicio publica la notificación «Amanecer en curso · Suena a las {HH:mm}» (`ring_title_sunrise_quiet`, es/en: «Sunrise in progress · Rings at %1$s») con la acción «Ver amanecer» (`action_view_sunrise` / «View sunrise») que abre `RingActivity`, y **sin** `fullScreenIntent` durante el amanecer. En T, el servicio vuelve a publicar la notificación con `fullScreenIntent`.
- `Absorb`: no se inicia sesión; `AlarmScheduler.reschedule(spec)` programa la siguiente ocurrencia. `DeferToRingTime`: `AlarmScheduler.scheduleFireAt(spec, fireAt = ringAt, ringAt)` (método nuevo).
- `Start`: crea el `RingRequest` (E04-T04) con una copia de la configuración de la alarma en ese momento (RF-82: los cambios posteriores no afectan; `sunriseStartMs = ringAt − sunriseMinutes·60 000` limitado a ≥ now) y arranca `RingService` con `startForegroundService`. Con `setAlarmClock` el arranque de servicios en primer plano desde segundo plano está permitido.
- `onSessionEnded`: si la alarma ya no existe en el store (borrada durante la sesión, RF-83) → nada. Si `weekdays` está vacío → `enabled = false` y `scheduledRingAtEpochMs = null` (RF-06). Si es repetida → `AlarmScheduler.reschedule(spec)`. Si `skipRingAtEpochMs <= now` → se limpia. En la vista previa (`alarmId == "preview"`) → nada.

## Archivos
- Crear: `android/app/src/main/kotlin/com/migdlp/gentlealarm/ring/LaunchDecision.kt`, `ring/SessionEndHandler.kt`, `android/app/src/test/kotlin/com/migdlp/gentlealarm/ring/LaunchDecisionTest.kt` y `ring/SessionEndHandlerTest.kt`
- Modificar: `alarm/RingLauncher.kt`, `alarm/AlarmScheduler.kt` (`scheduleFireAt`), `ring/RingService.kt` (soporte de `quietSunrise`) y los dos `strings.xml`

## Pasos
1. RED: un test por fila de la tabla y además: una alarma de una sola vez al terminar queda desactivada; una repetida se reprograma; una borrada durante la sesión no se recrea (prueba de `SessionEndHandler`, la lógica pura de `onSessionEnded`, con un store en memoria y un puerto falso).
2. Implementa `LaunchDecision` y `SessionEndHandler`.
3. Implementa `RingLauncher`: lee la batería con `registerReceiver(null, IntentFilter(ACTION_BATTERY_CHANGED))`, `UserManager.isUserUnlocked`, `PowerManager.isInteractive && !KeyguardManager.isKeyguardLocked` (= interactive y desbloqueado) y `sessionActive = RingSessionBus.current() != null`.
4. GREEN.
5. Manual: dos alarmas a las 07:30 y 07:31 con amanecer de 5 min → sólo se ve un amanecer; la segunda suena después de apagar la primera sólo si su T aún no ha pasado y, si no, queda absorbida (anótalo).

## Criterios de aceptación
- [ ] Los 11 tests (8 filas + 3 de fin de sesión) pasan.
- [ ] La prueba manual del paso 5 está anotada.

## Verificación
```bash
cd android && ./gradlew testDebugUnitTest --tests "*LaunchDecisionTest*" --tests "*SessionEndHandlerTest*"
flutter build apk --debug
```

## Fuera de alcance
- UI de Flutter (E04-T06 en adelante) y vista previa (E07-T04).

## Si te bloqueas
- Si `startForegroundService` desde `AlarmReceiver` falla en API 31+, comprueba que se llama desde el `onReceive` del disparo de `setAlarmClock` (exento); si no, para y reporta el stacktrace.

## Notas de implementación
- LaunchDecision (10 tests) y SessionEndHandler (4 tests) puros; RingLauncher real (batería, desbloqueo, interactividad), AlarmScheduler.scheduleFireAt, amanecer silencioso en RingNotifications/RingService y strings es/en. Las alarmas absorbidas pasan por SessionEndHandler (una sola vez se desactiva en vez de reprogramarse al día siguiente). PENDIENTE manual: paso 5 (dos alarmas seguidas) en dispositivo.
