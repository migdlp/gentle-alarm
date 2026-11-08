import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<bool> canReadUri(String uri) async =>
      await _ch.invokeMethod<bool>('canReadUri', {'uri': uri}) ?? false;
}

final systemChannelProvider = Provider((ref) => SystemChannel());
