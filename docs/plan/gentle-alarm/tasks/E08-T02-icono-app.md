---
id: E08-T02
title: Icono adaptativo y monocromo de la app
epic: E08
status: todo
depends_on: [E01-T04]
requirements: [RF-90]
size: S
---

# E08-T02 · Icono adaptativo y monocromo de la app

## Objetivo
El launcher muestra el icono propio de la app (un sol medio asomando sobre el horizonte) en todas las versiones de Android, incluido el icono monocromo temático de Android 13+.

## Contexto
- PA-1: propuesta de icono, un semicírculo de sol en `coral` `#FF7A3D` asomando sobre una línea de horizonte en `honey` `#FFC872`, sobre un fondo `night` `#0B1026`. Mientras PA-1 no se cierre, se usa esta propuesta.
- Sin dependencias nuevas (no se usa `flutter_launcher_icons`): drawables vectoriales a mano.
- Zona segura del primer plano adaptativo: el contenido dentro del círculo central de 66 dp de un lienzo de 108 dp.

## Archivos
- Crear: `android/app/src/main/res/drawable/ic_launcher_foreground.xml` (vector de 108 dp: semicírculo de radio 22 dp con el centro en (54, 60) y una línea de horizonte de 44 dp de ancho y 3 dp de grosor en y = 60), `drawable/ic_launcher_monochrome.xml` (las mismas formas en `#FFFFFFFF`), `values/ic_launcher_background.xml` (`<color name="ic_launcher_background">#0B1026</color>`) y `mipmap-anydpi-v26/ic_launcher.xml` (`<adaptive-icon>` con background, foreground y monochrome)
- Modificar: borra los `mipmap-*/ic_launcher.png` generados por `flutter create` sólo después de comprobar que `mipmap-anydpi-v26` cubre minSdk 26 (lo cubre)

## Pasos
1. Crea los 4 recursos con las medidas del apartado Archivos.
2. `flutter build apk --debug` e instálalo.
3. Comprueba el icono en un emulador con API 26 y en uno con API 34 con «Iconos temáticos» activado. Haz capturas.

## Criterios de aceptación
- [ ] El icono se ve en API 26 y en API 34 (capturas en la PR).
- [ ] Con los iconos temáticos se ve la versión monocroma.

## Verificación
```bash
flutter build apk --debug && adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

## Fuera de alcance
- Icono de 512 px para la ficha de Play (E09-T03 lo exporta desde el mismo vector).

## Si te bloqueas
- Si el propietario aporta otro diseño en PA-1, sustituye los paths del vector sin cambiar los nombres de archivo.
