---
id: E02-T02
title: AlarmStore en almacenamiento protegido del dispositivo
epic: E02
status: todo
depends_on: [E02-T01]
requirements: [RNF-10]
size: S
---

# E02-T02 · AlarmStore en almacenamiento protegido del dispositivo

## Objetivo
`AlarmStore` guarda, lee, actualiza y borra `AlarmSpec`, y la instantánea de sesión activa, en SharedPreferences del contexto protegido del dispositivo, accesible antes del primer desbloqueo.

## Contexto
- ADR-03: el store es la fuente de verdad. SharedPreferences `gentle_alarm_store`, obtenidas de `context.createDeviceProtectedStorageContext()`.
- Claves: `alarms_v1` (String con un JSON array de `AlarmSpec.toJson()`), `schema_version` (Int = 1) y `active_session` (String JSON o ausente).
- Para poder probarlo en JVM, la lógica se separa con una interfaz `KeyValueStore { fun getString(k): String?; fun putString(k, v: String?); fun getInt(k, def): Int; fun putInt(k, v) }` y una implementación `SharedPrefsKeyValueStore(context)`.

## Archivos
- Crear: `android/app/src/main/kotlin/com/migdlp/gentlealarm/alarm/AlarmStore.kt`, `alarm/KeyValueStore.kt` (interfaz + `SharedPrefsKeyValueStore` + `InMemoryKeyValueStore`) y `android/app/src/test/kotlin/com/migdlp/gentlealarm/alarm/AlarmStoreTest.kt`

## Pasos
1. RED: en `AlarmStoreTest`, con `InMemoryKeyValueStore`, prueba: lista vacía al inicio; `upsert` añade; `upsert` con el mismo id reemplaza; `delete` devuelve true y elimina; `delete` de un id inexistente devuelve false; `get(id)`; `saveSession`/`loadSession`/`clearSession` con un `JSONObject`; y que un `alarms_v1` corrupto (`"no-json"`) devuelve lista vacía sin lanzar.
2. Implementa `class AlarmStore(private val kv: KeyValueStore)` con `fun list(): List<AlarmSpec>`, `fun get(id: String): AlarmSpec?`, `fun upsert(spec: AlarmSpec)`, `fun delete(id: String): Boolean`, `fun saveSession(json: JSONObject)`, `fun loadSession(): JSONObject?` y `fun clearSession()`. Todos los métodos son `@Synchronized`.
3. En `upsert`, la primera escritura fija `schema_version = 1`.
4. `SharedPrefsKeyValueStore(context)` usa `context.createDeviceProtectedStorageContext().getSharedPreferences("gentle_alarm_store", MODE_PRIVATE)` y escribe con `commit()` (síncrono: hay que garantizarlo antes de programar la alarma).
5. `companion fun from(context: Context) = AlarmStore(SharedPrefsKeyValueStore(context))`.
6. GREEN.

## Criterios de aceptación
- [ ] Todos los tests de `AlarmStoreTest` pasan.
- [ ] `SharedPrefsKeyValueStore` usa `createDeviceProtectedStorageContext()` (revisión de código).

## Verificación
```bash
cd android && ./gradlew testDebugUnitTest --tests "*AlarmStoreTest*"
```

## Fuera de alcance
- Programación de alarmas (E02-T04) y canal Dart (E02-T06).

## Si te bloqueas
- No uses Room ni DataStore: ADR-03 fija SharedPreferences + JSON.
