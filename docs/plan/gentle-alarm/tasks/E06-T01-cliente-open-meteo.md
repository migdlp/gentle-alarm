---
id: E06-T01
title: Cliente Open-Meteo (geocodificación y tiempo actual) con caché
epic: E06
status: todo
depends_on: [E03-T01]
requirements: [RF-70, RF-71]
size: M
---

# E06-T01 · Cliente Open-Meteo (geocodificación y tiempo actual) con caché

## Objetivo
`WeatherRepository` busca ciudades, guarda la elegida, obtiene el tiempo actual con un límite de 5 s y lo guarda en caché 3 h; ningún error llega a la interfaz como excepción.

## Contexto
- Endpoints (`02-architecture.md` §5.5):
  - `https://geocoding-api.open-meteo.com/v1/search?name={q}&count=10&language={es|en}&format=json` → `results` (puede faltar si no hay coincidencias).
  - `https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current=temperature_2m,weather_code&timezone=auto` → `current.temperature_2m` y `current.weather_code`.
- Preferencias (§3.3): `weather.city` (JSON `{name, country, latitude, longitude}`) y `weather.cache` (JSON `{temperatureC, weatherCode, fetchedAtEpochMs, cityName}`).
- Modelos: `City(name, country, latitude, longitude, admin1?)` y `WeatherNow(temperatureC: double, weatherCode: int, fetchedAt: DateTime, cityName: String)`.
- Reglas: la búsqueda exige `q.trim().length >= 2` (si no, lista vacía sin llamar a la red); `timeout(5 s)`; cualquier excepción o código ≠ 200 → `searchCities` devuelve `[]` y `refresh` devuelve `null`. `cachedFresh(now)` devuelve la caché si `now − fetchedAt < 3 h` y su `cityName` coincide con la ciudad actual; si no, null. Al cambiar de ciudad se borra la caché.
- El cliente `http.Client` se inyecta para poder probarlo (`MockClient` de `package:http/testing.dart`).

## Archivos
- Crear: `lib/src/features/greeting/domain/weather.dart` (City y WeatherNow), `lib/src/features/greeting/data/open_meteo_client.dart`, `lib/src/features/greeting/data/weather_repository.dart`, `lib/src/features/greeting/state/weather_providers.dart`, `test/features/greeting/open_meteo_client_test.dart` y `test/features/greeting/weather_repository_test.dart`

## Pasos
1. RED: búsqueda con `MockClient` que devuelve 2 resultados → 2 `City`; búsqueda de 1 letra → no hay petición; respuesta sin `results` → []; timeout (un `MockClient` que espera 6 s) → []; `refresh` guarda la caché; `cachedFresh` a 2 h 59 min → valor y a 3 h 1 min → null; cambiar de ciudad borra la caché.
2. Implementa `OpenMeteoClient(http.Client)` con `searchCities(q, languageCode)` y `currentWeather(lat, lon)`, y `WeatherRepository(client, prefs, clock)` con `City? get city`, `setCity(City?)`, `searchCities`, `Future<WeatherNow?> refresh()` y `WeatherNow? cachedFresh()`.
3. Providers: `weatherRepositoryProvider`.
4. GREEN.

## Criterios de aceptación
- [ ] Las 7 pruebas pasan.
- [ ] Ninguna petición sale a otros hosts (revisión de código).

## Verificación
```bash
flutter analyze && flutter test test/features/greeting
```

## Fuera de alcance
- Interfaz de búsqueda (E06-T02) y saludo (E06-T03).

## Si te bloqueas
- No añadas `dio` ni `geolocator`: usa `http` (ADR-09).
