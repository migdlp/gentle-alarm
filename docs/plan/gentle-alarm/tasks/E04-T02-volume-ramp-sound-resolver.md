---
id: E04-T02
title: Curva de volumen y resolución del sonido con respaldo
epic: E04
status: done
depends_on: [E02-T01]
requirements: [RF-21, RF-27]
size: S
---

# E04-T02 · Curva de volumen y resolución del sonido con respaldo

## Objetivo
Dos utilidades puras: `VolumeRamp`, que calcula el volumen perceptual de la rampa y del fundido, y `SoundResolver`, que decide qué sonido reproducir y si hay que usar el de respaldo.

## Contexto
- RF-21: curva perceptual. Con un volumen inicial `s` y un progreso `p ∈ [0,1]`: `v = (√s + (1 − √s)·p)²`. Con s = 0, `v = p²`. Se actualiza cada 250 ms.
- Fundido de salida desde `from` en `fadeMs`: `v = from·(1 − p)²`.
- RF-27: sonidos incluidos `birds_dawn`, `soft_waves`, `light_rain`, `chimes`, `calm_piano` y `singing_bowls` → recurso `res/raw/<id>`. Con `custom`, si `canRead(uri)` es falso o `uri` es null → `birds_dawn` con `fallback = true`. Un id desconocido → `birds_dawn` con `fallback = true`.

## Archivos
- Crear: `android/app/src/main/kotlin/com/migdlp/gentlealarm/ring/VolumeRamp.kt`, `ring/SoundResolver.kt`, `android/app/src/test/kotlin/com/migdlp/gentlealarm/ring/VolumeRampTest.kt` y `ring/SoundResolverTest.kt`

## Pasos
1. RED, con estos tests:
   - `VolumeRamp.rampVolume(elapsedMs = 0, rampMs = 180000, start = 0f) == 0f`; a la mitad → `0.25f` (±0.001); al final y después → `1f`.
   - Con start 0.2 en 0 → 0.2; al final → 1.
   - `fadeVolume(elapsed = 1000, fadeMs = 2000, from = 0.8f) == 0.2f` (±0.001); con elapsed ≥ fadeMs → 0.
   - `SoundResolver.resolve("chimes", null) { true } == Resolved.Raw("chimes", fallback = false)`.
   - `resolve("custom", "content://x") { false } == Resolved.Raw("birds_dawn", fallback = true)`.
   - `resolve("custom", "content://x") { true } == Resolved.Uri("content://x", fallback = false)`.
   - `resolve("unknown", null) { true } == Resolved.Raw("birds_dawn", fallback = true)`.
2. Implementa `object VolumeRamp { fun rampVolume(elapsedMs: Long, rampMs: Long, start: Float): Float; fun fadeVolume(elapsedMs: Long, fadeMs: Long, from: Float): Float }` y `object SoundResolver { val BUILT_IN = listOf(/* 6 ids */); fun resolve(soundId: String, customUri: String?, canRead: (String) -> Boolean): Resolved }` con `sealed interface Resolved { val fallback: Boolean; data class Raw(val name: String, override val fallback: Boolean); data class Uri(val uri: String, override val fallback: Boolean) }`.
3. GREEN.

## Criterios de aceptación
- [x] Los 7 tests pasan.
- [x] Ninguno de los dos archivos importa `android.*`.

## Verificación
```bash
cd android && ./gradlew testDebugUnitTest --tests "*VolumeRampTest*" --tests "*SoundResolverTest*"
```

## Fuera de alcance
- Reproducir el audio (E04-T03).

## Si te bloqueas
- Para comparar floats usa `assertEquals(expected, actual, 0.001f)`.

## Notas de implementación
- VolumeRamp y SoundResolver puros, 10 tests OK, sin android.*.
