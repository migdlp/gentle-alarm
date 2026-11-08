---
id: E09-T01
title: Prueba de integración de crear, editar y borrar alarma en emulador dentro de CI
epic: E09
status: todo
depends_on: [E03-T04, E01-T02, E07-T02]
requirements: [RNF-08, RNF-09]
size: M
---

# E09-T01 · Prueba de integración de crear, editar y borrar alarma en emulador dentro de CI

## Objetivo
Una prueba `integration_test` recorre en un emulador real el flujo de crear, editar y borrar una alarma contra el Kotlin real, y CI la ejecuta en API 34.

## Contexto
- Flujo: arrancar con `onboarding.done = true` (pon la marca con `(await SharedPreferences.getInstance()).setBool('onboarding.done', true)` antes de `runApp` en la prueba) → FAB → cambiar la hora con el selector a las 06:45 → guardar → ver «06:45» en la lista → abrirla → marcar L → guardar → ver «L» → deslizar para borrar → esperar 6 s → la lista vacía muestra `emptyTitle`.
- Comprobación nativa: tras guardar, `AlarmChannel().list()` devuelve una alarma con `scheduledRingAtEpochMs` no nulo.
- CI: un job `android-emulator` con `reactivecircus/android-emulator-runner@v2` (`api-level: 34`, `target: google_apis`, `arch: x86_64`) que ejecuta `flutter test integration_test`.

## Archivos
- Crear: `integration_test/alarm_crud_test.dart`
- Modificar: `.github/workflows/ci.yml`

## Pasos
1. Escribe la prueba (en este caso es la prueba la que verifica comportamiento ya implementado; RED = ejecutarla antes de ajustar los selectores y observar en qué falla).
2. Ejecútala en local con un emulador: `flutter test integration_test/alarm_crud_test.dart -d emulator-5554`.
3. Añade el job a `ci.yml` con `needs: flutter`.

## Criterios de aceptación
- [ ] La prueba pasa en local.
- [ ] El job `android-emulator` pasa en la PR.

## Verificación
```bash
flutter test integration_test/alarm_crud_test.dart -d emulator-5554
```

## Fuera de alcance
- Hacer sonar alarmas en CI (se verifica a mano en E09-T02).

## Si te bloqueas
- Si el selector de hora de Material es difícil de manejar, cambia al modo de entrada de texto con `tester.tap(find.byIcon(Icons.keyboard_outlined))` y escribe la hora.
