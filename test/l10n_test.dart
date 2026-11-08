import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/app.dart';
import 'package:gentle_alarm/src/features/alarms/state/alarms_providers.dart';

void main() {
  for (final (code, text) in [
    ('en', 'Gentle Alarm'),
    ('es', 'Despertar suave'),
  ]) {
    test('appTitle en $code', () {
      expect(lookupAppLocalizations(Locale(code)).appTitle, text);
    });
  }

  for (final (code, text) in [('en', 'Alarms'), ('es', 'Alarmas')]) {
    testWidgets('la app se muestra en $code', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [alarmsProvider.overrideWith(_Empty.new)],
          child: GentleAlarmApp(locale: Locale(code)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(text), findsOneWidget);
    });
  }
}

class _Empty extends AlarmsNotifier {
  @override
  Future<List<Never>> build() async => const [];
}
