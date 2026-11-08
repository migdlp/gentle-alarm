# Sonidos

Los 6 sonidos de `android/app/src/main/res/raw/` son de **síntesis propia**: los genera `generate_sounds.py` (numpy + ffmpeg/libvorbis) con semilla fija, sin muestras de terceros. Se dedican al dominio público bajo **CC0 1.0** (https://creativecommons.org/publicdomain/zero/1.0/).

| Archivo | Descripción | Autor | Origen | Licencia | Fecha |
|---|---|---|---|---|---|
| birds_dawn.ogg | Trinos sintéticos (barridos de seno) sobre un lecho suave | Proyecto Gentle Alarm | `generate_sounds.py` | CC0 1.0 | 2026-11-08 |
| soft_waves.ogg | Ruido rosa filtrado con oleaje lento | Proyecto Gentle Alarm | `generate_sounds.py` | CC0 1.0 | 2026-11-08 |
| light_rain.ogg | Ruido filtrado y gotas aleatorias | Proyecto Gentle Alarm | `generate_sounds.py` | CC0 1.0 | 2026-11-08 |
| chimes.ogg | Campanillas pentatónicas con parciales inarmónicos | Proyecto Gentle Alarm | `generate_sounds.py` | CC0 1.0 | 2026-11-08 |
| calm_piano.ogg | Notas tipo piano en escala pentatónica | Proyecto Gentle Alarm | `generate_sounds.py` | CC0 1.0 | 2026-11-08 |
| singing_bowls.ogg | Cuencos con parciales inarmónicos y batido lento | Proyecto Gentle Alarm | `generate_sounds.py` | CC0 1.0 | 2026-11-08 |

Cada archivo dura 60 s, es estéreo a 44,1 kHz, con bucle por fundido cruzado de 2 s y fundido de entrada de 2 s.
Si el propietario prefiere grabaciones reales (SUPUESTO-2, Freesound CC0), basta con sustituir los `.ogg` y actualizar esta tabla.
