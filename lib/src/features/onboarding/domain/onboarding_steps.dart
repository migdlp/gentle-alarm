import 'package:gentle_alarm/src/features/permissions/domain/permission_status.dart';

enum OnboardingStepKind {
  welcome,
  notifications,
  exactAlarms,
  fullScreen,
  battery,
  tip,
}

enum BatteryBrand { xiaomi, huawei, oppo, vivo, samsung }

class OnboardingStep {
  const OnboardingStep(this.kind, [this.brand]);

  final OnboardingStepKind kind;
  final BatteryBrand? brand;

  @override
  bool operator ==(Object other) =>
      other is OnboardingStep && other.kind == kind && other.brand == brand;

  @override
  int get hashCode => Object.hash(kind, brand);

  @override
  String toString() =>
      'OnboardingStep($kind${brand == null ? '' : ', $brand'})';
}

BatteryBrand? batteryBrandFor(String manufacturer) =>
    switch (manufacturer.toLowerCase()) {
      'xiaomi' || 'redmi' || 'poco' => BatteryBrand.xiaomi,
      'huawei' || 'honor' => BatteryBrand.huawei,
      'oppo' || 'realme' || 'oneplus' => BatteryBrand.oppo,
      'vivo' => BatteryBrand.vivo,
      'samsung' => BatteryBrand.samsung,
      _ => null,
    };

List<OnboardingStep> buildSteps(PermissionStatus s) {
  final brand = batteryBrandFor(s.manufacturer);
  return [
    const OnboardingStep(OnboardingStepKind.welcome),
    if (!s.notifications)
      const OnboardingStep(OnboardingStepKind.notifications),
    if (!s.exactAlarms) const OnboardingStep(OnboardingStepKind.exactAlarms),
    if (!s.fullScreen) const OnboardingStep(OnboardingStepKind.fullScreen),
    if (brand != null) OnboardingStep(OnboardingStepKind.battery, brand),
    const OnboardingStep(OnboardingStepKind.tip),
  ];
}
