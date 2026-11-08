import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/core/theme/app_theme.dart';
import 'package:gentle_alarm/src/core/time/clock.dart';
import 'package:gentle_alarm/src/features/alarms/data/alarm_repository.dart';
import 'package:gentle_alarm/src/features/alarms/domain/alarm.dart';
import 'package:gentle_alarm/src/features/alarms/ui/alarm_editor_screen.dart';
import 'package:gentle_alarm/src/features/alarms/ui/alarm_list_screen.dart';
import 'package:gentle_alarm/src/features/greeting/data/weather_repository.dart';
import 'package:gentle_alarm/src/features/greeting/domain/weather.dart';
import 'package:gentle_alarm/src/features/greeting/state/weather_providers.dart';
import 'package:gentle_alarm/src/features/greeting/ui/city_search_screen.dart';
import 'package:gentle_alarm/src/features/onboarding/ui/onboarding_screen.dart';
import 'package:gentle_alarm/src/features/permissions/domain/permission_status.dart';
import 'package:gentle_alarm/src/features/permissions/state/permission_providers.dart';
import 'package:gentle_alarm/src/features/ring/domain/ring_session.dart';
import 'package:gentle_alarm/src/features/ring/ui/confirm_view.dart';
import 'package:gentle_alarm/src/features/ring/ui/greeting_view.dart';
import 'package:gentle_alarm/src/features/ring/ui/ringing_view.dart';
import 'package:gentle_alarm/src/features/ring/ui/snoozed_view.dart';
import 'package:gentle_alarm/src/features/ring/ui/sunrise_view.dart';
import 'package:gentle_alarm/src/features/settings/state/settings_providers.dart';
import 'package:gentle_alarm/src/features/settings/ui/settings_screen.dart';
import 'package:gentle_alarm/src/features/sounds/ui/sound_picker_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Repo implements AlarmRepository {
  final _a = Alarm(
    id: 'a',
    weekdays: const [1, 2, 3],
    label: 'Trabajo',
    scheduledRingAtEpochMs: DateTime(
      2026,
      11,
      10,
      7,
      30,
    ).millisecondsSinceEpoch,
    createdAtEpochMs: 0,
  );
  @override
  Future<List<Alarm>> list() async => [_a];
  @override
  Future<Alarm> save(Alarm alarm) async => alarm;
  @override
  Future<void> delete(String id) async {}
  @override
  Future<Alarm> setEnabled(String id, bool enabled) async => _a;
  @override
  Future<Alarm> setSkipNext(String id, bool skip) async => _a;
  @override
  Future<void> startPreview(Alarm alarm) async {}
}

class _Weather implements WeatherRepository {
  @override
  WeatherNow? cachedFresh() => WeatherNow(
    temperatureC: 12,
    weatherCode: 0,
    fetchedAt: DateTime.now(),
    cityName: 'Madrid',
  );
  @override
  City? get city => null;
  @override
  Future<void> setCity(City? city) async {}
  @override
  Future<List<City>> searchCities(String q, String l) async => const [];
  @override
  Future<WeatherNow?> refresh() async => null;
}

RingSession _session(RingState state) => RingSession(
  alarmId: 'a',
  label: 'Trabajo',
  ringAtEpochMs: DateTime(2026, 11, 9, 7, 30).millisecondsSinceEpoch,
  sunriseStartEpochMs: DateTime(2026, 11, 9, 7, 10).millisecondsSinceEpoch,
  state: state,
  stateSinceEpochMs: DateTime(2026, 11, 9, 7, 30).millisecondsSinceEpoch,
  snoozesLeft: 3,
  autoSnoozeUsed: false,
  snoozeUntilEpochMs: DateTime(2026, 11, 9, 7, 40).millisecondsSinceEpoch,
  isPreview: false,
  soundFallback: false,
  brightnessRampFromSnooze: false,
);

final _now = DateTime(2026, 11, 9, 7, 20);

typedef _Case = ({String name, Widget Function() build, bool contrast});

final _cases = <_Case>[
  (name: 'lista', build: () => const AlarmListScreen(), contrast: true),
  (name: 'editor', build: () => const AlarmEditorScreen(), contrast: true),
  (
    name: 'selector de sonido',
    build: () => const SoundPickerScreen(selectedId: 'birds_dawn'),
    contrast: true,
  ),
  (name: 'ajustes', build: () => const SettingsScreen(), contrast: true),
  (
    name: 'búsqueda de ciudad',
    build: () => const CitySearchScreen(),
    contrast: true,
  ),
  (name: 'onboarding', build: () => const OnboardingScreen(), contrast: true),
  (
    name: 'amanecer',
    build: () => SunriseView(session: _session(RingState.sunrise), now: _now),
    contrast: false, // hora al 10 % por diseño (RF-14)
  ),
  (
    name: 'sonando',
    build: () => RingingView(session: _session(RingState.ringing), now: _now),
    contrast: true,
  ),
  (name: 'confirmación', build: () => const ConfirmView(), contrast: true),
  (
    name: 'pospuesta',
    build: () => SnoozedView(session: _session(RingState.snoozed)),
    contrast: true,
  ),
  (
    name: 'saludo',
    build: () => GreetingView(random: Random(3)),
    contrast: true,
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    for (final ch in ['gentle_alarm/ring', 'gentle_alarm/system']) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(ch), (_) async => null);
    }
  });

  Future<void> pump(
    WidgetTester tester,
    Widget Function() build, {
    double scale = 1.0,
    bool disableAnimations = false,
  }) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          alarmRepositoryProvider.overrideWithValue(_Repo()),
          weatherRepositoryProvider.overrideWithValue(_Weather()),
          clockProvider.overrideWithValue(() => _now),
          permissionStatusProvider.overrideWith(
            (ref) async => const PermissionStatus(
              notifications: true,
              exactAlarms: true,
              fullScreen: true,
              manufacturer: 'xiaomi',
            ),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          theme: buildLightTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(scale),
              disableAnimations: disableAnimations,
              alwaysUse24HourFormat: true,
            ),
            child: child!,
          ),
          home: Scaffold(body: build()),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 700));
  }

  for (final c in _cases) {
    group(c.name, () {
      testWidgets('directrices de accesibilidad', (tester) async {
        final handle = tester.ensureSemantics();
        await pump(tester, c.build);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        if (c.contrast) {
          await expectLater(tester, meetsGuideline(textContrastGuideline));
        }
        handle.dispose();
      });

      testWidgets('texto al 200 % sin desbordes', (tester) async {
        await pump(tester, c.build, scale: 2.0);
        expect(tester.takeException(), isNull);
      });

      testWidgets('con animaciones reducidas', (tester) async {
        await pump(tester, c.build, disableAnimations: true);
        expect(tester.takeException(), isNull);
      });
    });
  }
}
