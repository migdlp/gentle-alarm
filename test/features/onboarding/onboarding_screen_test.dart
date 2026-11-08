import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/features/alarms/state/alarms_providers.dart';
import 'package:gentle_alarm/src/features/alarms/ui/alarm_list_screen.dart';
import 'package:gentle_alarm/src/features/onboarding/ui/onboarding_screen.dart';
import 'package:gentle_alarm/src/features/permissions/domain/permission_status.dart';
import 'package:gentle_alarm/src/features/permissions/state/permission_providers.dart';
import 'package:gentle_alarm/src/features/settings/state/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Empty extends AlarmsNotifier {
  @override
  Future<List<Never>> build() async => const [];
}

void main() {
  testWidgets('«Listo» guarda la marca y navega a la lista', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          alarmsProvider.overrideWith(_Empty.new),
          permissionStatusProvider.overrideWith(
            (ref) async => const PermissionStatus(
              notifications: true,
              exactAlarms: true,
              fullScreen: true,
              manufacturer: 'google',
            ),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Empezar'));
    await tester.pumpAndSettle();
    expect(find.text('Un consejo para esta noche'), findsOneWidget);
    await tester.tap(find.text('Listo'));
    await tester.pumpAndSettle();
    expect(prefs.getBool('onboarding.done'), isTrue);
    expect(find.byType(AlarmListScreen), findsOneWidget);
  });
}
