---
id: E01-T04
title: Tema claro/oscuro, paleta y tipografía Nunito
epic: E01
status: todo
depends_on: [E01-T03]
requirements: [RNF-05]
size: S
---

# E01-T04 · Tema claro/oscuro, paleta y tipografía Nunito

## Objetivo
La app usa un tema cálido claro u oscuro según el sistema, con la tipografía Nunito empaquetada, y una prueba garantiza un contraste ≥ 4,5:1 en los pares de texto.

## Contexto
Paleta (`02-architecture.md` §2.1):
`night #0B1026`, `nightDeep #05060F`, `dusk #2A1B3D`, `ember #3A0F1E`, `coral #FF7A3D`, `honey #FFC872`, `peach #FFB36B`, `cream #FFF4E0`, `inkOnDark #F5EBDD`, `inkOnLight #2B1A12`, `accent #E8693A`.
- Claro: fondo `cream`, superficie `#FFFFFF`, texto `inkOnLight`, primario `accent` con texto `inkOnLight`.
- Oscuro: fondo `night`, superficie `dusk`, texto `inkOnDark`, primario `coral` con texto `night`.
- Radio de bordes de 20 en tarjetas y botones. Botones de 56 dp de alto como mínimo.

## Archivos
- Crear: `lib/src/core/theme/palette.dart`, `lib/src/core/theme/app_theme.dart`, `lib/src/app.dart`, `test/core/theme/contrast_test.dart` y `assets/fonts/` (Nunito-Regular.ttf, Nunito-SemiBold.ttf, Nunito-Bold.ttf y OFL.txt)
- Modificar: `lib/main.dart` (usa `GentleAlarmApp` de `app.dart`) y `pubspec.yaml` (`fonts`)

## Pasos
1. RED: `contrast_test.dart` con una función `double contrastRatio(Color a, Color b)` (WCAG 2.1, luminancia relativa) que se importa de `palette.dart` y comprueba ≥ 4,5 en: `inkOnLight/cream`, `inkOnLight/white`, `inkOnDark/night`, `inkOnDark/dusk`, `inkOnLight/accent` y `night/coral`. Falla porque no existe `palette.dart`.
2. Crea `palette.dart` con `abstract final class Palette { static const night = Color(0xFF0B1026); /* resto de tokens */ }` y `contrastRatio`.
3. Descarga Nunito de `https://github.com/googlefonts/nunito` (carpeta `fonts/ttf`, pesos 400, 600 y 700) con su `OFL.txt` y declara `family: Nunito` en `pubspec.yaml` con `weight: 400/600/700`.
4. `app_theme.dart`: `ThemeData buildLightTheme()` y `ThemeData buildDarkTheme()` con `useMaterial3: true`, `fontFamily: 'Nunito'` y el `ColorScheme` del contexto (`ColorScheme(brightness:, primary:, onPrimary:, secondary: honey, onSecondary: inkOnLight, error: Color(0xFFB3261E), onError: white, surface:, onSurface:)`), `filledButtonTheme` con `minimumSize: Size(64, 56)` y `RoundedRectangleBorder(borderRadius: 20)`, y `cardTheme` con un radio de 20.
5. `app.dart`: `class GentleAlarmApp extends StatelessWidget` con `MaterialApp(theme: buildLightTheme(), darkTheme: buildDarkTheme(), themeMode: ThemeMode.system, ...l10n de E01-T03)`.
6. GREEN y ejecuta todas las pruebas.

## Criterios de aceptación
- [ ] `contrast_test.dart` pasa con los 6 pares.
- [ ] La app se ve en Nunito, en claro y en oscuro según el sistema (captura de cada modo en la PR).

## Verificación
```bash
flutter analyze && flutter test
```

## Fuera de alcance
- Pantallas reales y paleta del amanecer (E04-T06).

## Si te bloqueas
- Si un par no llega a 4,5, no cambies el token: para y reporta el par y la ratio.
