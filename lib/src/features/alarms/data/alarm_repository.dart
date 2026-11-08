import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_alarm/src/core/platform/alarm_channel.dart';
import 'package:gentle_alarm/src/features/alarms/domain/alarm.dart';

class AlarmException implements Exception {
  const AlarmException({required this.code, this.field});

  /// INVALID_SPEC, NOT_FOUND, NOT_REPEATING, SCHEDULE_FAILED o INTERNAL.
  final String code;
  final String? field;

  @override
  String toString() => 'AlarmException($code, $field)';
}

class AlarmRepository {
  AlarmRepository(this._channel);

  final AlarmChannel _channel;

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on PlatformException catch (e) {
      throw AlarmException(code: e.code, field: e.message);
    }
  }

  Future<List<Alarm>> list() => _guard(() async {
    final raw = await _channel.list();
    return raw.map(Alarm.fromMap).toList();
  });

  Future<Alarm> save(Alarm alarm) =>
      _guard(() async => Alarm.fromMap(await _channel.upsert(alarm.toMap())));

  Future<void> delete(String id) => _guard(() => _channel.delete(id));

  Future<Alarm> setEnabled(String id, bool enabled) =>
      _guard(() async => Alarm.fromMap(await _channel.setEnabled(id, enabled)));

  Future<Alarm> setSkipNext(String id, bool skip) =>
      _guard(() async => Alarm.fromMap(await _channel.setSkipNext(id, skip)));
}

final alarmRepositoryProvider = Provider(
  (ref) => AlarmRepository(AlarmChannel()),
);
