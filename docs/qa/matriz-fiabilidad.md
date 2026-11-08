# Matriz de fiabilidad (E09-T02)

Estado: **plantilla sin ejecutar**. Requiere dispositivos reales (A: Pixel o emulador API 35+; B: Samsung One UI; C: Xiaomi/Redmi/POCO). Cada escenario con amanecer de 5 min y rampa de 1 min. Por celda anota: ¿amanecer a su hora (±5 s)?, ¿sonó a T (±5 s)?, ¿subió sin saltos?, ¿se restauró el volumen del sistema?

| # | Escenario | A · Pixel/emulador | B · Samsung | C · Xiaomi |
|---|---|---|---|---|
| 1 | Bloqueado y 1 h en reposo (`adb shell dumpsys deviceidle force-idle`) | pendiente (sin dispositivo) | pendiente (sin dispositivo) | pendiente (sin dispositivo) |
| 2 | App cerrada desde recientes | pendiente (sin dispositivo) | pendiente (sin dispositivo) | pendiente (sin dispositivo) |
| 3 | Reiniciado sin desbloquear (suena sin UI de Flutter, ADR-13) | pendiente (sin dispositivo) | pendiente (sin dispositivo) | pendiente (sin dispositivo) |
| 4 | No molestar y modo silencio | pendiente (sin dispositivo) | pendiente (sin dispositivo) | pendiente (sin dispositivo) |
| 5 | Cambio de zona horaria entre programar y sonar | pendiente (sin dispositivo) | pendiente (sin dispositivo) | pendiente (sin dispositivo) |
| 6 | Llamada entrante mientras suena | pendiente (sin dispositivo) | pendiente (sin dispositivo) | pendiente (sin dispositivo) |
| 7 | Cascos Bluetooth (anotar por dónde suena) | pendiente (sin dispositivo) | pendiente (sin dispositivo) | pendiente (sin dispositivo) |

Fecha y versión de Android por dispositivo: pendiente.

## RNF-03 (sin wakelocks fuera de sesión)
Pendiente: tras 1 h sin sesión, `adb shell dumpsys batterystats --charged com.migdlp.gentlealarm | grep -i wake` no debe mostrar wakelocks de la app.

## Incidencias
Ninguna registrada (no se ha ejecutado la matriz).
