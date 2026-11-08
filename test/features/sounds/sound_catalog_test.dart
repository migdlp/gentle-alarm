import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/features/sounds/domain/sound_catalog.dart';

void main() {
  final es = lookupAppLocalizations(const Locale('es'));
  final en = lookupAppLocalizations(const Locale('en'));

  test('ids integrados en orden', () {
    expect(SoundCatalog.builtInIds, [
      'birds_dawn',
      'soft_waves',
      'light_rain',
      'chimes',
      'calm_piano',
      'singing_bowls',
    ]);
  });
  test('etiquetas', () {
    expect(SoundCatalog.label(es, 'chimes', null), 'Campanillas');
    expect(SoundCatalog.label(en, 'chimes', null), 'Chimes');
    expect(SoundCatalog.label(es, 'custom', 'mi.mp3'), 'De mi móvil: mi.mp3');
    expect(SoundCatalog.label(es, 'zzz', null), 'Pájaros al alba');
  });
}
