#!/usr/bin/env python3
"""Genera los 6 sonidos de Gentle Alarm de forma procedimental (síntesis propia).

Uso: python3 generate_sounds.py <directorio_salida>
Requiere numpy y ffmpeg (con libvorbis). Resultado dedicado al dominio público (CC0 1.0).
"""
import subprocess
import sys
import wave

import numpy as np

SR = 44100
DUR = 60
XF = 2  # segundos de fundido cruzado para el bucle
rng = np.random.default_rng(7)


def lowpass(x, cutoff):
    f = np.fft.rfft(x)
    fr = np.fft.rfftfreq(len(x), 1 / SR)
    f[fr > cutoff] = 0
    return np.fft.irfft(f, len(x))


def highpass(x, cutoff):
    f = np.fft.rfft(x)
    fr = np.fft.rfftfreq(len(x), 1 / SR)
    f[fr < cutoff] = 0
    return np.fft.irfft(f, len(x))


def pinkish(n):
    f = np.fft.rfft(rng.standard_normal(n))
    fr = np.fft.rfftfreq(n, 1 / SR)
    fr[0] = 1
    return np.fft.irfft(f / np.sqrt(fr), n)


def loopify(x):
    """Convierte x (DUR+XF segundos) en un bucle de DUR segundos sin corte."""
    n = DUR * SR
    xf = XF * SR
    out = x[:n].copy()
    tail = x[n:n + xf]
    w = np.linspace(0, 1, xf)
    out[:xf] = out[:xf] * w + tail * (1 - w)
    return out


def total():
    return (DUR + XF) * SR


def t_axis():
    return np.arange(total()) / SR


def note(freq, length, partials=((1, 1.0),), decay=1.5, attack=0.01):
    t = np.arange(int(length * SR)) / SR
    y = sum(a * np.sin(2 * np.pi * freq * k * t) for k, a in partials)
    env = np.minimum(t / attack, 1) * np.exp(-t / decay)
    return y * env


def place(buf, snd, at):
    i = int(at * SR)
    j = min(i + len(snd), len(buf))
    buf[i:j] += snd[: j - i]


def stereo(l, r):
    return np.stack([l, r], axis=1)


def soft_waves():
    t = t_axis()
    n = total()
    chans = []
    for ph in (0.0, 1.3):
        base = lowpass(pinkish(n), 1800)
        swell = 0.55 + 0.45 * np.sin(2 * np.pi * (1 / 9.0) * t + ph) ** 2
        chans.append(base * swell)
    return stereo(*[loopify(c) for c in chans])


def light_rain():
    n = total()
    chans = []
    for _ in range(2):
        bed = highpass(lowpass(rng.standard_normal(n), 9000), 1200) * 0.25
        drops = np.zeros(n)
        for at in rng.uniform(0, DUR + XF - 0.1, 900):
            d = highpass(rng.standard_normal(int(0.012 * SR)), 2500)
            d *= np.exp(-np.arange(len(d)) / (0.003 * SR)) * rng.uniform(0.1, 0.6)
            place(drops, d, at)
        chans.append(loopify(bed + drops))
    return stereo(*chans)


def birds_dawn():
    n = total()
    out = [np.zeros(n), np.zeros(n)]
    bed = lowpass(pinkish(n), 800) * 0.05
    for c in range(2):
        out[c] += bed
    t_now = 1.0
    while t_now < DUR + XF - 1.5:
        base = rng.uniform(2400, 4800)
        pan = rng.uniform(0.2, 0.8)
        for k in range(rng.integers(2, 6)):
            L = rng.uniform(0.08, 0.18)
            t = np.arange(int(L * SR)) / SR
            sweep = base * (1 + rng.uniform(-0.25, 0.35) * t / L)
            y = np.sin(2 * np.pi * np.cumsum(sweep) / SR)
            y *= np.sin(np.pi * t / L) ** 2 * 0.35
            place(out[0], y * (1 - pan), t_now + k * 0.15)
            place(out[1], y * pan, t_now + k * 0.15)
        t_now += rng.uniform(1.5, 5.0)
    return stereo(*[loopify(o) for o in out])


def chimes():
    n = total()
    out = [np.zeros(n), np.zeros(n)]
    scale = [784, 880, 987.8, 1174.7, 1318.5, 1568]
    t_now = 0.5
    while t_now < DUR + XF - 4:
        f = scale[rng.integers(0, len(scale))]
        y = note(f, 5.0, ((1, 1.0), (2.76, 0.25), (5.4, 0.08)), decay=1.4, attack=0.003) * 0.4
        pan = rng.uniform(0.2, 0.8)
        place(out[0], y * (1 - pan), t_now)
        place(out[1], y * pan, t_now)
        t_now += rng.uniform(1.2, 4.0)
    return stereo(*[loopify(o) for o in out])


def calm_piano():
    n = total()
    out = [np.zeros(n), np.zeros(n)]
    scale = [261.6, 293.7, 329.6, 392.0, 440.0, 523.3, 587.3]
    t_now = 0.5
    while t_now < DUR + XF - 5:
        f = scale[rng.integers(0, len(scale))]
        y = note(f, 6.0, ((1, 1.0), (2, 0.4), (3, 0.18), (4, 0.07)), decay=1.8, attack=0.006) * 0.4
        place(out[0], y * 0.55, t_now)
        place(out[1], y * 0.45, t_now)
        t_now += rng.uniform(2.0, 4.5)
    return stereo(*[loopify(o) for o in out])


def singing_bowls():
    n = total()
    out = [np.zeros(n), np.zeros(n)]
    t_now = 0.5
    while t_now < DUR + XF - 8:
        f = rng.choice([196.0, 220.0, 261.6, 293.7])
        parts = ((1, 1.0), (2.71, 0.45), (5.15, 0.2))
        y = note(f, 9.0, parts, decay=3.5, attack=0.25)
        y2 = note(f * 1.004, 9.0, parts, decay=3.5, attack=0.25)
        place(out[0], y * 0.3, t_now)
        place(out[1], y2 * 0.3, t_now)
        t_now += rng.uniform(5.0, 8.0)
    return stereo(*[loopify(o) for o in out])


GEN = {
    "birds_dawn": birds_dawn,
    "soft_waves": soft_waves,
    "light_rain": light_rain,
    "chimes": chimes,
    "calm_piano": calm_piano,
    "singing_bowls": singing_bowls,
}


def main(outdir):
    for name, fn in GEN.items():
        s = fn()
        s = s / (np.max(np.abs(s)) + 1e-9) * 0.7
        wav = f"/tmp/{name}.wav"
        with wave.open(wav, "wb") as w:
            w.setnchannels(2)
            w.setsampwidth(2)
            w.setframerate(SR)
            w.writeframes((s * 32767).astype("<i2").tobytes())
        subprocess.run(
            ["ffmpeg", "-y", "-loglevel", "error", "-i", wav, "-af",
             "afade=t=in:d=2,loudnorm=I=-20:TP=-3", "-ac", "2", "-ar", "44100",
             "-c:a", "libvorbis", "-q:a", "4", f"{outdir}/{name}.ogg"],
            check=True,
        )


if __name__ == "__main__":
    main(sys.argv[1])
