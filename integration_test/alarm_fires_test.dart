import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/src/core/platform/alarm_channel.dart';
import 'package:integration_test/integration_test.dart';

/// Programa una alarma real para dentro de 2-3 min y termina. El CI espera con
/// la app en segundo plano y comprueba por adb que el sonido llega a sonar.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('programa una alarma con la app después en segundo plano', (
    tester,
  ) async {
    final channel = AlarmChannel();
    for (final a in await channel.list()) {
      await channel.delete(a['id'] as String);
    }
    final at = DateTime.now().add(const Duration(minutes: 2));
    final saved = await channel.upsert({
      'id': 'ci-fires',
      'enabled': true,
      'hour': at.hour,
      'minute': at.minute,
      'weekdays': <int>[],
      'label': 'CI',
      'soundId': 'birds_dawn',
      'sunriseMinutes': 0,
      'rampMinutes': 1,
      'maxVolumePercent': 70,
      'vibrate': false,
      'createdAtEpochMs': DateTime.now().millisecondsSinceEpoch,
    });
    final ring = saved['scheduledRingAtEpochMs'] as int;
    // ignore: avoid_print
    print(
      'CI_ALARM_RING_AT=$ring now=${DateTime.now().millisecondsSinceEpoch}',
    );
    expect(ring, greaterThan(DateTime.now().millisecondsSinceEpoch));
  });
}
