import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: unused_import
import 'package:gentle_alarm/ring_main.dart' as ring_entry;
import 'package:gentle_alarm/src/app.dart';
import 'package:gentle_alarm/src/features/settings/state/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const GentleAlarmApp(),
    ),
  );
}
