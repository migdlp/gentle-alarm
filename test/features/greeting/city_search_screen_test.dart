import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/features/greeting/data/weather_repository.dart';
import 'package:gentle_alarm/src/features/greeting/domain/weather.dart';
import 'package:gentle_alarm/src/features/greeting/state/weather_providers.dart';
import 'package:gentle_alarm/src/features/greeting/ui/city_search_screen.dart';

const madrid = City(
  name: 'Madrid',
  country: 'España',
  latitude: 40.4,
  longitude: -3.7,
  admin1: 'Comunidad de Madrid',
);

class FakeWeatherRepo implements WeatherRepository {
  FakeWeatherRepo({this.current});
  City? current;
  final searches = <String>[];
  final setCalls = <City?>[];

  @override
  City? get city => current;
  @override
  Future<void> setCity(City? city) async {
    setCalls.add(city);
    current = city;
  }

  @override
  Future<List<City>> searchCities(String query, String languageCode) async {
    searches.add(query);
    return [madrid];
  }

  @override
  Future<WeatherNow?> refresh() async => null;
  @override
  WeatherNow? cachedFresh() => null;
}

Future<void> _pump(WidgetTester tester, FakeWeatherRepo repo) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [weatherRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (c) => TextButton(
            onPressed: () => Navigator.of(c).push(
              MaterialPageRoute<void>(builder: (_) => const CitySearchScreen()),
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('escribir «Ma» busca una vez tras 400 ms', (tester) async {
    final repo = FakeWeatherRepo();
    await _pump(tester, repo);
    await tester.enterText(find.byType(TextField), 'Ma');
    await tester.pump(const Duration(milliseconds: 399));
    expect(repo.searches, isEmpty);
    await tester.pump(const Duration(milliseconds: 2));
    await tester.pumpAndSettle();
    expect(repo.searches, ['Ma']);
    expect(find.text('Madrid'), findsOneWidget);
    expect(find.text('Comunidad de Madrid, España'), findsOneWidget);
  });

  testWidgets('una letra muestra citySearchStart', (tester) async {
    await _pump(tester, FakeWeatherRepo());
    await tester.enterText(find.byType(TextField), 'M');
    await tester.pump();
    expect(find.text('Escribe al menos 2 letras'), findsOneWidget);
  });

  testWidgets('elegir un resultado llama a setCity', (tester) async {
    final repo = FakeWeatherRepo();
    await _pump(tester, repo);
    await tester.enterText(find.byType(TextField), 'Madrid');
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Madrid'));
    await tester.pumpAndSettle();
    expect(repo.setCalls, [madrid]);
    expect(find.byType(CitySearchScreen), findsNothing);
  });

  testWidgets('Quitar llama a setCity(null)', (tester) async {
    final repo = FakeWeatherRepo(current: madrid);
    await _pump(tester, repo);
    await tester.tap(find.text('Quitar'));
    await tester.pumpAndSettle();
    expect(repo.setCalls, [null]);
  });
}
