package com.migdlp.gentlealarm.channel

import com.migdlp.gentlealarm.alarm.AlarmClockPort
import com.migdlp.gentlealarm.alarm.AlarmScheduler
import com.migdlp.gentlealarm.alarm.AlarmSpec
import com.migdlp.gentlealarm.alarm.AlarmStore
import com.migdlp.gentlealarm.alarm.InMemoryKeyValueStore
import java.time.ZoneId
import java.time.ZonedDateTime
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.fail
import org.junit.Test

class AlarmChannelHandlerTest {
    private class FakePort : AlarmClockPort {
        val cancels = mutableListOf<String>()
        val sets = mutableListOf<Long>()
        override fun set(fireAtMs: Long, alarmId: String, ringAtMs: Long) {
            sets += ringAtMs
        }
        override fun cancel(alarmId: String) {
            cancels += alarmId
        }
        override fun canScheduleExact() = true
    }

    private val zone = ZoneId.of("Europe/Madrid")
    private fun at(d: Int, h: Int, m: Int) =
        ZonedDateTime.of(2026, 11, d, h, m, 0, 0, zone).toInstant().toEpochMilli()

    private val now = at(9, 22, 0) // lunes
    private val store = AlarmStore(InMemoryKeyValueStore())
    private val port = FakePort()
    private var active = false
    private val launched = mutableListOf<com.migdlp.gentlealarm.ring.RingRequest>()
    private val h = AlarmChannelHandler(
        store, AlarmScheduler(store, port, { now }, { zone }), { now }, { zone },
        sessionActive = { active }, launchPreview = { launched += it },
    )

    private fun expectError(code: String, msg: String? = null, block: () -> Unit) {
        try {
            block()
            fail("esperaba $code")
        } catch (e: ChannelError) {
            assertEquals(code, e.code)
            if (msg != null) assertEquals(msg, e.message)
        }
    }

    @Test fun upsertValidReturnsScheduled() {
        val r = h.upsert(AlarmSpec("a", hour = 7, minute = 30).toMap())
        assertEquals(at(10, 7, 30), r["scheduledRingAtEpochMs"])
    }

    @Test fun upsertIgnoresClientScheduledValue() {
        val r = h.upsert(AlarmSpec("a", scheduledRingAtEpochMs = 5L).toMap())
        assertEquals(at(10, 7, 30), r["scheduledRingAtEpochMs"])
    }

    @Test fun upsertInvalidHour() = expectError("INVALID_SPEC", "hour") {
        h.upsert(AlarmSpec("a", hour = 25).toMap())
    }

    @Test fun deleteMissing() = expectError("NOT_FOUND") { h.delete("zzz") }

    @Test fun deleteCancelsAndRemoves() {
        h.upsert(AlarmSpec("a").toMap())
        h.delete("a")
        assertEquals(listOf("a"), port.cancels)
        assertNull(store.get("a"))
    }

    @Test fun setEnabledFalseCancels() {
        h.upsert(AlarmSpec("a").toMap())
        val r = h.setEnabled("a", false)
        assertEquals(false, r["enabled"])
        assertNull(r["scheduledRingAtEpochMs"])
        assertEquals(listOf("a"), port.cancels)
    }

    @Test fun skipNextNotRepeating() {
        h.upsert(AlarmSpec("a").toMap())
        expectError("NOT_REPEATING") { h.setSkipNext("a", true) }
    }

    @Test fun skipNextSchedulesFollowing() {
        h.upsert(AlarmSpec("a", weekdays = (1..7).toList()).toMap())
        val r = h.setSkipNext("a", true)
        assertEquals(at(10, 7, 30), r["skipRingAtEpochMs"])
        assertEquals(at(11, 7, 30), r["scheduledRingAtEpochMs"])
        val back = h.setSkipNext("a", false)
        assertNull(back["skipRingAtEpochMs"])
        assertEquals(at(10, 7, 30), back["scheduledRingAtEpochMs"])
    }

    @Test fun listSorted() {
        h.upsert(AlarmSpec("late", hour = 9, minute = 0).toMap())
        h.upsert(AlarmSpec("early", hour = 6, minute = 15).toMap())
        h.upsert(AlarmSpec("early2", hour = 6, minute = 15, createdAtEpochMs = 1).toMap())
        assertEquals(listOf("early", "early2", "late"), h.list().map { it["id"] })
        assertNotNull(h.list().first()["scheduledRingAtEpochMs"])
    }

    @Test fun previewWithActiveSessionFails() {
        active = true
        expectError("SESSION_ACTIVE") { h.startPreview(AlarmSpec("a").toMap()) }
        assertEquals(0, launched.size)
    }

    @Test fun previewLaunchesWithoutSaving() {
        h.startPreview(AlarmSpec("a", sunriseMinutes = 20).toMap())
        val r = launched.single()
        assertEquals(true, r.config.isPreview)
        assertEquals(now + 30_000, r.config.ringAtMs)
        assertEquals("preview", r.config.alarmId)
        assertEquals(false, r.config.skipSunrise)
        assertEquals(false, r.quietSunrise)
        assertEquals(0, store.list().size)
    }

    @Test fun previewWithoutSunriseSkipsIt() {
        h.startPreview(AlarmSpec("a", sunriseMinutes = 0).toMap())
        assertEquals(true, launched.single().config.skipSunrise)
    }
}
