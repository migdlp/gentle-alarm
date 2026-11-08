import 'package:flutter/foundation.dart';

enum PermissionKind { notifications, exactAlarms, fullScreen }

@immutable
class PermissionStatus {
  const PermissionStatus({
    required this.notifications,
    required this.exactAlarms,
    required this.fullScreen,
    this.sdkInt = 0,
    this.manufacturer = '',
  });

  factory PermissionStatus.fromMap(Map<dynamic, dynamic> m) => PermissionStatus(
    notifications: m['notifications'] as bool? ?? false,
    exactAlarms: m['exactAlarms'] as bool? ?? false,
    fullScreen: m['fullScreen'] as bool? ?? false,
    sdkInt: m['sdkInt'] as int? ?? 0,
    manufacturer: (m['manufacturer'] as String? ?? '').toLowerCase(),
  );

  final bool notifications;
  final bool exactAlarms;
  final bool fullScreen;
  final int sdkInt;
  final String manufacturer;

  bool get allCritical => notifications && exactAlarms && fullScreen;

  List<PermissionKind> get missing => [
    if (!notifications) PermissionKind.notifications,
    if (!exactAlarms) PermissionKind.exactAlarms,
    if (!fullScreen) PermissionKind.fullScreen,
  ];

  @override
  bool operator ==(Object other) =>
      other is PermissionStatus &&
      other.notifications == notifications &&
      other.exactAlarms == exactAlarms &&
      other.fullScreen == fullScreen &&
      other.sdkInt == sdkInt &&
      other.manufacturer == manufacturer;

  @override
  int get hashCode =>
      Object.hash(notifications, exactAlarms, fullScreen, sdkInt, manufacturer);
}
