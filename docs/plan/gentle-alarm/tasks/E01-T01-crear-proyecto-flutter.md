---
id: E01-T01
title: Crear el proyecto Flutter con estructura, lints y README
epic: E01
status: todo
depends_on: []
requirements: [RNF-08, RNF-09]
size: S
---

# E01-T01 · Crear el proyecto Flutter con estructura, lints y README

## Objetivo
El repo contiene una app Flutter que compila para Android, con `applicationId` `com.migdlp.gentlealarm` y `minSdk 26`, y `flutter analyze`, `flutter test` y `./gradlew testDebugUnitTest` pasan en verde.

## Contexto
- Repo: `migdlp/gentle_alarm`. El plan vive en `docs/plan/gentle-alarm/` y no se toca.
- Stack (ADR-01, ADR-08): Flutter estable ≥ 3.35, Dart ≥ 3.9 y sólo Android en la v1.
- Dependencias Dart permitidas: `flutter_riverpod`, `shared_preferences`, `http`, `uuid`, `intl` y `flutter_localizations` (sdk). Desarrollo: `flutter_lints`, `mocktail` e `integration_test` (sdk).
- Dependencias Kotlin de prueba: `junit:junit:4.13.2` y `org.json:json:20240303`.

## Archivos
- Crear: los archivos que genera `flutter create` en la raíz del repo
- Modificar: `pubspec.yaml`, `analysis_options.yaml`, `android/app/build.gradle.kts` (o `build.gradle` si `flutter create` genera Groovy), `.gitignore` y `README.md`
- Crear: `test/smoke_test.dart` y `android/app/src/test/kotlin/com/migdlp/gentlealarm/SmokeTest.kt`
- No tocar: `docs/plan/`

## Pasos
1. En la raíz: `flutter create --org com.migdlp --project-name gentle_alarm --platforms android .`
2. Comprueba que `applicationId` y `namespace` valen `com.migdlp.gentlealarm` en `android/app/build.gradle.kts`. Fija `minSdk = 26`, `targetSdk = 35` y `compileSdk = 35`.
3. En `android/app/build.gradle.kts`, en `dependencies`: `testImplementation("junit:junit:4.13.2")` y `testImplementation("org.json:json:20240303")`.
4. Ejecuta `flutter pub add flutter_riverpod shared_preferences http uuid intl`, `flutter pub add flutter_localizations --sdk=flutter`, `flutter pub add --dev mocktail` y `flutter pub add --dev integration_test --sdk=flutter`. `flutter_lints` ya viene.
5. En `pubspec.yaml`: `environment: sdk: ">=3.9.0 <4.0.0"` y `flutter: generate: true`.
6. En `analysis_options.yaml`, incluye `package:flutter_lints/flutter.yaml` y añade bajo `linter.rules`: `prefer_const_constructors: true`, `prefer_single_quotes: true` y `always_declare_return_types: true`.
7. Sustituye `lib/main.dart` por una app mínima: `void main() => runApp(const ProviderScope(child: MaterialApp(home: Scaffold(body: Center(child: Text('Gentle Alarm'))))));` (texto provisional que retira E01-T03).
8. Borra `test/widget_test.dart` y crea `test/smoke_test.dart`, que monta la app y comprueba que existe un `Scaffold`.
9. Crea `SmokeTest.kt` con un test JUnit `fun smoke() { assertEquals(2, 1 + 1) }` para comprobar que el runner JVM funciona.
10. Añade a `.gitignore`: `android/key.properties`, `*.jks`, `*.keystore` y `graphify-out/`.
11. Reescribe `README.md` con: descripción (2 frases de `00-overview.md`), requisitos de instalación (Flutter, versión anotada de `flutter --version`, JDK 17 y Android SDK 35), comandos (`flutter pub get`, `flutter gen-l10n`, `flutter run`, `flutter test`, `cd android && ./gradlew testDebugUnitTest`) y un enlace a `docs/plan/gentle-alarm/README.md`.

## Criterios de aceptación
- [ ] `flutter analyze` sin avisos.
- [ ] `flutter test` pasa (1 test).
- [ ] `cd android && ./gradlew testDebugUnitTest` pasa (1 test).
- [ ] `flutter build apk --debug` genera el APK.
- [ ] El README contiene la versión exacta de Flutter usada.

## Verificación
```bash
flutter analyze && flutter test
(cd android && ./gradlew testDebugUnitTest)
flutter build apk --debug
```

## Fuera de alcance
- i18n (E01-T03), tema (E01-T04) y CI (E01-T02).

## Si te bloqueas
- Si `flutter create` genera Groovy (`build.gradle`), aplica los mismos valores con sintaxis Groovy y anótalo en «Notas de implementación».
