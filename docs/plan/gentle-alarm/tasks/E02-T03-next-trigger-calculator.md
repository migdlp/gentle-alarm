---
id: E02-T03
title: NextTriggerCalculator con recurrencia, salto y horario de verano
epic: E02
status: todo
depends_on: [E02-T01]
requirements: [RF-43, RF-12, RF-07]
size: M
---

# E02-T03 · NextTriggerCalculator con recurrencia, salto y horario de verano

## Objetivo
Una función pura calcula, para una `AlarmSpec` y un instante, la T de la siguiente ocurrencia y el instante de inicio del amanecer, cubriendo días de la semana, salto de ocurrencia y cambios de horario.

## Contexto
- RF-43: hora local + días; en el salto de primavera (Europe/Madrid, último domingo de marzo, 02:00 → 03:00), 02:30 suena a las 03:30; en el retroceso de otoño (03:00 → 02:00), 02:30 suena en la primera aparición (offset +02:00).
- `ZonedDateTime.of(localDateTime, zone)` ya resuelve así: hueco → desplaza la duración del hueco; solapamiento → offset anterior. Úsalo.
- RF-07: si `skipRingAtEpochMs` coincide con la T candidata, se salta a la siguiente.
- RF-12: inicio del amanecer = max(T − sunriseMinutes, now). Si T − now < 60 000 ms, no hay amanecer (inicio = T).
- Las alarmas sin días suenan en la próxima vez que llegue HH:mm estrictamente después de `now`.

## Archivos
- Crear: `android/app/src/main/kotlin/com/migdlp/gentlealarm/alarm/NextTriggerCalculator.kt` y `android/app/src/test/kotlin/com/migdlp/gentlealarm/alarm/NextTriggerCalculatorTest.kt`

## Pasos
1. RED: escribe primero todos los tests de la tabla con `zone = ZoneId.of("Europe/Madrid")` e instantes construidos con `ZonedDateTime.of(...)`.
2. Implementa:
   ```kotlin
   data class NextTrigger(val ringAtEpochMs: Long, val fireAtEpochMs: Long)
   object NextTriggerCalculator {
     fun nextRingAt(spec: AlarmSpec, nowMs: Long, zone: ZoneId): Long
     fun next(spec: AlarmSpec, nowMs: Long, zone: ZoneId): NextTrigger
   }
   ```
   `fireAtEpochMs` es el inicio del amanecer (RF-12).
3. Algoritmo de `nextRingAt`: para d = 0..8, fecha = hoy(zone) + d; si `weekdays` no está vacío y `fecha.dayOfWeek.value` no está en `weekdays`, continúa; candidato = `ZonedDateTime.of(fecha, LocalTime.of(hour, minute), zone).toInstant().toEpochMilli()`; si candidato ≤ now, continúa; si candidato == skipRingAtEpochMs, continúa; devuelve el candidato. Con d = 8 sin resultado se lanza `IllegalStateException` (no debería ocurrir; está cubierto por un test con el salto activo).
4. GREEN y REFACTOR.

## Casos límite a cubrir
| Caso (Europe/Madrid) | Esperado |
|---|---|
| Sin días, now = lun 22:00 y alarma a las 07:30 | mar 07:30 |
| Sin días, now = lun 07:30:00 exacto y alarma a las 07:30 | mar 07:30 (estrictamente después) |
| Días [1..5], now = vie 08:00 y alarma a las 07:30 | lun 07:30 |
| Días [6], now = sáb 07:29 y alarma a las 07:30 | ese sábado 07:30 |
| Días [1..7] con skip = T de mañana | pasado mañana |
| Sólo un día [3] con skip = T del próximo miércoles | el miércoles siguiente (+7 días) |
| 02:30 el día del salto de primavera | 03:30 (+02:00) |
| 02:30 el día del retroceso de otoño | 02:30 con offset +02:00 |
| sunrise 20, now = T − 60 min | fireAt = T − 20 min |
| sunrise 20, now = T − 8 min | fireAt = now |
| sunrise 20, now = T − 30 s | fireAt = T |
| sunrise 0 | fireAt = T |

## Criterios de aceptación
- [ ] Los 12 casos tienen un test que pasa.
- [ ] El calculador no lee el reloj del sistema: `now` y `zone` siempre llegan como parámetros.

## Verificación
```bash
cd android && ./gradlew testDebugUnitTest --tests "*NextTriggerCalculatorTest*"
```

## Fuera de alcance
- Llamar a AlarmManager (E02-T04).

## Si te bloqueas
- Si `java.time` no está disponible en API 26: sí lo está (desde API 26). No añadas desugaring.
