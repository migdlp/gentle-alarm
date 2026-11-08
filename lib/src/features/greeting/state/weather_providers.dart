import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_alarm/src/features/greeting/data/open_meteo_client.dart';
import 'package:gentle_alarm/src/features/greeting/data/weather_repository.dart';
import 'package:gentle_alarm/src/features/settings/state/settings_providers.dart';
import 'package:http/http.dart' as http;

final weatherRepositoryProvider = Provider(
  (ref) => WeatherRepository(
    OpenMeteoClient(http.Client()),
    ref.watch(sharedPreferencesProvider),
  ),
);
