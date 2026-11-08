# Ficha de Google Play y declaraciones

> Nombre provisional (SUPUESTO-1 / PA-1 abierta): «Despertar suave» (es) · «Gentle Alarm» (en). Icono: `docs/release/icon-512.png` (propuesta de PA-1: sol asomando sobre el horizonte, sobre `#0B1026`).

## Ficha (es)
**Título:** Despertar suave
**Descripción corta (≤ 80):** Despierta con un amanecer en tu pantalla y sonidos que suben poco a poco.

**Descripción larga:**
Despertar suave te despierta con calma. Durante los minutos anteriores a la hora, la pantalla simula un amanecer: del azul noche al naranja y, por fin, a una luz cálida, mientras el brillo sube despacio.

A la hora, el sonido empieza casi en silencio y sube poco a poco. Elige entre seis sonidos naturales (pájaros, olas, lluvia, campanillas, piano y cuencos) o usa un archivo de tu móvil. Si lo necesitas, hay una vibración suave y un «ratito más» hasta tres veces.

Apagarla es un gesto tranquilo: desliza el sol hacia arriba y confirma que estás despierto/a. Después te damos los buenos días con la hora, el tiempo de tu ciudad (opcional) y una frase amable.

Es gratuita, sin cuentas ni anuncios, y no recoge datos. El tiempo se consulta a Open-Meteo con una ciudad que eliges tú; la app no usa tu ubicación.

## Listing (en)
**Title:** Gentle Alarm
**Short description (≤ 80):** Wake up to a sunrise on your screen and sounds that rise gently.

**Full description:**
Gentle Alarm wakes you up calmly. In the minutes before your alarm, the screen simulates a sunrise: from night blue to orange and finally a warm light, as the brightness slowly rises.

At the set time, the sound starts almost silent and builds up gradually. Pick one of six natural sounds (birds, waves, rain, chimes, piano and singing bowls) or use a file from your phone. If you need it, there's a soft vibration and a "little longer" snooze up to three times.

Turning it off is a calm gesture: slide the sun up and confirm you're awake. Then we say good morning with the time, your city's weather (optional) and a kind phrase.

It's free, with no accounts or ads, and collects no data. Weather is requested from Open-Meteo for a city you choose; the app doesn't use your location.

## Capturas (1080 × 1920)
`docs/release/screenshots/`: `1-lista.png`, `2-amanecer.png` (50 %), `3-sonando.png`, `4-saludo.png`. Generadas con `GENERATE_SCREENSHOTS=1 flutter test test/tool` (renderizado de widgets con Nunito); el propietario puede sustituirlas por capturas de emulador.

## Declaraciones en Play Console
- **`USE_EXACT_ALARM`:** «La función principal de la app es un despertador que debe sonar a una hora exacta elegida por la persona.»
- **Pantalla completa (`USE_FULL_SCREEN_INTENT`):** «Despertador: muestra la alarma a pantalla completa sobre la pantalla de bloqueo.»
- **Servicio en primer plano `systemExempted`:** «Mantiene activa la alarma mientras suena y durante la fase de amanecer previa.» Si se rechaza → plan B de ADR-06 (`mediaPlayback`) en un issue nuevo.
- **Seguridad de los datos:** la app no recoge ni comparte datos. La petición a Open-Meteo envía las coordenadas de una ciudad elegida a mano, sin identificadores.
- **Política de privacidad:** `docs/privacy/index.md`; URL pública pendiente de activar GitHub Pages en `docs/` (lo hace el propietario).

## Firma y compilación
1. El propietario genera la clave de subida: `keytool -genkeypair -v -keystore ~/gentle-alarm-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`.
2. Crea `android/key.properties` (fuera de Git) con `storePassword`, `keyPassword`, `keyAlias` y `storeFile`.
3. `flutter build appbundle --release --dart-define=APP_VERSION=1.0.0` → `build/app/outputs/bundle/release/app-release.aab`. Sin `key.properties` firma con debug (solo para pruebas locales).
