import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/features/alarms/data/alarm_repository.dart';
import 'package:gentle_alarm/src/features/alarms/domain/alarm.dart';
import 'package:gentle_alarm/src/features/alarms/state/alarms_providers.dart';
import 'package:gentle_alarm/src/features/alarms/ui/alarm_editor_screen.dart';
import 'package:gentle_alarm/src/features/settings/state/settings_providers.dart';

class FakeRepo implements AlarmRepository {
  FakeRepo({this.fail, this.previewFail});
  final AlarmException? fail;
  final AlarmException? previewFail;
  final previews = <Alarm>[];
  final saved = <Alarm>[];

  @override
  Future<List<Alarm>> list() async => const [];
  @override
  Future<Alarm> save(Alarm alarm) async {
    if (fail != null) throw fail!;
    saved.add(alarm);
    return alarm.copyWith(
      scheduledRingAtEpochMs: DateTime(
        2026,
        11,
        10,
        7,
        30,
      ).millisecondsSinceEpoch,
    );
  }

  @override
  Future<void> startPreview(Alarm alarm) async {
    if (previewFail != null) throw previewFail!;
    previews.add(alarm);
  }

  @override
  Future<void> delete(String id) async {}
  @override
  Future<Alarm> setEnabled(String id, bool enabled) async =>
      throw UnimplementedError();
  @override
  Future<Alarm> setSkipNext(String id, bool skip) async =>
      throw UnimplementedError();
}

Future<void> _open(
  WidgetTester tester,
  FakeRepo repo, {
  AlarmDefaults defaults = const AlarmDefaults(),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        alarmRepositoryProvider.overrideWithValue(repo),
        alarmDefaultsProvider.overrideWith(() => _Defaults(defaults)),
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 9, 22, 0)),
      ],
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (c) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(c).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AlarmEditorScreen(),
                ),
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}

Future<void> _scrollTo(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(
    find.text(text),
    300,
    scrollable: find
        .descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        )
        .first,
  );
}

Future<void> _save(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.text('Guardar'),
    300,
    scrollable: find
        .descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.tap(find.text('Guardar'));
}

class _Defaults extends AlarmDefaultsNotifier {
  _Defaults(this.d);
  final AlarmDefaults d;
  @override
  AlarmDefaults build() => d;
}

void main() {
  testWidgets('muestra los valores por defecto', (tester) async {
    await _open(
      tester,
      FakeRepo(),
      defaults: const AlarmDefaults(sunriseMinutes: 10),
    );
    final chip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, '10 min').first,
    );
    expect(chip.selected, isTrue);
  });

  testWidgets('marcar L y X envía weekdays [1, 3]', (tester) async {
    final repo = FakeRepo();
    await _open(tester, repo);
    await tester.tap(find.byKey(const ValueKey('day1')));
    await tester.tap(find.byKey(const ValueKey('day3')));
    await tester.pump();
    await _save(tester);
    await tester.pumpAndSettle();
    expect(repo.saved.single.weekdays, [1, 3]);
    expect(find.text('Sonará en 9 h 30 min'), findsOneWidget);
  });

  testWidgets('la etiqueta se guarda con trim', (tester) async {
    final repo = FakeRepo();
    await _open(tester, repo);
    await tester.enterText(find.byType(TextField), '  Gym  ');
    await tester.pumpAndSettle();
    await _save(tester);
    await tester.pumpAndSettle();
    expect(repo.saved.single.label, 'Gym');
  });

  testWidgets('Atrás con cambios pide confirmación', (tester) async {
    await _open(tester, FakeRepo());
    await tester.tap(find.byKey(const ValueKey('day2')));
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('¿Descartar los cambios?'), findsOneWidget);
    await tester.tap(find.text('Descartar'));
    await tester.pumpAndSettle();
    expect(find.byType(AlarmEditorScreen), findsNothing);
  });

  testWidgets('SCHEDULE_FAILED muestra el error y no sale', (tester) async {
    await _open(
      tester,
      FakeRepo(fail: const AlarmException(code: 'SCHEDULE_FAILED')),
    );
    await _save(tester);
    await tester.pumpAndSettle();
    expect(find.textContaining('No hemos podido programar'), findsOneWidget);
    expect(find.byType(AlarmEditorScreen), findsOneWidget);
  });

  testWidgets('Probar despertar envía la alarma en edición', (tester) async {
    final repo = FakeRepo();
    await _open(tester, repo);
    await tester.tap(find.byKey(const ValueKey('day1')));
    await tester.pump();
    await _scrollTo(tester, 'Probar despertar');
    await tester.tap(find.text('Probar despertar'));
    await tester.pumpAndSettle();
    expect(repo.previews.single.weekdays, [1]);
    expect(repo.saved, isEmpty);
  });

  testWidgets('SESSION_ACTIVE muestra previewBusy', (tester) async {
    final repo = FakeRepo(
      previewFail: const AlarmException(code: 'SESSION_ACTIVE'),
    );
    await _open(tester, repo);
    await _scrollTo(tester, 'Probar despertar');
    await tester.tap(find.text('Probar despertar'));
    await tester.pumpAndSettle();
    expect(find.text('Ya hay una alarma sonando.'), findsOneWidget);
  });
}
