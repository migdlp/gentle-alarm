---
id: E09
title: Calidad y publicación
depends_on: [E08]
requirements: [RF-26, RF-41, RF-84, RF-85, RNF-01, RNF-03, RNF-06, RNF-08, RNF-09]
---

# E09 · Calidad y publicación

## Objetivo
La app está verificada en dispositivos reales y lista para subirse a Google Play.

## Alcance
- Incluido: Prueba de integración en CI, matriz manual de fiabilidad y materiales de Play.
- No incluido: Subida y respuesta a la revisión (propietario).

## Diseño
Entornos y despliegue §8; riesgos R-01 y R-02.

## Tareas
| ID | Título | Depende de | Tamaño |
|---|---|---|---|
| [E09-T01](../tasks/E09-T01-prueba-integracion-ci.md) | Prueba de integración de crear, editar y borrar alarma en emulador dentro de CI | E03-T04, E01-T02, E07-T02 | M |
| [E09-T02](../tasks/E09-T02-matriz-fiabilidad.md) | Matriz manual de fiabilidad en dispositivos reales | E07-T04, E08-T01 | M |
| [E09-T03](../tasks/E09-T03-publicacion-play.md) | Preparar la publicación en Google Play (firma, privacidad, ficha y declaraciones) | E09-T02, E08-T02 | M |

## Definición de terminado del epic
- [ ] Todas las tareas `done`.
- [ ] Matriz sin fallos de «no sonó».
- [ ] `.aab` de release generado.
