---
id: E07-T04
title: «Probar despertar», una vista previa de 60 s desde el editor
epic: E07
status: todo
depends_on: [E04-T09, E03-T03]
requirements: [RF-52]
size: S
---

# E07-T04 · «Probar despertar», una vista previa de 60 s desde el editor

## Objetivo
En el editor, «Probar despertar» lanza al momento una sesión de vista previa con la configuración que se está editando: 30 s de amanecer, sonido con una rampa de 30 s y posponer de 10 s.

## Contexto
- `RingTimings.preview()` existe (E04-T01): sunrise 30 s, ramp 30 s, snooze 10 s, confirm 10 s, vibración a 15 s, sin autoposponer y fin a los 90 s del primer Ringing.
- Método nuevo `startPreview(Map spec)` en `gentle_alarm/alarms` → `RingLauncher.startPreview(context, spec)`: si hay una sesión activa → error `SESSION_ACTIVE`; si no → `SessionConfig(alarmId = "preview", label, ringAtMs = now + 30 000, sunriseStartMs = now, vibrate, isPreview = true, skipSunrise = sunriseMinutes == 0)` dentro de un `RingRequest` (E04-T04) con el sonido y el volumen de la alarma en edición y `quietSunrise = false`, y arranca `RingService`, que usa `RingTimings.preview()`. La alarma no se guarda.
- `onSessionEnded` ya ignora `"preview"` (E04-T05).
- Botón en el editor: `OutlinedButton.icon(Icons.play_circle_outline, previewButton)` al final del formulario.
- Textos:
| Clave | es | en |
|---|---|---|
| `previewButton` | Probar despertar | Try the wake-up |
| `previewBusy` | Ya hay una alarma sonando. | An alarm is already ringing. |

## Archivos
- Modificar: `channel/AlarmChannelHandler.kt`, `channel/AlarmChannel.kt`, `alarm/RingLauncher.kt`, `lib/src/core/platform/alarm_channel.dart`, `alarm_repository.dart`, `alarm_editor_screen.dart` y los dos ARB
- Modificar: `AlarmChannelHandlerTest.kt` y `alarm_editor_screen_test.dart`

## Pasos
1. RED Kotlin: `startPreview` con una sesión activa (bus falso con una sesión) → `ChannelError("SESSION_ACTIVE")`; sin sesión → el lanzador falso recibe una config con `isPreview = true` y `ringAtMs = now + 30000`.
2. RED Dart: tocar `previewButton` llama a `startPreview` con el map de la alarma en edición; `SESSION_ACTIVE` → snackbar `previewBusy`.
3. Implementa.
4. GREEN.
5. Manual: probar con amanecer de 20 min → en 30 s pasa del negro al crema y empieza a sonar; posponer vuelve en 10 s.

## Criterios de aceptación
- [ ] Las pruebas pasan.
- [ ] La prueba manual está anotada.
- [ ] Tras la vista previa la lista de alarmas no ha cambiado.

## Verificación
```bash
cd android && ./gradlew testDebugUnitTest --tests "*AlarmChannelHandlerTest*"
flutter analyze && flutter test test/features/alarms
```

## Fuera de alcance
- Vista previa desde la lista.

## Si te bloqueas
- Si la vista previa necesita el permiso de pantalla completa y falta, la sesión sonará igual con la notificación: no lo bloquees.
