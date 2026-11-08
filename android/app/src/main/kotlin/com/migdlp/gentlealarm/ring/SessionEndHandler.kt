package com.migdlp.gentlealarm.ring

import com.migdlp.gentlealarm.alarm.AlarmScheduler
import com.migdlp.gentlealarm.alarm.AlarmStore
import com.migdlp.gentlealarm.alarm.ScheduleFailedException

class SessionEndHandler(
    private val store: AlarmStore,
    private val scheduler: AlarmScheduler,
    private val clock: () -> Long,
) {
    fun handle(alarmId: String, reason: String, ringAtMs: Long) {
        if (alarmId == "preview") return
        val spec = store.get(alarmId) ?: return
        if (spec.weekdays.isEmpty()) {
            store.upsert(spec.copy(enabled = false, scheduledRingAtEpochMs = null))
            return
        }
        val skip = spec.skipRingAtEpochMs
        val cleaned = if (skip != null && skip <= clock()) spec.copy(skipRingAtEpochMs = null) else spec
        try {
            scheduler.reschedule(cleaned)
        } catch (e: ScheduleFailedException) {
            store.upsert(cleaned.copy(scheduledRingAtEpochMs = null))
        }
    }
}
