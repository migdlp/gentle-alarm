// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Despertar suave';

  @override
  String get appTagline => 'Despierta con luz, no con sustos';

  @override
  String get soundBirdsDawn => 'Pájaros al alba';

  @override
  String get soundSoftWaves => 'Olas suaves';

  @override
  String get soundLightRain => 'Lluvia ligera';

  @override
  String get soundChimes => 'Campanillas';

  @override
  String get soundCalmPiano => 'Piano tranquilo';

  @override
  String get soundSingingBowls => 'Cuencos';

  @override
  String soundCustom(String name) {
    return 'De mi móvil: $name';
  }

  @override
  String get alarmsTitle => 'Alarmas';

  @override
  String get emptyTitle => 'Aún no tienes alarmas';

  @override
  String get emptyBody => 'Crea la primera y despierta con calma.';

  @override
  String get createAlarm => 'Crear alarma';

  @override
  String nextAlarm(String when, String inDuration) {
    return 'Próxima: $when ($inDuration)';
  }

  @override
  String get noActiveAlarms => 'Ninguna alarma activada';

  @override
  String todayAt(String time) {
    return 'hoy a las $time';
  }

  @override
  String tomorrowAt(String time) {
    return 'mañana a las $time';
  }

  @override
  String weekdayAt(String weekday, String time) {
    return 'el $weekday a las $time';
  }

  @override
  String inHoursMinutes(int h, int m) {
    return 'en $h h $m min';
  }

  @override
  String inMinutes(int m) {
    return 'en $m min';
  }

  @override
  String get inLessThanMinute => 'en menos de 1 min';

  @override
  String get everyDay => 'Todos los días';

  @override
  String get weekdaysOnly => 'De lunes a viernes';

  @override
  String get weekendsOnly => 'Fines de semana';

  @override
  String get onceOnly => 'Una vez';

  @override
  String get defaultLabel => 'Alarma';

  @override
  String get settingsTooltip => 'Ajustes';
}
