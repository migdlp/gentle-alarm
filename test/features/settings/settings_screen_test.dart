import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/features/settings/state/settings_providers.dart';
import 'package:gentle_alarm/src/features/settings/ui/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('cambiar el amanecer guarda el valor y muestra la atribución', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          locale: Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.tap(find.widgetWithText(ChoiceChip, '30 min').first);
    await tester.pumpAndSettle();
    expect(container.read(alarmDefaultsProvider).sunriseMinutes, 30);
    expect(prefs.getInt('defaults.sunriseMinutes'), 30);
    await tester.scrollUntilVisible(
      find.text('Datos del tiempo: Open-Meteo.com'),
      200,
    );
    expect(find.text('Datos del tiempo: Open-Meteo.com'), findsOneWidget);
  });
}
