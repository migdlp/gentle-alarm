---
id: E01-T03
title: Internacionalización ES/EN con ARB y gen-l10n
epic: E01
status: todo
depends_on: [E01-T01]
requirements: [RNF-07]
size: S
---

# E01-T03 · Internacionalización ES/EN con ARB y gen-l10n

## Objetivo
La app muestra sus textos desde ARB en español (por defecto) o en inglés según el idioma del sistema, y el nombre visible de Android está localizado.

## Contexto
- ADR-11: `l10n.yaml` con `arb-dir: lib/l10n`, `template-arb-file: app_es.arb`, `output-dir: lib/l10n/gen` y `synthetic-package: false`.
- SUPUESTO-1: nombre visible «Despertar suave» (es) y «Gentle Alarm» (en).
- Cada tarea posterior añade sus claves a los dos ARB. En esta sólo se crean `appTitle` y `appTagline`.

## Archivos
- Crear: `l10n.yaml`, `lib/l10n/app_es.arb`, `lib/l10n/app_en.arb`, `test/l10n_test.dart`, `android/app/src/main/res/values/strings.xml` y `android/app/src/main/res/values-en/strings.xml`
- Modificar: `lib/main.dart` y `android/app/src/main/AndroidManifest.xml` (`android:label="@string/app_name"`)

## Pasos
1. RED: escribe `test/l10n_test.dart`, que monta la app con `locale: Locale('en')` y espera el texto `Gentle Alarm`, y con `Locale('es')` espera `Despertar suave`. Ejecútalo: falla.
2. Crea `l10n.yaml` con los valores de ADR-11.
3. `app_es.arb`: `"@@locale": "es"`, `"appTitle": "Despertar suave"` y `"appTagline": "Despierta con luz, no con sustos"`. `app_en.arb`: `"appTitle": "Gentle Alarm"` y `"appTagline": "Wake up with light, not with a fright"`.
4. `flutter gen-l10n`. En `lib/main.dart`, en `MaterialApp`: `localizationsDelegates: AppLocalizations.localizationsDelegates`, `supportedLocales: AppLocalizations.supportedLocales` y `onGenerateTitle: (c) => AppLocalizations.of(c)!.appTitle`. El cuerpo muestra `appTitle`.
5. `strings.xml`: `<string name="app_name">Despertar suave</string>` (values) y `Gentle Alarm` (values-en).
6. Actualiza `test/smoke_test.dart` si dependía del texto provisional.
7. GREEN: `flutter test`.

## Criterios de aceptación
- [ ] `test/l10n_test.dart` pasa con los dos idiomas.
- [ ] Con el emulador en inglés, el launcher muestra «Gentle Alarm», y en español «Despertar suave».
- [ ] No queda ningún texto visible fijo en `lib/`.

## Verificación
```bash
flutter gen-l10n && flutter analyze && flutter test
```

## Fuera de alcance
- Textos de pantallas concretas (los añade cada tarea).

## Si te bloqueas
- Si `synthetic-package` da un aviso de obsolescencia en tu versión de Flutter, elimina esa línea y deja `output-dir`, y anótalo.
