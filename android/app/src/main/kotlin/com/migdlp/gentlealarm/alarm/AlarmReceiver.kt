package com.migdlp.gentlealarm.alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_FIRE) return
        val id = intent.getStringExtra(EXTRA_ALARM_ID) ?: return
        val ringAt = intent.getLongExtra(EXTRA_RING_AT, 0L)
        Log.i("AlarmReceiver", "FIRE $id ringAt=$ringAt")
        RingLauncher.onFire(context, id, ringAt)
    }

    companion object {
        const val ACTION_FIRE = "com.migdlp.gentlealarm.FIRE"
        const val EXTRA_ALARM_ID = "alarmId"
        const val EXTRA_RING_AT = "ringAtEpochMs"
    }
}
