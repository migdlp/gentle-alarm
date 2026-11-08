package com.migdlp.gentlealarm.alarm

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import com.migdlp.gentlealarm.MainActivity
import com.migdlp.gentlealarm.R
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter

class MissedNotifier(private val context: Context) {
    fun notify(spec: AlarmSpec, ringAt: Long) {
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (nm.getNotificationChannel(CHANNEL_ID) == null) {
            nm.createNotificationChannel(
                NotificationChannel(
                    CHANNEL_ID,
                    context.getString(R.string.channel_missed_name),
                    NotificationManager.IMPORTANCE_DEFAULT,
                ),
            )
        }
        val time = DateTimeFormatter.ofPattern("HH:mm")
            .format(Instant.ofEpochMilli(ringAt).atZone(ZoneId.systemDefault()))
        val open = PendingIntent.getActivity(
            context, 0, Intent(context, MainActivity::class.java), PendingIntent.FLAG_IMMUTABLE,
        )
        val n = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_launcher_monochrome)
            .setContentTitle(context.getString(R.string.missed_title, time))
            .setContentText(context.getString(R.string.missed_body))
            .setContentIntent(open)
            .setAutoCancel(true)
            .build()
        nm.notify(("missed" + spec.id).hashCode(), n)
    }

    companion object {
        const val CHANNEL_ID = "missed"
    }
}
