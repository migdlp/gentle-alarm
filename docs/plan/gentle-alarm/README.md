# Plan: Gentle Alarm («Despertar suave»)

Estado: borrador · Última actualización: 2026-11-08

## Resumen
Despertador para Android hecho en Flutter que despierta con calma. La pantalla simula un amanecer durante los 20 min anteriores a la hora, el sonido natural empieza casi en silencio y sube en 3 min, apagarlo es un gesto tranquilo con una confirmación y después aparece un saludo con la hora, el tiempo y una frase amable. Es gratuito, sin cuentas ni anuncios, en español e inglés y pensado para Google Play.

## Cómo usar este plan
- Personas: leer `00-overview.md` → `01-requirements.md` → `02-architecture.md` → `03-risks-open-questions.md`.
- Agente ejecutor: leer `AGENT_BRIEF.md` y después la siguiente tarea `todo` del orden de ejecución cuyas dependencias estén `done`.

## Decisiones clave
| Tema | Decisión |
|---|---|
| Plataforma | Android 8+ primero; iOS (AlarmKit) en la fase 2 (ADR-01) |
| Motor | Kotlin nativo propio: `setAlarmClock`, servicio en primer plano y máquina de estados pura (ADR-02, 05, 06, 07) |
| Fuente de verdad | Las alarmas viven en Kotlin (almacenamiento protegido); Dart es cliente por canal (ADR-03) |
| UI de despertar | Flutter en `RingActivity` con el entrypoint `ringMain`; el audio y los tiempos son nativos (ADR-04) |
| Luz | Pantalla: gradiente noche → rojo → naranja → crema y brillo 1 % → 100 % con curva cuadrática |
| Sonido | 6 sonidos CC0 + archivo propio; rampa perceptual; el volumen del sistema se fija y se restaura (ADR-10) |
| Escalada | Vibración a +5 min, autoposponer a +15 min (una vez) y parada tras otros 15 min con un aviso amable |
| Posponer | «Un ratito más», 10 min, máx. 3, con luz cálida tenue |
| Apagar | Deslizar el sol + «¿Ya estás despierto/a?» (60 s, o vuelve a sonar bajito) |
| Tiempo | Open-Meteo con la ciudad elegida a mano, sin permiso de ubicación (ADR-09) |
| Estado Dart | Riverpod sin generación de código (ADR-08) |

## Orden de ejecución
(Generado por `validate_plan.py`; las tareas del mismo nivel pueden hacerse en paralelo.)

| Nivel | Tareas |
|---|---|
| 1 | E01-T01 |
| 2 | E01-T02, E01-T03, E02-T01, E04-T01 |
| 3 | E01-T04, E02-T02, E02-T03, E04-T02, E05-T01 |
| 4 | E02-T04, E04-T03, E08-T02 |
| 5 | E02-T05, E02-T06 |
| 6 | E02-T07, E04-T04 |
| 7 | E03-T01, E04-T05 |
| 8 | E03-T02, E03-T05, E04-T06, E06-T01 |
| 9 | E03-T03, E04-T07, E06-T02 |
| 10 | E03-T04, E04-T08, E05-T02 |
| 11 | E04-T09, E07-T01 |
| 12 | E06-T03, E07-T02, E07-T04 |
| 13 | E07-T03, E09-T01 |
| 14 | E08-T01 |
| 15 | E09-T02 |
| 16 | E09-T03 |

## Epics
| ID | Título | Tareas | Estado |
|---|---|---|---|
| [E01](epics/E01-cimientos.md) | Cimientos del proyecto | 4 | done |
| [E02](epics/E02-motor-alarmas.md) | Motor nativo de alarmas | 7 | done |
| [E03](epics/E03-gestion-alarmas.md) | Gestión de alarmas en la interfaz | 5 | done |
| [E04](epics/E04-sesion-despertar.md) | Sesión de despertar | 9 | done |
| [E05](epics/E05-sonidos.md) | Sonidos | 2 | done |
| [E06](epics/E06-saludo-tiempo.md) | Saludo y tiempo | 3 | done |
| [E07](epics/E07-permisos-onboarding.md) | Permisos, primer uso y vista previa | 4 | done |
| [E08](epics/E08-accesibilidad-icono.md) | Accesibilidad e identidad visual | 2 | done |
| [E09](epics/E09-calidad-publicacion.md) | Calidad y publicación | 3 | blocked (2 tareas) |

## Supuestos a revisar
- SUPUESTO-1: nombre visible «Despertar suave» / «Gentle Alarm».
- SUPUESTO-2: sonidos CC0 de Freesound elegidos por el ejecutor y aprobados por el propietario.
- SUPUESTO-3: cuenta de desarrollador de Google Play disponible.
- SUPUESTO-5: Open-Meteo gratuito porque la app no es comercial.
- SUPUESTO-6: las 12 frases del saludo de E06-T03.

## Preguntas abiertas que bloquean
- PA-1 (bloquea E09-T03 y condiciona E08-T02): nombre comercial e icono definitivos. Propuesta: el nombre del SUPUESTO-1 y un sol asomando sobre el horizonte.

## Historial
- 2026-11-08: versión inicial (9 epics, 39 tareas, 66 requisitos).
