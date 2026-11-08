import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/src/features/permissions/domain/permission_status.dart';

void main() {
  test('fromMap y missing en orden', () {
    final s = PermissionStatus.fromMap({
      'notifications': false,
      'exactAlarms': true,
      'fullScreen': false,
      'sdkInt': 34,
      'manufacturer': 'Xiaomi',
    });
    expect(s.missing, [
      PermissionKind.notifications,
      PermissionKind.fullScreen,
    ]);
    expect(s.manufacturer, 'xiaomi');
    expect(s.sdkInt, 34);
  });

  test('allCritical es false si falta cualquiera', () {
    for (final m in [
      {'notifications': false, 'exactAlarms': true, 'fullScreen': true},
      {'notifications': true, 'exactAlarms': false, 'fullScreen': true},
      {'notifications': true, 'exactAlarms': true, 'fullScreen': false},
    ]) {
      expect(PermissionStatus.fromMap(m).allCritical, isFalse);
    }
    final ok = PermissionStatus.fromMap({
      'notifications': true,
      'exactAlarms': true,
      'fullScreen': true,
    });
    expect(ok.allCritical, isTrue);
    expect(ok.missing, isEmpty);
  });
}
