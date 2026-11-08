package com.migdlp.gentlealarm.ring

import com.migdlp.gentlealarm.alarm.AlarmSpec

sealed interface Launch {
    object Ignore : Launch
    object DeferToRingTime : Launch
    object Absorb : Launch
    data class Start(val skipSunrise: Boolean, val quietSunrise: Boolean = false) : Launch
}

data class LaunchInput(
    val spec: AlarmSpec?,
    val ringAt: Long,
    val now: Long,
    val sessionActive: Boolean,
    val batteryPct: Int,
    val charging: Boolean,
    val userUnlocked: Boolean,
    val interactive: Boolean,
)

object LaunchDecision {
    fun decide(i: LaunchInput): Launch = when {
        i.spec == null || !i.spec.enabled -> Launch.Ignore
        i.sessionActive && i.ringAt > i.now -> Launch.DeferToRingTime
        i.sessionActive -> Launch.Absorb
        i.ringAt <= i.now -> Launch.Start(skipSunrise = true)
        !i.userUnlocked -> Launch.Start(skipSunrise = true)
        i.batteryPct <= 10 && !i.charging -> Launch.Start(skipSunrise = true)
        i.interactive && i.userUnlocked -> Launch.Start(skipSunrise = false, quietSunrise = true)
        else -> Launch.Start(skipSunrise = false)
    }
}
