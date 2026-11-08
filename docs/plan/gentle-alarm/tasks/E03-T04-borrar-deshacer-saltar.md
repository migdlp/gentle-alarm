---
id: E03-T04
title: Borrar con deshacer y saltar la próxima ocurrencia
epic: E03
status: todo
depends_on: [E03-T03]
requirements: [RF-04, RF-07]
size: S
---

# E03-T04 · Borrar con deshacer y saltar la próxima ocurrencia

## Objetivo
Una alarma se borra deslizándola en la lista con 5 s para deshacer, y una alarma repetida puede saltarse sólo su próxima ocurrencia desde su menú.

## Contexto
- Borrar (RF-04): `Dismissible(direction: endToStart)`. Al deslizar se quita de la lista visible (estado optimista) y se muestra un snackbar `alarmDeleted` con la acción `undo`, con `duration: 5 s`. Si el snackbar se cierra sin deshacer → `repo.delete(id)`. Con «Deshacer» → vuelve a la lista sin llamar a nada (no se borró).
- Saltar (RF-07): `PopupMenuButton` en `AlarmTile` (sólo si `isRepeating`) con `skipNext` (o `unskipNext` si `skipsNext`). Llama a `repo.setSkipNext`. Si `skipsNext`, la fila muestra `skippingOn` con la fecha de `skipRingAtEpochMs` (`DateFormat.MMMEd(locale)`).
- Textos:
| Clave | es | en |
|---|---|---|
| `alarmDeleted` | Alarma borrada | Alarm deleted |
| `undo` | Deshacer | Undo |
| `skipNext` | Saltar la próxima | Skip next |
| `unskipNext` | No saltar | Don't skip |
| `skippingOn` | Se salta el {date} | Skipping {date} |
| `deleteAlarm` | Borrar | Delete |
- El menú también incluye `deleteAlarm` (borrado con el mismo snackbar) como alternativa accesible al deslizar.

## Archivos
- Modificar: `alarm_list_screen.dart`, `alarm_tile.dart`, `alarms_providers.dart` (añadir `hideTemporarily(id)` y `restore(id)`) y los dos ARB
- Modificar: `test/features/alarms/ui/alarm_list_screen_test.dart`

## Pasos
1. RED: deslizar → desaparece y aparece `alarmDeleted`; esperar 5 s (`tester.pump(Duration(seconds: 6))`) → `delete` llamado una vez; deslizar + `undo` → vuelve y `delete` no se llama; el menú de una alarma repetida tiene `skipNext`, y tocarlo llama a `setSkipNext(id, true)`; una alarma sin días no muestra `skipNext`.
2. Implementa.
3. GREEN.

## Criterios de aceptación
- [ ] Las 5 pruebas pasan.
- [ ] Con TalkBack, borrar es posible desde el menú.

## Verificación
```bash
flutter gen-l10n && flutter analyze && flutter test test/features/alarms
```

## Fuera de alcance
- Comportamiento de borrar durante una sesión activa (lo resuelve Kotlin en E04-T04).

## Si te bloqueas
- Si la app se cierra antes de que pasen los 5 s, el borrado no se ejecuta; es aceptable (la alarma sigue existiendo). No lo compenses.
