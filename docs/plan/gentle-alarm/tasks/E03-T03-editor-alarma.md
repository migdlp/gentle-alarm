---
id: E03-T03
title: Editor de alarma (crear y editar)
epic: E03
status: done
depends_on: [E03-T02, E05-T01]
requirements: [RF-01, RF-02, RF-80, RF-08]
size: M
---

# E03-T03 · Editor de alarma (crear y editar)

## Objetivo
Desde la lista se crea una alarma nueva (con los defaults de los ajustes) o se edita una existente, y al guardar vuelve a la lista con el snackbar «Sonará en 7 h 20 min» calculado con `scheduledRingAtEpochMs`.

## Contexto
- Campos y valores permitidos: hora (selector de reloj `showTimePicker`), días (7 `FilterChip` L M X J V S D en es y M T W T F S S en en, ISO 1-7), etiqueta (`TextField`, `maxLength: 40`), sonido (fila que muestra `SoundCatalog.label(l10n, soundId, customSoundName)` de E05-T01; tocarla aún no hace nada y E05-T02 la conecta), amanecer (`SegmentedButton` o desplegable con 0, 5, 10, 15, 20, 30 y 45; 0 = «Sin amanecer»), rampa (1, 2, 3, 5 o 10 min), volumen máximo (`Slider` de 10 a 100 con `divisions: 9`) y vibración (`SwitchListTile`).
- Crear: `Alarm.create(hour: 7, minute: 30, defaults: ref.read(alarmDefaultsProvider))`.
- Navegación: `Navigator.push(MaterialPageRoute(builder: (_) => AlarmEditorScreen(initial: alarm?)))`. Se llega desde el FAB, desde el botón del estado vacío y tocando un `AlarmTile`.
- Guardar → `ref.read(alarmsProvider.notifier).save(alarm)` → `pop` → snackbar `willRingIn` con `formatInDuration(nextRingAt − now)`.
- Error `SCHEDULE_FAILED` → snackbar `errorScheduleFailed` sin salir del editor. Cualquier otro `AlarmException` → `errorGeneric`.
- Salir con cambios sin guardar (Atrás) → diálogo `discardTitle` con «Descartar» y «Seguir editando».
- Textos nuevos:
| Clave | es | en |
|---|---|---|
| `newAlarm` | Nueva alarma | New alarm |
| `editAlarm` | Editar alarma | Edit alarm |
| `save` | Guardar | Save |
| `labelHint` | Etiqueta (opcional) | Label (optional) |
| `repeat` | Repetir | Repeat |
| `sound` | Sonido | Sound |
| `sunrise` | Amanecer antes de sonar | Sunrise before ringing |
| `noSunrise` | Sin amanecer | No sunrise |
| `minutesShort` | {m} min | {m} min |
| `ramp` | Subida del volumen | Volume fade-in |
| `maxVolume` | Volumen máximo | Maximum volume |
| `vibration` | Vibración suave | Gentle vibration |
| `willRingIn` | Sonará {inDuration} | Will ring {inDuration} |
| `errorScheduleFailed` | No hemos podido programar la alarma. Revisa el permiso de alarmas exactas. | We couldn't schedule the alarm. Check the exact alarms permission. |
| `errorGeneric` | Algo ha fallado. Inténtalo de nuevo. | Something went wrong. Please try again. |
| `discardTitle` | ¿Descartar los cambios? | Discard changes? |
| `discard` | Descartar | Discard |
| `keepEditing` | Seguir editando | Keep editing |

## Archivos
- Crear: `lib/src/features/alarms/ui/alarm_editor_screen.dart` y `test/features/alarms/ui/alarm_editor_screen_test.dart`
- Modificar: `alarm_list_screen.dart` (navegación), `alarm_tile.dart` (onTap) y los dos ARB

## Pasos
1. RED: (a) abrir el editor nuevo muestra los defaults de un `alarmDefaultsProvider` sobrescrito (sunrise 10 → aparece seleccionado «10 min»); (b) marcar L y X y guardar envía `weekdays: [1, 3]`; (c) una etiqueta «  Gym  » se guarda como «Gym»; (d) Atrás con cambios muestra `discardTitle`; (e) un repositorio que lanza `SCHEDULE_FAILED` muestra `errorScheduleFailed`.
2. Implementa el editor con estado local (`StatefulWidget` o `ConsumerStatefulWidget`) que guarda un `Alarm` en edición; `PopScope(canPop: !dirty, onPopInvokedWithResult: ...)`.
3. Aplica `trim()` a la etiqueta antes de guardar (RF-80).
4. GREEN.

## Criterios de aceptación
- [ ] Las 5 pruebas pasan.
- [ ] Manual: crear una alarma para dentro de 2 min y ver el snackbar «Sonará en 2 min».

## Verificación
```bash
flutter gen-l10n && flutter analyze && flutter test
```

## Fuera de alcance
- Selector de sonido (E05-T02), «Probar despertar» (E07-T04) y borrar (E03-T04).

## Si te bloqueas
- Si `SoundCatalog` no existe, E05-T01 no está hecha: para y reporta.

## Notas de implementación
- AlarmEditorScreen (hora, días con chips, etiqueta con trim, sonido de solo lectura, amanecer/rampa/volumen/vibración reutilizando alarm_options.dart), navegación desde FAB, estado vacío y tiles, snackbar «Sonará en…», errores y diálogo de descarte. AlarmsNotifier.save ahora devuelve la alarma guardada. 5 tests OK. Pendiente manual: alarma a 2 min.
