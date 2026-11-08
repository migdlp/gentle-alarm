# Requisitos

Prioridad: Must / Should / Could / Won't (esta versión).

## Flujos

### Flujo 1: Crear una alarma
1. En la lista de alarmas, la persona pulsa el botón flotante «+».
2. Se abre el editor con la hora por defecto 07:30, sin repetición, el sonido «Pájaros al alba», amanecer de 20 min, rampa de 3 min, volumen máximo del 70 %, vibración activada y etiqueta vacía.
3. Elige la hora, los días y las opciones, y pulsa «Guardar».
4. Vuelve a la lista con la alarma activada y un snackbar: «Sonará en 7 h 20 min».

Estados: lista vacía → ilustración de sol y «Aún no tienes alarmas. Crea la primera y despierta con calma.» con el botón «Crear alarma».

### Flujo 2: Despertar (camino feliz)
1. A las T − 20 min el móvil enciende la pantalla sobre la pantalla de bloqueo con un fondo casi negro (brillo al 1 %).
2. Durante 20 min el color pasa por rojo profundo, naranja y amarillo cálido hasta blanco cálido, y el brillo sube al 100 %.
3. A la hora T empieza el sonido elegido al 0 % del volumen y sube al máximo en 3 min. Aparecen la hora grande, un sol deslizable y el botón «Un ratito más».
4. La persona desliza el sol hacia arriba. El sonido se apaga en 2 s y aparece «¿Ya estás despierto/a?» con el botón «Sí, buenos días».
5. Lo pulsa y ve el saludo: la hora, el tiempo de su ciudad y una frase amable. Pulsa «Empezar el día» y se cierra la pantalla.

### Flujo 3: Posponer
1. Mientras suena, pulsa «Un ratito más».
2. El sonido se apaga y la pantalla queda en luz cálida tenue (brillo al 15 %) con «Vuelvo en 10:00», una cuenta atrás y el botón «Ya me levanto».
3. A los 10 min la luz sube al 100 % en 1 min y el sonido empieza de nuevo con una rampa de 3 min.
4. Tras posponer 3 veces, el botón desaparece y se muestra «Ya no quedan más ratitos».

### Flujo 4: Nadie apaga la alarma (escalada suave)
1. El tramo de sonido empieza (rampa de 3 min).
2. A los 5 min del tramo se añade una vibración suave.
3. A los 15 min sin interacción la alarma se autopospone 10 min (una vez por ocurrencia).
4. Vuelve a sonar. Si a los 15 min de este tramo sigue sin interacción, se para y deja la notificación «Alarma no atendida · 07:30».

### Flujo 5: Primer arranque
1. Bienvenida: «Despierta con luz, no con sustos».
2. Pasos de permisos con su explicación: notificaciones, alarmas exactas (si aplica) y pantalla completa (Android 14+), y la guía de batería en los fabricantes que cierran apps.
3. Consejo: «Deja el móvil boca arriba y cargando para ver el amanecer».
4. Se llega a la lista vacía.

## Requisitos funcionales

