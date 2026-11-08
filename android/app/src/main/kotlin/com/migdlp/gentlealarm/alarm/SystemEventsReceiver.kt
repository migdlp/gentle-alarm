package com.migdlp.gentlealarm.alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class SystemEventsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val pending = goAsync()
        try {
            val store = AlarmStore.from(context)
            val now = System.currentTimeMillis()
            val specs = store.list()
            BootRecovery.decide(specs, now).forEach { action ->
                when (action) {
                    is RecoveryAction.FireNow -> RingLauncher.onFire(context, action.alarmId, action.ringAt)
                    is RecoveryAction.NotifyMissed -> {
                        val spec = specs.first { it.id == action.alarmId }
                        MissedNotifier(context).notify(spec, action.ringAt)
                        if (spec.weekdays.isEmpty()) {
                            store.upsert(spec.copy(enabled = false, scheduledRingAtEpochMs = null))
                        }
                    }
                }
            }
            AlarmScheduler.from(context).rescheduleAll()
        } catch (e: Exception) {
            Log.e("SystemEventsReceiver", "fallo al recuperar alarmas", e)
        } finally {
            pending.finish()
        }
    }
}
