package com.migdlp.gentlealarm.alarm

import android.content.Context
import android.util.Log

/** Punto de entrada del disparo. E04-T04 sustituye el stub por el arranque de RingService. */
object RingLauncher {
    fun onFire(context: Context, alarmId: String, ringAtMs: Long) {
        Log.i("RingLauncher", "FIRE alarmId=$alarmId ringAt=$ringAtMs")
    }
}
