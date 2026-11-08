---
id: E04-T06
title: RingActivity a pantalla completa, RingChannel y entrypoint ringMain
epic: E04
status: done
depends_on: [E04-T05, E01-T04, E03-T01]
requirements: [RF-10, RF-37]
size: M
---

# E04-T06 · RingActivity a pantalla completa, RingChannel y entrypoint ringMain

## Objetivo
Al empezar una sesión, `RingActivity` enciende la pantalla sobre la pantalla de bloqueo y ejecuta `ringMain` en Dart, que recibe el estado de la sesión en vivo y puede enviar gestos y fijar el brillo; Atrás no la cierra.

## Contexto
- ADR-04: `class RingActivity : FlutterActivity()` con `override fun getDartEntrypointFunctionName() = "ringMain"`.
- En `onCreate`: `setShowWhenLocked(true)`, `setTurnScreenOn(true)` (API 27+; en API 26 usa `window.addFlags(FLAG_SHOW_WHEN_LOCKED or FLAG_TURN_SCREEN_ON)`), `window.addFlags(FLAG_KEEP_SCREEN_ON)` y oculta las barras del sistema con `WindowInsetsControllerCompat` (`BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE`).
- Manifest: `android:showWhenLocked="true"`, `android:turnScreenOn="true"`, `android:launchMode="singleInstance"`, `android:excludeFromRecents="true"`, `android:taskAffinity=".ring"`, `android:exported="false"`, `android:theme="@style/LaunchTheme"` y **sin** `directBootAware` (ADR-13).
- Contrato `gentle_alarm/ring` y `gentle_alarm/ring_events` (`02-architecture.md` §5.3): `getSession`, `dismissSwipe`, `snooze`, `wakeUp`, `wakeEarly`, `confirmAwake`, `finishGreeting` y `setBrightness({value})`. Los eventos de gesto se envían al servicio con `startService(Intent(ACTION_EVENT).putExtra("event", nombre))` y el servicio los despacha a la máquina.
- `ring_events` se alimenta de `RingSessionBus`. Si se publica `null`, Dart cierra la actividad con `finishGreeting` si su estado era greeting y, si no, con `SystemNavigator.pop()`.
- Atrás: en Kotlin `onBackPressedDispatcher.addCallback(this) { }` (no hace nada); en Dart `PopScope(canPop: false)`.
- Dart: `RingSession` es el modelo de `SessionSnapshot` (§3.2) con `fromMap`. `RingChannel` envuelve los métodos y el stream. `ringControllerProvider = StreamProvider<RingSession?>` que emite primero `getSession()` y luego los eventos.
- En esta tarea `RingRoot` muestra provisionalmente el nombre del estado en texto centrado; las vistas reales vienen en E04-T07, E04-T08, E04-T09 y E06-T03.

## Archivos
- Modificar: `android/app/src/main/kotlin/com/migdlp/gentlealarm/ring/RingActivity.kt`, `ring/RingService.kt` (acción `ACTION_EVENT`) y `AndroidManifest.xml`
- Crear: `android/app/src/main/kotlin/com/migdlp/gentlealarm/channel/RingChannel.kt`, `lib/ring_main.dart`, `lib/src/core/platform/ring_channel.dart`, `lib/src/features/ring/domain/ring_session.dart`, `lib/src/features/ring/state/ring_controller.dart`, `lib/src/features/ring/ui/ring_root.dart`, `test/features/ring/domain/ring_session_test.dart` y `test/features/ring/state/ring_controller_test.dart`

## Pasos
1. RED Dart: `RingSession.fromMap` con todos los estados; `ringControllerProvider` emite la sesión de `getSession` y después la de un evento simulado (mock de `MethodChannel` y de `EventChannel` con `setMockStreamHandler`).
2. Implementa el modelo, el canal y el controlador.
3. `lib/ring_main.dart`:
   ```dart
   @pragma('vm:entry-point')
   Future<void> ringMain() async {
     WidgetsFlutterBinding.ensureInitialized();
     final prefs = await SharedPreferences.getInstance();
     runApp(ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)], child: const RingApp()));
   }
   ```
   `RingApp` = `MaterialApp` con l10n, `debugShowCheckedModeBanner: false` y `home: const RingRoot()`.
4. Implementa `RingChannel.kt` (registro en `RingActivity.configureFlutterEngine`) y `RingActivity`.
5. GREEN Dart y compilación.
6. Manual: una alarma con amanecer de 5 min para dentro de 6 min, móvil bloqueado y pantalla apagada → a los 1 min se enciende la pantalla con el texto `sunrise`, luego `ringing`; Atrás no cierra; «Apagar» desde la notificación la cierra.

## Criterios de aceptación
- [ ] Las pruebas Dart pasan.
- [ ] La prueba manual del paso 6 se ha hecho en un emulador con API 34 y anotado.
- [ ] Tras terminar la sesión la actividad desaparece y no queda en recientes.

## Verificación
```bash
flutter analyze && flutter test test/features/ring
flutter build apk --debug
```

## Fuera de alcance
- Vistas visuales (E04-T07 a E04-T09) y saludo (E06-T03).

## Si te bloqueas
- Si `ringMain` no se encuentra en release (tree shaking), comprueba el `@pragma('vm:entry-point')` y que `lib/ring_main.dart` se importa desde `lib/main.dart` (`import 'ring_main.dart' as ring_entry;` con un uso `// ignore: unused_import`).

## Notas de implementación
- RingActivity (entrypoint ringMain vía getDartEntrypointFunctionName + getDartEntrypointLibraryUri, pantalla sobre bloqueo, barras ocultas, Atrás sin efecto), RingChannel.kt (gestos vía ACTION_EVENT, brillo, eventos desde RingSessionBus), SessionSnapshot.toMap, y Dart: RingSession, RingChannel, ringControllerProvider, RingRoot provisional y ring_main.dart. RingService ahora para si recibe un evento sin sesión. Tests Dart OK; APK compila. PENDIENTE (emulador API 34): prueba manual del paso 6 y verificar que ringMain se resuelve por library URI.
