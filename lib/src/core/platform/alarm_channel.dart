import 'package:flutter/services.dart';

class AlarmChannel {
  static const _ch = MethodChannel('gentle_alarm/alarms');

  Future<List<Map<dynamic, dynamic>>> list() async {
    final r = await _ch.invokeListMethod<Map<dynamic, dynamic>>('listAlarms');
    return r ?? const [];
  }

  Future<Map<dynamic, dynamic>> upsert(Map<String, Object?> alarm) async =>
      (await _ch.invokeMapMethod<dynamic, dynamic>('upsertAlarm', alarm))!;

  Future<void> delete(String id) =>
      _ch.invokeMethod<void>('deleteAlarm', {'id': id});

  Future<Map<dynamic, dynamic>> setEnabled(String id, bool enabled) async =>
      (await _ch.invokeMapMethod<dynamic, dynamic>('setEnabled', {
        'id': id,
        'enabled': enabled,
      }))!;

  Future<Map<dynamic, dynamic>> setSkipNext(String id, bool skip) async =>
      (await _ch.invokeMapMethod<dynamic, dynamic>('setSkipNext', {
        'id': id,
        'skip': skip,
      }))!;
}
