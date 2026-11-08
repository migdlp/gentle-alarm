---
id: E07
title: Permisos, primer uso y vista previa
depends_on: [E03, E04, E05]
requirements: [RF-50, RF-51, RF-52, RF-53]
---

# E07 · Permisos, primer uso y vista previa

## Objetivo
La persona entiende y concede lo necesario para que la alarma no falle, y puede probar el despertar en 60 s.

## Alcance
- Incluido: Estado de permisos, onboarding, guía de batería por marca, banner de salud y «Probar despertar».
- No incluido: Petición de exención de batería.

## Diseño
`02-architecture.md` §4 (permisos) y §5.2.

## Tareas
| ID | Título | Depende de | Tamaño |
|---|---|---|---|
| [E07-T01](../tasks/E07-T01-estado-permisos.md) | Estado de permisos y accesos a sus ajustes desde Dart | E05-T02 | S |
| [E07-T02](../tasks/E07-T02-onboarding.md) | Onboarding de primer arranque con permisos, guía de batería y consejo | E07-T01, E03-T02 | M |
| [E07-T03](../tasks/E07-T03-banner-salud.md) | Banner «Tu alarma podría no sonar» en la lista | E07-T02 | S |
| [E07-T04](../tasks/E07-T04-probar-despertar.md) | «Probar despertar», una vista previa de 60 s desde el editor | E04-T09, E03-T03 | S |

## Definición de terminado del epic
- [ ] Todas las tareas `done`.
- [ ] En un emulador limpio con API 34, el onboarding guía hasta tener todos los permisos.
- [ ] «Probar despertar» funciona.
