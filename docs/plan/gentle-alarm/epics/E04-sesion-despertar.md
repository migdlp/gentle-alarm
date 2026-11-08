---
id: E04
title: Sesión de despertar
depends_on: [E02, E03]
requirements: [RF-06, RF-10, RF-11, RF-13, RF-14, RF-15, RF-16, RF-20, RF-21, RF-22, RF-23, RF-24, RF-25, RF-26, RF-27, RF-30, RF-31, RF-32, RF-33, RF-34, RF-35, RF-37, RF-44, RF-45, RF-81, RF-82, RF-83, RF-84, RNF-02]
---

# E04 · Sesión de despertar

## Objetivo
A la hora programada se produce el despertar completo: amanecer en pantalla, sonido con rampa, escalada suave, posponer y confirmación.

## Alcance
- Incluido: Máquina de estados, audio, vibración, servicio en primer plano, decisión de arranque, RingActivity y vistas Flutter de amanecer, sonando, confirmación y pospuesta.
- No incluido: Saludo (E06-T03) y vista previa (E07-T04).

## Diseño
ADR-04, ADR-06, ADR-07, ADR-10 y ADR-13; máquina §3.4; constantes §3.5; contrato §5.3.

## Tareas
| ID | Título | Depende de | Tamaño |
|---|---|---|---|
| [E04-T01](../tasks/E04-T01-ring-session-machine.md) | RingSessionMachine pura con escalada, posponer y confirmación | E01-T01 | M |
| [E04-T02](../tasks/E04-T02-volume-ramp-sound-resolver.md) | Curva de volumen y resolución del sonido con respaldo | E02-T01 | S |
| [E04-T03](../tasks/E04-T03-audio-player-vibracion.md) | Reproductor de alarma con rampa, fundido, foco de audio, volumen del sistema y vibración | E04-T02 | M |
| [E04-T04](../tasks/E04-T04-ring-service.md) | RingService en primer plano que ejecuta la máquina de estados | E04-T01, E04-T03, E02-T05 | M |
| [E04-T05](../tasks/E04-T05-ring-launcher-sesion.md) | RingLauncher que inicia y cierra sesiones (absorción, batería baja, móvil en uso) | E04-T04 | M |
| [E04-T06](../tasks/E04-T06-ring-activity-channel.md) | RingActivity a pantalla completa, RingChannel y entrypoint ringMain | E04-T05, E01-T04 | M |
| [E04-T07](../tasks/E04-T07-amanecer-vista-brillo.md) | Vista de amanecer con gradiente, brillo progresivo y hoja de opciones | E04-T06 | M |
| [E04-T08](../tasks/E04-T08-vista-sonando.md) | Vista de sonando con sol deslizable y «Un ratito más» | E04-T07 | M |
| [E04-T09](../tasks/E04-T09-confirmacion-pospuesta.md) | Vistas de confirmación «¿Ya estás despierto/a?» y de pospuesta con luz tenue | E04-T08 | S |

## Definición de terminado del epic
- [ ] Todas las tareas `done`.
- [ ] Flujos 2, 3 y 4 de `01-requirements.md` probados a mano en un emulador con API 34.
- [ ] Todas las pruebas JVM de `ring/` pasan.
