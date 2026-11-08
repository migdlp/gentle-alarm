import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/core/time/clock.dart';
import 'package:gentle_alarm/src/features/ring/domain/ring_session.dart';
import 'package:gentle_alarm/src/features/ring/ui/snoozed_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cuenta atrás y «Ya me levanto»', (tester) async {
    final calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('gentle_alarm/ring'), (
          c,
        ) async {
          calls.add(c.method);
          return null;
        });
    var now = DateTime(2026, 11, 9, 7, 30);
    final session = RingSession(
      alarmId: 'a',
      label: '',
      ringAtEpochMs: 0,
      sunriseStartEpochMs: 0,
      state: RingState.snoozed,
      stateSinceEpochMs: 0,
      snoozesLeft: 2,
      autoSnoozeUsed: false,
      snoozeUntilEpochMs: now.millisecondsSinceEpoch + 125000,
      isPreview: false,
      soundFallback: false,
      brightnessRampFromSnooze: false,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [clockProvider.overrideWithValue(() => now)],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SnoozedView(session: session)),
        ),
      ),
    );
    expect(find.text('Vuelvo en 02:05'), findsOneWidget);
    now = now.add(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Vuelvo en 02:04'), findsOneWidget);
    await tester.tap(find.text('Ya me levanto'));
    expect(calls, ['wakeUp']);
  });
}
