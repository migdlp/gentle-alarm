import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';

void main() => runApp(const ProviderScope(child: GentleAlarmApp()));

class GentleAlarmApp extends StatelessWidget {
  const GentleAlarmApp({super.key, this.locale});

  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: locale,
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
