---
id: E06-T02
title: Búsqueda y elección de ciudad para el tiempo en Ajustes
epic: E06
status: todo
depends_on: [E06-T01, E03-T05]
requirements: [RF-70]
size: S
---

# E06-T02 · Búsqueda y elección de ciudad para el tiempo en Ajustes

## Objetivo
En Ajustes → Tiempo, la persona busca y elige su ciudad o la quita, y la fila muestra la ciudad elegida.

## Contexto
- `weatherRepositoryProvider` (E06-T01). Fila `ListTile` con título `weatherCity` y subtítulo `"{name}, {country}"` o `weatherCityNone`. Al tocar → `CitySearchScreen`.
- `CitySearchScreen`: `TextField` con autofoco y la pista `citySearchHint`; búsqueda con una espera de 400 ms entre pulsaciones (`Timer`); `ListView` de resultados `"{name}"` con el subtítulo `"{admin1}, {country}"`. Estados: menos de 2 caracteres → `citySearchStart`; buscando → `LinearProgressIndicator`; sin resultados → `citySearchEmpty`. Al elegir → `setCity` y `pop`. Si hay ciudad, `TextButton` `cityRemove` en la AppBar → `setCity(null)` y `pop`.
- Textos:
| Clave | es | en |
|---|---|---|
| `weatherCity` | Ciudad para el tiempo | City for the weather |
| `weatherCityNone` | Sin ciudad · el saludo no mostrará el tiempo | No city · the greeting won't show the weather |
| `citySearchHint` | Busca tu ciudad | Search your city |
| `citySearchStart` | Escribe al menos 2 letras | Type at least 2 letters |
| `citySearchEmpty` | No encontramos esa ciudad | We couldn't find that city |
| `cityRemove` | Quitar | Remove |

## Archivos
- Crear: `lib/src/features/greeting/ui/city_search_screen.dart` y `test/features/greeting/city_search_screen_test.dart`
- Modificar: `settings_screen.dart` y los dos ARB

## Pasos
1. RED: escribir «Ma» y esperar 400 ms → se llama a `searchCities` una vez; escribir «M» → `citySearchStart`; elegir un resultado → `setCity` llamado; `cityRemove` → `setCity(null)`.
2. Implementa.
3. GREEN.

## Criterios de aceptación
- [ ] Las 4 pruebas pasan.
- [ ] Manual: buscar «Madrid», elegirla y ver «Madrid, España» en Ajustes.

## Verificación
```bash
flutter gen-l10n && flutter analyze && flutter test test/features/greeting
```

## Fuera de alcance
- Ubicación por GPS (ADR-09).

## Si te bloqueas
- Si la API no responde desde el emulador, comprueba la conexión del emulador; no cambies el host.
