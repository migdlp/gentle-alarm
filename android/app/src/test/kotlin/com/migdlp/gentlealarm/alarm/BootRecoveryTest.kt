package com.migdlp.gentlealarm.alarm

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class BootRecoveryTest {
    private val now = 100_000_000L
    private val min = 60_000L

    private fun spec(id: String, agoMin: Long, enabled: Boolean = true) =
        AlarmSpec(id, enabled = enabled, scheduledRingAtEpochMs = now - agoMin * min)

    @Test fun nonePending() {
        assertTrue(BootRecovery.decide(listOf(AlarmSpec("a", scheduledRingAtEpochMs = now + min)), now).isEmpty())
        assertTrue(BootRecovery.decide(emptyList(), now).isEmpty())
    }

    @Test fun tenMinutesAgoFires() =
        assertEquals(listOf(RecoveryAction.FireNow("a", now - 10 * min)), BootRecovery.decide(listOf(spec("a", 10)), now))

    @Test fun exactlyThirtyFires() =
        assertEquals(listOf(RecoveryAction.FireNow("a", now - 30 * min)), BootRecovery.decide(listOf(spec("a", 30)), now))

    @Test fun thirtyOneNotifies() =
        assertEquals(listOf(RecoveryAction.NotifyMissed("a", now - 31 * min)), BootRecovery.decide(listOf(spec("a", 31)), now))

    @Test fun onlyMostRecentFires() {
        val r = BootRecovery.decide(listOf(spec("a", 5), spec("b", 20)), now)
        assertEquals(
            setOf(RecoveryAction.FireNow("a", now - 5 * min), RecoveryAction.NotifyMissed("b", now - 20 * min)),
            r.toSet(),
        )
    }

    @Test fun disabledIgnored() =
        assertTrue(BootRecovery.decide(listOf(spec("a", 5, enabled = false)), now).isEmpty())
}
