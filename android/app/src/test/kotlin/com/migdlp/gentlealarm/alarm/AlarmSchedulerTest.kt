package com.migdlp.gentlealarm.alarm

import java.time.ZoneId
import java.time.ZonedDateTime
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Assert.fail
import org.junit.Test

class AlarmSchedulerTest {
    private class FakePort(var exact: Boolean = true) : AlarmClockPort {
        val sets = mutableListOf<Triple<Long, String, Long>>()
        val cancels = mutableListOf<String>()
        override fun set(fireAtMs: Long, alarmId: String, ringAtMs: Long) {
            sets += Triple(fireAtMs, alarmId, ringAtMs)
        }
        override fun cancel(alarmId: String) {
            cancels += alarmId
        }
        override fun canScheduleExact() = exact
    }

    private val zone = ZoneId.of("Europe/Madrid")
    private val now = ZonedDateTime.of(2026, 11, 9, 22, 0, 0, 0, zone).toInstant().toEpochMilli()
    private val store = AlarmStore(InMemoryKeyValueStore())
    private val port = FakePort()
    private val scheduler = AlarmScheduler(store, port, { now }, { zone })

    @Test fun enabledAlarmIsSetAndSaved() {
        val spec = AlarmSpec("a", hour = 7, minute = 30)
        val expected = NextTriggerCalculator.next(spec, now, zone)
        val saved = scheduler.reschedule(spec)
        assertEquals(listOf(Triple(expected.fireAtEpochMs, "a", expected.ringAtEpochMs)), port.sets)
        assertEquals(expected.ringAtEpochMs, saved.scheduledRingAtEpochMs)
        assertEquals(expected.ringAtEpochMs, store.get("a")!!.scheduledRingAtEpochMs)
    }

    @Test fun disabledAlarmIsCancelled() {
        val saved = scheduler.reschedule(AlarmSpec("a", enabled = false, scheduledRingAtEpochMs = 5L))
        assertEquals(listOf("a"), port.cancels)
        assertNull(saved.scheduledRingAtEpochMs)
        assertNull(store.get("a")!!.scheduledRingAtEpochMs)
    }

    @Test fun noExactPermissionFailsAndSavesNothing() {
        port.exact = false
        try {
            scheduler.reschedule(AlarmSpec("a"))
            fail()
        } catch (e: ScheduleFailedException) {
            assertTrue(store.list().isEmpty())
            assertTrue(port.sets.isEmpty())
        }
    }

    @Test fun rescheduleAllHandlesBoth() {
        store.upsert(AlarmSpec("on"))
        store.upsert(AlarmSpec("off", enabled = false))
        scheduler.rescheduleAll()
        assertEquals(listOf("on"), port.sets.map { it.second })
        assertEquals(listOf("off"), port.cancels)
    }
}
