---
id: E05
title: Sonidos
depends_on: [E01]
requirements: [RF-60, RF-61, RF-62]
---

# E05 · Sonidos

## Objetivo
La alarma suena con 6 sonidos suaves incluidos o con un archivo propio, con escucha previa y respaldo si falla.

## Alcance
- Incluido: Sonidos CC0, catálogo, selector, escucha previa y archivo propio con permiso persistente.
- No incluido: Streaming.

## Diseño
ADR-12; contrato `gentle_alarm/system` §5.2.

## Tareas
| ID | Título | Depende de | Tamaño |
|---|---|---|---|
| [E05-T01](../tasks/E05-T01-sonidos-incluidos.md) | Seis sonidos CC0 incluidos y catálogo de sonidos | E01-T03 | M |
| [E05-T02](../tasks/E05-T02-selector-sonido.md) | Selector de sonido con escucha previa y archivo propio del móvil | E05-T01, E03-T03, E03-T05, E04-T02 | M |

## Definición de terminado del epic
- [ ] Todas las tareas `done`.
- [ ] Se puede elegir y escuchar cada sonido.
- [ ] Un archivo propio sigue sonando tras reiniciar.
