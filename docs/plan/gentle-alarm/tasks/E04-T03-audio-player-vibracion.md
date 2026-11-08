---
id: E04-T03
title: Reproductor de alarma con rampa, fundido, foco de audio, volumen del sistema y vibración
epic: E04
status: done
depends_on: [E04-T02]
requirements: [RF-20, RF-22, RF-26, RF-84]
size: M
---

# E04-T03 · Reproductor de alarma con rampa, fundido, foco de audio, volumen del sistema y vibración

## Objetivo
`AlarmAudioPlayer` reproduce en bucle el sonido resuelto con `USAGE_ALARM`, aplica la rampa o el fundido, pausa y reanuda con el foco de audio, fija y restaura el volumen del flujo de alarma, y `GentleVibrator` vibra con el patrón suave.

## Contexto
- `VolumeRamp` y `SoundResolver` (E04-T02).
- `AudioAttributes.Builder().setUsage(USAGE_ALARM).setContentType(CONTENT_TYPE_SONIFICATION)`. Con eso suena en silencio y en No molestar (RF-84).
- ADR-10: al primer `start` de la sesión se guarda `previousAlarmVolume = am.getStreamVolume(STREAM_ALARM)` y se fija `am.setStreamVolume(STREAM_ALARM, max(1, round(am.getStreamMaxVolume(STREAM_ALARM) * maxVolumePercent / 100.0)), 0)`. `release()` lo restaura.
- Foco: `AudioFocusRequest(AUDIOFOCUS_GAIN_TRANSIENT)` en API 26+. `AUDIOFOCUS_LOSS*` → callback `onFocusLost()`; `AUDIOFOCUS_GAIN` → `onFocusGained()`. El servicio traduce esos callbacks a `FocusLost` y `FocusGained` de la máquina.
- Rampa: un `Handler(Looper.getMainLooper())` actualiza `player.setVolume(v, v)` cada 250 ms.
- Vibración (RF-23): `VibrationEffect.createWaveform(longArrayOf(0, 400, 1600), intArrayOf(0, 80, 0), 0)` con repetición desde el índice 0. En dispositivos sin control de amplitud (`!hasAmplitudeControl()`), usa `createWaveform(longArrayOf(0, 400, 1600), 0)`. `AudioAttributes` de alarma (`VibrationAttributes.USAGE_ALARM` en API 33+).
- Un fallo de `MediaPlayer` (`onError`) con un URI propio → reintenta una vez con `res/raw/birds_dawn` y marca `fallback = true`.

## Archivos
- Crear: `android/app/src/main/kotlin/com/migdlp/gentlealarm/ring/AlarmAudioPlayer.kt` y `ring/GentleVibrator.kt`
- Crear: `android/app/src/test/kotlin/com/migdlp/gentlealarm/ring/RampSchedulerTest.kt` (prueba de la lógica de pasos de rampa extraída en `RampScheduler`, pura)

## Pasos
1. Extrae la lógica de pasos en `class RampScheduler(private val startMs: Long, private val rampMs: Long, private val startVolume: Float)`, con `fun volumeAt(nowMs: Long): Float` (usa `VolumeRamp`) y `fun isDone(nowMs): Boolean`. RED: tests de `volumeAt` en 0, 50 % y 100 % e `isDone`.
2. GREEN de `RampScheduler`.
3. Implementa `class AlarmAudioPlayer(context: Context, listener: Listener)` con `interface Listener { fun onFocusLost(); fun onFocusGained(); fun onFallbackUsed() }` y los métodos `fun start(resolved: Resolved, maxVolumePercent: Int, startVolume: Float, rampMs: Long)`, `fun stop(fadeMs: Long)`, `fun pause()`, `fun resume(rampMs: Long)` y `fun release()` (restaura el volumen, abandona el foco y libera el reproductor). `start` en un tramo nuevo reutiliza la misma instancia de `MediaPlayer` si ya está preparada.
4. `class GentleVibrator(context)` con `start()` y `stop()`. Obtiene el vibrador con `VibratorManager` en API 31+ y con `Vibrator` en 26-30.
5. Compila. La prueba manual completa se hace en E04-T04.

## Criterios de aceptación
- [x] `RampSchedulerTest` pasa.
- [x] `AlarmAudioPlayer.release()` restaura `STREAM_ALARM` al valor previo (revisión de código; se comprueba a mano en E04-T04).
- [x] La app compila.

## Verificación
```bash
cd android && ./gradlew testDebugUnitTest --tests "*RampSchedulerTest*"
flutter build apk --debug
```

## Fuera de alcance
- El servicio y sus notificaciones (E04-T04) y la vista previa de sonido en el selector (E05-T02).

## Si te bloqueas
- Si `setStreamVolume` lanza `SecurityException` en No molestar (ocurre en algunos dispositivos con la política de acceso a No molestar), captúrala, registra un log y continúa sin cambiar el volumen.

## Notas de implementación
- RampScheduler (4 tests OK), AlarmAudioPlayer (USAGE_ALARM, foco GAIN_TRANSIENT, volumen del flujo de alarma fijado/restaurado, fallback a birds_dawn si falla un URI propio, SecurityException capturada) y GentleVibrator. Compila. Pendiente manual en dispositivo: E04-T04.