### Gestión de alarmas
| ID | Requisito | Prioridad | Criterio de aceptación |
|---|---|---|---|
| RF-01 | Crear una alarma con hora (HH:mm), días de repetición (0-7 días; 0 = una sola vez), etiqueta opcional (máx. 40 caracteres), sonido, duración del amanecer (0, 5, 10, 15, 20, 30 o 45 min; 0 = sin amanecer), duración de la rampa (1, 2, 3, 5 o 10 min), volumen máximo (10-100 %, en pasos de 10) y vibración (sí/no) | Must | La alarma guardada se lista con esos valores y queda programada |
| RF-02 | Editar todos los campos de una alarma existente | Must | Al guardar se reprograma con los valores nuevos |
| RF-03 | Activar o desactivar una alarma con un interruptor en la lista | Must | Desactivada no suena; al activarla se programa la siguiente ocurrencia |
| RF-04 | Borrar una alarma deslizándola en la lista, con «Deshacer» durante 5 s | Must | Tras 5 s sin deshacer se elimina y se desprograma; con «Deshacer» vuelve con su estado anterior |
| RF-05 | La lista muestra en la cabecera la próxima alarma: «Próxima: mañana a las 07:30 (en 7 h 20 min)» | Must | Coincide con la siguiente ocurrencia real de todas las alarmas activadas |
| RF-06 | Una alarma de una sola vez se desactiva sola después de su sesión (atendida o no) | Must | Tras sonar, su interruptor aparece desactivado |
| RF-07 | «Saltar la próxima» en el menú de la alarma repetida: omite sólo la siguiente ocurrencia | Should | La siguiente ocurrencia no suena; la posterior sí. La fila muestra «Se salta el mar 10» |
| RF-08 | Los ajustes guardan los valores por defecto de alarmas nuevas (amanecer, rampa, volumen, vibración y sonido) | Must | Una alarma nueva se abre con los valores de los ajustes |
| RF-09 | La hora se muestra en formato de 24 h o 12 h según el ajuste del sistema | Must | Con el sistema en 12 h se ve «7:30 a. m.» |

### Amanecer
| ID | Requisito | Prioridad | Criterio de aceptación |
|---|---|---|---|
| RF-10 | A las T − duración del amanecer se abre a pantalla completa, sobre la pantalla de bloqueo y con la pantalla encendida, la vista de amanecer | Must | Con el móvil bloqueado y la pantalla apagada, la pantalla se enciende a la hora prevista |
| RF-11 | El color y el brillo del amanecer dependen sólo del tiempo transcurrido (función pura `sunriseFrame(progress)`); el brillo de la ventana va de 0,01 a 1,0 con curva de entrada cuadrática | Must | Las pruebas unitarias verifican los fotogramas al 0, 25, 50, 75 y 100 % |
| RF-12 | Si se crea o activa la alarma cuando falta menos que la duración del amanecer, el amanecer empieza en ese momento con el progreso que corresponda; si falta menos de 1 min, no hay amanecer | Must | Prueba unitaria del cálculo del inicio |
| RF-13 | Al tocar la pantalla durante el amanecer aparece una hoja con «Suena a las 07:30», «Ya estoy despierto/a» (termina la ocurrencia y pasa al saludo) y «Seguir durmiendo» (cierra la hoja) | Must | Las dos opciones funcionan |
| RF-14 | Durante el amanecer sólo se muestra la hora con una opacidad del 10 %, sin ningún otro texto | Must | Revisión visual |
| RF-15 | Si la batería está al 10 % o menos y el móvil no está cargando al empezar el amanecer, no se enciende la pantalla y la alarma sólo suena a la hora T | Must | Prueba unitaria de la decisión, más una prueba manual |
| RF-16 | Si el móvil está en uso (desbloqueado e interactivo) al empezar el amanecer, no se fuerza la pantalla: se publica la notificación «Amanecer en curso · Suena a las 07:30» con la acción «Ver amanecer» | Should | Prueba manual |

