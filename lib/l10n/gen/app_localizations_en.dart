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

  @override
  String get weatherCity => 'City for the weather';

  @override
  String get weatherCityNone =>
      'No city · the greeting won\'t show the weather';

  @override
  String get citySearchHint => 'Search your city';

  @override
  String get citySearchStart => 'Type at least 2 letters';

  @override
  String get citySearchEmpty => 'We couldn\'t find that city';

  @override
  String get cityRemove => 'Remove';

  @override
  String get newAlarm => 'New alarm';

  @override
  String get editAlarm => 'Edit alarm';

  @override
  String get save => 'Save';

  @override
  String get labelHint => 'Label (optional)';

  @override
  String get repeat => 'Repeat';

  @override
  String willRingIn(String inDuration) {
    return 'Will ring $inDuration';
  }

  @override
  String get errorScheduleFailed =>
      'We couldn\'t schedule the alarm. Check the exact alarms permission.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get discardTitle => 'Discard changes?';

  @override
  String get discard => 'Discard';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get alarmDeleted => 'Alarm deleted';

  @override
  String get undo => 'Undo';

  @override
  String get skipNext => 'Skip next';

  @override
  String get unskipNext => 'Don\'t skip';

  @override
  String skippingOn(String date) {
    return 'Skipping $date';
  }

  @override
  String get deleteAlarm => 'Delete';

  @override
  String sunriseRingsAt(String time) {
    return 'Rings at $time';
  }

  @override
  String get wakeEarly => 'I\'m already awake';

  @override
  String get keepSleeping => 'Keep sleeping';

  @override
  String get swipeUpToStop => 'Slide the sun up';

  @override
  String get stopAlarmA11y => 'Turn off alarm';

  @override
  String get snoozeButton => 'A little longer';

  @override
  String snoozesLeftText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count left',
      one: '1 left',
    );
    return '$_temp0';
  }

  @override
  String get noMoreSnoozes => 'No more snoozes left';

  @override
  String get confirmQuestion => 'Are you awake?';

  @override
  String get confirmHint => 'If you don\'t answer, I\'ll ring softly again.';

  @override
  String get confirmYes => 'Yes, good morning';

  @override
  String snoozeBackIn(String time) {
    return 'Back in $time';
  }

  @override
  String get iGetUp => 'I\'m getting up';

  @override
  String get soundPickerTitle => 'Choose a sound';

  @override
  String get pickFromPhone => 'Choose from my phone';

  @override
  String playPreviewA11y(String name) {
    return 'Play $name';
  }

  @override
  String get stopPreviewA11y => 'Stop';
}
