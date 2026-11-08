import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/src/features/greeting/data/open_meteo_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('búsqueda devuelve ciudades', () async {
    late Uri seen;
    final c = OpenMeteoClient(
      MockClient((r) async {
        seen = r.url;
        return http.Response(
          '{"results":[{"name":"Madrid","country":"España","latitude":40.4,"longitude":-3.7,"admin1":"Madrid"},'
          '{"name":"Madrid","country":"Colombia","latitude":4.7,"longitude":-74.2}]}',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );
    final r = await c.searchCities('  Madrid ', 'es');
    expect(r.length, 2);
    expect(r.first.country, 'España');
    expect(seen.host, 'geocoding-api.open-meteo.com');
    expect(seen.queryParameters['language'], 'es');
    expect(seen.queryParameters['name'], 'Madrid');
  });

  test('una letra no hace petición', () async {
    var calls = 0;
    final c = OpenMeteoClient(
      MockClient((r) async {
        calls++;
        return http.Response('{}', 200);
      }),
    );
    expect(await c.searchCities('M', 'es'), isEmpty);
    expect(calls, 0);
  });

  test('sin results devuelve vacío y errores no lanzan', () async {
    expect(
      await OpenMeteoClient(
        MockClient((r) async => http.Response('{}', 200)),
      ).searchCities('Madrid', 'es'),
      isEmpty,
    );
    expect(
      await OpenMeteoClient(
        MockClient((r) async => http.Response('x', 500)),
      ).searchCities('Madrid', 'es'),
      isEmpty,
    );
    expect(
      await OpenMeteoClient(
        MockClient((r) async => throw Exception('red')),
      ).searchCities('Madrid', 'es'),
      isEmpty,
    );
  });

  test('timeout devuelve vacío / null', () async {
    final slow = MockClient((r) async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return http.Response('{}', 200);
    });
    final c = OpenMeteoClient(slow, timeout: const Duration(milliseconds: 50));
    expect(await c.searchCities('Madrid', 'es'), isEmpty);
    expect(await c.currentWeather(1, 2), isNull);
  });

  test('currentWeather decodifica', () async {
    late Uri seen;
    final c = OpenMeteoClient(
      MockClient((r) async {
        seen = r.url;
        return http.Response(
          '{"current":{"temperature_2m":14.5,"weather_code":61}}',
          200,
        );
      }),
    );
    final w = await c.currentWeather(40.4, -3.7);
    expect(w!.temperatureC, 14.5);
    expect(w.weatherCode, 61);
    expect(seen.host, 'api.open-meteo.com');
    expect(seen.queryParameters['current'], 'temperature_2m,weather_code');
  });
}
