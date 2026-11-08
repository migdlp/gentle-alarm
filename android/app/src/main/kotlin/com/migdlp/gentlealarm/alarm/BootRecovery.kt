package com.migdlp.gentlealarm.alarm

sealed class RecoveryAction {
    data class FireNow(val alarmId: String, val ringAt: Long) : RecoveryAction()
    data class NotifyMissed(val alarmId: String, val ringAt: Long) : RecoveryAction()
}

object BootRecovery {
    const val MISSED_BOOT_WINDOW_MS = 1_800_000L

    fun decide(specs: List<AlarmSpec>, nowMs: Long): List<RecoveryAction> {
        val pending = specs.filter {
            val s = it.scheduledRingAtEpochMs
            it.enabled && s != null && s <= nowMs
        }.map { it.id to it.scheduledRingAtEpochMs!! }
        val fireable = pending.filter { nowMs - it.second <= MISSED_BOOT_WINDOW_MS }
        val winner = fireable.maxByOrNull { it.second }
        return pending.map { (id, ringAt) ->
            if (winner != null && id == winner.first && ringAt == winner.second) {
                RecoveryAction.FireNow(id, ringAt)
            } else {
                RecoveryAction.NotifyMissed(id, ringAt)
            }
        }
    }
}
