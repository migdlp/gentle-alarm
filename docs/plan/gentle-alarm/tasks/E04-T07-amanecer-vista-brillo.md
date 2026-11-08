---
id: E04-T07
title: Vista de amanecer con gradiente, brillo progresivo y hoja de opciones
epic: E04
status: todo
depends_on: [E04-T06]
requirements: [RF-11, RF-13, RF-14, RNF-02]
size: M
---

# E04-T07 · Vista de amanecer con gradiente, brillo progresivo y hoja de opciones

## Objetivo
Durante el estado `sunrise` la pantalla muestra un gradiente que va de la noche al blanco cálido y sube el brillo según el progreso, con la hora apenas visible, y al tocarla aparece una hoja con «Ya estoy despierto/a» y «Seguir durmiendo».

## Contexto
- `progress = clamp((now − sunriseStartEpochMs) / (ringAtEpochMs − sunriseStartEpochMs), 0, 1)`. Si el denominador es 0 → 1.
- Fotogramas clave (color superior, color inferior):
| p | arriba | abajo |
|---|---|---|
| 0,00 | `#05060F` | `#0B1026` |
| 0,25 | `#1A1033` | `#3A0F1E` |
| 0,50 | `#5A1E3A` | `#C2452D` |
| 0,75 | `#FF7A3D` | `#FFC872` |
| 1,00 | `#FFE3B8` | `#FFF4E0` |
  Interpolación lineal por tramo con `Color.lerp`.
- Brillo de la ventana: `0.01 + 0.99 × p²`.
- `targetBrightness(session, now)` para todas las vistas (lo usan también E04-T08 y E04-T09): sunrise → la fórmula anterior; ringing con `brightnessRampFromSnooze` → `0.15 + 0.85 × clamp((now − stateSince) / snoozeBrightnessRampMs, 0, 1)` (usa 60 000 si no es vista previa y 5 000 si lo es); ringing sin esa marca → 1,0; snoozed → 0,15; confirming → 1,0; greeting → 1,0.
- `RingRoot` tiene un `Timer.periodic(500 ms)` que recalcula `progress` y llama a `ringChannel.setBrightness(targetBrightness(session, now))` sólo si cambia más de 0,005.
- RF-14: sólo se ve la hora actual en grande (72 sp, Nunito SemiBold) en blanco con opacidad 0,10, centrada. Excluida de la regla de contraste RNF-05 por diseño.
- RNF-02: `AnimatedContainer(duration: 500 ms, decoration: BoxDecoration(gradient: LinearGradient(begin: topCenter, end: bottomCenter, colors: [arriba, abajo])))`, sin reconstruir más de 2 veces por segundo.
- RF-13: al tocar → `showModalBottomSheet` con `sunriseRingsAt` y los botones `wakeEarly` (`FilledButton`, llama a `ringChannel.wakeEarly()`) y `keepSleeping` (`TextButton`, cierra la hoja). Con la hoja abierta el brillo baja temporalmente a 0,3 para no deslumbrar.
- Textos:
| Clave | es | en |
|---|---|---|
| `sunriseRingsAt` | Suena a las {time} | Rings at {time} |
| `wakeEarly` | Ya estoy despierto/a | I'm already awake |
| `keepSleeping` | Seguir durmiendo | Keep sleeping |

## Archivos
- Crear: `lib/src/features/ring/domain/sunrise.dart` (`SunriseFrame sunriseFrame(double p)` y `double targetBrightness(RingSession s, DateTime now)`), `lib/src/features/ring/ui/sunrise_view.dart`, `test/features/ring/domain/sunrise_test.dart` y `test/features/ring/ui/sunrise_view_test.dart`
- Modificar: `ring_root.dart` (temporizador y selección de vista) y los dos ARB

## Pasos
1. RED `sunrise_test.dart`: los colores en p = 0, 0,25, 0,5, 0,75 y 1 coinciden con la tabla; p = 0,125 está a medio camino entre los dos primeros (comprueba el canal rojo ±1); brillo en 0 = 0,01, en 0,5 = 0,2575 y en 1 = 1,0; `targetBrightness` para cada estado; p fuera de [0,1] se limita.
2. RED `sunrise_view_test.dart`: tocar abre la hoja con los 3 textos; tocar `wakeEarly` llama al canal (mock).
3. Implementa.
4. GREEN.
5. Manual: en modo profile en un móvil real, la vista de amanecer no deja caer fotogramas (Flutter DevTools, anota la captura).

## Criterios de aceptación
- [ ] Las pruebas pasan.
- [ ] En un móvil real el amanecer de 5 min se ve suave, sin saltos de color.
- [ ] Prueba de rendimiento anotada (RNF-02).

## Verificación
```bash
flutter gen-l10n && flutter analyze && flutter test test/features/ring
flutter run --profile
```

## Fuera de alcance
- Vista de sonando (E04-T08).

## Si te bloqueas
- Si `setBrightness` no tiene efecto, comprueba en Kotlin que se modifica `window.attributes` y se vuelve a asignar (`window.attributes = lp`) en el hilo principal.
