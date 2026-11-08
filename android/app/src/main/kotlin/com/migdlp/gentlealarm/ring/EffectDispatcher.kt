package com.migdlp.gentlealarm.ring

interface AudioPort {
    fun start(resolved: Resolved, maxVolumePercent: Int, startVolume: Float, rampMs: Long)
    fun stop(fadeMs: Long)
    fun pause()
    fun resume(rampMs: Long)
}

interface VibrationPort {
    fun start()
    fun stop()
}

interface SessionNotifierPort {
    fun update(snapshot: SessionSnapshot)
    fun missed(snapshot: SessionSnapshot)
}

class EffectDispatcher(
    private val audio: AudioPort,
    private val vib: VibrationPort,
    private val notifier: SessionNotifierPort,
    private val sound: () -> Resolved,
    private val maxVolumePercent: Int,
    private val onEnd: (String) -> Unit = {},
) {
    fun apply(effects: List<Effect>, snapshot: SessionSnapshot) {
        for (e in effects) {
            when (e) {
                is Effect.StartSound -> audio.start(sound(), maxVolumePercent, e.startVolume, e.rampMs)
                is Effect.StopSound -> audio.stop(e.fadeMs)
                Effect.PauseSound -> audio.pause()
                is Effect.ResumeSound -> audio.resume(e.rampMs)
                Effect.StartVibration -> vib.start()
                Effect.StopVibration -> vib.stop()
                Effect.ShowMissedNotification -> notifier.missed(snapshot)
                Effect.StateChanged -> notifier.update(snapshot)
                is Effect.EndSession -> onEnd(e.reason)
            }
        }
    }
}
