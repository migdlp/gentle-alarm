import 'package:gentle_alarm/l10n/gen/app_localizations.dart';

/// Texto de la condición para un código WMO, o null si no se debe mostrar.
String? weatherConditionText(AppLocalizations l10n, int code) {
  if (code == 0) return l10n.weatherClear;
  if (code >= 1 && code <= 3) return l10n.weatherPartlyCloudy;
  if (code == 45 || code == 48) return l10n.weatherFog;
  if (code >= 51 && code <= 57) return l10n.weatherDrizzle;
  if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82)) {
    return l10n.weatherRain;
  }
  if ((code >= 71 && code <= 77) || code == 85 || code == 86) {
    return l10n.weatherSnow;
  }
  if (code >= 95 && code <= 99) return l10n.weatherStorm;
  return null;
}

String greetingPhrase(AppLocalizations l10n, int index) => switch (index) {
  1 => l10n.greetingPhrase1,
  2 => l10n.greetingPhrase2,
  3 => l10n.greetingPhrase3,
  4 => l10n.greetingPhrase4,
  5 => l10n.greetingPhrase5,
  6 => l10n.greetingPhrase6,
  7 => l10n.greetingPhrase7,
  8 => l10n.greetingPhrase8,
  9 => l10n.greetingPhrase9,
  10 => l10n.greetingPhrase10,
  11 => l10n.greetingPhrase11,
  _ => l10n.greetingPhrase12,
};
