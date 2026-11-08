import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/features/ring/domain/ring_session.dart';
import 'package:gentle_alarm/src/features/ring/ui/ringing_view.dart';

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

  Future<SemanticsHandle> pump(WidgetTester tester, {int snoozes = 3}) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: RingingView(
              now: DateTime(2026, 11, 9, 7, 30),
              session: RingSession(
                alarmId: 'a',
                label: 'Trabajo',
                ringAtEpochMs: 0,
                sunriseStartEpochMs: 0,
                state: RingState.ringing,
                stateSinceEpochMs: 0,
                snoozesLeft: snoozes,
                autoSnoozeUsed: false,
                isPreview: false,
                soundFallback: false,
                brightnessRampFromSnooze: false,
              ),
            ),
          ),
        ),
      ),
    );
    return handle;
  }

  testWidgets('arrastrar 200 dp apaga', (tester) async {
    final h = await pump(tester);
    await tester.drag(find.byKey(const ValueKey('sun')), const Offset(0, -200));
    await tester.pump();
    expect(calls, ['dismissSwipe']);
    h.dispose();
  });

  testWidgets('arrastrar 100 dp no apaga y el sol vuelve', (tester) async {
    final h = await pump(tester);
    await tester.drag(find.byKey(const ValueKey('sun')), const Offset(0, -100));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 1));
    expect(calls, isEmpty);
    final t = tester.widget<Transform>(
      find
          .descendant(
            of: find.byKey(const ValueKey('sun')),
            matching: find.byType(Transform),
          )
          .first,
    );
    expect(t.transform.getTranslation().y.abs(), lessThan(1));
    h.dispose();
  });

  testWidgets('tocar «Un ratito más» llama a snooze', (tester) async {
    final h = await pump(tester);
    await tester.tap(find.byType(OutlinedButton));
    expect(calls, ['snooze']);
    expect(find.textContaining('Quedan 3', findRichText: true), findsOneWidget);
    h.dispose();
  });

  testWidgets('sin posposiciones no hay botón', (tester) async {
    final h = await pump(tester, snoozes: 0);
    expect(find.byType(OutlinedButton), findsNothing);
    expect(find.text('Ya no quedan más ratitos'), findsOneWidget);
    h.dispose();
  });

  testWidgets('acción semántica «Apagar alarma»', (tester) async {
    final h = await pump(tester);
    final node = tester.getSemantics(find.bySemanticsLabel('Apagar alarma'));
    expect(node.getSemanticsData().customSemanticsActionIds, isNotEmpty);
    expect(find.bySemanticsLabel('Apagar alarma'), findsOneWidget);
    h.dispose();
  });
}
