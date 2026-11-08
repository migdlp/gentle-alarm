package com.migdlp.gentlealarm.ring

import org.junit.Assert.assertEquals
import org.junit.Test

class RingRequestTest {
    @Test fun roundTrip() {
        val r = RingRequest(
            SessionConfig("a", "Trabajo", 1000L, 400L, true, false, false),
            "custom", "content://x", 70, 20, 3, true,
        )
        assertEquals(r, RingRequest.fromJson(r.toJson()))
        val r2 = r.copy(customSoundUri = null, config = r.config.copy(isPreview = true, skipSunrise = true))
        assertEquals(r2, RingRequest.fromJson(r2.toJson()))
    }
}
