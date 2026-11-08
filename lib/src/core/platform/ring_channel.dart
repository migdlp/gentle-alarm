import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_alarm/src/features/ring/domain/ring_session.dart';

class RingChannel {
  static const _ch = MethodChannel('gentle_alarm/ring');
  static const _events = EventChannel('gentle_alarm/ring_events');

  Future<RingSession?> getSession() async {
    final m = await _ch.invokeMapMethod<dynamic, dynamic>('getSession');
    return m == null ? null : RingSession.fromMap(m);
  }

  Stream<RingSession?> events() => _events.receiveBroadcastStream().map(
    (e) => e == null ? null : RingSession.fromMap(e as Map<dynamic, dynamic>),
  );

  Future<void> dismissSwipe() => _ch.invokeMethod<void>('dismissSwipe');
  Future<void> snooze() => _ch.invokeMethod<void>('snooze');
  Future<void> wakeUp() => _ch.invokeMethod<void>('wakeUp');
  Future<void> wakeEarly() => _ch.invokeMethod<void>('wakeEarly');
  Future<void> confirmAwake() => _ch.invokeMethod<void>('confirmAwake');
  Future<void> finishGreeting() => _ch.invokeMethod<void>('finishGreeting');
  Future<void> setBrightness(double value) =>
      _ch.invokeMethod<void>('setBrightness', {'value': value});
}

final ringChannelProvider = Provider((ref) => RingChannel());
