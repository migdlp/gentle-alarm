---
id: E04-T01
title: RingSessionMachine pura con escalada, posponer y confirmación
epic: E04
status: done
depends_on: [E01-T01]
requirements: [RF-23, RF-24, RF-31, RF-32, RF-33, RF-35]
size: M
---

# E04-T01 · RingSessionMachine pura con escalada, posponer y confirmación

## Objetivo
Una máquina de estados Kotlin pura (sin `android.*`) decide estados, efectos y el siguiente plazo de una sesión de despertar, con todas las reglas de escalada cubiertas por JUnit.

## Contexto
Estados: `sunrise`, `ringing`, `confirming`, `snoozed`, `greeting` y `ended`. Diagrama y efectos en `02-architecture.md` §3.4. Constantes (§3.5):
| Constante | Normal | Vista previa |
|---|---|---|
| sunriseMs | sunriseMinutes × 60 000 | 30 000 |
| rampMs | rampMinutes × 60 000 | 30 000 |
| snoozeMs | 600 000 | 10 000 |
| maxSnoozes | 3 | 3 |
| vibrationAfterMs | 300 000 | 15 000 |
| autoSnoozeAfterMs | 900 000 | null (desactivado) |
| confirmTimeoutMs | 60 000 | 10 000 |
| confirmRetryStartVolume | 0.2 | 0.2 |
| fadeOutMs | 2 000 | 2 000 |
| focusResumeRampMs | 30 000 | 30 000 |
| previewHardStopMs | null | 90 000 |
| snoozeBrightnessRampMs | 60 000 | 5 000 |

Reglas:
- `start(now)`: si `skipSunrise` o `now >= ringAtMs` → Ringing (startVolume 0, rampMs); si no → Sunrise.
- Sunrise: `Tick` con `now >= ringAtMs` → Ringing. `WakeEarly` → Greeting con `endReason` pendiente `woke_early`.
- Ringing: `SwipeDismiss` → Confirming + `StopSound(2000)` + `StopVibration`. `Snooze` con `snoozesLeft > 0` → Snoozed(manual): `snoozesLeft--`, `StopSound(500)` y `StopVibration`; con 0 se ignora (sin efectos). `Tick` ≥ segmentStart + vibrationAfterMs y `vibrate` → `StartVibration` (una vez por tramo). `Tick` ≥ segmentStart + autoSnoozeAfterMs: si `!autoSnoozeUsed` → Snoozed(auto) y `autoSnoozeUsed = true`; si no → Ended(missed) + `ShowMissedNotification`. En la vista previa, `Tick` ≥ firstRingingAt + previewHardStopMs → Ended(preview_done).
- `FocusLost` en Ringing → `PauseSound` y congela (guarda pausedAt; no hay plazo mientras está pausado). `FocusGained` → `ResumeSound(30 000)`, segmentStart += (now − pausedAt).
- Snoozed: `Tick` ≥ snoozeUntil → Ringing con `brightnessRampFromSnooze = true`, startVolume 0. `WakeUp` → Confirming.
- Confirming: `ConfirmAwake` → Greeting. `Tick` ≥ since + confirmTimeoutMs → Ringing con startVolume 0.2 (tramo nuevo, `brightnessRampFromSnooze = false`).
- Greeting: `FinishGreeting` → Ended(`confirmed`, o `woke_early` si se llegó por WakeEarly).
- Toda entrada en `ended` añade `EndSession(reason)`. Cada cambio de estado añade `StateChanged`.
- Cualquier evento que no se ajuste al estado actual se ignora y devuelve una lista vacía.

## Archivos
- Crear: `android/app/src/main/kotlin/com/migdlp/gentlealarm/ring/RingTimings.kt`, `ring/RingSessionMachine.kt`, `ring/SessionSnapshot.kt` y `android/app/src/test/kotlin/com/migdlp/gentlealarm/ring/RingSessionMachineTest.kt`

