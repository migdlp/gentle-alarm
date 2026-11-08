import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/src/core/platform/alarm_channel.dart';
import 'package:gentle_alarm/src/features/alarms/data/alarm_repository.dart';
import 'package:gentle_alarm/src/features/alarms/domain/alarm.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('gentle_alarm/alarms');
  final repo = AlarmRepository(AlarmChannel());
  final alarm = Alarm(id: 'a', createdAtEpochMs: 1);
  MethodCall? last;

  void mock(Future<Object?> Function(MethodCall) h) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (c) {
          last = c;
          return h(c);
        });
  }

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('list decodifica', () async {
    mock((_) async => [alarm.toMap()]);
    expect(await repo.list(), [alarm]);
    expect(last!.method, 'listAlarms');
  });

  test('save envía el map y devuelve el resultado', () async {
    mock((c) async => {...(c.arguments as Map), 'scheduledRingAtEpochMs': 99});
    final saved = await repo.save(alarm);
    expect(last!.method, 'upsertAlarm');
    expect((last!.arguments as Map)['id'], 'a');
    expect(saved.scheduledRingAtEpochMs, 99);
  });

  test('delete, setEnabled y setSkipNext usan sus argumentos', () async {
    mock((c) async => c.method == 'deleteAlarm' ? null : alarm.toMap());
    await repo.delete('a');
    expect(last!.arguments, {'id': 'a'});
    await repo.setEnabled('a', false);
    expect(last!.arguments, {'id': 'a', 'enabled': false});
    await repo.setSkipNext('a', true);
    expect(last!.arguments, {'id': 'a', 'skip': true});
  });

  test('PlatformException se convierte en AlarmException', () async {
    mock(
      (_) async =>
          throw PlatformException(code: 'INVALID_SPEC', message: 'hour'),
    );
    await expectLater(
      repo.save(alarm),
      throwsA(
        isA<AlarmException>()
            .having((e) => e.code, 'code', 'INVALID_SPEC')
            .having((e) => e.field, 'field', 'hour'),
      ),
    );
  });
}
