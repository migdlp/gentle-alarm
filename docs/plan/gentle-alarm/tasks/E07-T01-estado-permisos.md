---
id: E07-T01
title: Estado de permisos y accesos a sus ajustes desde Dart
epic: E07
status: todo
depends_on: [E05-T02]
requirements: [RF-50]
size: S
---

# E07-T01 · Estado de permisos y accesos a sus ajustes desde Dart

## Objetivo
Dart puede consultar qué permisos críticos faltan, pedir el de notificaciones y abrir la pantalla de ajustes de cada uno.

## Contexto
- Métodos nuevos en `gentle_alarm/system` (`02-architecture.md` §5.2): `getPermissionStatus` → `{notifications, exactAlarms, fullScreen, sdkInt, manufacturer}`; `requestNotificationPermission` → bool; `openNotificationSettings`; `openExactAlarmSettings`; `openFullScreenSettings`; `openBatterySettings`.
- Cálculo: `notifications` = `NotificationManagerCompat.from(ctx).areNotificationsEnabled()`; `exactAlarms` = `sdk < 31 || alarmManager.canScheduleExactAlarms()`; `fullScreen` = `sdk < 34 || notificationManager.canUseFullScreenIntent()`; `manufacturer` = `Build.MANUFACTURER.lowercase()`.
- `requestNotificationPermission`: en API 33+ usa `ActivityResultContracts.RequestPermission()` con `POST_NOTIFICATIONS` (registrado en `MainActivity`); en < 33 devuelve el valor actual.
- Dart: `PermissionStatus` (modelo) con `bool get allCritical => notifications && exactAlarms && fullScreen` y `List<PermissionKind> get missing` (orden: notifications, exactAlarms, fullScreen). `permissionStatusProvider = FutureProvider.autoDispose`, que se invalida en `AppLifecycleState.resumed`.

## Archivos
- Modificar: `android/app/src/main/kotlin/com/migdlp/gentlealarm/channel/SystemChannel.kt` y `MainActivity.kt`
- Crear: `lib/src/features/permissions/domain/permission_status.dart`, `lib/src/features/permissions/state/permission_providers.dart` y `test/features/permissions/permission_status_test.dart`
- Modificar: `lib/src/core/platform/system_channel.dart`

## Pasos
1. RED: `PermissionStatus.fromMap` y `missing` en el orden indicado; `allCritical` false si falta cualquiera.
2. Implementa Kotlin y Dart.
3. GREEN.
4. Manual en un emulador con API 34: revoca la pantalla completa en Ajustes → `getPermissionStatus().fullScreen == false`.

## Criterios de aceptación
- [ ] Las pruebas pasan.
- [ ] La prueba manual del paso 4 está anotada.

## Verificación
```bash
flutter analyze && flutter test test/features/permissions
flutter build apk --debug
```

## Fuera de alcance
- Interfaz del onboarding (E07-T02) y banner (E07-T03).

## Si te bloqueas
- Si `ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT` no existe en el SDK de compilación, usa la cadena literal `"android.settings.MANAGE_APP_USE_FULL_SCREEN_INTENT"`.
