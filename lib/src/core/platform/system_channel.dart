import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_alarm/src/features/permissions/domain/permission_status.dart';

class PickedAudio {
  const PickedAudio({required this.uri, required this.name});

  final String uri;
  final String name;
}

class SystemChannel {
  static const _ch = MethodChannel('gentle_alarm/system');

  Future<PickedAudio?> pickAudio() async {
    final m = await _ch.invokeMapMethod<String, String>('pickAudio');
    if (m == null) return null;
    return PickedAudio(uri: m['uri']!, name: m['name'] ?? '');
  }

  Future<void> previewSound(String soundId, {String? uri}) =>
      _ch.invokeMethod<void>('previewSound', {'soundId': soundId, 'uri': uri});

  Future<void> stopPreviewSound() => _ch.invokeMethod<void>('stopPreviewSound');

  Future<PermissionStatus> getPermissionStatus() async =>
      PermissionStatus.fromMap(
        (await _ch.invokeMapMethod<dynamic, dynamic>('getPermissionStatus'))!,
      );

  Future<bool> requestNotificationPermission() async =>
      await _ch.invokeMethod<bool>('requestNotificationPermission') ?? false;

  Future<void> openNotificationSettings() =>
      _ch.invokeMethod<void>('openNotificationSettings');
  Future<void> openExactAlarmSettings() =>
      _ch.invokeMethod<void>('openExactAlarmSettings');
  Future<void> openFullScreenSettings() =>
      _ch.invokeMethod<void>('openFullScreenSettings');
  Future<void> openBatterySettings() =>
      _ch.invokeMethod<void>('openBatterySettings');

  Future<bool> canReadUri(String uri) async =>
      await _ch.invokeMethod<bool>('canReadUri', {'uri': uri}) ?? false;
}

final systemChannelProvider = Provider((ref) => SystemChannel());
