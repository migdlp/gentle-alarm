import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/features/greeting/data/weather_repository.dart';
import 'package:gentle_alarm/src/features/greeting/domain/weather.dart';
import 'package:gentle_alarm/src/features/greeting/state/weather_providers.dart';
import 'package:gentle_alarm/src/features/ring/ui/greeting_view.dart';
import 'package:gentle_alarm/src/features/settings/state/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Repo implements WeatherRepository {
  _Repo(this.cached);
  final WeatherNow? cached;
  @override
  WeatherNow? cachedFresh() => cached;
  @override
  City? get city => null;
  @override
  Future<void> setCity(City? city) async {}
  @override
  Future<List<City>> searchCities(String q, String l) async => const [];
  @override
  Future<WeatherNow?> refresh() async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <String>[];

  setUp(() {
    calls.clear();
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('gentle_alarm/ring'), (
          c,
        ) async {
          calls.add(c.method);
          return null;
        });
  });

  Future<SharedPreferences> pump(WidgetTester tester, WeatherNow? w) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          weatherRepositoryProvider.overrideWithValue(_Repo(w)),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: GreetingView(random: Random(1))),
        ),
      ),
    );
    return prefs;
  }

  testWidgets('con caché válida muestra el tiempo', (tester) async {
    final prefs = await pump(
      tester,
      WeatherNow(
        temperatureC: 12.2,
        weatherCode: 0,
        fetchedAt: DateTime.now(),
        cityName: 'Madrid',
      ),
    );
    expect(find.text('12 °C · Despejado en Madrid'), findsOneWidget);
    expect(find.text('Buenos días'), findsOneWidget);
    expect(prefs.getInt('greeting.lastIndex'), inInclusiveRange(1, 12));
  });

  testWidgets('sin caché omite la línea sin errores', (tester) async {
    await pump(tester, null);
    expect(find.textContaining('°C'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('«Empezar el día» llama a finishGreeting', (tester) async {
    await pump(tester, null);
    await tester.tap(find.text('Empezar el día'));
    expect(calls, ['finishGreeting']);
  });
}
