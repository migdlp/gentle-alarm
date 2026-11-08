package com.migdlp.gentlealarm.ring

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class RingSessionMachineTest {
    private val min = 60_000L
    private val ringAt = 20 * min
    private val normal = RingTimings.normal(20, 3)

    private fun cfg(vibrate: Boolean = true, skip: Boolean = false, preview: Boolean = false) =
        SessionConfig("a", "x", ringAt, 0L, vibrate, preview, skip)

    private fun machine(
        vibrate: Boolean = true,
        skip: Boolean = false,
        timings: RingTimings = normal,
        preview: Boolean = false,
    ) = RingSessionMachine(cfg(vibrate, skip, preview), timings)

    private fun ringing(m: RingSessionMachine = machine()): RingSessionMachine {
        m.start(0L)
        m.handle(RingEvent.Tick, ringAt)
        return m
    }

    @Test fun startBeforeRingAtIsSunrise() {
        val m = machine()
        m.start(0L)
        assertEquals("sunrise", m.snapshot().state)
        assertEquals(ringAt, m.nextDeadlineMs())
    }

    @Test fun startWithSkipSunriseRings() {
        val m = machine(skip = true)
        val e = m.start(0L)
        assertEquals("ringing", m.snapshot().state)
        assertTrue(e.contains(Effect.StartSound(0f, 3 * min)))
    }

    @Test fun tickAtRingAtRings() {
        val m = machine()
        m.start(0L)
        val e = m.handle(RingEvent.Tick, ringAt)
        assertEquals("ringing", m.snapshot().state)
        assertTrue(e.contains(Effect.StartSound(0f, 3 * min)))
    }

    @Test fun vibrationOnlyOnce() {
        val m = ringing()
        assertTrue(m.handle(RingEvent.Tick, ringAt + 5 * min).contains(Effect.StartVibration))
        assertFalse(m.handle(RingEvent.Tick, ringAt + 5 * min + 1000).contains(Effect.StartVibration))
    }

    @Test fun noVibrationWhenDisabled() {
        val m = ringing(machine(vibrate = false))
        assertFalse(m.handle(RingEvent.Tick, ringAt + 5 * min).contains(Effect.StartVibration))
    }

    @Test fun autoSnoozeThenMissed() {
        val m = ringing()
        m.handle(RingEvent.Tick, ringAt + 15 * min)
        var s = m.snapshot()
        assertEquals("snoozed", s.state)
        assertTrue(s.autoSnoozeUsed)
        assertEquals(3, s.snoozesLeft)
        val back = s.snoozeUntilEpochMs!!
        m.handle(RingEvent.Tick, back)
        assertEquals("ringing", m.snapshot().state)
        val e = m.handle(RingEvent.Tick, back + 15 * min)
        s = m.snapshot()
        assertEquals("ended", s.state)
        assertEquals("missed", s.endReason)
        assertTrue(e.contains(Effect.ShowMissedNotification))
        assertTrue(e.contains(Effect.EndSession("missed")))
    }

    @Test fun snoozeThreeTimesThenIgnored() {
        val m = ringing()
        var now = ringAt
        repeat(3) {
            m.handle(RingEvent.Snooze, now)
            now = m.snapshot().snoozeUntilEpochMs!!
            m.handle(RingEvent.Tick, now)
        }
        assertEquals(0, m.snapshot().snoozesLeft)
        val before = m.snapshot()
        assertTrue(m.handle(RingEvent.Snooze, now).isEmpty())
        assertEquals(before, m.snapshot())
    }

    @Test fun snoozeReturnsWithBrightnessRamp() {
        val m = ringing()
        m.handle(RingEvent.Snooze, ringAt)
        assertEquals(ringAt + 10 * min, m.nextDeadlineMs())
        m.handle(RingEvent.Tick, ringAt + 10 * min)
        val s = m.snapshot()
        assertEquals("ringing", s.state)
        assertTrue(s.brightnessRampFromSnooze)
    }

    @Test fun swipeDismissConfirms() {
        val m = ringing()
        val e = m.handle(RingEvent.SwipeDismiss, ringAt + 1000)
        assertEquals("confirming", m.snapshot().state)
        assertTrue(e.contains(Effect.StopSound(2000)))
        assertTrue(e.contains(Effect.StopVibration))
    }

    @Test fun confirmTimeoutRingsAgainQuietly() {
        val m = ringing()
        m.handle(RingEvent.SwipeDismiss, ringAt)
        val e = m.handle(RingEvent.Tick, ringAt + 60_000)
        assertEquals("ringing", m.snapshot().state)
        assertTrue(e.contains(Effect.StartSound(0.2f, 3 * min)))
        assertFalse(m.snapshot().brightnessRampFromSnooze)
    }

    @Test fun confirmedFlowEndsConfirmed() {
        val m = ringing()
        m.handle(RingEvent.SwipeDismiss, ringAt)
        m.handle(RingEvent.ConfirmAwake, ringAt + 1000)
        assertEquals("greeting", m.snapshot().state)
        val e = m.handle(RingEvent.FinishGreeting, ringAt + 2000)
        assertEquals("confirmed", m.snapshot().endReason)
        assertTrue(e.contains(Effect.EndSession("confirmed")))
    }

    @Test fun wakeEarlyEndsWokeEarly() {
        val m = machine()
        m.start(0L)
        m.handle(RingEvent.WakeEarly, 5 * min)
        assertEquals("greeting", m.snapshot().state)
        val e = m.handle(RingEvent.FinishGreeting, 6 * min)
        assertTrue(e.contains(Effect.EndSession("woke_early")))
    }

    @Test fun wakeUpFromSnoozedConfirms() {
        val m = ringing()
        m.handle(RingEvent.Snooze, ringAt)
        m.handle(RingEvent.WakeUp, ringAt + min)
        assertEquals("confirming", m.snapshot().state)
    }

    @Test fun focusPauseFreezesTimers() {
        val m = ringing()
        assertTrue(m.handle(RingEvent.FocusLost, ringAt + 2 * min).contains(Effect.PauseSound))
        assertNull(m.nextDeadlineMs())
        val e = m.handle(RingEvent.FocusGained, ringAt + 7 * min)
        assertTrue(e.contains(Effect.ResumeSound(30_000)))
        assertEquals(ringAt + 10 * min, m.nextDeadlineMs())
        assertTrue(m.handle(RingEvent.Tick, ringAt + 10 * min).contains(Effect.StartVibration))
    }

    @Test fun previewEndsAfter90s() {
        val m = machine(timings = RingTimings.preview(), preview = true)
        m.start(0L)
        m.handle(RingEvent.Tick, ringAt)
        val e = m.handle(RingEvent.Tick, ringAt + 90_000)
        assertEquals("preview_done", m.snapshot().endReason)
        assertTrue(e.contains(Effect.EndSession("preview_done")))
    }

    @Test fun restoreKeepsSnapshotAndDeadline() {
        val m = machine()
        m.start(0L)
        val s = m.snapshot()
        val r = RingSessionMachine.restore(s, cfg(), normal)
        assertEquals(m.nextDeadlineMs(), r.nextDeadlineMs())
        assertEquals(s, r.snapshot())
        val m2 = ringing()
        m2.handle(RingEvent.Snooze, ringAt)
        val r2 = RingSessionMachine.restore(m2.snapshot(), cfg(), normal)
        assertEquals(m2.nextDeadlineMs(), r2.nextDeadlineMs())
        assertEquals(m2.snapshot(), r2.snapshot())
    }

    @Test fun irrelevantEventsAreIgnored() {
        val m = machine()
        m.start(0L)
        assertTrue(m.handle(RingEvent.SwipeDismiss, 1000).isEmpty())
        assertTrue(m.handle(RingEvent.ConfirmAwake, 1000).isEmpty())
    }

    @Test fun snapshotJsonRoundTrip() {
        val s = ringing().snapshot()
        assertEquals(s, SessionSnapshot.fromJson(s.toJson()))
    }
}
