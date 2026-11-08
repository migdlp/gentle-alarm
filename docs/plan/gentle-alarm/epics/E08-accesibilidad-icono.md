---
id: E08
title: Accesibilidad e identidad visual
depends_on: [E04, E06, E07]
requirements: [RF-90, RNF-04, RNF-05]
---

# E08 · Accesibilidad e identidad visual

## Objetivo
Todas las pantallas se usan con TalkBack y texto grande, y la app tiene icono propio.

## Alcance
- Incluido: Auditoría de accesibilidad con pruebas e icono adaptativo.
- No incluido: Rediseños.

## Diseño
RNF-04, RNF-05 y RF-90.

## Tareas
| ID | Título | Depende de | Tamaño |
|---|---|---|---|
| [E08-T01](../tasks/E08-T01-auditoria-accesibilidad.md) | Auditoría de accesibilidad (TalkBack, texto al 200 % y animaciones reducidas) | E06-T03, E07-T03, E07-T04, E05-T02, E06-T02 | M |
| [E08-T02](../tasks/E08-T02-icono-app.md) | Icono adaptativo y monocromo de la app | E01-T04 | S |

## Definición de terminado del epic
- [ ] Todas las tareas `done`.
- [ ] `test/a11y` pasa.
- [ ] El icono se ve en API 26 y 34.
