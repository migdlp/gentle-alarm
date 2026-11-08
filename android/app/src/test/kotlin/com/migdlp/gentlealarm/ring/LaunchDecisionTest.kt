package com.migdlp.gentlealarm.ring

import com.migdlp.gentlealarm.alarm.AlarmSpec
import org.junit.Assert.assertEquals
import org.junit.Test

class LaunchDecisionTest {
    private val now = 1_000_000L
    private val spec = AlarmSpec("a")
    private fun input(
        spec: AlarmSpec? = this.spec,
        ringAt: Long = now + 600_000,
        active: Boolean = false,
        battery: Int = 80,
        charging: Boolean = false,
        unlocked: Boolean = true,
        interactive: Boolean = false,
    ) = LaunchInput(spec, ringAt, now, active, battery, charging, unlocked, interactive)

    @Test fun nullSpecIgnored() = assertEquals(Launch.Ignore, LaunchDecision.decide(input(spec = null)))
    @Test fun disabledIgnored() =
        assertEquals(Launch.Ignore, LaunchDecision.decide(input(spec = spec.copy(enabled = false))))
    @Test fun activeBeforeRingAtDefers() =
        assertEquals(Launch.DeferToRingTime, LaunchDecision.decide(input(active = true)))
    @Test fun activeAfterRingAtAbsorbs() =
        assertEquals(Launch.Absorb, LaunchDecision.decide(input(active = true, ringAt = now)))
    @Test fun lateFireSkipsSunrise() =
        assertEquals(Launch.Start(true), LaunchDecision.decide(input(ringAt = now - 1)))
    @Test fun lockedUserSkipsSunrise() =
        assertEquals(Launch.Start(true), LaunchDecision.decide(input(unlocked = false)))
    @Test fun lowBatterySkipsSunrise() =
        assertEquals(Launch.Start(true), LaunchDecision.decide(input(battery = 10)))
    @Test fun lowBatteryChargingKeepsSunrise() =
        assertEquals(Launch.Start(false), LaunchDecision.decide(input(battery = 5, charging = true)))
    @Test fun interactiveIsQuiet() =
        assertEquals(Launch.Start(false, true), LaunchDecision.decide(input(interactive = true)))
    @Test fun normalStartsSunrise() =
        assertEquals(Launch.Start(false, false), LaunchDecision.decide(input()))
}
