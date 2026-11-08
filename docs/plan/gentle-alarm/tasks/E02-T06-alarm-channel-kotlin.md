---
id: E02-T06
title: Canal gentle_alarm/alarms en Kotlin
epic: E02
status: done
depends_on: [E02-T04]
requirements: [RF-01, RF-02, RF-03, RF-04, RF-07]
size: M
---

# E02-T06 · Canal gentle_alarm/alarms en Kotlin

## Objetivo
Desde Dart se pueden listar, crear o actualizar, borrar, activar o desactivar y saltar la próxima ocurrencia de las alarmas mediante el MethodChannel `gentle_alarm/alarms`, con la programación aplicada en cada cambio.

## Contexto
Contrato (`02-architecture.md` §5.1):
| Método | Argumentos | Respuesta | Errores |
|---|---|---|---|
| `listAlarms` | — | `List<Map>` ordenada por hour, minute y createdAtEpochMs | — |
| `upsertAlarm` | `Map` de AlarmSpec (se ignora `scheduledRingAtEpochMs`) | `Map` guardado y programado | `INVALID_SPEC` (message = campo), `SCHEDULE_FAILED` |
| `deleteAlarm` | `{id}` | null | `NOT_FOUND` |
| `setEnabled` | `{id, enabled}` | `Map` | `NOT_FOUND` |
| `setSkipNext` | `{id, skip}` | `Map` | `NOT_FOUND`, `NOT_REPEATING` |
- `setSkipNext(skip = true)`: calcula la T siguiente con `NextTriggerCalculator.nextRingAt` sin salto y guarda `skipRingAtEpochMs = T`; después reprograma. `skip = false`: `skipRingAtEpochMs = null` y reprograma.
- Si al reprogramar ya pasó `skipRingAtEpochMs` (≤ now), se limpia a null.
- Los `Map` usan las mismas claves que el JSON de §3.1. Conversión: `JSONObject` ↔ `Map<String, Any?>`, con `weekdays` como `List<Int>` y los Long como `Long`.

## Archivos
- Crear: `android/app/src/main/kotlin/com/migdlp/gentlealarm/channel/AlarmChannel.kt`, `channel/AlarmChannelHandler.kt` (lógica sin Flutter) y `android/app/src/test/kotlin/com/migdlp/gentlealarm/channel/AlarmChannelHandlerTest.kt`
- Modificar: `android/app/src/main/kotlin/com/migdlp/gentlealarm/MainActivity.kt` (registra el canal en `configureFlutterEngine`) y `AlarmSpec.kt` (añade `toMap()` y `fromMap()`)

## Pasos
1. RED: `AlarmChannelHandlerTest` con store en memoria, un puerto falso y un reloj fijo: `upsert` válido devuelve el map con `scheduledRingAtEpochMs`; `upsert` con hour 25 lanza `ChannelError("INVALID_SPEC", "hour")`; `delete` de un inexistente → `NOT_FOUND`; `setEnabled(false)` cancela; `setSkipNext` en una alarma sin días → `NOT_REPEATING`; `setSkipNext(true)` programa la ocurrencia de después; `list` ordenado.
2. Implementa `class AlarmChannelHandler(store, scheduler, clock, zone)` con un método por llamada, que lanza `ChannelError(code, message)`.
3. `AlarmChannel.register(engine, context)`: `MethodChannel(messenger, "gentle_alarm/alarms").setMethodCallHandler`, que delega en el handler, traduce `ChannelError` a `result.error(code, message, null)` y `ScheduleFailedException` a `SCHEDULE_FAILED`.
4. En `deleteAlarm`: `scheduler.cancel(id)` y luego `store.delete(id)`.
5. GREEN.
6. Prueba manual una vez que E02-T07 esté hecha (anótala allí).

## Criterios de aceptación
- [ ] Los 7 tests pasan.
- [ ] Cualquier error inesperado del handler devuelve `result.error("INTERNAL", e.message, null)` y no rompe la app.

## Verificación
```bash
cd android && ./gradlew testDebugUnitTest --tests "*AlarmChannelHandlerTest*"
flutter build apk --debug
```

## Fuera de alcance
- `startPreview` (E07-T04) y el cliente Dart (E02-T07).

## Si te bloqueas
- Si un `Int` llega desde Dart como `Long` (o al revés), convierte con `(value as Number).toInt()` o `.toLong()`; no cambies el contrato.

## Notas de implementación
- AlarmChannelHandler (9 tests OK) + AlarmChannel registrado en MainActivity; AlarmSpec.toMap/fromMap; el scheduler limpia skipRingAtEpochMs pasado. APK compila. Pendiente manual: dumpsys alarm tras E02-T07.
