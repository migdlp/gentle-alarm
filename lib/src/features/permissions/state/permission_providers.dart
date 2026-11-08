import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_alarm/src/core/platform/system_channel.dart';
import 'package:gentle_alarm/src/features/permissions/domain/permission_status.dart';

/// Estado de los permisos críticos; se invalida al volver a primer plano.
final permissionStatusProvider = FutureProvider.autoDispose<PermissionStatus>((
  ref,
) {
  final listener = AppLifecycleListener(onResume: ref.invalidateSelf);
  ref.onDispose(listener.dispose);
  return ref.watch(systemChannelProvider).getPermissionStatus();
});
