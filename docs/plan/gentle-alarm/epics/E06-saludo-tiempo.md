---
id: E06
title: Saludo y tiempo
depends_on: [E03, E04]
requirements: [RF-36, RF-70, RF-71, RF-72, RF-73]
---

# E06 · Saludo y tiempo

## Objetivo
Tras despertar, un saludo amable muestra la hora, el tiempo de la ciudad elegida y una frase.

## Alcance
- Incluido: Cliente Open-Meteo, caché, búsqueda de ciudad y vista de saludo con frases.
- No incluido: Ubicación por GPS y voz.

## Diseño
ADR-09; contrato Open-Meteo §5.5; preferencias §3.3.

## Tareas
| ID | Título | Depende de | Tamaño |
|---|---|---|---|
| [E06-T01](../tasks/E06-T01-cliente-open-meteo.md) | Cliente Open-Meteo (geocodificación y tiempo actual) con caché | E03-T01 | M |
| [E06-T02](../tasks/E06-T02-busqueda-ciudad.md) | Búsqueda y elección de ciudad para el tiempo en Ajustes | E06-T01, E03-T05 | S |
| [E06-T03](../tasks/E06-T03-saludo.md) | Pantalla de saludo con hora, tiempo y frase amable | E06-T01, E04-T09 | M |

## Definición de terminado del epic
- [ ] Todas las tareas `done`.
- [ ] El saludo muestra el tiempo con red y lo omite sin red.
