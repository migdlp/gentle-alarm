# Riesgos, supuestos y preguntas abiertas

## Riesgos

| ID | Riesgo | Probabilidad | Impacto | Mitigación | Tarea |
|---|---|---|---|---|---|
| R-01 | Fabricantes con gestión de batería agresiva (Xiaomi, Huawei, OPPO, vivo, Samsung) matan el proceso o retrasan la alarma | Alta | Alto | `setAlarmClock` (exento de Doze), servicio en primer plano con wakelock, guía de batería por marca y matriz con un Xiaomi o un Samsung real | E02-T04, E07-T02, E09-T02 |
| R-02 | Play rechaza el tipo de servicio `systemExempted` o la declaración de `USE_EXACT_ALARM` | Media | Alto | ADR-06 trae el plan B (`mediaPlayback` reproduciendo en silencio desde el amanecer); la declaración justifica que la función principal es despertar | E09-T03 |
| R-03 | El permiso de pantalla completa está revocado en Android 14+ y el amanecer no se ve | Media | Medio | Onboarding, banner de salud y, como respaldo, notificación con acciones; el sonido suena igualmente | E07-T01, E07-T03 |
| R-04 | El móvil está boca abajo o dentro de un cajón y el amanecer no surte efecto | Media | Bajo | Consejo en el onboarding; el sonido progresivo despierta igual | E07-T02 |
| R-05 | Fallo del motor de Flutter en `RingActivity` | Baja | Medio | ADR-04: audio y escalada nativos, y notificación con Apagar y Posponer | E04-T03 |
| R-06 | Bucles de audio con cortes audibles | Media | Bajo | Requisitos de ADR-12 y escucha manual en E05-T01 | E05-T01 |
| R-07 | Pantalla encendida 20 min con batería baja | Media | Medio | RF-15 (umbral del 10 %) | E04-T04 |
| R-08 | Open-Meteo cambia o limita su API gratuita | Baja | Bajo | El saludo funciona sin el tiempo (RF-72) | E06-T01 |

## Supuestos

| ID | Supuesto | Si resulta falso |
|---|---|---|
| SUPUESTO-1 | Nombre visible «Despertar suave» (es) y «Gentle Alarm» (en) | Se cambian `app_name` en `strings.xml` (values y values-en) y `appTitle` en los ARB |
| SUPUESTO-2 | Los sonidos son CC0 de Freesound.org elegidos por el ejecutor según el criterio de E05-T01 y validados por el propietario | El propietario aporta sus archivos con los mismos nombres |
| SUPUESTO-3 | El propietario tiene o creará una cuenta de desarrollador de Google Play (25 USD, pago único) | Se distribuye el APK firmado a mano |
| SUPUESTO-4 | La persona deja el móvil en la mesilla con la pantalla hacia arriba | Ver R-04 |
| SUPUESTO-5 | Open-Meteo se usa sin clave porque la app es gratuita y no comercial | Si se monetiza, contratar un plan comercial de Open-Meteo |
| SUPUESTO-6 | Las frases del saludo (12 por idioma, en E06-T03) las aprueba el propietario | Se sustituyen en los ARB |

## Preguntas abiertas

| ID | Pregunta | Propuesta por defecto | Bloquea | Responsable |
|---|---|---|---|---|
| PA-1 | ¿Nombre comercial definitivo e icono? | «Despertar suave» / «Gentle Alarm», con un icono de un sol medio asomando sobre una línea de horizonte en `coral` sobre `night` | E09-T03 (ficha de Play) | Propietario |
| PA-2 | ¿Se planifica la fase 2 (iOS con AlarmKit, rutina para dormir, bombillas inteligentes)? | Sí, en un plan aparte después de publicar la v1 | Nada de la v1 | Propietario |
