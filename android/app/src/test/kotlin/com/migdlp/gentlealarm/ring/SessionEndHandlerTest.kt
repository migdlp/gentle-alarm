package com.migdlp.gentlealarm.ring

import com.migdlp.gentlealarm.alarm.AlarmClockPort
import com.migdlp.gentlealarm.alarm.AlarmScheduler
import com.migdlp.gentlealarm.alarm.AlarmSpec
import com.migdlp.gentlealarm.alarm.AlarmStore
import com.migdlp.gentlealarm.alarm.InMemoryKeyValueStore
import java.time.ZoneId
import java.time.ZonedDateTime
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class SessionEndHandlerTest {
    private class Port : AlarmClockPort {
        val sets = mutableListOf<String>()
        override fun set(fireAtMs: Long, alarmId: String, ringAtMs: Long) {
            sets += alarmId
        }
        override fun cancel(alarmId: String) {}
        override fun canScheduleExact() = true
    }

    private val zone = ZoneId.of("Europe/Madrid")
    private val now = ZonedDateTime.of(2026, 11, 9, 7, 40, 0, 0, zone).toInstant().toEpochMilli()
    private val store = AlarmStore(InMemoryKeyValueStore())
    private val port = Port()
    private val h = SessionEndHandler(store, AlarmScheduler(store, port, { now }, { zone }), { now })

    @Test fun oneShotIsDisabled() {
        store.upsert(AlarmSpec("a", scheduledRingAtEpochMs = now - 1000))
        h.handle("a", "confirmed", now - 1000)
        assertFalse(store.get("a")!!.enabled)
        assertNull(store.get("a")!!.scheduledRingAtEpochMs)
        assertTrue(port.sets.isEmpty())
    }

    @Test fun repeatingIsRescheduledAndPastSkipCleared() {
        store.upsert(AlarmSpec("a", weekdays = (1..7).toList(), skipRingAtEpochMs = now - 1))
        h.handle("a", "confirmed", now)
        val s = store.get("a")!!
        assertNull(s.skipRingAtEpochMs)
        assertEquals(listOf("a"), port.sets)
        assertTrue(s.scheduledRingAtEpochMs!! > now)
    }

    @Test fun deletedAlarmIsNotRecreated() {
        h.handle("zzz", "confirmed", now)
        assertTrue(store.list().isEmpty())
    }

    @Test fun previewDoesNothing() {
        h.handle("preview", "preview_done", now)
        assertTrue(store.list().isEmpty())
    }
}
