---
id: E07-T02
title: Onboarding de primer arranque con permisos, guía de batería y consejo
epic: E07
status: todo
depends_on: [E07-T01, E03-T02]
requirements: [RF-50, RF-53]
size: M
---

# E07-T02 · Onboarding de primer arranque con permisos, guía de batería y consejo

## Objetivo
En el primer arranque se muestran, por orden, la bienvenida, los permisos que falten, la guía de batería (sólo en las marcas de la lista) y el consejo de la mesilla, y después se llega a la lista de alarmas.

## Contexto
- `onboardingDone` (E03-T01): si es false, `app.dart` abre `OnboardingScreen` en lugar de la lista. Al terminar → `setOnboardingDone(true)` y `pushReplacement` a la lista.
- Pasos (`PageView` sin deslizamiento manual; botones abajo):
  1. Bienvenida: `appTagline`, `onbWelcomeBody` y el botón `onbStart`.
  2. Notificaciones (sólo si faltan): `onbNotifTitle`, `onbNotifBody`, botón `onbAllow` → `requestNotificationPermission`. Botón secundario `onbLater`.
  3. Alarmas exactas (sólo si faltan, API 31-32): `onbExactTitle`, `onbExactBody`, `onbOpenSettings` → `openExactAlarmSettings`.
  4. Pantalla completa (sólo si falta, API 34+): `onbFullTitle`, `onbFullBody`, `onbOpenSettings` → `openFullScreenSettings`.
  5. Batería (sólo si `manufacturer` ∈ {xiaomi, redmi, poco, huawei, honor, oppo, realme, vivo, oneplus, samsung}): `onbBatteryTitle`, el cuerpo de su marca y `onbOpenSettings` → `openBatterySettings`.
  6. Consejo: `onbTipTitle`, `onbTipBody` y `onbDone`.
- Al volver de los ajustes del sistema se vuelve a leer el estado y, si ya está concedido, se avanza solo.
- Textos (es / en):
  - `onbWelcomeBody`: «Te despertaremos poco a poco: primero la luz y luego un sonido suave.» / «We'll wake you gently: light first, then a soft sound.»
  - `onbStart`: «Empezar» / «Let's start»
  - `onbNotifTitle`: «Avisos de alarma» / «Alarm notifications»
  - `onbNotifBody`: «Las necesitamos para mostrar la alarma y poder apagarla desde la pantalla de bloqueo.» / «We need them to show the alarm and let you turn it off from the lock screen.»
  - `onbAllow`: «Permitir» / «Allow»
  - `onbLater`: «Ahora no» / «Not now»
  - `onbExactTitle`: «Alarmas puntuales» / «On-time alarms»
  - `onbExactBody`: «Activa «Alarmas y recordatorios» para que suene justo a su hora.» / «Turn on "Alarms & reminders" so it rings right on time.»
  - `onbFullTitle`: «Amanecer en pantalla completa» / «Full-screen sunrise»
  - `onbFullBody`: «Permite la pantalla completa para que el amanecer aparezca aunque el móvil esté bloqueado.» / «Allow full screen so the sunrise appears even when your phone is locked.»
  - `onbOpenSettings`: «Abrir ajustes» / «Open settings»
  - `onbBatteryTitle`: «Que nada apague tu alarma» / «Don't let anything stop your alarm»
  - `onbBatteryXiaomi` (xiaomi, redmi, poco): «En Ajustes → Batería, elige «Sin restricciones» y activa «Inicio automático».» / «In Settings → Battery, choose "No restrictions" and turn on "Autostart".»
  - `onbBatteryHuawei` (huawei, honor): «En Ajustes → Batería → Inicio de aplicaciones, desactiva «Gestionar automáticamente» y deja las tres opciones activadas.» / «In Settings → Battery → App launch, turn off "Manage automatically" and leave everything on.»
  - `onbBatteryOppo` (oppo, realme, oneplus): «En Ajustes → Batería, permite la actividad en segundo plano y el inicio automático.» / «In Settings → Battery, allow background activity and auto-launch.»
  - `onbBatteryVivo`: «En Ajustes → Batería → Consumo en segundo plano, permite el consumo alto.» / «In Settings → Battery → Background power consumption, allow high usage.»
  - `onbBatterySamsung`: «En Ajustes → Batería → Límites de uso en segundo plano, añade la app a «Nunca en suspensión».» / «In Settings → Battery → Background usage limits, add the app to "Never sleeping apps".»
  - `onbTipTitle`: «Un consejo para esta noche» / «A tip for tonight»
  - `onbTipBody`: «Deja el móvil boca arriba y cargando en la mesilla para ver el amanecer.» / «Leave your phone face up and charging on your nightstand to see the sunrise.»
  - `onbDone`: «Listo» / «Done»

## Archivos
- Crear: `lib/src/features/onboarding/ui/onboarding_screen.dart`, `lib/src/features/onboarding/domain/onboarding_steps.dart` (`List<OnboardingStep> buildSteps(PermissionStatus s)`) y `test/features/onboarding/onboarding_steps_test.dart` y `onboarding_screen_test.dart`
- Modificar: `lib/src/app.dart` y los dos ARB

## Pasos
1. RED `onboarding_steps_test.dart`: con todos los permisos concedidos y marca `google` → [welcome, tip]; falta fullScreen y marca `xiaomi` → [welcome, fullScreen, battery(xiaomi), tip]; marca `Samsung` (mayúsculas) → battery(samsung).
2. RED de widget: «Listo» guarda `onboarding.done = true` y navega a la lista.
3. Implementa.
4. GREEN.

## Criterios de aceptación
- [ ] Las pruebas pasan.
- [ ] Manual en un emulador limpio con API 34: se ven los pasos y, tras «Listo», no vuelven a aparecer.

## Verificación
```bash
flutter gen-l10n && flutter analyze && flutter test test/features/onboarding
```

## Fuera de alcance
- Banner en la lista (E07-T03).

## Si te bloqueas
- No pidas `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` (decisión en `02-architecture.md` §4).
