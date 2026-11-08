import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/core/platform/system_channel.dart';
import 'package:gentle_alarm/src/core/widgets/scroll_body.dart';
import 'package:gentle_alarm/src/features/alarms/ui/alarm_list_screen.dart';
import 'package:gentle_alarm/src/features/onboarding/domain/onboarding_steps.dart';
import 'package:gentle_alarm/src/features/permissions/domain/permission_status.dart';
import 'package:gentle_alarm/src/features/permissions/state/permission_providers.dart';
import 'package:gentle_alarm/src/features/settings/state/settings_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  List<OnboardingStep>? _steps;
  int _index = 0;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _recheck);
    ref.read(permissionStatusProvider.future).then((s) {
      if (mounted) setState(() => _steps = buildSteps(s));
    });
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  bool _granted(OnboardingStepKind k, PermissionStatus s) => switch (k) {
    OnboardingStepKind.notifications => s.notifications,
    OnboardingStepKind.exactAlarms => s.exactAlarms,
    OnboardingStepKind.fullScreen => s.fullScreen,
    _ => false,
  };

  /// Al volver de los ajustes del sistema avanza solo si ya se concedió.
  Future<void> _recheck() async {
    final steps = _steps;
    if (steps == null) return;
    final s = await ref.read(systemChannelProvider).getPermissionStatus();
    if (!mounted) return;
    if (_granted(steps[_index].kind, s)) _next();
  }

  void _next() => setState(() {
    if (_index < _steps!.length - 1) _index++;
  });

  Future<void> _finish() async {
    await ref.read(settingsRepositoryProvider).setOnboardingDone(true);
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const AlarmListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps;
    if (steps == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final step = steps[_index];
    final l10n = AppLocalizations.of(context)!;
    final system = ref.read(systemChannelProvider);
    final isLast = _index == steps.length - 1;

    late final String title;
    late final String body;
    late final String primary;
    late final VoidCallback onPrimary;
    String? secondary;
    switch (step.kind) {
      case OnboardingStepKind.welcome:
        title = l10n.appTitle;
        body = '${l10n.appTagline}\n\n${l10n.onbWelcomeBody}';
        primary = l10n.onbStart;
        onPrimary = _next;
      case OnboardingStepKind.notifications:
        title = l10n.onbNotifTitle;
        body = l10n.onbNotifBody;
        primary = l10n.onbAllow;
        secondary = l10n.onbLater;
        onPrimary = () async {
          await system.requestNotificationPermission();
          if (mounted) _next();
        };
      case OnboardingStepKind.exactAlarms:
        title = l10n.onbExactTitle;
        body = l10n.onbExactBody;
        primary = l10n.onbOpenSettings;
        secondary = l10n.onbLater;
        onPrimary = system.openExactAlarmSettings;
      case OnboardingStepKind.fullScreen:
        title = l10n.onbFullTitle;
        body = l10n.onbFullBody;
        primary = l10n.onbOpenSettings;
        secondary = l10n.onbLater;
        onPrimary = system.openFullScreenSettings;
      case OnboardingStepKind.battery:
        title = l10n.onbBatteryTitle;
        body = switch (step.brand!) {
          BatteryBrand.xiaomi => l10n.onbBatteryXiaomi,
          BatteryBrand.huawei => l10n.onbBatteryHuawei,
          BatteryBrand.oppo => l10n.onbBatteryOppo,
          BatteryBrand.vivo => l10n.onbBatteryVivo,
          BatteryBrand.samsung => l10n.onbBatterySamsung,
        };
        primary = l10n.onbOpenSettings;
        secondary = l10n.onbLater;
        onPrimary = system.openBatterySettings;
      case OnboardingStepKind.tip:
        title = l10n.onbTipTitle;
        body = l10n.onbTipBody;
        primary = l10n.onbDone;
        onPrimary = _finish;
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ScrollBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                const Icon(
                  Icons.wb_twilight,
                  size: 96,
                  color: Color(0xFFFF7A3D),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                FilledButton(onPressed: onPrimary, child: Text(primary)),
                if (secondary != null)
                  TextButton(
                    onPressed: isLast ? _finish : _next,
                    child: Text(secondary),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
