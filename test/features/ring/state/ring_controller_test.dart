import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/src/features/ring/domain/ring_session.dart';
import 'package:gentle_alarm/src/features/ring/state/ring_controller.dart';

Map<String, Object?> snap(String state) => {
  'alarmId': 'a',
  'label': '',
  'ringAtEpochMs': 1,
  'sunriseStartEpochMs': 0,
  'state': state,
  'stateSinceEpochMs': 0,
  'snoozesLeft': 3,
  'autoSnoozeUsed': false,
  'snoozeUntilEpochMs': null,
  'segmentStartEpochMs': null,
  'endReason': null,
  'isPreview': false,
  'soundFallback': false,
  'brightnessRampFromSnooze': false,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  test('emite getSession y luego los eventos', () async {
    messenger.setMockMethodCallHandler(
      const MethodChannel('gentle_alarm/ring'),
      (c) async => c.method == 'getSession' ? snap('sunrise') : null,
    );
    messenger.setMockStreamHandler(
      const EventChannel('gentle_alarm/ring_events'),
      MockStreamHandler.inline(
        onListen: (args, sink) {
          sink.success(snap('ringing'));
          sink.success(null);
        },
      ),
    );
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final seen = <RingState?>[];
    final done = Completer<void>();
    container.listen(ringControllerProvider, (p, n) {
      if (n is AsyncData<RingSession?>) {
        seen.add(n.value?.state);
        if (n.value == null && seen.length > 1) done.complete();
      }
    }, fireImmediately: true);
    await done.future.timeout(const Duration(seconds: 5));
    expect(seen, [RingState.sunrise, RingState.ringing, null]);
  });
}
