---
id: E02
title: Motor nativo de alarmas
depends_on: [E01]
requirements: [RF-01, RF-02, RF-03, RF-04, RF-07, RF-12, RF-40, RF-41, RF-42, RF-43, RF-80, RNF-10]
---

# E02 · Motor nativo de alarmas

## Objetivo
Las alarmas se guardan en Kotlin y se programan con exactitud, sobreviven a reinicios y cambios de hora y Dart puede gestionarlas por canal.

## Alcance
- Incluido: AlarmSpec, AlarmStore, NextTriggerCalculator, AlarmScheduler, receptores de sistema, canal `gentle_alarm/alarms` y repositorio Dart.
- No incluido: La sesión de despertar (E04) y la interfaz (E03).

## Diseño
ADR-02, ADR-03 y ADR-05; modelo §3.1; contrato §5.1; intents §5.4.

## Tareas
| ID | Título | Depende de | Tamaño |
|---|---|---|---|
| [E02-T01](../tasks/E02-T01-alarmspec-modelo-kotlin.md) | Modelo AlarmSpec en Kotlin con validación y JSON | E01-T01 | S |
| [E02-T02](../tasks/E02-T02-alarmstore.md) | AlarmStore en almacenamiento protegido del dispositivo | E02-T01 | S |
| [E02-T03](../tasks/E02-T03-next-trigger-calculator.md) | NextTriggerCalculator con recurrencia, salto y horario de verano | E02-T01 | M |
| [E02-T04](../tasks/E02-T04-alarm-scheduler-receiver.md) | AlarmScheduler con setAlarmClock y AlarmReceiver | E02-T02, E02-T03 | M |
| [E02-T05](../tasks/E02-T05-reprogramar-eventos-sistema.md) | Reprogramar tras reinicio, actualización o cambio de hora y gestionar perdidas | E02-T04 | M |
| [E02-T06](../tasks/E02-T06-alarm-channel-kotlin.md) | Canal gentle_alarm/alarms en Kotlin | E02-T04 | M |
| [E02-T07](../tasks/E02-T07-alarm-model-repository-dart.md) | Modelo Alarm y AlarmRepository en Dart | E02-T06 | M |

## Definición de terminado del epic
- [ ] Todas las tareas `done`.
- [ ] Crear una alarma desde Dart la deja visible en `adb shell dumpsys alarm`.
- [ ] Tras `adb reboot` sigue programada.
