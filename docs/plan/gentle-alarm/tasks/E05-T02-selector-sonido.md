---
id: E05-T02
title: Selector de sonido con escucha previa y archivo propio del móvil
epic: E05
status: todo
depends_on: [E05-T01, E03-T03, E03-T05, E04-T02]
requirements: [RF-61, RF-62]
size: M
---

# E05-T02 · Selector de sonido con escucha previa y archivo propio del móvil

## Objetivo
Desde el editor y desde Ajustes, la fila «Sonido» abre un selector donde se escucha cada sonido 10 s, se elige uno incluido o se elige un archivo del móvil con permiso persistente.

## Contexto
- Canal `gentle_alarm/system` (`02-architecture.md` §5.2). Esta tarea crea `SystemChannel.kt` con: `pickAudio` → `{uri, name}` o null; `previewSound({soundId, uri?})`; `stopPreviewSound`; y `canReadUri({uri})` → bool. E07-T01 añadirá los métodos de permisos al mismo archivo.
- `pickAudio`: `Intent(ACTION_OPEN_DOCUMENT).addCategory(CATEGORY_OPENABLE).setType("audio/*")` con `registerForActivityResult` en `MainActivity` (`ActivityResultContracts.OpenDocument()` con `arrayOf("audio/*")`). Al volver: `contentResolver.takePersistableUriPermission(uri, FLAG_GRANT_READ_URI_PERMISSION)`. El nombre sale de `OpenableColumns.DISPLAY_NAME`.
- `previewSound`: `MediaPlayer` con `USAGE_MEDIA` (no de alarma), volumen con un fundido de entrada de 0 a 1 en 1 s, se para a los 10 s o con `stopPreviewSound`. Si ya suena otro, se para antes. Los incluidos se resuelven con `SoundResolver` (E04-T02).
- `canReadUri`: abre `contentResolver.openFileDescriptor(uri, "r")` y lo cierra; true si no lanza excepción.
- Pantalla `SoundPickerScreen(selectedId, customUri, customName)` → devuelve `SoundChoice(id, uri?, name?)` con `Navigator.pop`. Lista de `RadioListTile` con los 6 incluidos, cada uno con un `IconButton` de play/stop, y al final una fila `pickFromPhone`. Al salir de la pantalla, `stopPreviewSound`.
- Textos:
| Clave | es | en |
|---|---|---|
| `soundPickerTitle` | Elige un sonido | Choose a sound |
| `pickFromPhone` | Elegir de mi móvil | Choose from my phone |
| `playPreviewA11y` | Escuchar {name} | Play {name} |
| `stopPreviewA11y` | Parar | Stop |

## Archivos
- Crear: `android/app/src/main/kotlin/com/migdlp/gentlealarm/channel/SystemChannel.kt`, `lib/src/core/platform/system_channel.dart`, `lib/src/features/sounds/ui/sound_picker_screen.dart` y `test/features/sounds/sound_picker_screen_test.dart`
- Modificar: `MainActivity.kt` (registro del canal y del lanzador de resultados), `alarm_editor_screen.dart` y `settings_screen.dart` (la fila «Sonido» abre el selector) y los dos ARB

## Pasos
1. RED: elegir «Campanillas» devuelve `SoundChoice('chimes')`; tocar play llama a `previewSound` con `soundId: 'chimes'` y vuelve a tocar llama a `stopPreviewSound`; `pickFromPhone` con un canal simulado que devuelve `{uri: 'content://a', name: 'a.mp3'}` devuelve `SoundChoice('custom', 'content://a', 'a.mp3')`; y cancelar (null) no cambia la selección.
2. Implementa Dart y Kotlin.
3. GREEN.
4. Manual: elegir una canción propia, reiniciar el móvil y comprobar que la alarma suena con esa canción (RF-62); borrar la canción y comprobar que suena «Pájaros al alba» (RF-27).

## Criterios de aceptación
- [ ] Las 4 pruebas pasan.
- [ ] Las pruebas manuales del paso 4 están anotadas.

## Verificación
```bash
flutter gen-l10n && flutter analyze && flutter test test/features/sounds
flutter build apk --debug
```

## Fuera de alcance
- Streaming (no-objetivo).

## Si te bloqueas
- Si `takePersistableUriPermission` lanza `SecurityException` con algún proveedor (p. ej. Google Drive sin copia local), devuelve `null` desde `pickAudio` y muestra el snackbar `errorGeneric`.
