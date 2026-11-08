import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/src/features/onboarding/domain/onboarding_steps.dart';
import 'package:gentle_alarm/src/features/permissions/domain/permission_status.dart';

PermissionStatus st({
  bool n = true,
  bool e = true,
  bool f = true,
  String m = 'google',
}) => PermissionStatus(
  notifications: n,
  exactAlarms: e,
  fullScreen: f,
  manufacturer: m,
);

void main() {
  const k = OnboardingStepKind.values;
  test('todo concedido y Google: bienvenida y consejo', () {
    expect(buildSteps(st()), const [
      OnboardingStep(OnboardingStepKind.welcome),
      OnboardingStep(OnboardingStepKind.tip),
    ]);
  });

  test('falta pantalla completa y Xiaomi', () {
    expect(buildSteps(st(f: false, m: 'xiaomi')), const [
      OnboardingStep(OnboardingStepKind.welcome),
      OnboardingStep(OnboardingStepKind.fullScreen),
      OnboardingStep(OnboardingStepKind.battery, BatteryBrand.xiaomi),
      OnboardingStep(OnboardingStepKind.tip),
    ]);
  });

  test('marca en mayúsculas', () {
    expect(
      buildSteps(st(m: 'Samsung'))[1],
      const OnboardingStep(OnboardingStepKind.battery, BatteryBrand.samsung),
    );
  });

  test('orden con todo pendiente', () {
    expect(buildSteps(st(n: false, e: false, f: false)).map((s) => s.kind), [
      k[0],
      OnboardingStepKind.notifications,
      OnboardingStepKind.exactAlarms,
      OnboardingStepKind.fullScreen,
      OnboardingStepKind.tip,
    ]);
  });

  test('marcas agrupadas', () {
    expect(batteryBrandFor('redmi'), BatteryBrand.xiaomi);
    expect(batteryBrandFor('honor'), BatteryBrand.huawei);
    expect(batteryBrandFor('oneplus'), BatteryBrand.oppo);
    expect(batteryBrandFor('motorola'), isNull);
  });
}
