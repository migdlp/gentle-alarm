---
id: E04-T09
title: Vistas de confirmación «¿Ya estás despierto/a?» y de pospuesta con luz tenue
epic: E04
status: todo
depends_on: [E04-T08]
requirements: [RF-31, RF-34, RF-35]
size: S
---

# E04-T09 · Vistas de confirmación «¿Ya estás despierto/a?» y de pospuesta con luz tenue

## Objetivo
El estado `confirming` pregunta con calma si ya estás despierto/a, y el estado `snoozed` muestra luz cálida tenue con una cuenta atrás y la opción de levantarse.

## Contexto
- Confirming (RF-31): fondo crema (p = 1). Texto `confirmQuestion` (32 sp), `confirmHint` (16 sp, opacidad 0,7) y un `FilledButton` grande `confirmYes` → `ringChannel.confirmAwake()`. Si pasan 60 s, el servicio vuelve a sonar (lo decide Kotlin; la vista sólo reacciona al cambio de estado).
- Snoozed (RF-34): fondo liso `peach` `#FFB36B`, brillo 0,15 (lo fija `targetBrightness`). Texto `snoozeBackIn` con mm:ss calculado como `snoozeUntilEpochMs − now`, refrescado cada segundo, y un `TextButton` `iGetUp` → `ringChannel.wakeUp()`. Texto en `inkOnLight`.
- RF-35: la subida de brillo al volver de posponer ya la implementa `targetBrightness` (E04-T07).
- Textos:
| Clave | es | en |
|---|---|---|
| `confirmQuestion` | ¿Ya estás despierto/a? | Are you awake? |
| `confirmHint` | Si no respondes, volveré a sonar bajito. | If you don't answer, I'll ring softly again. |
| `confirmYes` | Sí, buenos días | Yes, good morning |
| `snoozeBackIn` | Vuelvo en {time} | Back in {time} |
| `iGetUp` | Ya me levanto | I'm getting up |

## Archivos
- Crear: `lib/src/core/time/clock.dart`, `lib/src/features/ring/ui/confirm_view.dart`, `lib/src/features/ring/ui/snoozed_view.dart`, `test/features/ring/ui/confirm_view_test.dart` y `test/features/ring/ui/snoozed_view_test.dart`
- Modificar: `ring_root.dart` (cambio de vista con `AnimatedSwitcher` de 600 ms en fundido) y los dos ARB

## Pasos
1. RED: confirm → tocar `confirmYes` llama a `confirmAwake`; snoozed con `snoozeUntil = now + 125 s` muestra «Vuelvo en 02:05» y, tras `pump(1 s)`, «02:04»; tocar `iGetUp` llama a `wakeUp`.
2. Implementa. Usa un reloj inyectable (`clockProvider = Provider<DateTime Function()>((_) => DateTime.now)`) para poder probarlo.
3. GREEN.

## Criterios de aceptación
- [ ] Las 3 pruebas pasan.
- [ ] Manual: posponer → luz tenue melocotón con cuenta atrás; a los 10 min vuelve a sonar con la luz subiendo (anotado).

## Verificación
```bash
flutter gen-l10n && flutter analyze && flutter test test/features/ring
```

## Fuera de alcance
- Saludo (E06-T03).

## Si te bloqueas
- No uses `DateTime.now()` directamente en las vistas: usa siempre `clockProvider`.
