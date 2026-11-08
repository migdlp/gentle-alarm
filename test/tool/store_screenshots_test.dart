// Genera las capturas de la ficha de Play (1080 × 1920) en docs/release/screenshots.
// Se omite salvo que se pida: GENERATE_SCREENSHOTS=1 flutter test test/tool
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/core/theme/app_theme.dart';
import 'package:gentle_alarm/src/core/time/clock.dart';
import 'package:gentle_alarm/src/features/alarms/data/alarm_repository.dart';
import 'package:gentle_alarm/src/features/alarms/domain/alarm.dart';
import 'package:gentle_alarm/src/features/alarms/ui/alarm_list_screen.dart';
import 'package:gentle_alarm/src/features/greeting/data/weather_repository.dart';
import 'package:gentle_alarm/src/features/greeting/domain/weather.dart';
import 'package:gentle_alarm/src/features/greeting/state/weather_providers.dart';
import 'package:gentle_alarm/src/features/ring/domain/ring_session.dart';
import 'package:gentle_alarm/src/features/ring/ui/greeting_view.dart';
import 'package:gentle_alarm/src/features/ring/ui/ringing_view.dart';
import 'package:gentle_alarm/src/features/ring/ui/sunrise_view.dart';
import 'package:gentle_alarm/src/features/settings/state/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _now = DateTime(2026, 11, 9, 7, 25);

class _Repo implements AlarmRepository {
  final _list = [
    Alarm(
      id: 'a',
      hour: 7,
      minute: 30,
      weekdays: const [1, 2, 3, 4, 5],
      label: 'Trabajo',
      scheduledRingAtEpochMs: DateTime(
        2026,
        11,
        9,
        7,
        30,
      ).millisecondsSinceEpoch,
      createdAtEpochMs: 0,
    ),
    Alarm(
      id: 'b',
      hour: 9,
      minute: 30,
      weekdays: const [6, 7],
      label: 'Fin de semana',
      scheduledRingAtEpochMs: DateTime(
        2026,
        11,
        14,
        9,
        30,
      ).millisecondsSinceEpoch,
      createdAtEpochMs: 1,
    ),
  ];
  @override
  Future<List<Alarm>> list() async => _list;
  @override
  Future<Alarm> save(Alarm a) async => a;
  @override
  Future<void> delete(String id) async {}
  @override
  Future<Alarm> setEnabled(String id, bool e) async => _list.first;
  @override
  Future<Alarm> setSkipNext(String id, bool s) async => _list.first;
  @override
  Future<void> startPreview(Alarm a) async {}
}

class _Weather implements WeatherRepository {
  @override
  WeatherNow? cachedFresh() => WeatherNow(
    temperatureC: 12,
    weatherCode: 0,
    fetchedAt: _now,
    cityName: 'Madrid',
  );
  @override
  City? get city => null;
  @override
  Future<void> setCity(City? c) async {}
  @override
  Future<List<City>> searchCities(String q, String l) async => const [];
  @override
  Future<WeatherNow?> refresh() async => null;
}

RingSession _session(RingState state) => RingSession(
  alarmId: 'a',
  label: 'Trabajo',
  ringAtEpochMs: DateTime(2026, 11, 9, 7, 30).millisecondsSinceEpoch,
  sunriseStartEpochMs: DateTime(2026, 11, 9, 7, 20).millisecondsSinceEpoch,
  state: state,
  stateSinceEpochMs: 0,
  snoozesLeft: 3,
  autoSnoozeUsed: false,
  isPreview: false,
  soundFallback: false,
  brightnessRampFromSnooze: false,
);

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final p in paths) {
    loader.addFont(
      Future.value(ByteData.view(File(p).readAsBytesSync().buffer)),
    );
  }
  await loader.load();
}

void main() {
  final enabled = Platform.environment['GENERATE_SCREENSHOTS'] == '1';
  final key = GlobalKey();

  testWidgets('capturas de la ficha', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    debugDisableShadows = false; // sombras reales en las capturas
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await _loadFont('Nunito', [
      'assets/fonts/Nunito-Regular.ttf',
      'assets/fonts/Nunito-SemiBold.ttf',
      'assets/fonts/Nunito-Bold.ttf',
    ]);
    final sdk = Platform.environment['FLUTTER_ROOT'] ?? '/opt/flutter';
    await _loadFont('MaterialIcons', [
      '$sdk/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    ]);
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    Future<void> shot(
      String name,
      Widget child, {
      bool scaffold = false,
    }) async {
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefs),
              alarmRepositoryProvider.overrideWithValue(_Repo()),
              weatherRepositoryProvider.overrideWithValue(_Weather()),
              clockProvider.overrideWithValue(() => _now),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: const Locale('es'),
              theme: buildLightTheme(),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (c, w) => MediaQuery(
                data: MediaQuery.of(c).copyWith(alwaysUse24HourFormat: true),
                child: w!,
              ),
              home: scaffold ? child : Scaffold(body: child),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 3);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File(
          'docs/release/screenshots/$name.png',
        ).writeAsBytesSync(bytes!.buffer.asUint8List());
      });
    }

    await shot('1-lista', const AlarmListScreen(), scaffold: true);
    await shot(
      '2-amanecer',
      SunriseView(
        session: _session(RingState.sunrise),
        now: DateTime(2026, 11, 9, 7, 25),
      ),
    );
    await shot(
      '3-sonando',
      RingingView(
        session: _session(RingState.ringing),
        now: DateTime(2026, 11, 9, 7, 30),
      ),
    );
    await shot('4-saludo', GreetingView(random: Random(5)));
    debugDisableShadows = true;
  }, skip: !enabled);
}
