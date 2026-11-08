import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_alarm/src/features/greeting/data/open_meteo_client.dart';
import 'package:gentle_alarm/src/features/greeting/data/weather_repository.dart';
import 'package:gentle_alarm/src/features/greeting/domain/weather.dart';
import 'package:gentle_alarm/src/features/settings/state/settings_providers.dart';
import 'package:http/http.dart' as http;

final weatherRepositoryProvider = Provider(
  (ref) => WeatherRepository(
    OpenMeteoClient(http.Client()),
    ref.watch(sharedPreferencesProvider),
  ),
);

class CityNotifier extends Notifier<City?> {
  @override
  City? build() => ref.watch(weatherRepositoryProvider).city;

  Future<void> choose(City? city) async {
    await ref.read(weatherRepositoryProvider).setCity(city);
    state = city;
  }
}

final cityProvider = NotifierProvider<CityNotifier, City?>(CityNotifier.new);
