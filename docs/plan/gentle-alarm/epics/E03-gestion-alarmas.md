---
id: E03
title: Gestión de alarmas en la interfaz
depends_on: [E02]
requirements: [RF-01, RF-02, RF-03, RF-04, RF-05, RF-07, RF-08, RF-09, RF-80]
---

# E03 · Gestión de alarmas en la interfaz

## Objetivo
La persona crea, edita, activa, desactiva, borra y salta alarmas, y ajusta los valores por defecto.

## Alcance
- Incluido: Lista, editor, borrar con deshacer, saltar la próxima y ajustes.
- No incluido: Selector de sonido (E05), ciudad (E06) y permisos (E07).

## Diseño
Flujo 1 de `01-requirements.md`; ajustes §3.3.

## Tareas
| ID | Título | Depende de | Tamaño |
|---|---|---|---|
| [E03-T01](../tasks/E03-T01-settings-repository.md) | SettingsRepository con valores por defecto de alarmas | E02-T07 | S |
| [E03-T02](../tasks/E03-T02-lista-alarmas.md) | Pantalla de lista de alarmas con próxima alarma e interruptores | E03-T01, E01-T04 | M |
| [E03-T03](../tasks/E03-T03-editor-alarma.md) | Editor de alarma (crear y editar) | E03-T02, E05-T01 | M |
| [E03-T04](../tasks/E03-T04-borrar-deshacer-saltar.md) | Borrar con deshacer y saltar la próxima ocurrencia | E03-T03 | S |
| [E03-T05](../tasks/E03-T05-pantalla-ajustes.md) | Pantalla de ajustes con valores por defecto y Acerca de | E03-T01, E05-T01 | S |

## Definición de terminado del epic
- [ ] Todas las tareas `done`.
- [ ] Flujo «crear → editar → borrar» funciona a mano.
- [ ] Las pruebas de widget de E03 pasan.
