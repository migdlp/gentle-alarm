package com.migdlp.gentlealarm.channel

import android.app.Activity
import android.content.Intent
import com.migdlp.gentlealarm.ring.RingService
import com.migdlp.gentlealarm.ring.RingSessionBus
import com.migdlp.gentlealarm.ring.SessionSnapshot
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

object RingChannel {
    const val NAME = "gentle_alarm/ring"
    const val EVENTS = "gentle_alarm/ring_events"

    private val gestures = mapOf(
        "dismissSwipe" to "swipeDismiss",
        "snooze" to "snooze",
        "wakeUp" to "wakeUp",
        "wakeEarly" to "wakeEarly",
        "confirmAwake" to "confirmAwake",
        "finishGreeting" to "finishGreeting",
    )

    fun register(engine: FlutterEngine, activity: Activity) {
        val messenger = engine.dartExecutor.binaryMessenger
        MethodChannel(messenger, NAME).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "getSession" -> result.success(RingSessionBus.current()?.toMap())
                    "setBrightness" -> {
                        val v = (call.argument<Number>("value") ?: 1.0).toFloat().coerceIn(0.01f, 1f)
                        val attrs = activity.window.attributes
                        attrs.screenBrightness = v
                        activity.window.attributes = attrs
                        result.success(null)
                    }
                    in gestures -> {
                        if (RingSessionBus.current() != null) {
                            activity.startService(
                                Intent(activity, RingService::class.java)
                                    .setAction(RingService.ACTION_EVENT)
                                    .putExtra(RingService.EXTRA_EVENT, gestures[call.method]),
                            )
                        }
                        if (call.method == "finishGreeting") activity.finish()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("INTERNAL", e.message, null)
            }
        }
        var listener: ((SessionSnapshot?) -> Unit)? = null
        EventChannel(messenger, EVENTS).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    val l: (SessionSnapshot?) -> Unit = { s -> events.success(s?.toMap()) }
                    listener = l
                    RingSessionBus.listeners.add(l)
                }

                override fun onCancel(arguments: Any?) {
                    listener?.let { RingSessionBus.listeners.remove(it) }
                    listener = null
                }
            },
        )
    }
}
