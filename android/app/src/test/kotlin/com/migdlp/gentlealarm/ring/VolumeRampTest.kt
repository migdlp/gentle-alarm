package com.migdlp.gentlealarm.ring

import org.junit.Assert.assertEquals
import org.junit.Test

class VolumeRampTest {
    @Test fun startsAtZero() = assertEquals(0f, VolumeRamp.rampVolume(0, 180_000, 0f), 0.001f)
    @Test fun halfIsQuarter() = assertEquals(0.25f, VolumeRamp.rampVolume(90_000, 180_000, 0f), 0.001f)
    @Test fun endsAtOne() {
        assertEquals(1f, VolumeRamp.rampVolume(180_000, 180_000, 0f), 0.001f)
        assertEquals(1f, VolumeRamp.rampVolume(999_999, 180_000, 0f), 0.001f)
    }
    @Test fun nonZeroStart() {
        assertEquals(0.2f, VolumeRamp.rampVolume(0, 180_000, 0.2f), 0.001f)
        assertEquals(1f, VolumeRamp.rampVolume(180_000, 180_000, 0.2f), 0.001f)
    }
    @Test fun fade() {
        assertEquals(0.2f, VolumeRamp.fadeVolume(1000, 2000, 0.8f), 0.001f)
        assertEquals(0f, VolumeRamp.fadeVolume(2000, 2000, 0.8f), 0.001f)
    }
}
