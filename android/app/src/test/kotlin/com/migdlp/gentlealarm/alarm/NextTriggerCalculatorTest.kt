package com.migdlp.gentlealarm.alarm

import java.time.ZoneId
import java.time.ZonedDateTime
import org.junit.Assert.assertEquals
import org.junit.Test

class NextTriggerCalculatorTest {
    private val zone = ZoneId.of("Europe/Madrid")

    private fun at(y: Int, mo: Int, d: Int, h: Int, mi: Int, s: Int = 0): Long =
        ZonedDateTime.of(y, mo, d, h, mi, s, 0, zone).toInstant().toEpochMilli()

    private val spec = AlarmSpec(id = "a", hour = 7, minute = 30)

    // 2026-11-09 es lunes
    @Test fun oneShotNextDay() =
        assertEquals(at(2026, 11, 10, 7, 30), NextTriggerCalculator.nextRingAt(spec, at(2026, 11, 9, 22, 0), zone))

    @Test fun exactlyNowIsStrictlyAfter() =
        assertEquals(at(2026, 11, 10, 7, 30), NextTriggerCalculator.nextRingAt(spec, at(2026, 11, 9, 7, 30), zone))

    @Test fun weekdaysFridayToMonday() {
        val s = spec.copy(weekdays = listOf(1, 2, 3, 4, 5))
        assertEquals(at(2026, 11, 16, 7, 30), NextTriggerCalculator.nextRingAt(s, at(2026, 11, 13, 8, 0), zone))
    }

    @Test fun saturdayJustBefore() {
        val s = spec.copy(weekdays = listOf(6))
        assertEquals(at(2026, 11, 14, 7, 30), NextTriggerCalculator.nextRingAt(s, at(2026, 11, 14, 7, 29), zone))
    }

    @Test fun skipTomorrowEveryDay() {
        val s = spec.copy(weekdays = (1..7).toList(), skipRingAtEpochMs = at(2026, 11, 10, 7, 30))
        assertEquals(at(2026, 11, 11, 7, 30), NextTriggerCalculator.nextRingAt(s, at(2026, 11, 9, 22, 0), zone))
    }

    @Test fun skipSingleWeekdayJumpsAWeek() {
        val s = spec.copy(weekdays = listOf(3), skipRingAtEpochMs = at(2026, 11, 11, 7, 30))
        assertEquals(at(2026, 11, 18, 7, 30), NextTriggerCalculator.nextRingAt(s, at(2026, 11, 9, 22, 0), zone))
    }

    @Test fun springForwardGap() {
        val s = spec.copy(hour = 2, minute = 30)
        val ring = NextTriggerCalculator.nextRingAt(s, at(2026, 3, 28, 12, 0), zone)
        assertEquals(at(2026, 3, 29, 3, 30), ring)
        assertEquals(2 * 3600, zone.rules.getOffset(java.time.Instant.ofEpochMilli(ring)).totalSeconds)
    }

    @Test fun fallBackOverlapUsesFirstOccurrence() {
        val s = spec.copy(hour = 2, minute = 30)
        val ring = NextTriggerCalculator.nextRingAt(s, at(2026, 10, 24, 12, 0), zone)
        assertEquals(2 * 3600, zone.rules.getOffset(java.time.Instant.ofEpochMilli(ring)).totalSeconds)
        assertEquals(at(2026, 10, 25, 0, 30) + 2 * 3600_000L, ring)
    }

    @Test fun sunriseFullLead() {
        val t = at(2026, 11, 10, 7, 30)
        assertEquals(t - 20 * 60_000L, NextTriggerCalculator.next(spec, t - 60 * 60_000L, zone).fireAtEpochMs)
    }

    @Test fun sunriseClampedToNow() {
        val t = at(2026, 11, 10, 7, 30)
        val now = t - 8 * 60_000L
        assertEquals(now, NextTriggerCalculator.next(spec, now, zone).fireAtEpochMs)
    }

    @Test fun sunriseSkippedWhenLessThanAMinute() {
        val t = at(2026, 11, 10, 7, 30)
        assertEquals(t, NextTriggerCalculator.next(spec, t - 30_000L, zone).fireAtEpochMs)
    }

    @Test fun sunriseZero() {
        val s = spec.copy(sunriseMinutes = 0)
        val r = NextTriggerCalculator.next(s, at(2026, 11, 9, 22, 0), zone)
        assertEquals(r.ringAtEpochMs, r.fireAtEpochMs)
    }

    @Test fun skipDuringSpringForwardStillResolves() {
        val s = spec.copy(hour = 2, minute = 30, weekdays = (1..7).toList())
        val skip = at(2026, 3, 29, 3, 30)
        val ring = NextTriggerCalculator.nextRingAt(s.copy(skipRingAtEpochMs = skip), at(2026, 3, 28, 12, 0), zone)
        assertEquals(at(2026, 3, 30, 2, 30), ring)
    }
}