### Sonido y escalada
| ID | Requisito | Prioridad | Criterio de aceptación |
|---|---|---|---|
| RF-20 | A la hora T empieza a sonar el sonido de la alarma en bucle con `USAGE_ALARM`, en un servicio en primer plano, aunque la app esté cerrada | Must | Suena con la app cerrada desde recientes y con No molestar activado |
| RF-21 | La rampa sube el volumen del reproductor de 0 a 1 en la duración de la rampa, con curva perceptual (`v = p²`), actualizando cada 250 ms | Must | Prueba unitaria de la curva y prueba manual de que no hay saltos |
| RF-22 | Mientras dura la sesión, el volumen del flujo de alarma del sistema se fija al volumen máximo de la alarma; al acabar la sesión se restaura el valor anterior | Must | Tras apagar, el volumen de alarma del sistema vuelve a su valor previo |
| RF-23 | A los 5 min de un tramo de sonido, si la vibración está activada, empieza una vibración suave (patrón 0-400 ms on, 1600 ms off, amplitud 80/255) | Must | Prueba unitaria de la máquina de estados y prueba manual |
| RF-24 | A los 15 min de un tramo sin interacción se autopospone 10 min si no se ha usado ya el autoposponer en esta ocurrencia; si ya se usó, la sesión termina como no atendida | Must | Pruebas unitarias de la máquina de estados |
| RF-25 | Una sesión no atendida publica la notificación «Alarma no atendida · {hora}» con el texto «No te hemos querido despertar a gritos. ¿Todo bien?» | Must | Prueba manual |
| RF-26 | Si llega una llamada (pérdida del foco de audio), el sonido se pausa y los temporizadores de escalada se congelan; al recuperar el foco el sonido vuelve con una rampa de 30 s desde el 0 % | Must | Prueba manual con llamada entrante |
| RF-27 | Si el sonido elegido no se puede leer (archivo propio borrado o sin permiso), se usa «Pájaros al alba» y la sesión registra `soundFallback=true` | Must | Prueba unitaria de la elección y prueba manual borrando el archivo |

### Apagar, posponer y saludo
| ID | Requisito | Prioridad | Criterio de aceptación |
|---|---|---|---|
| RF-30 | Para apagar se desliza hacia arriba un sol de 96 dp de diámetro al menos 160 dp; si se suelta antes, vuelve a su sitio con animación | Must | Prueba de widget |
| RF-31 | Al deslizar, el sonido baja a 0 en 2 s y aparece la confirmación «¿Ya estás despierto/a?» con el botón «Sí, buenos días» | Must | Prueba de widget y de la máquina de estados |
| RF-32 | Si la confirmación no se pulsa en 60 s, empieza un tramo nuevo con volumen inicial del 20 % y la rampa normal hasta el máximo; cuenta como tramo de sonido para la escalada | Must | Prueba unitaria de la máquina de estados |
| RF-33 | «Un ratito más» pospone 10 min, como máximo 3 veces por ocurrencia; el autoposponer no cuenta para ese límite | Must | Pruebas unitarias |
| RF-34 | Al posponer, la pantalla queda con luz cálida (`#FFB36B`) al 15 % de brillo, la cuenta atrás «Vuelvo en mm:ss» y el botón «Ya me levanto» (va a la confirmación) | Must | Prueba de widget |
| RF-35 | Al volver de posponer, el brillo sube del 15 % al 100 % en 60 s y empieza un tramo con rampa normal | Must | Prueba unitaria de la máquina de estados |
| RF-36 | Tras confirmar se muestra el saludo: hora grande, línea del tiempo («12 °C · Soleado en Madrid» u omitida si no hay datos), una frase aleatoria de la lista de su idioma y el botón «Empezar el día», que cierra la pantalla | Must | Prueba de widget con y sin datos del tiempo |
| RF-37 | La pantalla de la alarma no se cierra con el botón Atrás ni con gestos del sistema mientras suena o está pospuesta | Must | Prueba manual |

