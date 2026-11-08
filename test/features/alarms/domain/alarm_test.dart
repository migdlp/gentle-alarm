import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/src/features/alarms/domain/alarm.dart';

void main() {
  final full = Alarm(
    id: 'x',
    enabled: false,
    hour: 6,
    minute: 5,
    weekdays: const [1, 5],
    label: 'Trabajo',
    soundId: 'custom',
    customSoundUri: 'content://a',
    customSoundName: 'mi.mp3',
    sunriseMinutes: 45,
    rampMinutes: 10,
    maxVolumePercent: 100,
    vibrate: false,
    skipRingAtEpochMs: 1,
    scheduledRingAtEpochMs: 2,
    createdAtEpochMs: 3,
  );

  test('ida y vuelta toMap/fromMap', () {
    expect(Alarm.fromMap(full.toMap()), full);
    final min = Alarm(id: 'y', createdAtEpochMs: 0);
    expect(Alarm.fromMap(min.toMap()), min);
  });

  test('copyWith conserva y anula campos', () {
    final c = full.copyWith(hour: 8, skipRingAtEpochMs: null);
    expect(c.hour, 8);
    expect(c.skipRingAtEpochMs, isNull);
    expect(c.customSoundUri, 'content://a');
    expect(c.id, 'x');
  });

  test('igualdad y hashCode', () {
    final a = full.copyWith();
    expect(a, full);
    expect(a.hashCode, full.hashCode);
    expect(full.copyWith(minute: 6), isNot(full));
  });

  test('weekdays es inmodificable', () {
    expect(() => full.weekdays.add(3), throwsUnsupportedError);
  });

  test('create aplica los valores por defecto', () {
    final a = Alarm.create(
      hour: 7,
      minute: 0,
      defaults: const AlarmDefaults(sunriseMinutes: 10, vibrate: false),
    );
    expect(a.id, isNotEmpty);
    expect(a.sunriseMinutes, 10);
    expect(a.vibrate, isFalse);
    expect(a.enabled, isTrue);
    expect(a.weekdays, isEmpty);
    expect(a.isRepeating, isFalse);
    expect(a.skipsNext, isFalse);
  });

  test('nextRingAt', () {
    expect(full.nextRingAt, DateTime.fromMillisecondsSinceEpoch(2));
    expect(Alarm(id: 'z', createdAtEpochMs: 0).nextRingAt, isNull);
  });
}
