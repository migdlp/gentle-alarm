package com.migdlp.gentlealarm.alarm

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Assert.fail
import org.junit.Test

class AlarmSpecTest {
    private val base = AlarmSpec(id = "a1")

    private fun assertInvalid(field: String, spec: AlarmSpec) {
        try {
            spec.validate()
            fail("esperaba InvalidSpecException($field)")
        } catch (e: InvalidSpecException) {
            assertEquals(field, e.field)
        }
    }

    @Test fun hour24() = assertInvalid("hour", base.copy(hour = 24))
    @Test fun minuteNegative() = assertInvalid("minute", base.copy(minute = -1))
    @Test fun weekdaysOutOfRange() = assertInvalid("weekdays", base.copy(weekdays = listOf(8)))
    @Test fun sunriseSeven() = assertInvalid("sunriseMinutes", base.copy(sunriseMinutes = 7))
    @Test fun volume55() = assertInvalid("maxVolumePercent", base.copy(maxVolumePercent = 55))
    @Test fun rampInvalid() = assertInvalid("rampMinutes", base.copy(rampMinutes = 4))
    @Test fun soundInvalid() = assertInvalid("soundId", base.copy(soundId = "x"))
    @Test fun idEmpty() = assertInvalid("id", base.copy(id = ""))

    @Test fun customWithoutUri() =
        assertInvalid("customSoundUri", base.copy(soundId = "custom", customSoundName = "n"))

    @Test fun customWithoutName() =
        assertInvalid("customSoundName", base.copy(soundId = "custom", customSoundUri = "u"))

    @Test fun label41WithEmojis() =
        assertInvalid("label", base.copy(label = "😀".repeat(41)))

    @Test fun label40WithEmojisIsValid() {
        assertEquals(40, base.copy(label = "😀".repeat(40)).validate().label.codePointCount(0, 80))
    }

    @Test fun weekdaysNormalized() {
        assertEquals(listOf(1, 3), base.copy(weekdays = listOf(3, 1, 3)).validate().weekdays)
    }

    @Test fun labelTrimmed() {
        assertEquals("hola", base.copy(label = "  hola  ").validate().label)
    }

    @Test fun jsonWithoutVibrateDefaultsTrue() {
        val o = base.toJson()
        o.remove("vibrate")
        assertTrue(AlarmSpec.fromJson(o).vibrate)
    }

    @Test fun roundTripWithoutOptionals() {
        assertEquals(base, AlarmSpec.fromJson(base.toJson()))
    }

    @Test fun roundTripWithOptionals() {
        val s = AlarmSpec(
            id = "x", enabled = false, hour = 6, minute = 5, weekdays = listOf(1, 5),
            label = "Trabajo", soundId = "custom", customSoundUri = "content://a/b",
            customSoundName = "mi.mp3", sunriseMinutes = 45, rampMinutes = 10,
            maxVolumePercent = 100, vibrate = false, skipRingAtEpochMs = 123L,
            scheduledRingAtEpochMs = 456L, createdAtEpochMs = 789L,
        )
        assertEquals(s, AlarmSpec.fromJson(s.toJson()))
    }
}
