package com.migdlp.gentlealarm.alarm

import java.time.Instant
import java.time.LocalTime
import java.time.ZoneId
import java.time.ZonedDateTime

data class NextTrigger(val ringAtEpochMs: Long, val fireAtEpochMs: Long)

object NextTriggerCalculator {
    private const val MIN_SUNRISE_GAP_MS = 60_000L

    fun nextRingAt(spec: AlarmSpec, nowMs: Long, zone: ZoneId): Long {
        val today = Instant.ofEpochMilli(nowMs).atZone(zone).toLocalDate()
        for (d in 0..14) {
            val date = today.plusDays(d.toLong())
            if (spec.weekdays.isNotEmpty() && date.dayOfWeek.value !in spec.weekdays) continue
            val candidate = ZonedDateTime.of(date, LocalTime.of(spec.hour, spec.minute), zone)
                .toInstant().toEpochMilli()
            if (candidate <= nowMs) continue
            if (candidate == spec.skipRingAtEpochMs) continue
            return candidate
        }
        throw IllegalStateException("sin próxima ocurrencia para ${spec.id}")
    }

    fun next(spec: AlarmSpec, nowMs: Long, zone: ZoneId): NextTrigger {
        val ringAt = nextRingAt(spec, nowMs, zone)
        val fireAt = if (spec.sunriseMinutes == 0 || ringAt - nowMs < MIN_SUNRISE_GAP_MS) {
            ringAt
        } else {
            maxOf(ringAt - spec.sunriseMinutes * 60_000L, nowMs)
        }
        return NextTrigger(ringAt, fireAt)
    }
}
