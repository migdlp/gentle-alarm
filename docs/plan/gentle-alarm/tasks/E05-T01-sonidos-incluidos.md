---
id: E05-T01
title: Seis sonidos CC0 incluidos y catálogo de sonidos
epic: E05
status: todo
depends_on: [E01-T03]
requirements: [RF-60]
size: M
---

# E05-T01 · Seis sonidos CC0 incluidos y catálogo de sonidos

## Objetivo
La app incluye 6 sonidos suaves con licencia CC0 en `res/raw`, con su procedencia documentada, y un catálogo Dart que da el nombre visible de cada sonido.

## Contexto
- ADR-12: OGG Vorbis, 44,1 kHz, estéreo, 96-128 kbps, ≤ 1,5 MB por archivo, 45-120 s de duración y bucle sin corte audible (con un fundido cruzado de 2 s entre el final y el inicio hecho al editar).
- SUPUESTO-2: los archivos salen de Freesound.org filtrando por licencia «Creative Commons 0». Requisitos de elección: sin voces, sin golpes bruscos, con un pico ≤ −3 dBFS y un comienzo suave (los 2 primeros segundos con un fundido de entrada).
| id | Nombre es | Nombre en | Búsqueda sugerida en Freesound |
|---|---|---|---|
| `birds_dawn` | Pájaros al alba | Dawn birds | `dawn chorus birds` |
| `soft_waves` | Olas suaves | Soft waves | `gentle waves shore` |
| `light_rain` | Lluvia ligera | Light rain | `light rain ambience` |
| `chimes` | Campanillas | Chimes | `wind chimes soft` |
| `calm_piano` | Piano tranquilo | Calm piano | `soft piano loop` |
| `singing_bowls` | Cuencos | Singing bowls | `singing bowl` |
- Claves ARB: `soundBirdsDawn`, `soundSoftWaves`, `soundLightRain`, `soundChimes`, `soundCalmPiano`, `soundSingingBowls` y `soundCustom` («De mi móvil: {name}» / «From my phone: {name}»).

## Archivos
- Crear: `android/app/src/main/res/raw/birds_dawn.ogg`, `soft_waves.ogg`, `light_rain.ogg`, `chimes.ogg`, `calm_piano.ogg` y `singing_bowls.ogg`; `assets/sounds/LICENSES.md`; `lib/src/features/sounds/domain/sound_catalog.dart` y `test/features/sounds/sound_catalog_test.dart`
- Crear: `android/app/src/main/res/raw/keep.xml` con `<resources xmlns:tools="http://schemas.android.com/tools" tools:keep="@raw/*"/>` (evita que el reductor de recursos los elimine)
- Modificar: los dos ARB

## Pasos
1. RED `sound_catalog_test.dart`: `SoundCatalog.builtInIds` tiene los 6 ids en el orden de la tabla; `SoundCatalog.label(l10nEs, 'chimes', null) == 'Campanillas'`; `label(l10nEs, 'custom', 'mi.mp3') == 'De mi móvil: mi.mp3'`; y un id desconocido devuelve la etiqueta de `birds_dawn`.
2. Implementa `abstract final class SoundCatalog { static const builtInIds = [/* 6 */]; static const defaultId = 'birds_dawn'; static String label(AppLocalizations l10n, String id, String? customName); }`.
3. GREEN.
4. Descarga y edita los 6 sonidos con `ffmpeg`: `ffmpeg -i in.wav -af "afade=t=in:d=2,loudnorm=I=-20:TP=-3" -ac 2 -ar 44100 -c:a libvorbis -q:a 4 out.ogg`. Recorta a 45-120 s.
5. `LICENSES.md`: por archivo, el título original, el autor, la URL de Freesound, la licencia «CC0 1.0» y la fecha de descarga.
6. Escucha cada uno en bucle en el móvil con un reproductor de audio que permita el bucle y anota en la tarea que no hay corte audible.

## Criterios de aceptación
- [ ] La prueba del catálogo pasa.
- [ ] Los 6 archivos existen, cada uno ≤ 1,5 MB, y `LICENSES.md` tiene 6 entradas CC0 con URL.
- [ ] El propietario ha escuchado y aprobado los 6 (anotado en la PR).

## Verificación
```bash
flutter gen-l10n && flutter test test/features/sounds
ls -la android/app/src/main/res/raw/
```

## Fuera de alcance
- Selector y vista previa (E05-T02).

## Si te bloqueas
- Si un sonido no tiene un candidato CC0 que cumpla los requisitos, para y pide al propietario un archivo; no uses CC-BY ni otras licencias.
