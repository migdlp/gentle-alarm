import 'dart:convert';

import 'package:gentle_alarm/src/features/greeting/domain/weather.dart';
import 'package:http/http.dart' as http;

class OpenMeteoClient {
  OpenMeteoClient(this._http, {this.timeout = const Duration(seconds: 5)});

  final http.Client _http;
  final Duration timeout;

  /// Devuelve [] ante cualquier error (nunca lanza).
  Future<List<City>> searchCities(String query, String languageCode) async {
    final q = query.trim();
    if (q.length < 2) return const [];
    try {
      final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
        'name': q,
        'count': '10',
        'language': languageCode,
        'format': 'json',
      });
      final r = await _http.get(uri).timeout(timeout);
      if (r.statusCode != 200) return const [];
      final json = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
      final results = json['results'] as List?;
      if (results == null) return const [];
      return results
          .cast<Map<String, dynamic>>()
          .map(City.fromMap)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  /// Devuelve null ante cualquier error (nunca lanza).
  Future<({double temperatureC, int weatherCode})?> currentWeather(
    double lat,
    double lon,
  ) async {
    try {
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': '$lat',
        'longitude': '$lon',
        'current': 'temperature_2m,weather_code',
        'timezone': 'auto',
      });
      final r = await _http.get(uri).timeout(timeout);
      if (r.statusCode != 200) return null;
      final current =
          (jsonDecode(r.body) as Map<String, dynamic>)['current']
              as Map<String, dynamic>;
      return (
        temperatureC: (current['temperature_2m'] as num).toDouble(),
        weatherCode: current['weather_code'] as int,
      );
    } catch (_) {
      return null;
    }
  }
}
