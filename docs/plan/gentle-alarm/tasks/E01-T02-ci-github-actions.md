---
id: E01-T02
title: Pipeline de CI en GitHub Actions
epic: E01
status: done
depends_on: [E01-T01]
requirements: [RNF-08]
size: S
---

# E01-T02 · Pipeline de CI en GitHub Actions

## Objetivo
Cada PR y cada push a `main` ejecuta formato, análisis, pruebas Dart, pruebas JVM de Kotlin y la compilación del APK de debug.

## Contexto
- Comandos del proyecto (`02-architecture.md` §8): `dart format --output=none --set-exit-if-changed .`, `flutter gen-l10n`, `flutter analyze`, `flutter test`, `./gradlew testDebugUnitTest` (en `android/`) y `flutter build apk --debug`.
- El job de integración con emulador lo añade E09-T01, no esta tarea.

## Archivos
- Crear: `.github/workflows/ci.yml`
- No tocar: código de la app

## Pasos
1. Crea `ci.yml` con `name: CI`, `on: pull_request` y `push` a `main`.
2. Job `flutter` en `ubuntu-latest`: `actions/checkout@v4`, `actions/setup-java@v4` (distribution `temurin`, java-version `17`), `subosito/flutter-action@v2` (channel `stable`, con la versión de Flutter del README en `flutter-version`, `cache: true`).
3. Pasos en orden: `flutter pub get`, `dart format --output=none --set-exit-if-changed .`, `flutter gen-l10n` (con `continue-on-error: false`; hasta E01-T03 no hay ARB, así que añade la condición `if: hashFiles('l10n.yaml') != ''`), `flutter analyze`, `flutter test`, `cd android && ./gradlew testDebugUnitTest` y `flutter build apk --debug`.
4. Añade `concurrency: group: ci-${{ github.ref }}, cancel-in-progress: true`.

## Criterios de aceptación
- [ ] La PR de esta tarea muestra el check `CI / flutter` en verde.
- [ ] Un error de formato introducido a propósito en una rama de prueba hace fallar el job (compruébalo y revierte el cambio).

## Verificación
```bash
# en local, los mismos pasos que el workflow:
dart format --output=none --set-exit-if-changed . && flutter analyze && flutter test
(cd android && ./gradlew testDebugUnitTest)
```
Manual: abre la PR y comprueba el check en GitHub.

## Fuera de alcance
- Job de emulador e `integration_test` (E09-T01) y firma de release.

## Si te bloqueas
- Si Gradle se queda sin memoria en CI, añade `org.gradle.jvmargs=-Xmx4g` en `android/gradle.properties` y anótalo.

## Notas de implementación
- Workflow creado en .github/workflows/ci.yml. Los pasos se ejecutaron en local con éxito. PENDIENTE: comprobar el check «CI / flutter» en GitHub y la prueba de fallo por formato (requieren ejecutar el workflow en remoto); por eso los criterios siguen sin marcar.
