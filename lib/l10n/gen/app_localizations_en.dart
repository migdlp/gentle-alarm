// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Gentle Alarm';

  @override
  String get appTagline => 'Wake up with light, not with a fright';

  @override
  String get soundBirdsDawn => 'Dawn birds';

  @override
  String get soundSoftWaves => 'Soft waves';

  @override
  String get soundLightRain => 'Light rain';

  @override
  String get soundChimes => 'Chimes';

  @override
  String get soundCalmPiano => 'Calm piano';

  @override
  String get soundSingingBowls => 'Singing bowls';

  @override
  String soundCustom(String name) {
    return 'From my phone: $name';
  }

  @override
  String get alarmsTitle => 'Alarms';

  @override
  String get emptyTitle => 'No alarms yet';

  @override
  String get emptyBody => 'Create your first one and wake up calmly.';

  @override
  String get createAlarm => 'Create alarm';

  @override
  String nextAlarm(String when, String inDuration) {
    return 'Next: $when ($inDuration)';
  }

  @override
  String get noActiveAlarms => 'No alarms on';

  @override
  String todayAt(String time) {
    return 'today at $time';
  }

  @override
  String tomorrowAt(String time) {
    return 'tomorrow at $time';
  }

  @override
  String weekdayAt(String weekday, String time) {
    return 'on $weekday at $time';
  }

  @override
  String inHoursMinutes(int h, int m) {
    return 'in $h h $m min';
  }

  @override
  String inMinutes(int m) {
    return 'in $m min';
  }

  @override
  String get inLessThanMinute => 'in less than 1 min';

  @override
  String get everyDay => 'Every day';

  @override
  String get weekdaysOnly => 'Weekdays';

  @override
  String get weekendsOnly => 'Weekends';

  @override
  String get onceOnly => 'Once';

  @override
  String get defaultLabel => 'Alarm';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get forNewAlarms => 'For new alarms';

  @override
  String get weatherSection => 'Weather';

  @override
  String get aboutSection => 'About';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get weatherAttribution => 'Weather data: Open-Meteo.com';

  @override
  String get sound => 'Sound';

  @override
  String get sunrise => 'Sunrise before ringing';

  @override
  String get noSunrise => 'No sunrise';

  @override
  String minutesShort(int m) {
    return '$m min';
  }

  @override
  String get ramp => 'Volume fade-in';

  @override
  String get maxVolume => 'Maximum volume';

  @override
  String get vibration => 'Gentle vibration';
}
