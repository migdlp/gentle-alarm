import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/features/greeting/domain/weather_text.dart';

void main() {
  final es = lookupAppLocalizations(const Locale('es'));
  test('correspondencia WMO', () {
    expect(weatherConditionText(es, 0), 'Despejado');
    expect(weatherConditionText(es, 2), 'Algo nublado');
    expect(weatherConditionText(es, 45), 'Niebla');
    expect(weatherConditionText(es, 63), 'Lluvia');
    expect(weatherConditionText(es, 73), 'Nieve');
    expect(weatherConditionText(es, 96), 'Tormenta');
    expect(weatherConditionText(es, 53), 'Llovizna');
    expect(weatherConditionText(es, 4), isNull);
  });
}
