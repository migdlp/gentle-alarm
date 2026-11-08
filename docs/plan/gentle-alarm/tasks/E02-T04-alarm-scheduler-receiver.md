---
id: E02-T04
title: AlarmScheduler con setAlarmClock y AlarmReceiver
epic: E02
status: done
depends_on: [E02-T02, E02-T03]
requirements: [RF-40]
size: M
---

# E02-T04 · AlarmScheduler con setAlarmClock y AlarmReceiver

## Objetivo
Al llamar a `AlarmScheduler.reschedule(spec)`, se programa (o cancela) en AlarmManager la siguiente ocurrencia de esa alarma, se guarda `scheduledRingAtEpochMs` en el store y, al dispararse, `AlarmReceiver` recibe `alarmId` y `ringAtEpochMs`.

## Contexto
- ADR-05: `AlarmManager.setAlarmClock(AlarmClockInfo(fireAtEpochMs, showIntent), firePendingIntent)`. `showIntent` = `PendingIntent.getActivity` a `MainActivity`.
- Intent de disparo: acción `com.migdlp.gentlealarm.FIRE`, componente explícito `AlarmReceiver`, extras `alarmId` (String) y `ringAtEpochMs` (Long). Código de petición: `alarmId.hashCode()`. Flags: `FLAG_IMMUTABLE or FLAG_UPDATE_CURRENT`.
- Permisos (`02-architecture.md` §4): `USE_EXACT_ALARM`; `SCHEDULE_EXACT_ALARM` con `android:maxSdkVersion="32"`.
- En API 31-32, si `canScheduleExactAlarms()` es falso, se lanza `ScheduleFailedException` (el canal la traducirá a `SCHEDULE_FAILED`).
- En esta tarea `AlarmReceiver` sólo registra un log y delega en `RingLauncher.onFire(context, alarmId, ringAt)`, una interfaz cuyo stub inicial sólo escribe en Logcat. E04-T04 la implementa.

## Archivos
- Crear: `android/app/src/main/kotlin/com/migdlp/gentlealarm/alarm/AlarmScheduler.kt`, `alarm/AlarmReceiver.kt`, `alarm/RingLauncher.kt` y `android/app/src/test/kotlin/com/migdlp/gentlealarm/alarm/AlarmSchedulerTest.kt`
- Modificar: `android/app/src/main/AndroidManifest.xml`

## Pasos
1. Separa la lógica para poder probarla: `interface AlarmClockPort { fun set(fireAtMs: Long, alarmId: String, ringAtMs: Long); fun cancel(alarmId: String); fun canScheduleExact(): Boolean }`, con la implementación real `AndroidAlarmClockPort(context)` y una falsa en las pruebas.
2. RED: `AlarmSchedulerTest` con `InMemoryKeyValueStore`, `FakeAlarmClockPort` y `now`/`zone` fijos: (a) alarma activada → `set` llamado con el fireAt y el ringAt de `NextTriggerCalculator` y `scheduledRingAtEpochMs` guardado; (b) alarma desactivada → `cancel` y `scheduledRingAtEpochMs = null`; (c) `canScheduleExact = false` → `ScheduleFailedException` y nada guardado; (d) `rescheduleAll()` reprograma todas las activadas y cancela las desactivadas.
3. Implementa `class AlarmScheduler(store: AlarmStore, port: AlarmClockPort, clock: () -> Long, zone: () -> ZoneId)` con `fun reschedule(spec: AlarmSpec): AlarmSpec`, `fun cancel(alarmId: String)` y `fun rescheduleAll()`. `companion fun from(context)` con `System::currentTimeMillis` y `ZoneId::systemDefault`.
4. `AlarmReceiver : BroadcastReceiver` que, en `onReceive` con acción FIRE, llama a `RingLauncher.onFire`.
5. Manifest: permisos, `<receiver android:name=".alarm.AlarmReceiver" android:exported="false" android:directBootAware="true"/>`.
6. GREEN.

## Criterios de aceptación
- [x] Los 4 tests pasan.
- [x] El manifest declara `USE_EXACT_ALARM`, `SCHEDULE_EXACT_ALARM` (maxSdk 32) y `AlarmReceiver` no exportado y `directBootAware`.
- [x] La app compila. La comprobación con `adb shell dumpsys alarm` se hace en E02-T06, cuando ya existe un canal desde el que crear alarmas.

## Verificación
```bash
cd android && ./gradlew testDebugUnitTest --tests "*AlarmSchedulerTest*"
flutter build apk --debug
```

## Fuera de alcance
- Reprogramar tras un reinicio (E02-T05) e iniciar la sesión (E04-T04).

## Si te bloqueas
- No uses `setExactAndAllowWhileIdle`: ADR-05 fija `setAlarmClock`.

## Notas de implementación
- AlarmScheduler con AlarmClockPort (setAlarmClock, PendingIntent FLAG_IMMUTABLE|UPDATE_CURRENT con requestCode alarmId.hashCode()), AlarmReceiver y RingLauncher (stub con log). 4 tests OK; APK debug compila. Se retira synthetic-package de l10n.yaml (obsoleto en esta versión de Flutter). Pendiente manual: dumpsys alarm en E02-T06.