## Pasos
1. Define los tipos:
   ```kotlin
   data class RingTimings(/* campos de la tabla */) { companion object { fun normal(sunriseMin: Int, rampMin: Int): RingTimings; fun preview(): RingTimings } }
   data class SessionConfig(val alarmId: String, val label: String, val ringAtMs: Long, val sunriseStartMs: Long, val vibrate: Boolean, val isPreview: Boolean, val skipSunrise: Boolean)
   sealed interface RingEvent { object SwipeDismiss; object Snooze; object WakeUp; object WakeEarly; object ConfirmAwake; object FinishGreeting; object FocusLost; object FocusGained; object Tick }
   sealed interface Effect { data class StartSound(val startVolume: Float, val rampMs: Long); data class StopSound(val fadeMs: Long); object PauseSound; data class ResumeSound(val rampMs: Long); object StartVibration; object StopVibration; object ShowMissedNotification; data class EndSession(val reason: String); object StateChanged }
   ```
2. `SessionSnapshot` con los campos de §3.2, `toJson(): JSONObject` y `fromJson`.
3. RED: escribe los tests de la tabla de casos límite con un reloj manual (`var now = 0L`).
4. Implementa `class RingSessionMachine(config, timings)` con `fun start(nowMs): List<Effect>`, `fun handle(event, nowMs): List<Effect>`, `fun nextDeadlineMs(): Long?`, `fun snapshot(): SessionSnapshot` y `companion fun restore(snapshot, config, timings)`.
5. GREEN y REFACTOR.

## Casos límite a cubrir
| Caso | Esperado |
|---|---|
| start con now < ringAt | estado sunrise; plazo = ringAt |
| start con skipSunrise | ringing; efectos StartSound(0, rampMs) |
| Tick en ringAt | ringing + StartSound(0, rampMs) |
| Tick a +5 min de tramo con vibrate | StartVibration una sola vez (un segundo Tick no la repite) |
| Tick a +5 min con vibrate = false | sin StartVibration |
| Tick a +15 min sin interacción (primera vez) | snoozed, autoSnoozeUsed = true, snoozesLeft = 3 |
| Tras el autoposponer, nuevo tramo y +15 min | ended(missed) + ShowMissedNotification + EndSession("missed") |
| Snooze 3 veces | snoozesLeft = 0; un cuarto Snooze no cambia nada |
| Snoozed y Tick en snoozeUntil | ringing, brightnessRampFromSnooze = true |
| SwipeDismiss | confirming + StopSound(2000) + StopVibration |
| Confirming sin respuesta 60 s | ringing + StartSound(0.2, rampMs) |
| ConfirmAwake y FinishGreeting | greeting → ended("confirmed") |
| WakeEarly en sunrise y FinishGreeting | ended("woke_early") |
| FocusLost a +2 min y FocusGained a +7 min | ResumeSound(30000); la vibración ocurre a +10 min de reloj (5 min de tramo efectivos) |
| Vista previa: 90 s desde el primer ringing | ended("preview_done") |
| restore(snapshot()) | misma salida de nextDeadlineMs y snapshot |

## Criterios de aceptación
- [x] Los 16 casos tienen un test que pasa.
- [x] `RingSessionMachine.kt` no importa nada de `android.*`.

## Verificación
```bash
cd android && ./gradlew testDebugUnitTest --tests "*RingSessionMachineTest*"
```

## Fuera de alcance
- Reproducir audio y servicio (E04-T03, E04-T04).

## Si te bloqueas
- Si una regla de esta tarea parece contradecir `02-architecture.md`, gana esta tarea; anótalo en «Notas de implementación».

## Notas de implementación
- RingTimings, SessionSnapshot y RingSessionMachine (sin android.*) con 19 tests JUnit que cubren los 16 casos. restore() reconstruye vibración/pausa desde el snapshot (la vibración puede repetirse tras una muerte del proceso; aceptable). Tests escritos junto a la implementación (sin ejecución RED separada). Usar `:app:testDebugUnitTest`.
