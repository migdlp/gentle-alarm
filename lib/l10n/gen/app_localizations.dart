import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'Despertar suave'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In es, this message translates to:
  /// **'Despierta con luz, no con sustos'**
  String get appTagline;

  /// No description provided for @soundBirdsDawn.
  ///
  /// In es, this message translates to:
  /// **'Pájaros al alba'**
  String get soundBirdsDawn;

  /// No description provided for @soundSoftWaves.
  ///
  /// In es, this message translates to:
  /// **'Olas suaves'**
  String get soundSoftWaves;

  /// No description provided for @soundLightRain.
  ///
  /// In es, this message translates to:
  /// **'Lluvia ligera'**
  String get soundLightRain;

  /// No description provided for @soundChimes.
  ///
  /// In es, this message translates to:
  /// **'Campanillas'**
  String get soundChimes;

  /// No description provided for @soundCalmPiano.
  ///
  /// In es, this message translates to:
  /// **'Piano tranquilo'**
  String get soundCalmPiano;

  /// No description provided for @soundSingingBowls.
  ///
  /// In es, this message translates to:
  /// **'Cuencos'**
  String get soundSingingBowls;

  /// No description provided for @soundCustom.
  ///
  /// In es, this message translates to:
  /// **'De mi móvil: {name}'**
  String soundCustom(String name);

  /// No description provided for @alarmsTitle.
  ///
  /// In es, this message translates to:
  /// **'Alarmas'**
  String get alarmsTitle;

  /// No description provided for @emptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes alarmas'**
  String get emptyTitle;

  /// No description provided for @emptyBody.
  ///
  /// In es, this message translates to:
  /// **'Crea la primera y despierta con calma.'**
  String get emptyBody;

  /// No description provided for @createAlarm.
  ///
  /// In es, this message translates to:
  /// **'Crear alarma'**
  String get createAlarm;

  /// No description provided for @nextAlarm.
  ///
  /// In es, this message translates to:
  /// **'Próxima: {when} ({inDuration})'**
  String nextAlarm(String when, String inDuration);

  /// No description provided for @noActiveAlarms.
  ///
  /// In es, this message translates to:
  /// **'Ninguna alarma activada'**
  String get noActiveAlarms;

  /// No description provided for @todayAt.
  ///
  /// In es, this message translates to:
  /// **'hoy a las {time}'**
  String todayAt(String time);

  /// No description provided for @tomorrowAt.
  ///
  /// In es, this message translates to:
  /// **'mañana a las {time}'**
  String tomorrowAt(String time);

  /// No description provided for @weekdayAt.
  ///
  /// In es, this message translates to:
  /// **'el {weekday} a las {time}'**
  String weekdayAt(String weekday, String time);

  /// No description provided for @inHoursMinutes.
  ///
  /// In es, this message translates to:
  /// **'en {h} h {m} min'**
  String inHoursMinutes(int h, int m);

  /// No description provided for @inMinutes.
  ///
  /// In es, this message translates to:
  /// **'en {m} min'**
  String inMinutes(int m);

  /// No description provided for @inLessThanMinute.
  ///
  /// In es, this message translates to:
  /// **'en menos de 1 min'**
  String get inLessThanMinute;

  /// No description provided for @everyDay.
  ///
  /// In es, this message translates to:
  /// **'Todos los días'**
  String get everyDay;

  /// No description provided for @weekdaysOnly.
  ///
  /// In es, this message translates to:
  /// **'De lunes a viernes'**
  String get weekdaysOnly;

  /// No description provided for @weekendsOnly.
  ///
  /// In es, this message translates to:
  /// **'Fines de semana'**
  String get weekendsOnly;

  /// No description provided for @onceOnly.
  ///
  /// In es, this message translates to:
  /// **'Una vez'**
  String get onceOnly;

  /// No description provided for @defaultLabel.
  ///
  /// In es, this message translates to:
  /// **'Alarma'**
  String get defaultLabel;

  /// No description provided for @settingsTooltip.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTooltip;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @forNewAlarms.
  ///
  /// In es, this message translates to:
  /// **'Para alarmas nuevas'**
  String get forNewAlarms;

  /// No description provided for @weatherSection.
  ///
  /// In es, this message translates to:
  /// **'Tiempo'**
  String get weatherSection;

  /// No description provided for @aboutSection.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get aboutSection;

  /// No description provided for @aboutVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión {version}'**
  String aboutVersion(String version);

  /// No description provided for @weatherAttribution.
  ///
  /// In es, this message translates to:
  /// **'Datos del tiempo: Open-Meteo.com'**
  String get weatherAttribution;

  /// No description provided for @sound.
  ///
  /// In es, this message translates to:
  /// **'Sonido'**
  String get sound;

  /// No description provided for @sunrise.
  ///
  /// In es, this message translates to:
  /// **'Amanecer antes de sonar'**
  String get sunrise;

  /// No description provided for @noSunrise.
  ///
  /// In es, this message translates to:
  /// **'Sin amanecer'**
  String get noSunrise;

  /// No description provided for @minutesShort.
  ///
  /// In es, this message translates to:
  /// **'{m} min'**
  String minutesShort(int m);

  /// No description provided for @ramp.
  ///
  /// In es, this message translates to:
  /// **'Subida del volumen'**
  String get ramp;

  /// No description provided for @maxVolume.
  ///
  /// In es, this message translates to:
  /// **'Volumen máximo'**
  String get maxVolume;

  /// No description provided for @vibration.
  ///
  /// In es, this message translates to:
  /// **'Vibración suave'**
  String get vibration;

  /// No description provided for @weatherCity.
  ///
  /// In es, this message translates to:
  /// **'Ciudad para el tiempo'**
  String get weatherCity;

  /// No description provided for @weatherCityNone.
  ///
  /// In es, this message translates to:
  /// **'Sin ciudad · el saludo no mostrará el tiempo'**
  String get weatherCityNone;

  /// No description provided for @citySearchHint.
  ///
  /// In es, this message translates to:
  /// **'Busca tu ciudad'**
  String get citySearchHint;

  /// No description provided for @citySearchStart.
  ///
  /// In es, this message translates to:
  /// **'Escribe al menos 2 letras'**
  String get citySearchStart;

  /// No description provided for @citySearchEmpty.
  ///
  /// In es, this message translates to:
  /// **'No encontramos esa ciudad'**
  String get citySearchEmpty;

  /// No description provided for @cityRemove.
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get cityRemove;

  /// No description provided for @newAlarm.
  ///
  /// In es, this message translates to:
  /// **'Nueva alarma'**
  String get newAlarm;

  /// No description provided for @editAlarm.
  ///
  /// In es, this message translates to:
  /// **'Editar alarma'**
  String get editAlarm;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @labelHint.
  ///
  /// In es, this message translates to:
  /// **'Etiqueta (opcional)'**
  String get labelHint;

  /// No description provided for @repeat.
  ///
  /// In es, this message translates to:
  /// **'Repetir'**
  String get repeat;

  /// No description provided for @willRingIn.
  ///
  /// In es, this message translates to:
  /// **'Sonará {inDuration}'**
  String willRingIn(String inDuration);

  /// No description provided for @errorScheduleFailed.
  ///
  /// In es, this message translates to:
  /// **'No hemos podido programar la alarma. Revisa el permiso de alarmas exactas.'**
  String get errorScheduleFailed;

  /// No description provided for @errorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Algo ha fallado. Inténtalo de nuevo.'**
  String get errorGeneric;

  /// No description provided for @discardTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Descartar los cambios?'**
  String get discardTitle;

  /// No description provided for @discard.
  ///
  /// In es, this message translates to:
  /// **'Descartar'**
  String get discard;

  /// No description provided for @keepEditing.
  ///
  /// In es, this message translates to:
  /// **'Seguir editando'**
  String get keepEditing;

  /// No description provided for @alarmDeleted.
  ///
  /// In es, this message translates to:
  /// **'Alarma borrada'**
  String get alarmDeleted;

  /// No description provided for @undo.
  ///
  /// In es, this message translates to:
  /// **'Deshacer'**
  String get undo;

  /// No description provided for @skipNext.
  ///
  /// In es, this message translates to:
  /// **'Saltar la próxima'**
  String get skipNext;

  /// No description provided for @unskipNext.
  ///
  /// In es, this message translates to:
  /// **'No saltar'**
  String get unskipNext;

  /// No description provided for @skippingOn.
  ///
  /// In es, this message translates to:
  /// **'Se salta el {date}'**
  String skippingOn(String date);

  /// No description provided for @deleteAlarm.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get deleteAlarm;

  /// No description provided for @sunriseRingsAt.
  ///
  /// In es, this message translates to:
  /// **'Suena a las {time}'**
  String sunriseRingsAt(String time);

  /// No description provided for @wakeEarly.
  ///
  /// In es, this message translates to:
  /// **'Ya estoy despierto/a'**
  String get wakeEarly;

  /// No description provided for @keepSleeping.
  ///
  /// In es, this message translates to:
  /// **'Seguir durmiendo'**
  String get keepSleeping;

  /// No description provided for @swipeUpToStop.
  ///
  /// In es, this message translates to:
  /// **'Desliza el sol hacia arriba'**
  String get swipeUpToStop;

  /// No description provided for @stopAlarmA11y.
  ///
  /// In es, this message translates to:
  /// **'Apagar alarma'**
  String get stopAlarmA11y;

  /// No description provided for @snoozeButton.
  ///
  /// In es, this message translates to:
  /// **'Un ratito más'**
  String get snoozeButton;

  /// No description provided for @snoozesLeftText.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Queda 1} other{Quedan {count}}}'**
  String snoozesLeftText(int count);

  /// No description provided for @noMoreSnoozes.
  ///
  /// In es, this message translates to:
  /// **'Ya no quedan más ratitos'**
  String get noMoreSnoozes;

  /// No description provided for @confirmQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Ya estás despierto/a?'**
  String get confirmQuestion;

  /// No description provided for @confirmHint.
  ///
  /// In es, this message translates to:
  /// **'Si no respondes, volveré a sonar bajito.'**
  String get confirmHint;

  /// No description provided for @confirmYes.
  ///
  /// In es, this message translates to:
  /// **'Sí, buenos días'**
  String get confirmYes;

  /// No description provided for @snoozeBackIn.
  ///
  /// In es, this message translates to:
  /// **'Vuelvo en {time}'**
  String snoozeBackIn(String time);

  /// No description provided for @iGetUp.
  ///
  /// In es, this message translates to:
  /// **'Ya me levanto'**
  String get iGetUp;

  /// No description provided for @soundPickerTitle.
  ///
  /// In es, this message translates to:
  /// **'Elige un sonido'**
  String get soundPickerTitle;

  /// No description provided for @pickFromPhone.
  ///
  /// In es, this message translates to:
  /// **'Elegir de mi móvil'**
  String get pickFromPhone;

  /// No description provided for @playPreviewA11y.
  ///
  /// In es, this message translates to:
  /// **'Escuchar {name}'**
  String playPreviewA11y(String name);

  /// No description provided for @stopPreviewA11y.
  ///
  /// In es, this message translates to:
  /// **'Parar'**
  String get stopPreviewA11y;

  /// No description provided for @greetingTitle.
  ///
  /// In es, this message translates to:
  /// **'Buenos días'**
  String get greetingTitle;

  /// No description provided for @weatherLine.
  ///
  /// In es, this message translates to:
  /// **'{temp} °C · {condition} en {city}'**
  String weatherLine(String temp, String condition, String city);

  /// No description provided for @startDay.
  ///
  /// In es, this message translates to:
  /// **'Empezar el día'**
  String get startDay;

  /// No description provided for @weatherClear.
  ///
  /// In es, this message translates to:
  /// **'Despejado'**
  String get weatherClear;

  /// No description provided for @weatherPartlyCloudy.
  ///
  /// In es, this message translates to:
  /// **'Algo nublado'**
  String get weatherPartlyCloudy;

  /// No description provided for @weatherFog.
  ///
  /// In es, this message translates to:
  /// **'Niebla'**
  String get weatherFog;

  /// No description provided for @weatherDrizzle.
  ///
  /// In es, this message translates to:
  /// **'Llovizna'**
  String get weatherDrizzle;

  /// No description provided for @weatherRain.
  ///
  /// In es, this message translates to:
  /// **'Lluvia'**
  String get weatherRain;

  /// No description provided for @weatherSnow.
  ///
  /// In es, this message translates to:
  /// **'Nieve'**
  String get weatherSnow;

  /// No description provided for @weatherStorm.
  ///
  /// In es, this message translates to:
  /// **'Tormenta'**
  String get weatherStorm;

  /// No description provided for @greetingPhrase1.
  ///
  /// In es, this message translates to:
  /// **'Hoy no hace falta correr. Un paso cada vez.'**
  String get greetingPhrase1;

  /// No description provided for @greetingPhrase2.
  ///
  /// In es, this message translates to:
  /// **'Bebe un vaso de agua: tu cuerpo te lo agradecerá.'**
  String get greetingPhrase2;

  /// No description provided for @greetingPhrase3.
  ///
  /// In es, this message translates to:
  /// **'Respira hondo tres veces antes de levantarte.'**
  String get greetingPhrase3;

  /// No description provided for @greetingPhrase4.
  ///
  /// In es, this message translates to:
  /// **'Lo que hoy salga bien, cuenta. Lo demás, también.'**
  String get greetingPhrase4;

  /// No description provided for @greetingPhrase5.
  ///
  /// In es, this message translates to:
  /// **'Abre la ventana y deja entrar el día.'**
  String get greetingPhrase5;

  /// No description provided for @greetingPhrase6.
  ///
  /// In es, this message translates to:
  /// **'Estírate como si nadie te viera.'**
  String get greetingPhrase6;

  /// No description provided for @greetingPhrase7.
  ///
  /// In es, this message translates to:
  /// **'Has descansado. Ahora, a por un buen día.'**
  String get greetingPhrase7;

  /// No description provided for @greetingPhrase8.
  ///
  /// In es, this message translates to:
  /// **'Elige una cosa pequeña que te haga ilusión hoy.'**
  String get greetingPhrase8;

  /// No description provided for @greetingPhrase9.
  ///
  /// In es, this message translates to:
  /// **'La luz ya está aquí. Tú también.'**
  String get greetingPhrase9;

  /// No description provided for @greetingPhrase10.
  ///
  /// In es, this message translates to:
  /// **'Despacio también se llega.'**
  String get greetingPhrase10;

  /// No description provided for @greetingPhrase11.
  ///
  /// In es, this message translates to:
  /// **'Sonríe un segundo: es gratis y funciona.'**
  String get greetingPhrase11;

  /// No description provided for @greetingPhrase12.
  ///
  /// In es, this message translates to:
  /// **'Hoy empieza algo nuevo, aunque sea pequeño.'**
  String get greetingPhrase12;

  /// No description provided for @onbWelcomeBody.
  ///
  /// In es, this message translates to:
  /// **'Te despertaremos poco a poco: primero la luz y luego un sonido suave.'**
  String get onbWelcomeBody;

  /// No description provided for @onbStart.
  ///
  /// In es, this message translates to:
  /// **'Empezar'**
  String get onbStart;

  /// No description provided for @onbNotifTitle.
  ///
  /// In es, this message translates to:
  /// **'Avisos de alarma'**
  String get onbNotifTitle;

  /// No description provided for @onbNotifBody.
  ///
  /// In es, this message translates to:
  /// **'Las necesitamos para mostrar la alarma y poder apagarla desde la pantalla de bloqueo.'**
  String get onbNotifBody;

  /// No description provided for @onbAllow.
  ///
  /// In es, this message translates to:
  /// **'Permitir'**
  String get onbAllow;

  /// No description provided for @onbLater.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get onbLater;

  /// No description provided for @onbExactTitle.
  ///
  /// In es, this message translates to:
  /// **'Alarmas puntuales'**
  String get onbExactTitle;

  /// No description provided for @onbExactBody.
  ///
  /// In es, this message translates to:
  /// **'Activa «Alarmas y recordatorios» para que suene justo a su hora.'**
  String get onbExactBody;

  /// No description provided for @onbFullTitle.
  ///
  /// In es, this message translates to:
  /// **'Amanecer en pantalla completa'**
  String get onbFullTitle;

  /// No description provided for @onbFullBody.
  ///
  /// In es, this message translates to:
  /// **'Permite la pantalla completa para que el amanecer aparezca aunque el móvil esté bloqueado.'**
  String get onbFullBody;

  /// No description provided for @onbOpenSettings.
  ///
  /// In es, this message translates to:
  /// **'Abrir ajustes'**
  String get onbOpenSettings;

  /// No description provided for @onbBatteryTitle.
  ///
  /// In es, this message translates to:
  /// **'Que nada apague tu alarma'**
  String get onbBatteryTitle;

  /// No description provided for @onbBatteryXiaomi.
  ///
  /// In es, this message translates to:
  /// **'En Ajustes → Batería, elige «Sin restricciones» y activa «Inicio automático».'**
  String get onbBatteryXiaomi;

  /// No description provided for @onbBatteryHuawei.
  ///
  /// In es, this message translates to:
  /// **'En Ajustes → Batería → Inicio de aplicaciones, desactiva «Gestionar automáticamente» y deja las tres opciones activadas.'**
  String get onbBatteryHuawei;

  /// No description provided for @onbBatteryOppo.
  ///
  /// In es, this message translates to:
  /// **'En Ajustes → Batería, permite la actividad en segundo plano y el inicio automático.'**
  String get onbBatteryOppo;

  /// No description provided for @onbBatteryVivo.
  ///
  /// In es, this message translates to:
  /// **'En Ajustes → Batería → Consumo en segundo plano, permite el consumo alto.'**
  String get onbBatteryVivo;

  /// No description provided for @onbBatterySamsung.
  ///
  /// In es, this message translates to:
  /// **'En Ajustes → Batería → Límites de uso en segundo plano, añade la app a «Nunca en suspensión».'**
  String get onbBatterySamsung;

  /// No description provided for @onbTipTitle.
  ///
  /// In es, this message translates to:
  /// **'Un consejo para esta noche'**
  String get onbTipTitle;

  /// No description provided for @onbTipBody.
  ///
  /// In es, this message translates to:
  /// **'Deja el móvil boca arriba y cargando en la mesilla para ver el amanecer.'**
  String get onbTipBody;

  /// No description provided for @onbDone.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get onbDone;

  /// No description provided for @healthTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu alarma podría no sonar'**
  String get healthTitle;

  /// No description provided for @healthNotif.
  ///
  /// In es, this message translates to:
  /// **'Faltan los avisos de alarma.'**
  String get healthNotif;

  /// No description provided for @healthExact.
  ///
  /// In es, this message translates to:
  /// **'Faltan las alarmas puntuales.'**
  String get healthExact;

  /// No description provided for @healthFull.
  ///
  /// In es, this message translates to:
  /// **'Falta la pantalla completa para el amanecer.'**
  String get healthFull;

  /// No description provided for @healthFix.
  ///
  /// In es, this message translates to:
  /// **'Arreglarlo'**
  String get healthFix;

  /// No description provided for @previewButton.
  ///
  /// In es, this message translates to:
  /// **'Probar despertar'**
  String get previewButton;

  /// No description provided for @previewBusy.
  ///
  /// In es, this message translates to:
  /// **'Ya hay una alarma sonando.'**
  String get previewBusy;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
