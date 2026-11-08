import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/src/features/alarms/domain/alarm.dart';
import 'package:gentle_alarm/src/features/settings/data/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SettingsRepository> repo([Map<String, Object> init = const {}]) async {
  SharedPreferences.setMockInitialValues(init);
  return SettingsRepository(await SharedPreferences.getInstance());
}

void main() {
  test('valores por defecto iniciales', () async {
    final r = await repo();
    expect(r.readDefaults(), const AlarmDefaults());
    expect(r.onboardingDone, isFalse);
  });

  test('saveDefaults y lectura posterior', () async {
    final r = await repo();
    const d = AlarmDefaults(
      sunriseMinutes: 45,
      rampMinutes: 10,
      maxVolumePercent: 30,
      vibrate: false,
      soundId: 'chimes',
    );
    await r.saveDefaults(d);
    expect(r.readDefaults(), d);
  });

  test('valores inválidos se ignoran', () async {
    final r = await repo({
      'defaults.sunriseMinutes': 7,
      'defaults.rampMinutes': 4,
      'defaults.maxVolumePercent': 55,
      'defaults.soundId': 'nope',
    });
    expect(r.readDefaults(), const AlarmDefaults());
  });

  test('onboarding', () async {
    final r = await repo();
    await r.setOnboardingDone(true);
    expect(r.onboardingDone, isTrue);
  });
}
