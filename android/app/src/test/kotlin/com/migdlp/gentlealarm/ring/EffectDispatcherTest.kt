package com.migdlp.gentlealarm.ring

import org.junit.Assert.assertEquals
import org.junit.Test

class EffectDispatcherTest {
    private val log = mutableListOf<String>()
    private val audio = object : AudioPort {
        override fun start(resolved: Resolved, maxVolumePercent: Int, startVolume: Float, rampMs: Long) {
            log += "start($resolved,$maxVolumePercent,$startVolume,$rampMs)"
        }
        override fun stop(fadeMs: Long) { log += "stop($fadeMs)" }
        override fun pause() { log += "pause" }
        override fun resume(rampMs: Long) { log += "resume($rampMs)" }
    }
    private val vib = object : VibrationPort {
        override fun start() { log += "vibStart" }
        override fun stop() { log += "vibStop" }
    }
    private val notifier = object : SessionNotifierPort {
        override fun update(snapshot: SessionSnapshot) { log += "update" }
        override fun missed(snapshot: SessionSnapshot) { log += "missed" }
    }
    private val snap = SessionSnapshot("a", "", 1, 1, "ringing", 1, 3, false, null, 1, null, false, false, false)
    private val ended = mutableListOf<String>()
    private val d = EffectDispatcher(audio, vib, notifier, { Resolved.Raw("chimes", false) }, 70) { ended += it }

    @Test fun mapsEveryEffect() {
        d.apply(
            listOf(
                Effect.StartSound(0.2f, 5000), Effect.StopSound(2000), Effect.PauseSound,
                Effect.ResumeSound(30000), Effect.StartVibration, Effect.StopVibration,
                Effect.ShowMissedNotification, Effect.StateChanged, Effect.EndSession("missed"),
            ),
            snap,
        )
        assertEquals(
            listOf(
                "start(Raw(name=chimes, fallback=false),70,0.2,5000)", "stop(2000)", "pause", "resume(30000)",
                "vibStart", "vibStop", "missed", "update",
            ),
            log,
        )
        assertEquals(listOf("missed"), ended)
    }
}
