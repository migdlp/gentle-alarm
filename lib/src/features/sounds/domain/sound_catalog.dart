import 'package:gentle_alarm/l10n/gen/app_localizations.dart';

abstract final class SoundCatalog {
  static const builtInIds = [
    'birds_dawn',
    'soft_waves',
    'light_rain',
    'chimes',
    'calm_piano',
    'singing_bowls',
  ];
  static const defaultId = 'birds_dawn';

  static String label(AppLocalizations l10n, String id, String? customName) {
    switch (id) {
      case 'soft_waves':
        return l10n.soundSoftWaves;
      case 'light_rain':
        return l10n.soundLightRain;
      case 'chimes':
        return l10n.soundChimes;
      case 'calm_piano':
        return l10n.soundCalmPiano;
      case 'singing_bowls':
        return l10n.soundSingingBowls;
      case 'custom':
        return l10n.soundCustom(customName ?? '');
      default:
        return l10n.soundBirdsDawn;
    }
  }
}
