---
id: E06-T03
title: Pantalla de saludo con hora, tiempo y frase amable
epic: E06
status: done
depends_on: [E06-T01, E04-T09]
requirements: [RF-36, RF-71, RF-72, RF-73]
size: M
---

# E06-T03 · Pantalla de saludo con hora, tiempo y frase amable

## Objetivo
Tras confirmar que estás despierto/a, el estado `greeting` muestra la hora, el tiempo de tu ciudad (si lo hay) y una frase amable, y «Empezar el día» cierra la pantalla.

## Contexto
- Al entrar en `RingRoot` con un estado `sunrise` o `ringing` (primera vez de la sesión), lanza `weatherRepository.refresh()` sin esperarlo (RF-71).
- Greeting: fondo crema (p = 1). Arriba `greetingTitle` (32 sp); la hora (72 sp); la línea del tiempo `weatherLine` si `cachedFresh()` no es null y el código WMO tiene clave (§5.5), y si no se omite (RF-72); la frase (20 sp, cursiva no, opacidad 0,85); y el `FilledButton` `startDay` → `ringChannel.finishGreeting()`.
- Frase: índice aleatorio entre 1 y 12 distinto de `greeting.lastIndex`; se guarda el nuevo índice (RF-73). Selector puro `pickPhraseIndex(Random rng, int lastIndex) → int`.
- Correspondencia WMO → clave: 0 `weatherClear`; 1-3 `weatherPartlyCloudy`; 45, 48 `weatherFog`; 51-57 `weatherDrizzle`; 61-67 y 80-82 `weatherRain`; 71-77 y 85-86 `weatherSnow`; 95-99 `weatherStorm`.
- Textos:
| Clave | es | en |
|---|---|---|
| `greetingTitle` | Buenos días | Good morning |
| `weatherLine` | {temp} °C · {condition} en {city} | {temp} °C · {condition} in {city} |
| `startDay` | Empezar el día | Start the day |
| `weatherClear` | Despejado | Clear |
| `weatherPartlyCloudy` | Algo nublado | Partly cloudy |
| `weatherFog` | Niebla | Fog |
| `weatherDrizzle` | Llovizna | Drizzle |
| `weatherRain` | Lluvia | Rain |
| `weatherSnow` | Nieve | Snow |
| `weatherStorm` | Tormenta | Storm |
- Frases (SUPUESTO-6), `greetingPhrase1` a `greetingPhrase12`:
| n | es | en |
|---|---|---|
| 1 | Hoy no hace falta correr. Un paso cada vez. | No need to rush today. One step at a time. |
| 2 | Bebe un vaso de agua: tu cuerpo te lo agradecerá. | Have a glass of water: your body will thank you. |
| 3 | Respira hondo tres veces antes de levantarte. | Take three deep breaths before you get up. |
| 4 | Lo que hoy salga bien, cuenta. Lo demás, también. | What goes well today counts. The rest does too. |
| 5 | Abre la ventana y deja entrar el día. | Open the window and let the day in. |
| 6 | Estírate como si nadie te viera. | Stretch like nobody's watching. |
| 7 | Has descansado. Ahora, a por un buen día. | You've rested. Now, on to a good day. |
| 8 | Elige una cosa pequeña que te haga ilusión hoy. | Pick one small thing to look forward to today. |
| 9 | La luz ya está aquí. Tú también. | The light is here. So are you. |
| 10 | Despacio también se llega. | Slowly still gets you there. |
| 11 | Sonríe un segundo: es gratis y funciona. | Smile for a second: it's free and it works. |
| 12 | Hoy empieza algo nuevo, aunque sea pequeño. | Something new starts today, even if it's small. |

## Archivos
- Crear: `lib/src/features/greeting/domain/phrase_picker.dart`, `lib/src/features/greeting/domain/weather_text.dart` (`String? weatherConditionText(AppLocalizations, int code)`), `lib/src/features/ring/ui/greeting_view.dart`, `test/features/greeting/phrase_picker_test.dart`, `test/features/greeting/weather_text_test.dart` y `test/features/ring/ui/greeting_view_test.dart`
- Modificar: `ring_root.dart` (refresco del tiempo y vista greeting) y los dos ARB

## Pasos
1. RED: `pickPhraseIndex` nunca devuelve `lastIndex` (1 000 iteraciones con semilla) y siempre está en 1-12; `weatherConditionText` para 0, 2, 45, 63, 73, 96 y 4 (→ null); la vista con caché válida muestra «12 °C · Despejado en Madrid»; la vista sin caché no muestra la línea ni ningún error; tocar `startDay` llama a `finishGreeting`.
2. Implementa. `temp` redondeado a entero (`round()`).
3. GREEN.

## Criterios de aceptación
- [ ] Las 5 pruebas pasan.
- [ ] Manual: con la ciudad configurada y red, el saludo muestra el tiempo; en modo avión, se omite sin error.

## Verificación
```bash
flutter gen-l10n && flutter analyze && flutter test test/features/greeting test/features/ring
```

## Fuera de alcance
- Voz (TTS), que no entra en la v1.

## Si te bloqueas
- Si el saludo aparece antes de que llegue el tiempo, no esperes: muestra lo que haya en la caché en ese momento (RF-72).

## Notas de implementación
- phrase_picker, weather_text (+greetingPhrase), GreetingView (hora, tiempo opcional, frase sin repetir la anterior guardada en greeting.lastIndex, «Empezar el día») y refresco del tiempo en RingRoot al primer sunrise/ringing. 5 pruebas pedidas + extras OK. Pendiente manual: tiempo real y modo avión.
