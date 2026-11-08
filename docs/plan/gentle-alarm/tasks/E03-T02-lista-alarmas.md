---
id: E03-T02
title: Pantalla de lista de alarmas con próxima alarma e interruptores
epic: E03
status: done
depends_on: [E03-T01, E01-T04]
requirements: [RF-03, RF-05, RF-09]
size: M
---

# E03-T02 · Pantalla de lista de alarmas con próxima alarma e interruptores

## Objetivo
La pantalla inicial lista las alarmas con su hora, días y etiqueta, permite activarlas o desactivarlas, muestra la próxima alarma en la cabecera y un estado vacío amable.

## Contexto
- `AlarmRepository` y `alarmRepositoryProvider` existen (E02-T07). Esta tarea crea `alarmsProvider = AsyncNotifierProvider<AlarmsNotifier, List<Alarm>>` con `build()` → `repo.list()`, `toggle(id, enabled)`, `save(alarm)`, `remove(id)` y `refresh()`.
- La lista se recarga al volver a primer plano (`AppLifecycleListener(onResume: () => ref.read(alarmsProvider.notifier).refresh())`), porque Kotlin cambia el store al acabar una sesión.
- Formato de hora: `MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay(hour:, minute:), alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat)`.
- Días: si están los 7 → `everyDay`; si son [1..5] → `weekdaysOnly`; si son [6,7] → `weekendsOnly`; si está vacío → `onceOnly`; en otro caso, abreviaturas de `DateFormat.E(locale)` unidas por «, ».
- Textos (añadir a `app_es.arb` y `app_en.arb`):
| Clave | es | en |
|---|---|---|
| `alarmsTitle` | Alarmas | Alarms |
| `emptyTitle` | Aún no tienes alarmas | No alarms yet |
| `emptyBody` | Crea la primera y despierta con calma. | Create your first one and wake up calmly. |
| `createAlarm` | Crear alarma | Create alarm |
| `nextAlarm` | Próxima: {when} ({inDuration}) | Next: {when} ({inDuration}) |
| `noActiveAlarms` | Ninguna alarma activada | No alarms on |
| `todayAt` | hoy a las {time} | today at {time} |
| `tomorrowAt` | mañana a las {time} | tomorrow at {time} |
| `weekdayAt` | el {weekday} a las {time} | on {weekday} at {time} |
| `inHoursMinutes` | en {h} h {m} min | in {h} h {m} min |
| `inMinutes` | en {m} min | in {m} min |
| `inLessThanMinute` | en menos de 1 min | in less than 1 min |
| `everyDay` | Todos los días | Every day |
| `weekdaysOnly` | De lunes a viernes | Weekdays |
| `weekendsOnly` | Fines de semana | Weekends |
| `onceOnly` | Una vez | Once |
| `defaultLabel` | Alarma | Alarm |
| `settingsTooltip` | Ajustes | Settings |

## Archivos
- Crear: `lib/src/features/alarms/state/alarms_providers.dart`, `lib/src/features/alarms/ui/alarm_list_screen.dart`, `lib/src/features/alarms/ui/widgets/alarm_tile.dart`, `lib/src/core/time/format.dart`, `test/core/time/format_test.dart` y `test/features/alarms/ui/alarm_list_screen_test.dart`
- Modificar: `lib/src/app.dart` (home = `AlarmListScreen`) y los dos ARB

## Pasos
1. RED `format_test.dart`: `formatInDuration(Duration)` → (2 h 5 min → `en 2 h 5 min`; 45 min → `en 45 min`; 30 s → `en menos de 1 min`; 1 h 0 min → `en 1 h 0 min`) y `formatWhen(DateTime ringAt, DateTime now)` → hoy, mañana o día de la semana (≤ 6 días). Redondeo: minutos hacia arriba (`(seconds + 59) ~/ 60`).
2. RED `alarm_list_screen_test.dart` sobrescribiendo `alarmRepositoryProvider` con un falso: lista vacía → muestra `emptyTitle` y el botón `createAlarm`; con 2 alarmas → 2 `AlarmTile`, la cabecera muestra `nextAlarm` de la más próxima y tocar el `Switch` llama a `setEnabled`; sin alarmas activadas → `noActiveAlarms`.
3. Implementa `format.dart`, `alarms_providers.dart`, `AlarmTile` (hora a 40 sp en SemiBold, días y etiqueta debajo, `Switch` a la derecha, opacidad de 0,5 si está desactivada; toda la fila tocable con mínimo 72 dp) y `AlarmListScreen` (`AppBar` con el título y un icono de ajustes que de momento navega a una ruta vacía `'/settings'`, la cabecera de la próxima alarma, `ListView` y un `FloatingActionButton.extended` con el icono `Icons.add` y `createAlarm` que de momento no hace nada; E03-T03 lo conecta).
4. Estado vacío: icono `Icons.wb_twilight` a 96 dp en `coral`, `emptyTitle`, `emptyBody` y un `FilledButton` con `createAlarm`.
5. GREEN.

## Criterios de aceptación
- [ ] Las pruebas de formato y de widget pasan.
- [ ] Con el sistema en 12 h, las horas se ven con a. m./p. m. (manual o test con `MediaQuery(alwaysUse24HourFormat: false)`).
- [ ] Al volver a la app tras una sesión, la lista se refresca.

## Verificación
```bash
flutter gen-l10n && flutter analyze && flutter test
```

## Fuera de alcance
- Editor (E03-T03), borrar o saltar (E03-T04) y banner de permisos (E07-T03).

## Si te bloqueas
- Si `alwaysUse24HourFormat` no refleja el sistema en un test, pásalo con `MediaQuery` explícito en el test.

## Notas de implementación
- format.dart (formatInDuration/When/Days/Time), AlarmsNotifier, AlarmTile, AlarmListScreen con cabecera, estado vacío, refresco al volver a primer plano y claves ARB es/en. l10n_test se reescribe porque la app ya no muestra appTitle en el cuerpo. El es 24 h formatea '7:30' (sin cero). formatInDuration/When reciben AppLocalizations como primer parámetro. Pendiente manual: refresco tras una sesión real.
