import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/core/time/format.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late AppLocalizations es;
  late AppLocalizations en;
  setUpAll(() async {
    await initializeDateFormatting('es');
    await initializeDateFormatting('en');
    es = lookupAppLocalizations(const Locale('es'));
    en = lookupAppLocalizations(const Locale('en'));
  });

  test('formatInDuration', () {
    expect(
      formatInDuration(es, const Duration(hours: 2, minutes: 5)),
      'en 2 h 5 min',
    );
    expect(formatInDuration(es, const Duration(minutes: 45)), 'en 45 min');
    expect(
      formatInDuration(es, const Duration(seconds: 30)),
      'en menos de 1 min',
    );
    expect(formatInDuration(es, const Duration(hours: 1)), 'en 1 h 0 min');
    expect(
      formatInDuration(en, const Duration(minutes: 3, seconds: 1)),
      'in 4 min',
    );
  });

  test('formatWhen', () {
    final now = DateTime(2026, 11, 9, 22, 0); // lunes
    expect(
      formatWhen(es, DateTime(2026, 11, 9, 23), now, '23:00', 'es'),
      'hoy a las 23:00',
    );
    expect(
      formatWhen(es, DateTime(2026, 11, 10, 7, 30), now, '7:30', 'es'),
      'mañana a las 7:30',
    );
    expect(
      formatWhen(es, DateTime(2026, 11, 13, 7, 30), now, '7:30', 'es'),
      'el viernes a las 7:30',
    );
    expect(
      formatWhen(en, DateTime(2026, 11, 13, 7, 30), now, '7:30 AM', 'en'),
      'on Friday at 7:30 AM',
    );
  });

  test('formatDays', () {
    expect(formatDays(es, [], 'es'), 'Una vez');
    expect(formatDays(es, [1, 2, 3, 4, 5, 6, 7], 'es'), 'Todos los días');
    expect(formatDays(es, [1, 2, 3, 4, 5], 'es'), 'De lunes a viernes');
    expect(formatDays(es, [7, 6], 'es'), 'Fines de semana');
    expect(formatDays(en, [1, 3], 'en'), 'Mon, Wed');
  });
}
