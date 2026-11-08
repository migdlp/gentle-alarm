package com.migdlp.gentlealarm.alarm

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import com.migdlp.gentlealarm.MainActivity
import java.time.ZoneId

class ScheduleFailedException(message: String) : RuntimeException(message)

interface AlarmClockPort {
    fun set(fireAtMs: Long, alarmId: String, ringAtMs: Long)
    fun cancel(alarmId: String)
    fun canScheduleExact(): Boolean
}

class AndroidAlarmClockPort(private val context: Context) : AlarmClockPort {
    private val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    private val flags = PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT

    private fun fireIntent(alarmId: String, ringAtMs: Long): PendingIntent {
        val i = Intent(AlarmReceiver.ACTION_FIRE).apply {
            setClass(context, AlarmReceiver::class.java)
            putExtra(AlarmReceiver.EXTRA_ALARM_ID, alarmId)
            putExtra(AlarmReceiver.EXTRA_RING_AT, ringAtMs)
        }
        return PendingIntent.getBroadcast(context, alarmId.hashCode(), i, flags)
    }

    override fun set(fireAtMs: Long, alarmId: String, ringAtMs: Long) {
        val show = PendingIntent.getActivity(
            context, 0, Intent(context, MainActivity::class.java), PendingIntent.FLAG_IMMUTABLE,
        )
        am.setAlarmClock(AlarmManager.AlarmClockInfo(fireAtMs, show), fireIntent(alarmId, ringAtMs))
    }

    override fun cancel(alarmId: String) {
        am.cancel(fireIntent(alarmId, 0L))
    }

    override fun canScheduleExact(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.S || am.canScheduleExactAlarms()
}

class AlarmScheduler(
    private val store: AlarmStore,
    private val port: AlarmClockPort,
    private val clock: () -> Long,
    private val zone: () -> ZoneId,
) {
    /** Programa o cancela la alarma y guarda `scheduledRingAtEpochMs`. Devuelve la alarma guardada. */
    @Synchronized
    fun reschedule(input: AlarmSpec): AlarmSpec {
        val skip = input.skipRingAtEpochMs
        val spec = if (skip != null && skip <= clock()) input.copy(skipRingAtEpochMs = null) else input
        if (!spec.enabled) {
            port.cancel(spec.id)
            return spec.copy(scheduledRingAtEpochMs = null).also { store.upsert(it) }
        }
        if (!port.canScheduleExact()) throw ScheduleFailedException("exact alarms not allowed")
        val next = NextTriggerCalculator.next(spec, clock(), zone())
        port.set(next.fireAtEpochMs, spec.id, next.ringAtEpochMs)
        return spec.copy(scheduledRingAtEpochMs = next.ringAtEpochMs).also { store.upsert(it) }
    }

    @Synchronized
    fun cancel(alarmId: String) = port.cancel(alarmId)

    @Synchronized
    fun rescheduleAll() {
        store.list().forEach {
            try {
                reschedule(it)
            } catch (e: ScheduleFailedException) {
                // sin permiso de alarmas exactas: se deja la alarma sin programar
            }
        }
    }

    companion object {
        fun from(context: Context) = AlarmScheduler(
            AlarmStore.from(context),
            AndroidAlarmClockPort(context),
            System::currentTimeMillis,
            ZoneId::systemDefault,
        )
    }
}
