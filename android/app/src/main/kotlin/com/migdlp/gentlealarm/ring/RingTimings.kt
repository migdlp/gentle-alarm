package com.migdlp.gentlealarm.ring

data class RingTimings(
    val sunriseMs: Long,
    val rampMs: Long,
    val snoozeMs: Long,
    val maxSnoozes: Int,
    val vibrationAfterMs: Long,
    val autoSnoozeAfterMs: Long?,
    val confirmTimeoutMs: Long,
    val confirmRetryStartVolume: Float,
    val fadeOutMs: Long,
    val focusResumeRampMs: Long,
    val previewHardStopMs: Long?,
    val snoozeBrightnessRampMs: Long,
) {
    companion object {
        fun normal(sunriseMin: Int, rampMin: Int) = RingTimings(
            sunriseMs = sunriseMin * 60_000L,
            rampMs = rampMin * 60_000L,
            snoozeMs = 600_000,
            maxSnoozes = 3,
            vibrationAfterMs = 300_000,
            autoSnoozeAfterMs = 900_000,
            confirmTimeoutMs = 60_000,
            confirmRetryStartVolume = 0.2f,
            fadeOutMs = 2_000,
            focusResumeRampMs = 30_000,
            previewHardStopMs = null,
            snoozeBrightnessRampMs = 60_000,
        )

        fun preview() = RingTimings(
            sunriseMs = 30_000,
            rampMs = 30_000,
            snoozeMs = 10_000,
            maxSnoozes = 3,
            vibrationAfterMs = 15_000,
            autoSnoozeAfterMs = null,
            confirmTimeoutMs = 10_000,
            confirmRetryStartVolume = 0.2f,
            fadeOutMs = 2_000,
            focusResumeRampMs = 30_000,
            previewHardStopMs = 90_000,
            snoozeBrightnessRampMs = 5_000,
        )
    }
}
