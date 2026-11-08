import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/app.dart';
import 'package:gentle_alarm/src/features/alarms/state/alarms_providers.dart';
import 'package:gentle_alarm/src/features/settings/state/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(
    () => SharedPreferences.setMockInitialValues({'onboarding.done': true}),
  );

  for (final (code, text) in [
    ('en', 'Gentle Alarm'),
    ('es', 'Despertar suave'),
  ]) {
    test('appTitle en $code', () {
      expect(lookupAppLocalizations(Locale(code)).appTitle, text);
    });
  }

  test('los apóstrofos del inglés se conservan', () {
    expect(
      lookupAppLocalizations(const Locale('en')).onbWelcomeBody,
      "We'll wake you gently: light first, then a soft sound.",
    );
  });

  for (final (code, text) in [('en', 'Alarms'), ('es', 'Alarmas')]) {
    testWidgets('la app se muestra en $code', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            alarmsProvider.overrideWith(_Empty.new),
          ],
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
