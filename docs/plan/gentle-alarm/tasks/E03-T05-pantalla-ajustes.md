---
id: E03-T05
title: Pantalla de ajustes con valores por defecto y Acerca de
epic: E03
status: todo
depends_on: [E03-T01, E05-T01]
requirements: [RF-08]
size: S
---

# E03-T05 · Pantalla de ajustes con valores por defecto y Acerca de

## Objetivo
La pantalla Ajustes permite cambiar los valores por defecto de las alarmas nuevas y muestra la sección Acerca de con la versión y la atribución de Open-Meteo.

## Contexto
- `alarmDefaultsProvider` (E03-T01). Controles iguales que en el editor (E03-T03): amanecer, rampa, volumen máximo, vibración y sonido (fila no interactiva hasta E05-T02).
- Secciones: «Para alarmas nuevas», «Tiempo» (placeholder vacío; la fila de la ciudad la añade E06-T02) y «Acerca de» (`aboutVersion` con la versión de `PackageInfo`, que **no** se añade como dependencia: usa `const String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0')` y pasa `--dart-define=APP_VERSION=` en release; y `weatherAttribution`).
- Ruta: `'/settings'` desde el icono de la lista.
- Textos:
| Clave | es | en |
|---|---|---|
| `settingsTitle` | Ajustes | Settings |
| `forNewAlarms` | Para alarmas nuevas | For new alarms |
| `weatherSection` | Tiempo | Weather |
| `aboutSection` | Acerca de | About |
| `aboutVersion` | Versión {version} | Version {version} |
| `weatherAttribution` | Datos del tiempo: Open-Meteo.com | Weather data: Open-Meteo.com |

## Archivos
- Crear: `lib/src/features/settings/ui/settings_screen.dart` y `test/features/settings/settings_screen_test.dart`
- Modificar: `lib/src/app.dart` (ruta) y los dos ARB

## Pasos
1. RED: cambiar el amanecer a 30 → `alarmDefaultsProvider` vale 30 y está guardado en las preferencias simuladas; aparece el texto de atribución.
2. Implementa la pantalla con `ListView` y secciones con cabecera.
3. GREEN.

## Criterios de aceptación
- [ ] Las pruebas pasan.
- [ ] Una alarma nueva creada después usa los valores cambiados (prueba manual o de widget).

## Verificación
```bash
flutter gen-l10n && flutter analyze && flutter test
```

## Fuera de alcance
- Ciudad del tiempo (E06-T02) y selector de sonido (E05-T02).

## Si te bloqueas
- No añadas `package_info_plus`: usa `--dart-define` como se indica.
