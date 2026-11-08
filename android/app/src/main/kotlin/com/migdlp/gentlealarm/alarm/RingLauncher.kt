package com.migdlp.gentlealarm.alarm

import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.PowerManager
import android.os.UserManager
import android.util.Log
import androidx.core.content.ContextCompat
import com.migdlp.gentlealarm.ring.Launch
import com.migdlp.gentlealarm.ring.LaunchDecision
import com.migdlp.gentlealarm.ring.LaunchInput
import com.migdlp.gentlealarm.ring.RingRequest
import com.migdlp.gentlealarm.ring.RingService
import com.migdlp.gentlealarm.ring.RingSessionBus
import com.migdlp.gentlealarm.ring.SessionConfig
import com.migdlp.gentlealarm.ring.SessionEndHandler

object RingLauncher {
    private const val TAG = "RingLauncher"

    fun onFire(context: Context, alarmId: String, ringAtMs: Long) {
        val store = AlarmStore.from(context)
        val scheduler = AlarmScheduler.from(context)
        val spec = store.get(alarmId)
        val now = System.currentTimeMillis()
        val battery = context.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val level = battery?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        val scale = battery?.getIntExtra(BatteryManager.EXTRA_SCALE, 100) ?: 100
        val status = battery?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
        val charging = status == BatteryManager.BATTERY_STATUS_CHARGING ||
            status == BatteryManager.BATTERY_STATUS_FULL
        val unlocked = (context.getSystemService(Context.USER_SERVICE) as UserManager).isUserUnlocked
        val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        val kg = context.getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        val interactive = pm.isInteractive && !kg.isKeyguardLocked

        val decision = LaunchDecision.decide(
            LaunchInput(
                spec, ringAtMs, now, RingSessionBus.current() != null,
                if (level < 0) 100 else level * 100 / scale, charging, unlocked, interactive,
            ),
        )
        Log.i(TAG, "FIRE $alarmId -> $decision")
        when (decision) {
            Launch.Ignore -> Unit
            Launch.DeferToRingTime -> scheduler.scheduleFireAt(spec!!, ringAtMs, ringAtMs)
            Launch.Absorb -> SessionEndHandler(store, scheduler, System::currentTimeMillis)
                .handle(alarmId, "absorbed", ringAtMs)
            is Launch.Start -> {
                val s = spec!!
                val sunriseStart = maxOf(ringAtMs - s.sunriseMinutes * 60_000L, now)
                val request = RingRequest(
                    config = SessionConfig(
                        alarmId = s.id,
                        label = s.label,
                        ringAtMs = ringAtMs,
                        sunriseStartMs = if (decision.skipSunrise) ringAtMs else sunriseStart,
                        vibrate = s.vibrate,
                        isPreview = false,
                        skipSunrise = decision.skipSunrise || s.sunriseMinutes == 0,
                    ),
                    soundId = s.soundId,
                    customSoundUri = s.customSoundUri,
                    maxVolumePercent = s.maxVolumePercent,
                    sunriseMinutes = s.sunriseMinutes,
                    rampMinutes = s.rampMinutes,
                    quietSunrise = decision.quietSunrise,
                )
                start(context, request)
            }
        }
    }

    fun start(context: Context, request: RingRequest) {
        val intent = Intent(context, RingService::class.java)
            .setAction(RingService.ACTION_START)
            .putExtra(RingService.EXTRA_REQUEST, request.toJson().toString())
        ContextCompat.startForegroundService(context, intent)
    }

    fun startPreview(context: Context, spec: AlarmSpec) =
        start(context, RingRequest.preview(spec, System.currentTimeMillis()))

    fun onSessionEnded(context: Context, alarmId: String, reason: String, ringAtMs: Long) {
        Log.i(TAG, "ended alarmId=$alarmId reason=$reason ringAt=$ringAtMs")
        SessionEndHandler(AlarmStore.from(context), AlarmScheduler.from(context), System::currentTimeMillis)
            .handle(alarmId, reason, ringAtMs)
    }
}
