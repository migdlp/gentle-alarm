import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/features/alarms/data/alarm_repository.dart';
import 'package:gentle_alarm/src/features/alarms/domain/alarm.dart';
import 'package:gentle_alarm/src/features/alarms/state/alarms_providers.dart';
import 'package:gentle_alarm/src/features/alarms/ui/alarm_list_screen.dart';
import 'package:gentle_alarm/src/features/alarms/ui/widgets/alarm_tile.dart';

class FakeRepo implements AlarmRepository {
  FakeRepo(this.alarms);
  List<Alarm> alarms;
  final calls = <String>[];

  @override
  Future<List<Alarm>> list() async => alarms;
  @override
  Future<Alarm> setEnabled(String id, bool enabled) async {
    calls.add('setEnabled($id,$enabled)');
    return alarms.firstWhere((a) => a.id == id).copyWith(enabled: enabled);
  }

  @override
  Future<Alarm> save(Alarm alarm) async => alarm;
  @override
  Future<void> delete(String id) async {}
  @override
  Future<Alarm> setSkipNext(String id, bool skip) async => alarms.first;
}

final _now = DateTime(2026, 11, 9, 22, 0);

Alarm _alarm(String id, int h, DateTime? at, {bool enabled = true}) => Alarm(
  id: id,
  hour: h,
  minute: 30,
  enabled: enabled,
  scheduledRingAtEpochMs: at?.millisecondsSinceEpoch,
  createdAtEpochMs: 0,
);

Future<void> _pump(WidgetTester tester, FakeRepo repo) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        alarmRepositoryProvider.overrideWithValue(repo),
        clockProvider.overrideWithValue(() => _now),
      ],
      child: const MaterialApp(
        locale: Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(alwaysUse24HourFormat: true),
          child: AlarmListScreen(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('estado vacío', (tester) async {
    await _pump(tester, FakeRepo([]));
    expect(find.text('Aún no tienes alarmas'), findsOneWidget);
    expect(find.text('Crear alarma'), findsOneWidget);
  });

  testWidgets('dos alarmas, cabecera y conmutador', (tester) async {
    final repo = FakeRepo([
      _alarm('a', 7, DateTime(2026, 11, 10, 7, 30)),
      _alarm('b', 9, DateTime(2026, 11, 10, 9, 30)),
    ]);
    await _pump(tester, repo);
    expect(find.byType(AlarmTile), findsNWidgets(2));
    expect(
      find.text('Próxima: mañana a las 7:30 (en 9 h 30 min)'),
      findsOneWidget,
    );
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    expect(repo.calls, ['setEnabled(a,false)']);
  });

  testWidgets('sin alarmas activadas', (tester) async {
    await _pump(tester, FakeRepo([_alarm('a', 7, null, enabled: false)]));
    expect(find.text('Ninguna alarma activada'), findsOneWidget);
  });

  testWidgets('hora en formato 12 h', (tester) async {
    final repo = FakeRepo([_alarm('a', 19, DateTime(2026, 11, 10, 19, 30))]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          alarmRepositoryProvider.overrideWithValue(repo),
          clockProvider.overrideWithValue(() => _now),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: MediaQueryData(alwaysUse24HourFormat: false),
            child: AlarmListScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('PM'), findsWidgets);
  });
}
