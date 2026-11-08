# Visión

## Problema

Los despertadores habituales arrancan de golpe: silencio total y, de repente, un sonido fuerte a volumen alto. Despertar así sobresalta y deja mal cuerpo. La naturaleza despierta poco a poco: primero la luz y después los sonidos.

**Gentle Alarm** es un despertador para Android hecho en Flutter que imita un amanecer. La pantalla del móvil se va iluminando con colores cálidos durante los minutos anteriores a la hora. A la hora, un sonido natural empieza casi en silencio y sube despacio. Apagarlo es un gesto tranquilo, pero con una comprobación para no apagarlo dormido, y después aparece un saludo amable con la hora y el tiempo que hace.

## Usuarios y roles

| Rol | Quién es | Qué necesita |
|---|---|---|
| Durmiente | Cualquier persona que use el móvil como despertador en la mesilla | Despertar sin sobresaltos y con la seguridad de que la alarma sonará |

Hay un solo rol. No hay cuentas, servidor ni datos compartidos.

## Objetivos

- O1: Despertar sin sobresaltos. Luz progresiva durante 20 min (configurable) antes de la hora y sonido que sube de 0 % al máximo en 3 min (configurable).
- O2: Fiabilidad total. La alarma suena a su hora aunque el móvil esté en Doze, bloqueado, en No molestar, recién reiniciado o con la app cerrada.
- O3: Amabilidad en cada pantalla: textos cálidos, gestos grandes, nada de colores agresivos y una escalada suave si no te despiertas.
- O4: Publicación en Google Play, gratuita, sin anuncios ni cuentas, en español e inglés.

## No-objetivos (fuera de la v1)

- iOS (fase 2; requiere AlarmKit, iOS 26+, con otras limitaciones).
- Bombillas inteligentes (Hue, Tuya) y linterna.
- Spotify u otros servicios de streaming como sonido de alarma.
- Despertar inteligente por fases de sueño, estadísticas de sueño y rutina para dormir.
- Retos para apagar la alarma (problemas matemáticos, códigos QR).
- Cuentas, sincronización, nube, anuncios, compras dentro de la app y analítica de terceros.
- Wear OS, widgets y tablets como objetivo de diseño (deben funcionar, pero no se optimizan).

## Métricas de éxito

- Sin alarmas perdidas en la matriz de pruebas manuales (E09-T02): 0 fallos en 3 dispositivos × 7 escenarios.
- Probado por el propietario 7 noches seguidas con la percepción de que «despierta suave».
- Ningún fallo de la app en la consola de Google Play durante las primeras dos semanas.

## Restricciones

- Flutter (Dart) para la interfaz y Kotlin nativo para programar las alarmas y hacerlas sonar. Android mínimo 8.0 (API 26) y objetivo el SDK que exija Play en el momento de publicar (≥ 35).
- Sin backend. Todo en local. La única llamada de red es al tiempo de Open-Meteo, que es opcional.
- TDD obligatorio: prueba primero (ver `AGENT_BRIEF.md`).

## Glosario

| Término | Definición |
|---|---|
| Alarma | Configuración guardada: hora, días, sonido, duración del amanecer y opciones. Puede estar activada o desactivada. |
| Ocurrencia | Cada vez concreta que una alarma debe sonar (p. ej. el martes 10/11 a las 07:30). |
| Hora de la alarma (T) | Momento en que empieza el sonido. |
| Amanecer | Fase visual previa: desde T − duración del amanecer hasta T la pantalla pasa de casi negro a blanco cálido. |
| Sesión de despertar | Todo lo que ocurre en una ocurrencia: amanecer → sonando → pospuesta / confirmación → saludo. Sólo hay una sesión activa a la vez. |
| Tramo de sonido | Periodo continuo en el que suena el audio, desde que empieza hasta que se pospone o se apaga. |
| Rampa | Subida progresiva de volumen desde el volumen inicial hasta el máximo de la alarma. |
| Posponer | Silenciar 10 min con el botón «Un ratito más» (máximo 3 por ocurrencia). |
| Autoposponer | Posponer automático a los 15 min de un tramo sin interacción (una vez por ocurrencia). |
| Alarma no atendida | Ocurrencia que termina sin que nadie la confirme; deja una notificación. |
