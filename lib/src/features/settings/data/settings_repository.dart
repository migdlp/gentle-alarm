import 'package:gentle_alarm/src/features/alarms/domain/alarm.dart';
import 'package:gentle_alarm/src/features/sounds/domain/sound_catalog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const sunriseOptions = [0, 5, 10, 15, 20, 30, 45];
  static const rampOptions = [1, 2, 3, 5, 10];

  AlarmDefaults readDefaults() {
    const d = AlarmDefaults();
    final sunrise = _prefs.getInt('defaults.sunriseMinutes');
    final ramp = _prefs.getInt('defaults.rampMinutes');
    final volume = _prefs.getInt('defaults.maxVolumePercent');
    final sound = _prefs.getString('defaults.soundId');
    return AlarmDefaults(
      sunriseMinutes: sunriseOptions.contains(sunrise)
          ? sunrise!
          : d.sunriseMinutes,
      rampMinutes: rampOptions.contains(ramp) ? ramp! : d.rampMinutes,
      maxVolumePercent:
          volume != null && volume >= 10 && volume <= 100 && volume % 10 == 0
          ? volume
          : d.maxVolumePercent,
      vibrate: _prefs.getBool('defaults.vibrate') ?? d.vibrate,
      soundId: sound != null && SoundCatalog.builtInIds.contains(sound)
          ? sound
          : d.soundId,
    );
  }

  Future<void> saveDefaults(AlarmDefaults d) async {
    await _prefs.setInt('defaults.sunriseMinutes', d.sunriseMinutes);
    await _prefs.setInt('defaults.rampMinutes', d.rampMinutes);
    await _prefs.setInt('defaults.maxVolumePercent', d.maxVolumePercent);
    await _prefs.setBool('defaults.vibrate', d.vibrate);
    await _prefs.setString('defaults.soundId', d.soundId);
  }

  bool get onboardingDone => _prefs.getBool('onboarding.done') ?? false;

  Future<void> setOnboardingDone(bool v) =>
      _prefs.setBool('onboarding.done', v);
}