### Programación y fiabilidad
| ID | Requisito | Prioridad | Criterio de aceptación |
|---|---|---|---|
| RF-40 | Cada ocurrencia se programa con `AlarmManager.setAlarmClock` en el instante del inicio del amanecer (o en T si no hay amanecer) | Must | Prueba instrumentada o manual con `adb shell dumpsys alarm` |
| RF-41 | Tras un reinicio (`BOOT_COMPLETED` y `LOCKED_BOOT_COMPLETED`), una actualización de la app (`MY_PACKAGE_REPLACED`) o un cambio de hora o zona horaria (`TIME_SET` y `TIMEZONE_CHANGED`), se reprograman todas las alarmas activadas | Must | Prueba manual de cada evento |
| RF-42 | Si al arrancar el móvil hay una ocurrencia cuya T pasó hace 30 min o menos y no se atendió, la sesión empieza ya, sin amanecer; si pasó hace más de 30 min, se publica «Alarma no atendida» | Must | Prueba unitaria y manual |
| RF-43 | Las horas se guardan como hora local más días; la siguiente ocurrencia se calcula con `java.time` en la zona actual. En el salto de primavera, una hora inexistente suena desplazada lo que dure el salto (02:30 → 03:30); en el retroceso de otoño, una hora ambigua suena en la primera aparición | Must | Pruebas unitarias con `Europe/Madrid` |
| RF-44 | Sólo hay una sesión activa a la vez. Si otra alarma se dispara durante una sesión, se marca como absorbida, no suena y se programa su siguiente ocurrencia | Must | Prueba unitaria |
| RF-45 | Si dos alarmas tienen el amanecer solapado, se muestra sólo el amanecer de la que suena antes; la otra empieza directamente en su T si la primera ya terminó | Should | Prueba unitaria |

### Permisos y primer uso
| ID | Requisito | Prioridad | Criterio de aceptación |
|---|---|---|---|
| RF-50 | En el primer arranque, un onboarding pide en orden: notificaciones (Android 13+), pantalla completa (Android 14+, si `canUseFullScreenIntent()` es falso, abre su ajuste) y la guía de batería en los fabricantes de la lista | Must | Prueba de widget por paso y prueba manual en Android 14 |
| RF-51 | Si falta un permiso crítico, la lista muestra el banner «Tu alarma podría no sonar» con el botón «Arreglarlo», que abre el paso correspondiente | Must | Prueba de widget con permisos simulados |
| RF-52 | «Probar despertar» en el editor lanza una sesión de vista previa de 60 s: 30 s de amanecer acelerado y 30 s de sonido con la rampa acelerada; se puede apagar o posponer (posponer en vista previa = 10 s) | Should | Prueba manual |
| RF-53 | Guía de batería para Xiaomi, Redmi, POCO, Huawei, Honor, OPPO, realme, vivo, OnePlus y Samsung: texto específico por marca y botón que abre los ajustes de batería de la app | Should | Prueba de widget con fabricante simulado |

