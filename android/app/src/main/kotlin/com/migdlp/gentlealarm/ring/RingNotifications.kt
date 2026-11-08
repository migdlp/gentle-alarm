package com.migdlp.gentlealarm.ring

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import com.migdlp.gentlealarm.R
import com.migdlp.gentlealarm.alarm.AlarmStore
import com.migdlp.gentlealarm.alarm.MissedNotifier
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter

class RingNotifications(private val context: Context) : SessionNotifierPort {
    var quietSunrise = false

    private val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    init {
        if (nm.getNotificationChannel(CHANNEL_ID) == null) {
            nm.createNotificationChannel(
                NotificationChannel(
                    CHANNEL_ID,
                    context.getString(R.string.channel_ring_name),
                    NotificationManager.IMPORTANCE_HIGH,
                ).apply {
                    setSound(null, null)
                    enableVibration(false)
                    setBypassDnd(true)
                },
            )
        }
    }

    private fun hhmm(ms: Long): String = DateTimeFormatter.ofPattern("HH:mm")
        .format(Instant.ofEpochMilli(ms).atZone(ZoneId.systemDefault()))

    private fun servicePi(action: String, code: Int): PendingIntent =
        PendingIntent.getService(
            context, code,
            Intent(context, RingService::class.java).setAction(action),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )

    fun build(s: SessionSnapshot): Notification {
        val quiet = quietSunrise && s.state == "sunrise"
        val title = when (s.state) {
            "sunrise" -> if (quiet) context.getString(R.string.ring_title_sunrise_quiet, hhmm(s.ringAtEpochMs)) else context.getString(R.string.ring_title_sunrise, hhmm(s.ringAtEpochMs))
            "snoozed" -> context.getString(
                R.string.ring_title_snoozed, hhmm(s.snoozeUntilEpochMs ?: s.ringAtEpochMs),
            )
            else -> context.getString(
                R.string.ring_title_ringing, s.label.ifEmpty { hhmm(s.ringAtEpochMs) },
            )
        }
        val full = PendingIntent.getActivity(
            context, 0, Intent(context, RingActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val b = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_launcher_monochrome)
            .setContentTitle(title)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentIntent(full)
            .addAction(0, context.getString(R.string.action_dismiss), servicePi(RingService.ACTION_DISMISS, 1))
        if (!quiet) b.setFullScreenIntent(full, true)
        if (quiet) b.addAction(0, context.getString(R.string.action_view_sunrise), full)
        if (s.state == "ringing" && s.snoozesLeft > 0) {
            b.addAction(0, context.getString(R.string.action_snooze), servicePi(RingService.ACTION_SNOOZE, 2))
        }
        return b.build()
    }

    override fun update(snapshot: SessionSnapshot) {
        if (snapshot.state == "ended") return
        nm.notify(NOTIFICATION_ID, build(snapshot))
    }

    override fun missed(snapshot: SessionSnapshot) {
        val spec = AlarmStore.from(context).get(snapshot.alarmId) ?: return
        MissedNotifier(context).notify(spec, snapshot.ringAtEpochMs)
    }

    companion object {
        const val CHANNEL_ID = "ring"
        const val NOTIFICATION_ID = 4242
    }
}
