import 'dart:convert';

import 'package:gentle_alarm/src/features/greeting/data/open_meteo_client.dart';
import 'package:gentle_alarm/src/features/greeting/domain/weather.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherRepository {
  WeatherRepository(this._client, this._prefs, [DateTime Function()? clock])
    : _clock = clock ?? DateTime.now;

  final OpenMeteoClient _client;
  final SharedPreferences _prefs;
  final DateTime Function() _clock;

  static const cacheTtl = Duration(hours: 3);

  City? get city {
    final raw = _prefs.getString('weather.city');
    if (raw == null) return null;
    try {
      return City.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> setCity(City? city) async {
    await _prefs.remove('weather.cache');
    if (city == null) {
      await _prefs.remove('weather.city');
    } else {
      await _prefs.setString('weather.city', jsonEncode(city.toMap()));
    }
  }

  Future<List<City>> searchCities(String query, String languageCode) =>
      _client.searchCities(query, languageCode);

  Future<WeatherNow?> refresh() async {
    final c = city;
    if (c == null) return null;
    final w = await _client.currentWeather(c.latitude, c.longitude);
    if (w == null) return null;
    final now = WeatherNow(
      temperatureC: w.temperatureC,
      weatherCode: w.weatherCode,
      fetchedAt: _clock(),
      cityName: c.name,
    );
    await _prefs.setString('weather.cache', jsonEncode(now.toMap()));
    return now;
  }

  WeatherNow? cachedFresh() {
    final c = city;
    final raw = _prefs.getString('weather.cache');
    if (c == null || raw == null) return null;
    try {
      final w = WeatherNow.fromMap(jsonDecode(raw) as Map<String, dynamic>);
      if (w.cityName != c.name) return null;
      return _clock().difference(w.fetchedAt) < cacheTtl ? w : null;
    } catch (_) {
      return null;
    }
  }
}