### Sonidos
| ID | Requisito | Prioridad | Criterio de aceptación |
|---|---|---|---|
| RF-60 | La app incluye 6 sonidos CC0: «Pájaros al alba» (por defecto), «Olas suaves», «Lluvia ligera», «Campanillas», «Piano tranquilo» y «Cuencos» | Must | Están en `android/app/src/main/res/raw/` con la licencia en `assets/sounds/LICENSES.md` |
| RF-61 | El selector de sonido permite escuchar cada uno 10 s (con fundido de entrada de 1 s) antes de elegirlo | Must | Prueba manual |
| RF-62 | «Elegir de mi móvil» abre el selector de documentos del sistema (audio/*), guarda la URI con permiso persistente y muestra el nombre del archivo | Must | Tras reiniciar el móvil sigue sonando el archivo elegido |

### Saludo y tiempo
| ID | Requisito | Prioridad | Criterio de aceptación |
|---|---|---|---|
| RF-70 | En ajustes, «Ciudad para el tiempo» busca ciudades con la API de geocodificación de Open-Meteo (mínimo 2 caracteres, espera de 400 ms entre pulsaciones, 10 resultados) y guarda nombre, latitud y longitud | Must | Prueba unitaria del cliente con respuesta simulada |
| RF-71 | Al empezar el amanecer (o en T si no hay amanecer) se pide el tiempo actual a Open-Meteo con un límite de 5 s y se guarda en caché; el saludo usa la caché si tiene menos de 3 h | Must | Pruebas unitarias del repositorio |
| RF-72 | Sin ciudad configurada, sin red o con error, el saludo omite la línea del tiempo sin mostrar ningún error | Must | Prueba de widget |
| RF-73 | Hay 12 frases por idioma en los ARB (`greetingPhrase1`…`greetingPhrase12`) y se elige una al azar distinta de la del día anterior | Must | Prueba unitaria del selector |

### Identidad visual
| ID | Requisito | Prioridad | Criterio de aceptación |
|---|---|---|---|
| RF-90 | La app tiene un icono adaptativo (un sol medio asomando sobre una línea de horizonte, en `coral` sobre fondo `night`) y un icono monocromo para los iconos temáticos de Android 13+ | Must | El launcher lo muestra en Android 8 y en Android 13+ con iconos temáticos |

## Casos límite (resumen y decisiones)

| ID | Situación | Comportamiento |
|---|---|---|
| RF-80 | Etiqueta vacía o sólo con espacios | Se guarda como vacía y la lista muestra «Alarma» |
| RF-81 | Dos alarmas con la misma hora y los mismos días | Se permite; sólo suena la primera según RF-44 y la otra se absorbe |
| RF-82 | Se edita una alarma durante su propia sesión activa | Los cambios se guardan pero la sesión en curso sigue con la configuración inicial; la nueva se aplica en la siguiente ocurrencia |
| RF-83 | Se borra una alarma durante su sesión activa | La sesión sigue hasta que termine y después no se reprograma |
| RF-84 | El móvil está en silencio, en vibración o en No molestar | La alarma suena igual (flujo de alarma y categoría `CATEGORY_ALARM`) |
| RF-85 | Cascos Bluetooth conectados | Se usa la salida que elija el sistema para `USAGE_ALARM` (Android la duplica en el altavoz); no se fuerza nada |

## Requisitos no funcionales

| ID | Categoría | Requisito | Cómo se verifica |
|---|---|---|---|
| RNF-01 | Fiabilidad | La alarma suena a su hora con un error de ±5 s en Doze, con el móvil bloqueado, con la app cerrada desde recientes y tras reiniciar | Matriz manual E09-T02 |
| RNF-02 | Rendimiento | La pantalla de amanecer se pinta a 30 fps o más sin dejar caer fotogramas visibles; el gradiente se recalcula cada 500 ms con interpolación animada | Perfil en modo profile en un móvil de gama media |
| RNF-03 | Batería | Sin sesión activa, la app no mantiene servicios, wakelocks ni trabajos periódicos | `adb shell dumpsys batterystats` sin wakelocks de la app |
| RNF-04 | Accesibilidad | Todos los controles tienen etiqueta para TalkBack; el deslizar el sol tiene la acción alternativa «Apagar alarma»; los textos escalan hasta el 200 % sin cortarse; con «Eliminar animaciones» activo se reducen las animaciones | Pruebas de widget de semántica y revisión manual con TalkBack |
| RNF-05 | Contraste | Texto con contraste mínimo de 4,5:1 sobre su fondo en todas las pantallas, incluidos los fotogramas del amanecer donde hay texto | Prueba unitaria de contraste en las paletas |
| RNF-06 | Privacidad | Sin analítica ni rastreo. La única petición de red es a `api.open-meteo.com` y `geocoding-api.open-meteo.com`, con coordenadas de la ciudad elegida y no del GPS | Revisión de código y política de privacidad |
| RNF-07 | i18n | Todos los textos de la interfaz en ARB, en español (por defecto) e inglés; la app sigue el idioma del sistema | `flutter gen-l10n` sin claves sin traducir |
| RNF-08 | Calidad | `flutter analyze` sin avisos, `flutter test` y `./gradlew testDebugUnitTest` en verde en CI en cada PR | GitHub Actions |
| RNF-09 | Compatibilidad | Android 8.0 (API 26) a la última versión estable; probado en API 26, 33, 34 y 35 o superior | Emuladores en CI más la matriz manual |
| RNF-10 | Almacenamiento | Los datos de las alarmas se guardan en almacenamiento protegido del dispositivo (`createDeviceProtectedStorageContext`) para poder reprogramar antes del primer desbloqueo | Prueba manual: reiniciar sin desbloquear y comprobar que suena |
