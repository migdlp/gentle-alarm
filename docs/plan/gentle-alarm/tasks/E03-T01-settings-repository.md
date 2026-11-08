---
id: E03-T01
title: SettingsRepository con valores por defecto de alarmas
epic: E03
status: done
depends_on: [E02-T07]
requirements: [RF-08]
size: S
---

# E03-T01 · SettingsRepository con valores por defecto de alarmas

## Objetivo
Los valores por defecto de las alarmas nuevas y la marca de onboarding se leen y guardan en `shared_preferences` mediante `SettingsRepository` y sus providers.

## Contexto
Claves (`02-architecture.md` §3.3): `defaults.sunriseMinutes` (20), `defaults.rampMinutes` (3), `defaults.maxVolumePercent` (70), `defaults.vibrate` (true), `defaults.soundId` (`birds_dawn`) y `onboarding.done` (false).
- `AlarmDefaults` ya existe en `lib/src/features/alarms/domain/alarm.dart` (E02-T07).
- Un valor guardado fuera de su conjunto permitido (p. ej. sunriseMinutes = 7) se ignora y se usa el default.

## Archivos
- Crear: `lib/src/features/settings/data/settings_repository.dart`, `lib/src/features/settings/state/settings_providers.dart` y `test/features/settings/settings_repository_test.dart`

## Pasos
1. RED: con `SharedPreferences.setMockInitialValues({})`: los defaults iniciales coinciden con la tabla; `saveDefaults` y una lectura posterior devuelven lo guardado; un valor inválido guardado a mano devuelve el default; y `onboardingDone`/`setOnboardingDone(true)`.
2. Implementa `class SettingsRepository { SettingsRepository(this._prefs); AlarmDefaults readDefaults(); Future<void> saveDefaults(AlarmDefaults d); bool get onboardingDone; Future<void> setOnboardingDone(bool v); }`.
3. Providers: `final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());` (se sobrescribe en `main.dart` tras `await SharedPreferences.getInstance()`), `final settingsRepositoryProvider` y `final alarmDefaultsProvider = NotifierProvider<AlarmDefaultsNotifier, AlarmDefaults>`, con `update(AlarmDefaults)` que guarda.
4. En `main.dart`: `WidgetsFlutterBinding.ensureInitialized(); final prefs = await SharedPreferences.getInstance(); runApp(ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)], child: const GentleAlarmApp()));`.
5. GREEN.

## Criterios de aceptación
- [x] Los 4 tests pasan.
- [x] `main.dart` inicializa las preferencias antes de `runApp`.

## Verificación
```bash
flutter analyze && flutter test test/features/settings
```

## Fuera de alcance
- Pantalla de ajustes (E03-T05) y ciudad del tiempo (E06).

## Si te bloqueas
- No uses `SharedPreferencesAsync` ni `SharedPreferencesWithCache`: usa `SharedPreferences.getInstance()`.

## Notas de implementación
- SettingsRepository + providers (sharedPreferencesProvider sobrescrito en main.dart). 4 tests OK.
