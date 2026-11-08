---
id: E09-T02
title: Matriz manual de fiabilidad en dispositivos reales
epic: E09
status: blocked
depends_on: [E07-T04, E08-T01]
requirements: [RNF-01, RNF-03, RF-84, RF-85, RF-41, RF-26]
size: M
---

# E09-T02 · Matriz manual de fiabilidad en dispositivos reales

## Objetivo
Queda documentado, con resultados, que la alarma suena a su hora y de forma suave en 3 dispositivos reales y 7 escenarios, sin wakelocks fuera de las sesiones.

## Contexto
- Dispositivos: (A) un Pixel o un emulador con API 35+; (B) un Samsung con One UI; (C) un Xiaomi, Redmi o POCO con HyperOS o MIUI. Si falta alguno, se usa el que tenga el propietario y se anota.
- Escenarios, cada uno con una alarma con amanecer de 5 min y rampa de 1 min:
  1. Pantalla apagada, bloqueado y 1 h en reposo (Doze). Fuerza Doze con `adb shell dumpsys deviceidle force-idle`.
  2. App cerrada desde recientes.
  3. Reiniciado sin desbloquear después (suena sin UI de Flutter, con la notificación; ADR-13).
  4. No molestar activado y modo silencio.
  5. Cambio de zona horaria a mano entre la programación y la hora.
  6. Llamada entrante mientras suena (pausa y vuelta suave).
  7. Cascos Bluetooth conectados (anotar por dónde suena).
- Para cada uno: ¿empezó el amanecer a su hora (±5 s)?, ¿sonó a T (±5 s)?, ¿subió sin saltos?, ¿se restauró el volumen del sistema?
- RNF-03: tras 1 h sin sesión, `adb shell dumpsys batterystats --charged com.migdlp.gentlealarm` sin wakelocks de la app.

## Archivos
- Crear: `docs/qa/matriz-fiabilidad.md` (tabla de 3 × 7 con fecha, versión de Android y resultado, y una sección de incidencias)

## Pasos
1. Instala el build de release firmado con debug (`flutter build apk --release` y `adb install`).
2. Ejecuta los escenarios en cada dispositivo y rellena la tabla.
3. Por cada fallo, abre un issue con los pasos y `adb logcat` adjunto, y enlázalo en la sección de incidencias.

## Criterios de aceptación
- [ ] Hay 21 celdas rellenas (o anotadas como «sin dispositivo»).
- [ ] 0 fallos de «no sonó» o, si hay alguno, un issue abierto que bloquea E09-T03.
- [ ] Comprobación de RNF-03 anotada.

## Verificación
```bash
adb shell dumpsys alarm | grep -A3 gentlealarm
adb shell dumpsys batterystats --charged com.migdlp.gentlealarm | grep -i wake
```

## Fuera de alcance
- Arreglar los fallos encontrados (cada uno va en su propio issue y tarea nueva).

## Si te bloqueas
- Si un fabricante mata la app pese a la guía, anótalo como riesgo R-01 materializado y sigue con el resto de escenarios.

## Bloqueo
- Requiere 3 dispositivos reales (Pixel/emulador API 35+, Samsung, Xiaomi) y horas de prueba manual; este entorno no tiene ni emulador. Se deja la plantilla `docs/qa/matriz-fiabilidad.md` con las 21 celdas marcadas «pendiente (sin dispositivo)».
- Opciones: (a) el propietario ejecuta los escenarios y rellena la tabla; (b) se acepta publicar en prueba interna con la matriz pendiente.
