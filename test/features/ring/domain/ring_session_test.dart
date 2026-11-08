import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/src/features/ring/domain/ring_session.dart';

Map<String, Object?> base(String state) => {
  'alarmId': 'a',
  'label': 'x',
  'ringAtEpochMs': 1000,
  'sunriseStartEpochMs': 400,
  'state': state,
  'stateSinceEpochMs': 500,
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
  test('fromMap con todos los estados', () {
    for (final s in RingState.values) {
      expect(RingSession.fromMap(base(s.name)).state, s);
    }
  });

  test('campos opcionales', () {
    final s = RingSession.fromMap({
      ...base('snoozed'),
      'snoozeUntilEpochMs': 9,
      'segmentStartEpochMs': 7,
      'endReason': 'missed',
      'isPreview': true,
      'soundFallback': true,
      'brightnessRampFromSnooze': true,
    });
    expect(s.snoozeUntilEpochMs, 9);
    expect(s.segmentStartEpochMs, 7);
    expect(s.endReason, 'missed');
    expect(
      s.isPreview && s.soundFallback && s.brightnessRampFromSnooze,
      isTrue,
    );
    expect(
      s,
      RingSession.fromMap({
        ...base('snoozed'),
        'snoozeUntilEpochMs': 9,
        'segmentStartEpochMs': 7,
        'endReason': 'missed',
        'isPreview': true,
        'soundFallback': true,
        'brightnessRampFromSnooze': true,
      }),
    );
  });
}
