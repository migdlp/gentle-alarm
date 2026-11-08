package com.migdlp.gentlealarm.channel

import com.migdlp.gentlealarm.alarm.AlarmScheduler
import com.migdlp.gentlealarm.alarm.AlarmSpec
import com.migdlp.gentlealarm.alarm.AlarmStore
import com.migdlp.gentlealarm.alarm.InvalidSpecException
import com.migdlp.gentlealarm.alarm.NextTriggerCalculator
import java.time.ZoneId

class ChannelError(val code: String, message: String?) : RuntimeException(message)

class AlarmChannelHandler(
    private val store: AlarmStore,
    private val scheduler: AlarmScheduler,
    private val clock: () -> Long,
    private val zone: () -> ZoneId,
) {
    fun list(): List<Map<String, Any?>> =
        store.list()
            .sortedWith(compareBy({ it.hour }, { it.minute }, { it.createdAtEpochMs }))
            .map { it.toMap() }

    fun upsert(map: Map<*, *>): Map<String, Any?> {
        val spec = try {
            AlarmSpec.fromMap(map).validate()
        } catch (e: InvalidSpecException) {
            throw ChannelError("INVALID_SPEC", e.field)
        }
        return scheduler.reschedule(spec.copy(scheduledRingAtEpochMs = null)).toMap()
    }

    fun delete(id: String) {
        store.get(id) ?: throw ChannelError("NOT_FOUND", id)
        scheduler.cancel(id)
        store.delete(id)
    }

    fun setEnabled(id: String, enabled: Boolean): Map<String, Any?> {
        val spec = store.get(id) ?: throw ChannelError("NOT_FOUND", id)
        return scheduler.reschedule(spec.copy(enabled = enabled)).toMap()
    }

    fun setSkipNext(id: String, skip: Boolean): Map<String, Any?> {
        val spec = store.get(id) ?: throw ChannelError("NOT_FOUND", id)
        if (spec.weekdays.isEmpty()) throw ChannelError("NOT_REPEATING", id)
        val skipAt = if (skip) {
            NextTriggerCalculator.nextRingAt(spec.copy(skipRingAtEpochMs = null), clock(), zone())
        } else null
        return scheduler.reschedule(spec.copy(skipRingAtEpochMs = skipAt)).toMap()
    }
}
