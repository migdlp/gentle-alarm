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
}
