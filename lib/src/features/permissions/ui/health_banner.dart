import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/core/platform/system_channel.dart';
import 'package:gentle_alarm/src/core/theme/palette.dart';
import 'package:gentle_alarm/src/features/permissions/domain/permission_status.dart';
import 'package:gentle_alarm/src/features/permissions/state/permission_providers.dart';

class HealthBanner extends ConsumerWidget {
  const HealthBanner({super.key});

  Future<void> _fix(WidgetRef ref, PermissionKind kind) async {
    final system = ref.read(systemChannelProvider);
    switch (kind) {
      case PermissionKind.notifications:
        final granted = await system.requestNotificationPermission();
        if (!granted) await system.openNotificationSettings();
      case PermissionKind.exactAlarms:
        await system.openExactAlarmSettings();
      case PermissionKind.fullScreen:
        await system.openFullScreenSettings();
    }
    ref.invalidate(permissionStatusProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(permissionStatusProvider);
    final s = status.value; // mantiene el último valor mientras recarga
    if (s == null || s.allCritical) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final first = s.missing.first;
    final message = switch (first) {
      PermissionKind.notifications => l10n.healthNotif,
      PermissionKind.exactAlarms => l10n.healthExact,
      PermissionKind.fullScreen => l10n.healthFull,
    };
    return MaterialBanner(
      backgroundColor: Palette.honey,
      contentTextStyle: const TextStyle(color: Palette.inkOnLight),
      leading: const Icon(Icons.wb_sunny_outlined, color: Palette.inkOnLight),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.healthTitle,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(message),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Palette.inkOnLight),
          onPressed: () => _fix(ref, first),
          child: Text(l10n.healthFix),
        ),
      ],
    );
  }
}
