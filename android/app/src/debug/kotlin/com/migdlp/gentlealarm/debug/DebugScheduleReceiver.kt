package com.migdlp.gentlealarm.debug

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.migdlp.gentlealarm.alarm.AlarmSpec
import com.migdlp.gentlealarm.alarm.AlarmStore
import com.migdlp.gentlealarm.alarm.AndroidAlarmClockPort

/**
 * Solo debug. `adb shell am broadcast -n com.migdlp.gentlealarm/.debug.DebugScheduleReceiver --ei seconds 90`
 * programa la alarma «debug» para dentro de N segundos, sin pasar por la interfaz.
 */
class DebugScheduleReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val seconds = intent.getIntExtra("seconds", 90)
        val ringAt = System.currentTimeMillis() + seconds * 1000L
        val spec = AlarmSpec(
            id = "debug",
            sunriseMinutes = 0,
            rampMinutes = 1,
            vibrate = false,
            scheduledRingAtEpochMs = ringAt,
        )
        AlarmStore.from(context).upsert(spec)
        AndroidAlarmClockPort(context).set(ringAt, spec.id, ringAt)
        Log.i("DebugSchedule", "alarma debug programada ringAt=$ringAt (en $seconds s)")
    }
}
