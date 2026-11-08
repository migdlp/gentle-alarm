package com.migdlp.gentlealarm.ring

data class SessionConfig(
    val alarmId: String,
    val label: String,
    val ringAtMs: Long,
    val sunriseStartMs: Long,
    val vibrate: Boolean,
    val isPreview: Boolean,
    val skipSunrise: Boolean,
)

sealed interface RingEvent {
    object SwipeDismiss : RingEvent
    object Snooze : RingEvent
    object WakeUp : RingEvent
    object WakeEarly : RingEvent
    object ConfirmAwake : RingEvent
    object FinishGreeting : RingEvent
    object FocusLost : RingEvent
    object FocusGained : RingEvent
    object Tick : RingEvent
}

sealed interface Effect {
    data class StartSound(val startVolume: Float, val rampMs: Long) : Effect
    data class StopSound(val fadeMs: Long) : Effect
    object PauseSound : Effect
    data class ResumeSound(val rampMs: Long) : Effect
    object StartVibration : Effect
    object StopVibration : Effect
    object ShowMissedNotification : Effect
    data class EndSession(val reason: String) : Effect
    object StateChanged : Effect
}

class RingSessionMachine(
    private val config: SessionConfig,
    private val timings: RingTimings,
) {
    private var state = "sunrise"
    private var stateSince = 0L
    private var snoozesLeft = timings.maxSnoozes
    private var autoSnoozeUsed = false
    private var snoozeUntil: Long? = null
    private var segmentStart: Long? = null
    private var pausedAt: Long? = null
    private var vibrationStarted = false
    private var firstRingingAt: Long? = null
    private var brightnessRampFromSnooze = false
    private var endReason: String? = null
    private var wokeEarly = false
    var soundFallback = false

    fun start(nowMs: Long): List<Effect> {
        stateSince = nowMs
        return if (config.skipSunrise || nowMs >= config.ringAtMs) {
            enterRinging(nowMs, 0f, false)
        } else {
            listOf(Effect.StateChanged)
        }
    }

    fun handle(event: RingEvent, nowMs: Long): List<Effect> = when (state) {
        "sunrise" -> when (event) {
            RingEvent.Tick -> if (nowMs >= config.ringAtMs) enterRinging(nowMs, 0f, false) else emptyList()
            RingEvent.WakeEarly -> {
                wokeEarly = true
                endReason = "woke_early"
                moveTo("greeting", nowMs)
            }
            else -> emptyList()
        }
        "ringing" -> ringing(event, nowMs)
        "snoozed" -> when (event) {
            RingEvent.Tick ->
                if (nowMs >= (snoozeUntil ?: Long.MAX_VALUE)) enterRinging(nowMs, 0f, true) else emptyList()
            RingEvent.WakeUp -> moveTo("confirming", nowMs)
            else -> emptyList()
        }
        "confirming" -> when (event) {
            RingEvent.ConfirmAwake -> moveTo("greeting", nowMs)
            RingEvent.Tick ->
                if (nowMs >= stateSince + timings.confirmTimeoutMs) {
                    enterRinging(nowMs, timings.confirmRetryStartVolume, false)
                } else emptyList()
            else -> emptyList()
        }
        "greeting" -> when (event) {
            RingEvent.FinishGreeting -> end(if (wokeEarly) "woke_early" else "confirmed", nowMs, emptyList())
            else -> emptyList()
        }
        else -> emptyList()
    }

    private fun ringing(event: RingEvent, now: Long): List<Effect> {
        val seg = segmentStart ?: now
        return when (event) {
            RingEvent.SwipeDismiss -> {
                pausedAt = null
                moveTo("confirming", now, listOf(Effect.StopSound(timings.fadeOutMs), Effect.StopVibration))
            }
            RingEvent.Snooze -> {
                if (snoozesLeft <= 0) emptyList() else {
                    snoozesLeft--
                    snooze(now)
                }
            }
            RingEvent.FocusLost -> {
                if (pausedAt != null) emptyList() else {
                    pausedAt = now
                    listOf(Effect.PauseSound)
                }
            }
            RingEvent.FocusGained -> {
                val p = pausedAt ?: return emptyList()
                pausedAt = null
                segmentStart = seg + (now - p)
                listOf(Effect.ResumeSound(timings.focusResumeRampMs))
            }
            RingEvent.Tick -> {
                if (pausedAt != null) return emptyList()
                val hard = timings.previewHardStopMs
                val first = firstRingingAt
                if (hard != null && first != null && now >= first + hard) {
                    return end("preview_done", now, listOf(Effect.StopSound(500), Effect.StopVibration))
                }
                val auto = timings.autoSnoozeAfterMs
                if (auto != null && now >= seg + auto) {
                    return if (!autoSnoozeUsed) {
                        autoSnoozeUsed = true
                        snooze(now)
                    } else {
                        end(
                            "missed", now,
                            listOf(Effect.StopSound(500), Effect.StopVibration, Effect.ShowMissedNotification),
                        )
                    }
                }
                if (config.vibrate && !vibrationStarted && now >= seg + timings.vibrationAfterMs) {
                    vibrationStarted = true
                    return listOf(Effect.StartVibration)
                }
                emptyList()
            }
            else -> emptyList()
        }
    }

    private fun snooze(now: Long): List<Effect> {
        snoozeUntil = now + timings.snoozeMs
        return moveTo("snoozed", now, listOf(Effect.StopSound(500), Effect.StopVibration))
    }

    private fun enterRinging(now: Long, startVolume: Float, fromSnooze: Boolean): List<Effect> {
        state = "ringing"
        stateSince = now
        segmentStart = now
        pausedAt = null
        vibrationStarted = false
        snoozeUntil = null
        brightnessRampFromSnooze = fromSnooze
        if (firstRingingAt == null) firstRingingAt = now
        return listOf(Effect.StartSound(startVolume, timings.rampMs), Effect.StateChanged)
    }

    private fun moveTo(next: String, now: Long, effects: List<Effect> = emptyList()): List<Effect> {
        state = next
        stateSince = now
        segmentStart = null
        if (next != "snoozed") snoozeUntil = null
        brightnessRampFromSnooze = false
        return effects + Effect.StateChanged
    }

    private fun end(reason: String, now: Long, effects: List<Effect>): List<Effect> {
        endReason = reason
        return moveTo("ended", now, effects) + Effect.EndSession(reason)
    }

    fun nextDeadlineMs(): Long? = when (state) {
        "sunrise" -> config.ringAtMs
        "snoozed" -> snoozeUntil
        "confirming" -> stateSince + timings.confirmTimeoutMs
        "ringing" -> if (pausedAt != null) null else {
            val seg = segmentStart ?: stateSince
            listOfNotNull(
                if (config.vibrate && !vibrationStarted) seg + timings.vibrationAfterMs else null,
                timings.autoSnoozeAfterMs?.let { seg + it },
                timings.previewHardStopMs?.let { (firstRingingAt ?: seg) + it },
            ).minOrNull()
        }
        else -> null
    }

    fun currentState(): String = state

    fun snapshot(): SessionSnapshot = SessionSnapshot(
        alarmId = config.alarmId,
        label = config.label,
        ringAtEpochMs = config.ringAtMs,
        sunriseStartEpochMs = config.sunriseStartMs,
        state = state,
        stateSinceEpochMs = stateSince,
        snoozesLeft = snoozesLeft,
        autoSnoozeUsed = autoSnoozeUsed,
        snoozeUntilEpochMs = snoozeUntil,
        segmentStartEpochMs = if (state == "ringing") segmentStart else null,
        endReason = endReason,
        isPreview = config.isPreview,
        soundFallback = soundFallback,
        brightnessRampFromSnooze = brightnessRampFromSnooze,
    )

    companion object {
        fun restore(s: SessionSnapshot, config: SessionConfig, timings: RingTimings): RingSessionMachine =
            RingSessionMachine(config, timings).apply {
                state = s.state
                stateSince = s.stateSinceEpochMs
                snoozesLeft = s.snoozesLeft
                autoSnoozeUsed = s.autoSnoozeUsed
                snoozeUntil = s.snoozeUntilEpochMs
                segmentStart = s.segmentStartEpochMs
                firstRingingAt = s.segmentStartEpochMs
                brightnessRampFromSnooze = s.brightnessRampFromSnooze
                endReason = s.endReason
                wokeEarly = s.endReason == "woke_early"
                soundFallback = s.soundFallback
            }
    }
}
