import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/core/theme/app_theme.dart';
import 'package:gentle_alarm/src/features/alarms/ui/alarm_list_screen.dart';
import 'package:gentle_alarm/src/features/onboarding/ui/onboarding_screen.dart';
import 'package:gentle_alarm/src/features/settings/state/settings_providers.dart';
import 'package:gentle_alarm/src/features/settings/ui/settings_screen.dart';

class GentleAlarmApp extends StatelessWidget {
  const GentleAlarmApp({super.key, this.locale});

  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: locale,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (c) => AppLocalizations.of(c)!.appTitle,
      routes: {'/settings': (_) => const SettingsScreen()},
      home: Consumer(
        builder: (context, ref, _) =>
            ref.read(settingsRepositoryProvider).onboardingDone
            ? const AlarmListScreen()
            : const OnboardingScreen(),
      ),
    );
  }
}
