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

  @override
  String get swipeUpToStop => 'Desliza el sol hacia arriba';

  @override
  String get stopAlarmA11y => 'Apagar alarma';

  @override
  String get snoozeButton => 'Un ratito más';

  @override
  String snoozesLeftText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count',
      one: 'Queda 1',
    );
    return '$_temp0';
  }

  @override
  String get noMoreSnoozes => 'Ya no quedan más ratitos';

  @override
  String get confirmQuestion => '¿Ya estás despierto/a?';

  @override
  String get confirmHint => 'Si no respondes, volveré a sonar bajito.';

  @override
  String get confirmYes => 'Sí, buenos días';

  @override
  String snoozeBackIn(String time) {
    return 'Vuelvo en $time';
  }

  @override
  String get iGetUp => 'Ya me levanto';

  @override
  String get soundPickerTitle => 'Elige un sonido';

  @override
  String get pickFromPhone => 'Elegir de mi móvil';

  @override
  String playPreviewA11y(String name) {
    return 'Escuchar $name';
  }

  @override
  String get stopPreviewA11y => 'Parar';

  @override
  String get greetingTitle => 'Buenos días';

  @override
  String weatherLine(String temp, String condition, String city) {
    return '$temp °C · $condition en $city';
  }

  @override
  String get startDay => 'Empezar el día';

  @override
  String get weatherClear => 'Despejado';

  @override
  String get weatherPartlyCloudy => 'Algo nublado';

  @override
  String get weatherFog => 'Niebla';

  @override
  String get weatherDrizzle => 'Llovizna';

  @override
  String get weatherRain => 'Lluvia';

  @override
  String get weatherSnow => 'Nieve';

  @override
  String get weatherStorm => 'Tormenta';

  @override
  String get greetingPhrase1 => 'Hoy no hace falta correr. Un paso cada vez.';

  @override
  String get greetingPhrase2 =>
      'Bebe un vaso de agua: tu cuerpo te lo agradecerá.';

  @override
  String get greetingPhrase3 => 'Respira hondo tres veces antes de levantarte.';

  @override
  String get greetingPhrase4 =>
      'Lo que hoy salga bien, cuenta. Lo demás, también.';

  @override
  String get greetingPhrase5 => 'Abre la ventana y deja entrar el día.';

  @override
  String get greetingPhrase6 => 'Estírate como si nadie te viera.';

  @override
  String get greetingPhrase7 => 'Has descansado. Ahora, a por un buen día.';

  @override
  String get greetingPhrase8 =>
      'Elige una cosa pequeña que te haga ilusión hoy.';

  @override
  String get greetingPhrase9 => 'La luz ya está aquí. Tú también.';

  @override
  String get greetingPhrase10 => 'Despacio también se llega.';

  @override
  String get greetingPhrase11 => 'Sonríe un segundo: es gratis y funciona.';

  @override
  String get greetingPhrase12 => 'Hoy empieza algo nuevo, aunque sea pequeño.';

  @override
  String get onbWelcomeBody =>
      'Te despertaremos poco a poco: primero la luz y luego un sonido suave.';

  @override
  String get onbStart => 'Empezar';

  @override
  String get onbNotifTitle => 'Avisos de alarma';

  @override
  String get onbNotifBody =>
      'Las necesitamos para mostrar la alarma y poder apagarla desde la pantalla de bloqueo.';

  @override
  String get onbAllow => 'Permitir';

  @override
  String get onbLater => 'Ahora no';

  @override
  String get onbExactTitle => 'Alarmas puntuales';

  @override
  String get onbExactBody =>
      'Activa «Alarmas y recordatorios» para que suene justo a su hora.';

  @override
  String get onbFullTitle => 'Amanecer en pantalla completa';

  @override
  String get onbFullBody =>
      'Permite la pantalla completa para que el amanecer aparezca aunque el móvil esté bloqueado.';

  @override
  String get onbOpenSettings => 'Abrir ajustes';

  @override
  String get onbBatteryTitle => 'Que nada apague tu alarma';

  @override
  String get onbBatteryXiaomi =>
      'En Ajustes → Batería, elige «Sin restricciones» y activa «Inicio automático».';

  @override
  String get onbBatteryHuawei =>
      'En Ajustes → Batería → Inicio de aplicaciones, desactiva «Gestionar automáticamente» y deja las tres opciones activadas.';

  @override
  String get onbBatteryOppo =>
      'En Ajustes → Batería, permite la actividad en segundo plano y el inicio automático.';

  @override
  String get onbBatteryVivo =>
      'En Ajustes → Batería → Consumo en segundo plano, permite el consumo alto.';

  @override
  String get onbBatterySamsung =>
      'En Ajustes → Batería → Límites de uso en segundo plano, añade la app a «Nunca en suspensión».';

  @override
  String get onbTipTitle => 'Un consejo para esta noche';

  @override
  String get onbTipBody =>
      'Deja el móvil boca arriba y cargando en la mesilla para ver el amanecer.';

  @override
  String get onbDone => 'Listo';

  @override
  String get healthTitle => 'Tu alarma podría no sonar';

  @override
  String get healthNotif => 'Faltan los avisos de alarma.';

  @override
  String get healthExact => 'Faltan las alarmas puntuales.';

  @override
  String get healthFull => 'Falta la pantalla completa para el amanecer.';

  @override
  String get healthFix => 'Arreglarlo';
}
