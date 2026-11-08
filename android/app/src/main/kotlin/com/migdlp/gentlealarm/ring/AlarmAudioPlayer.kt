package com.migdlp.gentlealarm.ring

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.util.Log
import kotlin.math.max
import kotlin.math.roundToInt

class AlarmAudioPlayer(private val context: Context, private val listener: Listener) : AudioPort {
    interface Listener {
        fun onFocusLost()
        fun onFocusGained()
        fun onFallbackUsed()
    }

    private val am = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private val handler = Handler(Looper.getMainLooper())
    private val attrs = AudioAttributes.Builder()
        .setUsage(AudioAttributes.USAGE_ALARM)
        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
        .build()

    private var player: MediaPlayer? = null
    private var previousAlarmVolume: Int? = null
    private var focusRequest: AudioFocusRequest? = null
    private var ramp: RampScheduler? = null
    private var currentVolume = 0f
    private var usedFallback = false
    private var fadeToken = 0

    private val focusListener = AudioManager.OnAudioFocusChangeListener { change ->
        when (change) {
            AudioManager.AUDIOFOCUS_GAIN -> listener.onFocusGained()
            AudioManager.AUDIOFOCUS_LOSS,
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT,
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK -> listener.onFocusLost()
        }
    }

    private val rampTick = object : Runnable {
        override fun run() {
            val r = ramp ?: return
            val now = SystemClock.elapsedRealtime()
            setVolume(r.volumeAt(now))
            if (!r.isDone(now)) handler.postDelayed(this, 250)
        }
    }

    override fun start(resolved: Resolved, maxVolumePercent: Int, startVolume: Float, rampMs: Long) {
        fadeToken++
        handler.removeCallbacks(rampTick)
        fixSystemVolume(maxVolumePercent)
        requestFocus()
        setVolume(startVolume)
        val p = player ?: createPlayer(resolved)
        if (p == null) return
        player = p
        if (!p.isPlaying) p.start()
        ramp = RampScheduler(SystemClock.elapsedRealtime(), rampMs, startVolume)
        handler.post(rampTick)
    }

    override fun stop(fadeMs: Long) {
        handler.removeCallbacks(rampTick)
        ramp = null
        val p = player ?: return
        val token = ++fadeToken
        val from = currentVolume
        val t0 = SystemClock.elapsedRealtime()
        val step = object : Runnable {
            override fun run() {
                if (token != fadeToken) return
                val e = SystemClock.elapsedRealtime() - t0
                setVolume(VolumeRamp.fadeVolume(e, fadeMs, from))
                if (e < fadeMs) handler.postDelayed(this, 50) else if (p.isPlaying) p.pause()
            }
        }
        handler.post(step)
    }

    override fun pause() {
        handler.removeCallbacks(rampTick)
        player?.takeIf { it.isPlaying }?.pause()
    }

    override fun resume(rampMs: Long) {
        val p = player ?: return
        fadeToken++
        setVolume(0f)
        if (!p.isPlaying) p.start()
        ramp = RampScheduler(SystemClock.elapsedRealtime(), rampMs, 0f)
        handler.removeCallbacks(rampTick)
        handler.post(rampTick)
    }

    fun release() {
        fadeToken++
        handler.removeCallbacksAndMessages(null)
        ramp = null
        player?.release()
        player = null
        previousAlarmVolume?.let {
            try {
                am.setStreamVolume(AudioManager.STREAM_ALARM, it, 0)
            } catch (e: SecurityException) {
                Log.w(TAG, "No se pudo restaurar el volumen", e)
            }
        }
        previousAlarmVolume = null
        focusRequest?.let { am.abandonAudioFocusRequest(it) }
        focusRequest = null
    }

    private fun setVolume(v: Float) {
        currentVolume = v
        player?.setVolume(v, v)
    }

    private fun fixSystemVolume(maxPercent: Int) {
        if (previousAlarmVolume != null) return
        previousAlarmVolume = am.getStreamVolume(AudioManager.STREAM_ALARM)
        val max = am.getStreamMaxVolume(AudioManager.STREAM_ALARM)
        val target = max(1, (max * maxPercent / 100.0).roundToInt())
        try {
            am.setStreamVolume(AudioManager.STREAM_ALARM, target, 0)
        } catch (e: SecurityException) {
            Log.w(TAG, "No se pudo fijar el volumen (No molestar)", e)
        }
    }

    private fun requestFocus() {
        if (focusRequest != null) return
        val req = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
            .setAudioAttributes(attrs)
            .setOnAudioFocusChangeListener(focusListener, handler)
            .build()
        am.requestAudioFocus(req)
        focusRequest = req
    }

    private fun createPlayer(resolved: Resolved): MediaPlayer? {
        return try {
            MediaPlayer().apply {
                setAudioAttributes(attrs)
                when (resolved) {
                    is Resolved.Raw -> {
                        val id = context.resources.getIdentifier(resolved.name, "raw", context.packageName)
                        context.resources.openRawResourceFd(id).use {
                            setDataSource(it.fileDescriptor, it.startOffset, it.length)
                        }
                    }
                    is Resolved.Uri -> setDataSource(context, Uri.parse(resolved.uri))
                }
                isLooping = true
                setOnErrorListener { _, _, _ ->
                    onPlayerError(resolved)
                    true
                }
                prepare()
            }
        } catch (e: Exception) {
            Log.w(TAG, "Fallo al preparar el audio", e)
            if (resolved is Resolved.Uri && !usedFallback) {
                usedFallback = true
                listener.onFallbackUsed()
                createPlayer(Resolved.Raw("birds_dawn", true))
            } else null
        }
    }

    private fun onPlayerError(resolved: Resolved) {
        player?.release()
        player = null
        if (resolved is Resolved.Uri && !usedFallback) {
            usedFallback = true
            listener.onFallbackUsed()
            val p = createPlayer(Resolved.Raw("birds_dawn", true)) ?: return
            player = p
            p.start()
        }
    }

    companion object {
        private const val TAG = "AlarmAudioPlayer"
    }
}
