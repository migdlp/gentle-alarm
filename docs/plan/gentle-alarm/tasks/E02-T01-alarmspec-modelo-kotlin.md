---
id: E02-T01
title: Modelo AlarmSpec en Kotlin con validación y JSON
epic: E02
status: done
depends_on: [E01-T01]
requirements: [RF-01, RF-80]
size: S
---

# E02-T01 · Modelo AlarmSpec en Kotlin con validación y JSON

## Objetivo
Existe `AlarmSpec` (data class Kotlin pura) con `validate()`, `toJson()` y `fromJson()`, cubierta por pruebas JVM.

## Contexto
Campos, tipos, defaults y restricciones (`02-architecture.md` §3.1):
| Campo | Tipo | Restricción |
|---|---|---|
| id | String | no vacío |
| enabled | Boolean | |
| hour | Int | 0-23 |
| minute | Int | 0-59 |
| weekdays | List<Int> | 1-7, sin repetidos; se normaliza ordenada |
| label | String | se aplica trim(); ≤ 40 caracteres (cuenta `codePointCount`) |
| soundId | String | `birds_dawn`, `soft_waves`, `light_rain`, `chimes`, `calm_piano`, `singing_bowls` o `custom` |
| customSoundUri / customSoundName | String? | obligatorios y no vacíos si soundId == custom; null si no |
| sunriseMinutes | Int | {0, 5, 10, 15, 20, 30, 45} |
| rampMinutes | Int | {1, 2, 3, 5, 10} |
| maxVolumePercent | Int | 10-100, múltiplo de 10 |
| vibrate | Boolean | |
| skipRingAtEpochMs | Long? | |
| scheduledRingAtEpochMs | Long? | |
| createdAtEpochMs | Long | |
- La lógica es pura: no importes `android.*`. JSON con `org.json.JSONObject` (en las pruebas lo aporta `org.json:json`).

## Archivos
- Crear: `android/app/src/main/kotlin/com/migdlp/gentlealarm/alarm/AlarmSpec.kt` y `android/app/src/test/kotlin/com/migdlp/gentlealarm/alarm/AlarmSpecTest.kt`

## Pasos
1. RED: en `AlarmSpecTest`, escribe los tests de la tabla de casos límite y un test de ida y vuelta `fromJson(spec.toJson()) == spec`. Ejecuta y observa el fallo de compilación o de aserción.
2. Implementa `data class AlarmSpec(...)` con los campos de arriba.
3. `fun validate(): AlarmSpec`: devuelve una copia normalizada (label con trim y weekdays ordenados y sin repetidos) o lanza `InvalidSpecException(field: String)` con el nombre del campo JSON del primer error, comprobando en el orden de la tabla.
4. `fun toJson(): JSONObject` (los nulos se escriben como `JSONObject.NULL`) y `companion fun fromJson(o: JSONObject): AlarmSpec` (los campos ausentes toman el default de §3.1; `weekdays` como `JSONArray`).
5. `class InvalidSpecException(val field: String) : IllegalArgumentException(field)`.
6. GREEN y luego REFACTOR.

## Casos límite a cubrir
| Caso | Esperado |
|---|---|
| hour = 24 | `InvalidSpecException("hour")` |
| minute = -1 | `InvalidSpecException("minute")` |
| weekdays = [3,1,3] | se normaliza a [1,3] |
| weekdays = [8] | `InvalidSpecException("weekdays")` |
| label = "  hola  " | "hola" |
| label de 41 caracteres (con emojis contados como 1) | `InvalidSpecException("label")` |
| soundId = "custom" y customSoundUri = null | `InvalidSpecException("customSoundUri")` |
| sunriseMinutes = 7 | `InvalidSpecException("sunriseMinutes")` |
| maxVolumePercent = 55 | `InvalidSpecException("maxVolumePercent")` |
| JSON sin `vibrate` | vibrate = true |

## Criterios de aceptación
- [x] Cada fila de la tabla tiene un test que pasa.
- [x] El test de ida y vuelta JSON pasa con todos los campos, incluidos los opcionales con y sin valor.

## Verificación
```bash
cd android && ./gradlew testDebugUnitTest --tests "*AlarmSpecTest*"
```

## Fuera de alcance
- Persistencia (E02-T02) y cálculo de fechas (E02-T03).

## Si te bloqueas
- Si `org.json` da `RuntimeException: Stub!` en las pruebas, falta `testImplementation("org.json:json:20240303")` (E01-T01): para y reporta.

## Notas de implementación
- AlarmSpec con validate/toJson/fromJson y InvalidSpecException; AlarmSpecTest cubre cada fila de casos límite y ida y vuelta JSON. Nota: con módulos de plugins hay que usar `./gradlew :app:testDebugUnitTest --tests ...` (el filtro sin :app falla en subproyectos sin tests). Tests escritos junto a la implementación (sin ejecución RED separada).
