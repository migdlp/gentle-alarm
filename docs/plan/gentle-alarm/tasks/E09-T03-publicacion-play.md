---
id: E09-T03
title: Preparar la publicación en Google Play (firma, privacidad, ficha y declaraciones)
epic: E09
status: todo
depends_on: [E09-T02, E08-T02]
requirements: [RNF-06]
size: M
---

# E09-T03 · Preparar la publicación en Google Play (firma, privacidad, ficha y declaraciones)

## Objetivo
Hay un `.aab` firmado de release, una política de privacidad publicada y todos los textos y declaraciones de Play Console listos para que el propietario suba la versión a la prueba interna.

## Contexto
- SUPUESTO-3: el propietario tiene la cuenta de desarrollador. La subida y el envío a revisión los hace el propietario; el agente prepara los materiales.
- Firma: `keytool -genkeypair -v -keystore ~/gentle-alarm-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload` (lo ejecuta el propietario); `android/key.properties` (fuera de Git) con `storePassword`, `keyPassword`, `keyAlias` y `storeFile`; `build.gradle.kts` lee `key.properties` si existe y, si no, firma con debug.
- Declaraciones en Play Console:
  - `USE_EXACT_ALARM`: «La función principal de la app es un despertador que debe sonar a una hora exacta elegida por la persona.»
  - Pantalla completa: «Despertador: muestra la alarma a pantalla completa sobre la pantalla de bloqueo.»
  - Servicio en primer plano `systemExempted`: «Mantiene activa la alarma mientras suena y durante la fase de amanecer previa.» Si se rechaza → plan B de ADR-06 en un issue nuevo.
  - Seguridad de los datos: no recoge ni comparte datos. La petición a Open-Meteo envía las coordenadas de una ciudad elegida a mano, sin identificadores.
- Política de privacidad (es/en), publicada en GitHub Pages del repo (`docs/privacy/index.md`): qué no se recoge, la llamada a Open-Meteo, los sonidos propios (sólo se leen en el dispositivo) y el contacto (el email que indique el propietario en la PR).
- Icono de 512 × 512 PNG exportado de `ic_launcher_foreground.xml` sobre el fondo `night` (`docs/release/icon-512.png`). Ficha: título (PA-1), descripción corta (≤ 80 caracteres): «Despierta con un amanecer en tu pantalla y sonidos que suben poco a poco.» / «Wake up to a sunrise on your screen and sounds that rise gently.»; descripción larga de 4 párrafos (amanecer, sonido suave, apagar con calma, privacidad); 4 capturas (lista, amanecer al 50 %, sonando y saludo) a 1080 × 1920.

## Archivos
- Modificar: `android/app/build.gradle.kts`
- Crear: `docs/privacy/index.md`, `docs/release/play-listing.md` (textos de la ficha y de las declaraciones) , `docs/release/screenshots/` (4 PNG) y `docs/release/icon-512.png`

## Pasos
1. Configura la firma condicional y comprueba que `flutter build appbundle --release --dart-define=APP_VERSION=1.0.0` funciona con la firma debug cuando no hay `key.properties`.
2. Escribe `privacy/index.md` y `play-listing.md` con los textos de arriba.
3. Captura las pantallas desde un emulador de 1080 × 1920 (la vista previa de E07-T04 permite capturar el amanecer y sonando).
4. Activa GitHub Pages en `docs/` (lo hace el propietario) y anota la URL de la política.

## Criterios de aceptación
- [ ] `flutter build appbundle --release` genera el `.aab`.
- [ ] `key.properties` y `*.jks` no están en Git (`git ls-files | grep -E "jks|key.properties"` vacío).
- [ ] `play-listing.md` contiene la ficha y las 3 declaraciones.
- [ ] La política de privacidad tiene una URL pública.

## Verificación
```bash
flutter build appbundle --release --dart-define=APP_VERSION=1.0.0
git ls-files | grep -E "jks|key.properties" || echo "sin secretos"
```

## Fuera de alcance
- Subir a Play y responder a la revisión (propietario).

## Si te bloqueas
- Si PA-1 (nombre e icono) sigue abierta, usa el nombre del SUPUESTO-1 y el icono propuesto en PA-1, y anótalo.
