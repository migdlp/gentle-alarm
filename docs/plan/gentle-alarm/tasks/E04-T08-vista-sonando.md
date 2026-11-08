---
id: E04-T08
title: Vista de sonando con sol deslizable y «Un ratito más»
epic: E04
status: done
depends_on: [E04-T07]
requirements: [RF-30, RF-33]
size: M
---

# E04-T08 · Vista de sonando con sol deslizable y «Un ratito más»

## Objetivo
En el estado `ringing` se ven la hora grande, la etiqueta, un sol que se desliza hacia arriba para apagar y el botón «Un ratito más» mientras queden posposiciones.

## Contexto
- Fondo: gradiente del fotograma p = 1 de `sunriseFrame` (crema cálido). Texto `inkOnLight` (`#2B1A12`).
- Diseño de arriba abajo: hora (96 sp, Nunito Bold); etiqueta o `defaultLabel` (24 sp); un hueco flexible; el sol (círculo de 96 dp, relleno con un gradiente radial `#FFC872` → `#FF7A3D` y una sombra suave) con una flecha hacia arriba y el texto `swipeUpToStop` debajo; y el botón `snoozeButton` (`OutlinedButton`, ancho completo, 64 dp de alto).
- RF-30: el sol sigue el dedo sólo en vertical hacia arriba. Al soltarlo, si ha subido ≥ 160 dp → `ringChannel.dismissSwipe()`; si no → vuelve con `Curves.easeOutBack` en 300 ms. Mientras se arrastra, el texto `swipeUpToStop` se desvanece de forma proporcional.
- Accesibilidad (RNF-04, aplicada aquí): `Semantics(label: stopAlarmA11y, button: true, onTap: dismissSwipe, customSemanticsActions: {CustomSemanticsAction(label: stopAlarmA11y): dismissSwipe})`.
- RF-33: si `snoozesLeft == 0`, en lugar del botón se muestra el texto `noMoreSnoozes`. El botón muestra `snoozeButton` y debajo `snoozesLeftText`.
- Respiración: el sol escala 1,0 ↔ 1,06 en un ciclo de 4 s, salvo con `MediaQuery.disableAnimations`.
- Textos:
| Clave | es | en |
|---|---|---|
| `swipeUpToStop` | Desliza el sol hacia arriba | Slide the sun up |
| `stopAlarmA11y` | Apagar alarma | Turn off alarm |
| `snoozeButton` | Un ratito más | A little longer |
| `snoozesLeftText` | {count, plural, =1{Queda 1} other{Quedan {count}}} | {count, plural, =1{1 left} other{{count} left}} |
| `noMoreSnoozes` | Ya no quedan más ratitos | No more snoozes left |

## Archivos
- Crear: `lib/src/features/ring/ui/ringing_view.dart`, `lib/src/features/ring/ui/widgets/swipe_sun.dart` y `test/features/ring/ui/ringing_view_test.dart`
- Modificar: `ring_root.dart` y los dos ARB

## Pasos
1. RED: arrastrar el sol 200 dp hacia arriba llama a `dismissSwipe`; arrastrar 100 dp no lo llama y el sol vuelve; tocar `snoozeButton` llama a `snooze`; con `snoozesLeft: 0` no hay botón y sí `noMoreSnoozes`; existe la acción semántica `stopAlarmA11y`.
2. Implementa.
3. GREEN.

## Criterios de aceptación
- [ ] Las 5 pruebas pasan.
- [ ] Con TalkBack, un doble toque sobre el sol apaga la alarma (manual).

## Verificación
```bash
flutter gen-l10n && flutter analyze && flutter test test/features/ring
```

## Fuera de alcance
- Confirmación y pospuesta (E04-T09).

## Si te bloqueas
- Usa `GestureDetector(onVerticalDragUpdate/End)`; no añadas paquetes de gestos.

## Notas de implementación
- RingingView + SwipeSun (arrastre vertical con umbral de 160 dp, retorno easeOutBack 300 ms, respiración 4 s que se desactiva con disableAnimations, acción semántica «Apagar alarma»), botón «Un ratito más» con contador y mensaje sin posposiciones. 5 tests OK. Pendiente manual: TalkBack.
