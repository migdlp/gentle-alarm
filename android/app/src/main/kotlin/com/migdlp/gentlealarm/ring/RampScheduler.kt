package com.migdlp.gentlealarm.ring

class RampScheduler(
    private val startMs: Long,
    private val rampMs: Long,
    private val startVolume: Float,
) {
    fun volumeAt(nowMs: Long): Float = VolumeRamp.rampVolume(nowMs - startMs, rampMs, startVolume)
    fun isDone(nowMs: Long): Boolean = nowMs - startMs >= rampMs
}
