---
id: E08-T01
title: Auditoría de accesibilidad (TalkBack, texto al 200 % y animaciones reducidas)
epic: E08
status: todo
depends_on: [E06-T03, E07-T03, E07-T04, E05-T02, E06-T02]
requirements: [RNF-04, RNF-05]
size: M
---

# E08-T01 · Auditoría de accesibilidad (TalkBack, texto al 200 % y animaciones reducidas)

## Objetivo
Todas las pantallas se pueden usar con TalkBack, con el texto al 200 % sin cortes y con las animaciones reducidas, y hay pruebas que lo protegen.

## Contexto
- Pantallas: lista, editor, selector de sonido, ajustes, búsqueda de ciudad, onboarding, amanecer, sonando, confirmación, pospuesta y saludo.
- Directrices: `meetsGuideline(androidTapTargetGuideline)`, `meetsGuideline(labeledTapTargetGuideline)` y `meetsGuideline(textContrastGuideline)` de `flutter_test`.
- Con `MediaQuery.disableAnimations` true: sin respiración del sol, con `AnimatedSwitcher` de 0 ms y el gradiente cambiando sin animación.
- Escalado: `MediaQuery(textScaler: TextScaler.linear(2.0))` sin `RenderFlex overflow`. Si algo desborda, se envuelve en `SingleChildScrollView` o se usa `FittedBox` en la hora grande.

## Archivos
- Crear: `test/a11y/a11y_guidelines_test.dart`
- Modificar: las pantallas listadas cuando una prueba falle (sólo para corregir el fallo)

## Pasos
1. RED: para cada pantalla (con providers simulados), un test que aplica las tres directrices y otro que monta con un `textScaler` de 2,0 y comprueba `tester.takeException()` == null. La vista de amanecer queda fuera de `textContrastGuideline` (hora al 10 % por diseño, RF-14).
2. Corrige cada fallo con el cambio mínimo.
3. GREEN.
4. Manual con TalkBack en el móvil: crear una alarma, posponer y apagar sin mirar la pantalla. Anota el resultado.

## Criterios de aceptación
- [ ] `a11y_guidelines_test.dart` pasa para las 11 pantallas.
- [ ] La prueba manual con TalkBack está anotada.

## Verificación
```bash
flutter analyze && flutter test test/a11y
```

## Fuera de alcance
- Rediseños visuales; sólo correcciones de accesibilidad.

## Si te bloqueas
- Si `textContrastGuideline` falla en un par de la paleta, no cambies el token: reporta el par (ya lo valida E01-T04).
