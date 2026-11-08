---
id: E07-T03
title: Banner «Tu alarma podría no sonar» en la lista
epic: E07
status: done
depends_on: [E07-T02]
requirements: [RF-51]
size: S
---

# E07-T03 · Banner «Tu alarma podría no sonar» en la lista

## Objetivo
Si falta un permiso crítico, la lista de alarmas muestra un banner amable con el botón «Arreglarlo», que lleva al ajuste del primer permiso que falte.

## Contexto
- `permissionStatusProvider` (E07-T01), que se refresca al volver a primer plano.
- `MaterialBanner` incrustado arriba de la lista (no el global de `ScaffoldMessenger`), fondo `honey` y texto `inkOnLight`, con el icono `Icons.wb_sunny_outlined`.
- «Arreglarlo»: según `missing.first` → `requestNotificationPermission` (si se deniega, `openNotificationSettings`), `openExactAlarmSettings` u `openFullScreenSettings`.
- Textos:
| Clave | es | en |
|---|---|---|
| `healthTitle` | Tu alarma podría no sonar | Your alarm might not ring |
| `healthNotif` | Faltan los avisos de alarma. | Alarm notifications are off. |
| `healthExact` | Faltan las alarmas puntuales. | On-time alarms are off. |
| `healthFull` | Falta la pantalla completa para el amanecer. | Full screen for the sunrise is off. |
| `healthFix` | Arreglarlo | Fix it |

## Archivos
- Crear: `lib/src/features/permissions/ui/health_banner.dart` y `test/features/permissions/health_banner_test.dart`
- Modificar: `alarm_list_screen.dart` y los dos ARB

## Pasos
1. RED: con todos los permisos concedidos no hay banner; sin fullScreen → banner con `healthFull` y, al tocar `healthFix`, se llama a `openFullScreenSettings`; sin notificaciones ni fullScreen → muestra `healthNotif` (el primero).
2. Implementa.
3. GREEN.

## Criterios de aceptación
- [x] Las 3 pruebas pasan.

## Verificación
```bash
flutter gen-l10n && flutter analyze && flutter test test/features/permissions
```

## Fuera de alcance
- Comprobar la batería (no hay API fiable; la guía va en el onboarding).

## Si te bloqueas
- Si el banner parpadea al volver de Ajustes, mantén el último valor mientras recarga (`AsyncValue` con `skipLoadingOnReload: true`).

## Notas de implementación
- HealthBanner (MaterialBanner incrustado en la lista, mantiene el último valor al recargar) con acción según el primer permiso que falta; 3 tests OK.
