package com.migdlp.gentlealarm.ring

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class RampSchedulerTest {
    private val r = RampScheduler(1_000, 180_000, 0f)

    @Test fun start() = assertEquals(0f, r.volumeAt(1_000), 0.001f)
    @Test fun half() = assertEquals(0.25f, r.volumeAt(91_000), 0.001f)
    @Test fun end() = assertEquals(1f, r.volumeAt(181_000), 0.001f)
    @Test fun done() {
        assertFalse(r.isDone(100_000))
        assertTrue(r.isDone(181_000))
    }
}
