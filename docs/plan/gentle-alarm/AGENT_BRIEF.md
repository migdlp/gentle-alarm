# Instrucciones para el agente ejecutor

## Tu trabajo
Implementar las tareas de `tasks/` de una en una, en el orden de `README.md`, sin tomar decisiones de producto ni de arquitectura: ya están tomadas en `01-requirements.md` y `02-architecture.md`.

## Antes de cada tarea
1. Comprueba que todas sus `depends_on` están en `status: done`.
2. Lee la tarea entera y los archivos de código que menciona.
3. Cambia su `status` a `in_progress`.
4. Crea una rama `tarea/<ID>-<slug>` desde `main` actualizado.

## Durante (TDD obligatorio)
1. **RED**: escribe primero las pruebas indicadas en «Pasos» y «Casos límite». Ejecútalas y comprueba que fallan por el comportamiento ausente, no por un error de configuración.
2. **GREEN**: implementa lo mínimo para que pasen.
3. **REFACTOR**: mejora sin cambiar el comportamiento y vuelve a ejecutar las pruebas.
4. Anota en «Notas de implementación» los comandos de RED, GREEN y REFACTOR con su resultado.

Reglas:
- Toca sólo los archivos listados en «Archivos». Si necesitas otro, para y reporta.
- Convenciones: Dart en `snake_case.dart` y modelos inmutables escritos a mano (sin generación de código); Riverpod sin generación; textos sólo en `lib/l10n/app_es.arb` y `app_en.arb`; la lógica Kotlin pura (calculadora, máquina, rampa y decisiones) no importa `android.*`; pruebas Dart en `test/` con ruta espejo y pruebas Kotlin en `android/app/src/test/kotlin/...` con el sufijo `Test.kt`.
- No añadas dependencias (la lista cerrada está en `02-architecture.md` §2), no cambies el modelo de datos ni los contratos de canal (§3 y §5) y no refactorices fuera del alcance.
- Si algo de la tarea contradice el código real o es ambiguo, NO improvises: marca `status: blocked`, añade una sección «Bloqueo» con lo que encontraste y las opciones que ves, y para.
- Nunca subas a Git keystores, `key.properties` ni contraseñas.

## Al terminar
1. Ejecuta todos los comandos de «Verificación»; deben pasar.
2. Marca cada criterio de aceptación.
3. Cambia `status` a `done` y añade «Notas de implementación» (2-5 líneas: qué hiciste, cualquier desviación justificada y los resultados de RED/GREEN/REFACTOR).
4. Commit con el mensaje `<ID>: <título>` y abre una PR hacia `main` enlazando la tarea.

## Comandos del proyecto
- Instalar: `flutter pub get`
- Generar textos: `flutter gen-l10n`
- Ejecutar: `flutter run` (emulador o móvil Android)
- Formato: `dart format .`
- Análisis: `flutter analyze`
- Pruebas Dart: `flutter test`
- Pruebas Kotlin (JVM): `cd android && ./gradlew testDebugUnitTest`
- Integración (emulador): `flutter test integration_test -d <device>`
- APK de debug: `flutter build apk --debug`
- Inspeccionar alarmas programadas: `adb shell dumpsys alarm | grep -A3 gentlealarm`

## Entorno
- Flutter estable (la versión exacta está en el README del repo), JDK 17 y Android SDK 35 con un emulador de API 34.
- No hay variables de entorno ni secretos en tiempo de ejecución. La única red es `api.open-meteo.com` y `geocoding-api.open-meteo.com`.
- Las pruebas manuales que requieran dispositivo real se anotan en la tarea con el modelo y la versión de Android.
