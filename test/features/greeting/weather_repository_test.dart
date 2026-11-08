import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/src/features/greeting/data/open_meteo_client.dart';
import 'package:gentle_alarm/src/features/greeting/data/weather_repository.dart';
import 'package:gentle_alarm/src/features/greeting/domain/weather.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const madrid = City(
  name: 'Madrid',
  country: 'España',
  latitude: 40.4,
  longitude: -3.7,
);

void main() {
  late DateTime now;
  late WeatherRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    now = DateTime(2026, 11, 9, 7, 0);
    repo = WeatherRepository(
      OpenMeteoClient(
        MockClient(
          (r) async => http.Response(
            '{"current":{"temperature_2m":9.0,"weather_code":3}}',
            200,
          ),
        ),
      ),
      await SharedPreferences.getInstance(),
      () => now,
    );
  });

  test('sin ciudad, refresh devuelve null', () async {
    expect(await repo.refresh(), isNull);
  });

  test('refresh guarda la caché y cachedFresh la lee', () async {
    await repo.setCity(madrid);
    expect(repo.city, madrid);
    final w = await repo.refresh();
    expect(w!.temperatureC, 9.0);
    now = now.add(const Duration(hours: 2, minutes: 59));
    expect(repo.cachedFresh(), isNotNull);
  });

  test('caché caducada a las 3 h 1 min', () async {
    await repo.setCity(madrid);
    await repo.refresh();
    now = now.add(const Duration(hours: 3, minutes: 1));
    expect(repo.cachedFresh(), isNull);
  });

  test('cambiar de ciudad borra la caché', () async {
    await repo.setCity(madrid);
    await repo.refresh();
    await repo.setCity(
      const City(
        name: 'Sevilla',
        country: 'España',
        latitude: 37.4,
        longitude: -6,
      ),
    );
    expect(repo.cachedFresh(), isNull);
  });
}
