package com.migdlp.gentlealarm.ring

import kotlin.math.sqrt

object VolumeRamp {
    fun rampVolume(elapsedMs: Long, rampMs: Long, start: Float): Float {
        if (rampMs <= 0 || elapsedMs >= rampMs) return 1f
        val p = (elapsedMs.coerceAtLeast(0).toFloat() / rampMs)
        val s = sqrt(start)
        val base = s + (1f - s) * p
        return base * base
    }

    fun fadeVolume(elapsedMs: Long, fadeMs: Long, from: Float): Float {
        if (fadeMs <= 0 || elapsedMs >= fadeMs) return 0f
        val p = elapsedMs.coerceAtLeast(0).toFloat() / fadeMs
        return from * (1f - p) * (1f - p)
    }
}
