import 'package:flutter/material.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/core/theme/app_theme.dart';

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
      home: Builder(
        builder: (c) => Scaffold(
          body: Center(child: Text(AppLocalizations.of(c)!.appTitle)),
        ),
      ),
    );
  }
}
