---
id: E02-T07
title: Modelo Alarm y AlarmRepository en Dart
epic: E02
status: todo
depends_on: [E02-T06]
requirements: [RF-01, RF-02, RF-03, RF-04, RF-07]
size: M
---

# E02-T07 · Modelo Alarm y AlarmRepository en Dart

## Objetivo
Dart dispone de un modelo inmutable `Alarm` y de `AlarmRepository`, que habla con el canal `gentle_alarm/alarms` y convierte sus errores en `AlarmException`, con pruebas sobre un canal simulado.

## Contexto
- Campos idénticos a §3.1. En Dart: `id` String, `enabled` bool, `hour` int, `minute` int, `weekdays` `List<int>` (inmodificable), `label` String, `soundId` String, `customSoundUri` String?, `customSoundName` String?, `sunriseMinutes` int, `rampMinutes` int, `maxVolumePercent` int, `vibrate` bool, `skipRingAtEpochMs` int?, `scheduledRingAtEpochMs` int? y `createdAtEpochMs` int.
- `Alarm.create({required int hour, required int minute, required AlarmDefaults defaults})` genera `id` con `const Uuid().v4()` y `createdAtEpochMs` = ahora. `AlarmDefaults` es una clase con `sunriseMinutes`, `rampMinutes`, `maxVolumePercent`, `vibrate` y `soundId` (en este mismo archivo; E03-T01 la reutiliza).
- Getters: `DateTime? get nextRingAt` (de `scheduledRingAtEpochMs`, hora local), `bool get isRepeating => weekdays.isNotEmpty` y `bool get skipsNext => skipRingAtEpochMs != null`.
- Errores: `class AlarmException implements Exception { final String code; final String? field; }` con code ∈ {`INVALID_SPEC`, `NOT_FOUND`, `NOT_REPEATING`, `SCHEDULE_FAILED`, `INTERNAL`}.

## Archivos
- Crear: `lib/src/features/alarms/domain/alarm.dart`, `lib/src/core/platform/alarm_channel.dart`, `lib/src/features/alarms/data/alarm_repository.dart`, `test/features/alarms/domain/alarm_test.dart` y `test/features/alarms/data/alarm_repository_test.dart`

## Pasos
1. RED: `alarm_test.dart` (ida y vuelta `fromMap(toMap())`, `copyWith`, igualdad, `create` con valores por defecto) y `alarm_repository_test.dart` usando `TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('gentle_alarm/alarms'), handler)`: `list` decodifica, `upsert` envía el map y devuelve el resultado, y un `PlatformException(code: 'INVALID_SPEC', message: 'hour')` se convierte en `AlarmException(code: 'INVALID_SPEC', field: 'hour')`.
2. Implementa `Alarm` (constructor `const`, `copyWith` con los campos anulables mediante un sentinela `Object? _unset`, `toMap`, `fromMap`, `==` y `hashCode` con `Object.hash` y `Object.hashAll(weekdays)`).
3. `alarm_channel.dart`: `class AlarmChannel { static const _ch = MethodChannel('gentle_alarm/alarms'); Future<List<Map>> list(); Future<Map> upsert(Map); Future<void> delete(String id); Future<Map> setEnabled(String id, bool enabled); Future<Map> setSkipNext(String id, bool skip); }`.
4. `alarm_repository.dart`: `class AlarmRepository { AlarmRepository(this._channel); Future<List<Alarm>> list(); Future<Alarm> save(Alarm); Future<void> delete(String id); Future<Alarm> setEnabled(String id, bool); Future<Alarm> setSkipNext(String id, bool); }`, que captura `PlatformException` y lanza `AlarmException`. Añade también `final alarmRepositoryProvider = Provider((ref) => AlarmRepository(AlarmChannel()));`.
5. GREEN.
6. Prueba manual de E02-T04 y E02-T06: añade temporalmente en `main.dart` un `FloatingActionButton` que guarde una alarma para dentro de 3 min, ejecuta `adb shell dumpsys alarm | grep -A3 gentlealarm`, comprueba que aparece y **borra el botón antes del commit**.

## Criterios de aceptación
- [ ] Los tests Dart pasan.
- [ ] La comprobación manual con `dumpsys alarm` se ha hecho y anotado en «Notas de implementación».
- [ ] El botón temporal no está en el commit.

## Verificación
```bash
flutter analyze && flutter test test/features/alarms
```

## Fuera de alcance
- Interfaz (E03) y estado Riverpod de la lista (E03-T02).

## Si te bloqueas
- Si los Long llegan como `int` en Dart: es correcto (Dart `int` es de 64 bits).
