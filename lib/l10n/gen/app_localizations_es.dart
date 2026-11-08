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

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get forNewAlarms => 'Para alarmas nuevas';

  @override
  String get weatherSection => 'Tiempo';

  @override
  String get aboutSection => 'Acerca de';

  @override
  String aboutVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get weatherAttribution => 'Datos del tiempo: Open-Meteo.com';

  @override
  String get sound => 'Sonido';

  @override
  String get sunrise => 'Amanecer antes de sonar';

  @override
  String get noSunrise => 'Sin amanecer';

  @override
  String minutesShort(int m) {
    return '$m min';
  }

  @override
  String get ramp => 'Subida del volumen';

  @override
  String get maxVolume => 'Volumen máximo';

  @override
  String get vibration => 'Vibración suave';

  @override
  String get weatherCity => 'Ciudad para el tiempo';

  @override
  String get weatherCityNone => 'Sin ciudad · el saludo no mostrará el tiempo';

  @override
  String get citySearchHint => 'Busca tu ciudad';

  @override
  String get citySearchStart => 'Escribe al menos 2 letras';

  @override
  String get citySearchEmpty => 'No encontramos esa ciudad';

  @override
  String get cityRemove => 'Quitar';

  @override
  String get newAlarm => 'Nueva alarma';

  @override
  String get editAlarm => 'Editar alarma';

  @override
  String get save => 'Guardar';

  @override
  String get labelHint => 'Etiqueta (opcional)';

  @override
  String get repeat => 'Repetir';

  @override
  String willRingIn(String inDuration) {
    return 'Sonará $inDuration';
  }

  @override
  String get errorScheduleFailed =>
      'No hemos podido programar la alarma. Revisa el permiso de alarmas exactas.';

  @override
  String get errorGeneric => 'Algo ha fallado. Inténtalo de nuevo.';

  @override
  String get discardTitle => '¿Descartar los cambios?';

  @override
  String get discard => 'Descartar';

  @override
  String get keepEditing => 'Seguir editando';

  @override
  String get alarmDeleted => 'Alarma borrada';

  @override
  String get undo => 'Deshacer';

  @override
  String get skipNext => 'Saltar la próxima';

  @override
  String get unskipNext => 'No saltar';

  @override
  String skippingOn(String date) {
    return 'Se salta el $date';
  }

  @override
  String get deleteAlarm => 'Borrar';

  @override
  String sunriseRingsAt(String time) {
    return 'Suena a las $time';
  }

  @override
  String get wakeEarly => 'Ya estoy despierto/a';

  @override
  String get keepSleeping => 'Seguir durmiendo';
}
