import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/features/ring/domain/ring_session.dart';
import 'package:gentle_alarm/src/features/ring/ui/sunrise_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <String>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('gentle_alarm/ring'), (
          c,
        ) async {
          calls.add(c.method);
          return null;
        });
  });

  Future<void> pump(WidgetTester tester) async {
    final session = RingSession(
      alarmId: 'a',
      label: '',
      ringAtEpochMs: DateTime(2026, 11, 9, 7, 30).millisecondsSinceEpoch,
      sunriseStartEpochMs: DateTime(2026, 11, 9, 7, 10).millisecondsSinceEpoch,
      state: RingState.sunrise,
      stateSinceEpochMs: 0,
      snoozesLeft: 3,
      autoSnoozeUsed: false,
      isPreview: false,
      soundFallback: false,
      brightnessRampFromSnooze: false,
    );
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(alwaysUse24HourFormat: true),
            child: SunriseView(
              session: session,
              now: DateTime(2026, 11, 9, 7, 20),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('tocar abre la hoja con los tres textos', (tester) async {
    await pump(tester);
    await tester.tap(find.byType(SunriseView));
    await tester.pumpAndSettle();
    expect(find.text('Suena a las 7:30'), findsOneWidget);
    expect(find.text('Ya estoy despierto/a'), findsOneWidget);
    expect(find.text('Seguir durmiendo'), findsOneWidget);
    expect(calls, contains('setBrightness'));
  });

  testWidgets('wakeEarly llama al canal', (tester) async {
    await pump(tester);
    await tester.tap(find.byType(SunriseView));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ya estoy despierto/a'));
    await tester.pumpAndSettle();
    expect(calls, contains('wakeEarly'));
  });

  testWidgets('seguir durmiendo cierra la hoja', (tester) async {
    await pump(tester);
    await tester.tap(find.byType(SunriseView));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Seguir durmiendo'));
    await tester.pumpAndSettle();
    expect(find.text('Seguir durmiendo'), findsNothing);
    expect(calls, isNot(contains('wakeEarly')));
  });
}
