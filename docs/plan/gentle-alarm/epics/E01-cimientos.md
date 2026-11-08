---
id: E01
title: Cimientos del proyecto
depends_on: []
requirements: [RNF-05, RNF-07, RNF-08, RNF-09]
---

# E01 · Cimientos del proyecto

## Objetivo
El repo tiene una app Flutter que compila, con CI, i18n ES/EN, tema cálido y tipografía, sobre la que construir todo lo demás.

## Alcance
- Incluido: Proyecto Flutter, lints, CI, ARB ES/EN, paleta, tema claro/oscuro y Nunito.
- No incluido: Pantallas funcionales y código nativo de alarmas.

## Diseño
Ver `02-architecture.md` §2 (stack, carpetas y convenciones) y §2.1 (paleta).

## Tareas
| ID | Título | Depende de | Tamaño |
|---|---|---|---|
| [E01-T01](../tasks/E01-T01-crear-proyecto-flutter.md) | Crear el proyecto Flutter con estructura, lints y README | — | S |
| [E01-T02](../tasks/E01-T02-ci-github-actions.md) | Pipeline de CI en GitHub Actions | E01-T01 | S |
| [E01-T03](../tasks/E01-T03-i18n-es-en.md) | Internacionalización ES/EN con ARB y gen-l10n | E01-T01 | S |
| [E01-T04](../tasks/E01-T04-tema-paleta-tipografia.md) | Tema claro/oscuro, paleta y tipografía Nunito | E01-T03 | S |

## Definición de terminado del epic
- [ ] Todas las tareas `done`.
- [ ] CI en verde en `main`.
- [ ] La app arranca mostrando «Despertar suave» o «Gentle Alarm» según el idioma.
