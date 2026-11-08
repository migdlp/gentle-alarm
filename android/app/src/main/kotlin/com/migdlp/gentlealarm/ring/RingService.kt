package com.migdlp.gentlealarm.ring

import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.os.SystemClock
import android.util.Log
import com.migdlp.gentlealarm.alarm.AlarmStore
import com.migdlp.gentlealarm.alarm.RingLauncher
import org.json.JSONObject

class RingService : Service(), AlarmAudioPlayer.Listener {
    private val handler = Handler(Looper.getMainLooper())
    private val token = Any()
    private lateinit var store: AlarmStore
    private lateinit var notifications: RingNotifications
    private lateinit var audio: AlarmAudioPlayer
    private lateinit var vibrator: GentleVibrator
    private var wakeLock: PowerManager.WakeLock? = null

    private var request: RingRequest? = null
    private var machine: RingSessionMachine? = null
    private var dispatcher: EffectDispatcher? = null

    override fun onCreate() {
        super.onCreate()
        store = AlarmStore.from(this)
        notifications = RingNotifications(this)
        audio = AlarmAudioPlayer(this, this)
        vibrator = GentleVibrator(this)
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> if (machine == null) begin(intent) else Unit
            ACTION_SNOOZE, ACTION_DISMISS, ACTION_EVENT -> {
                if (machine == null && !restore()) {
                    stopSelf()
                    return START_NOT_STICKY
                }
                when (intent.action) {
                    ACTION_SNOOZE -> dispatch(listOf(RingEvent.Snooze))
                    ACTION_DISMISS -> dispatch(dismissAllEvents())
                    else -> eventFor(intent.getStringExtra(EXTRA_EVENT))?.let { dispatch(listOf(it)) }
                }
            }
            else -> if (machine == null && !restore()) {
                stopSelf()
                return START_NOT_STICKY
            }
        }
        return START_STICKY
    }

    private fun begin(intent: Intent) {
        val json = intent.getStringExtra(EXTRA_REQUEST)
        if (json == null) {
            stopSelf()
            return
        }
        val req = RingRequest.fromJson(JSONObject(json))
        val m = RingSessionMachine(req.config, timingsFor(req))
        setup(req, m)
        val effects = m.start(System.currentTimeMillis())
        goForeground(m.snapshot())
        apply(effects, m)
    }

    private fun restore(): Boolean {
        val saved = store.loadSession() ?: return false
        return try {
            val req = RingRequest.fromJson(saved.getJSONObject("request"))
            val snap = SessionSnapshot.fromJson(saved)
            if (snap.state == "ended") return false
            val m = RingSessionMachine.restore(snap, req.config, timingsFor(req))
            setup(req, m)
            goForeground(m.snapshot())
            if (snap.state == "ringing") {
                // el proceso murió: se retoma el sonido desde el principio del tramo
                apply(listOf(Effect.StartSound(0f, timingsFor(req).rampMs), Effect.StateChanged), m)
            } else {
                apply(listOf(Effect.StateChanged), m)
            }
            true
        } catch (e: Exception) {
            Log.e(TAG, "No se pudo restaurar la sesión", e)
            false
        }
    }

    private fun timingsFor(r: RingRequest) =
        if (r.config.isPreview) RingTimings.preview() else RingTimings.normal(r.sunriseMinutes, r.rampMinutes)

    private fun setup(req: RingRequest, m: RingSessionMachine) {
        request = req
        notifications.quietSunrise = req.quietSunrise
        machine = m
        acquireWakeLock()
        dispatcher = EffectDispatcher(
            audio = object : AudioPort {
                override fun start(resolved: Resolved, maxVolumePercent: Int, startVolume: Float, rampMs: Long) =
                    audio.start(resolved, maxVolumePercent, startVolume, rampMs)
                override fun stop(fadeMs: Long) = audio.stop(fadeMs)
                override fun pause() = audio.pause()
                override fun resume(rampMs: Long) = audio.resume(rampMs)
            },
            vib = object : VibrationPort {
                override fun start() = vibrator.start()
                override fun stop() = vibrator.stop()
            },
            notifier = notifications,
            sound = {
                val r = SoundResolver.resolve(req.soundId, req.customSoundUri, ::canRead)
                if (r.fallback) m.soundFallback = true
                r
            },
            maxVolumePercent = req.maxVolumePercent,
            onEnd = { reason -> finish(req, reason) },
        )
    }

    private fun goForeground(s: SessionSnapshot) {
        val n = notifications.build(s)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(RingNotifications.NOTIFICATION_ID, n, ServiceInfo.FOREGROUND_SERVICE_TYPE_SYSTEM_EXEMPTED)
        } else {
            startForeground(RingNotifications.NOTIFICATION_ID, n)
        }
    }

    private fun dispatch(events: List<RingEvent>) {
        val m = machine ?: return
        for (e in events) {
            if (machine == null) return
            apply(m.handle(e, System.currentTimeMillis()), m)
        }
    }

    private fun apply(effects: List<Effect>, m: RingSessionMachine) {
        val snap = m.snapshot()
        if (effects.any { it == Effect.StateChanged }) {
            store.saveSession(snap.toJson().put("request", request!!.toJson()))
            RingSessionBus.publish(snap)
        }
        dispatcher?.apply(effects, snap)
        scheduleDeadline()
    }

    private fun scheduleDeadline() {
        handler.removeCallbacksAndMessages(token)
        val m = machine ?: return
        val deadline = m.nextDeadlineMs() ?: return
        val delay = (deadline - System.currentTimeMillis()).coerceAtLeast(0)
        handler.postAtTime({ dispatch(listOf(RingEvent.Tick)) }, token, SystemClock.uptimeMillis() + delay)
    }

    private fun dismissAllEvents(): List<RingEvent> = when (machine?.currentState()) {
        "sunrise" -> listOf(RingEvent.WakeEarly, RingEvent.FinishGreeting)
        "ringing" -> listOf(RingEvent.SwipeDismiss, RingEvent.ConfirmAwake, RingEvent.FinishGreeting)
        "snoozed" -> listOf(RingEvent.WakeUp, RingEvent.ConfirmAwake, RingEvent.FinishGreeting)
        "confirming" -> listOf(RingEvent.ConfirmAwake, RingEvent.FinishGreeting)
        "greeting" -> listOf(RingEvent.FinishGreeting)
        else -> emptyList()
    }

    private fun eventFor(name: String?): RingEvent? = when (name) {
        "swipeDismiss" -> RingEvent.SwipeDismiss
        "snooze" -> RingEvent.Snooze
        "wakeUp" -> RingEvent.WakeUp
        "wakeEarly" -> RingEvent.WakeEarly
        "confirmAwake" -> RingEvent.ConfirmAwake
        "finishGreeting" -> RingEvent.FinishGreeting
        else -> null
    }

    private fun finish(req: RingRequest, reason: String) {
        handler.removeCallbacksAndMessages(token)
        audio.release()
        vibrator.stop()
        store.clearSession()
        val ringAt = req.config.ringAtMs
        machine = null
        dispatcher = null
        RingSessionBus.publish(null)
        RingLauncher.onSessionEnded(this, req.config.alarmId, reason, ringAt)
        releaseWakeLock()
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun canRead(uri: String): Boolean = try {
        contentResolver.openInputStream(android.net.Uri.parse(uri))?.use { true } ?: false
    } catch (e: Exception) {
        false
    }

    private fun acquireWakeLock() {
        if (wakeLock?.isHeld == true) return
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "gentlealarm:session")
            .apply { acquire(2 * 60 * 60 * 1000L) }
    }

    private fun releaseWakeLock() {
        wakeLock?.takeIf { it.isHeld }?.release()
        wakeLock = null
    }

    override fun onFocusLost() = dispatch(listOf(RingEvent.FocusLost))
    override fun onFocusGained() = dispatch(listOf(RingEvent.FocusGained))
    override fun onFallbackUsed() {
        val m = machine ?: return
        m.soundFallback = true
        apply(listOf(Effect.StateChanged), m)
    }

    override fun onDestroy() {
        handler.removeCallbacksAndMessages(token)
        audio.release()
        vibrator.stop()
        releaseWakeLock()
        super.onDestroy()
    }

    companion object {
        private const val TAG = "RingService"
        const val ACTION_START = "com.migdlp.gentlealarm.START_SESSION"
        const val ACTION_SNOOZE = "com.migdlp.gentlealarm.ACTION_SNOOZE"
        const val ACTION_DISMISS = "com.migdlp.gentlealarm.ACTION_DISMISS"
        const val ACTION_EVENT = "com.migdlp.gentlealarm.EVENT"
        const val EXTRA_REQUEST = "request"
        const val EXTRA_EVENT = "event"
    }
}
