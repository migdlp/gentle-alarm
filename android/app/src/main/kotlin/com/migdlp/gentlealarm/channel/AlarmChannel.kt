package com.migdlp.gentlealarm.channel

import android.content.Context
import com.migdlp.gentlealarm.alarm.AlarmScheduler
import com.migdlp.gentlealarm.alarm.AlarmStore
import com.migdlp.gentlealarm.alarm.ScheduleFailedException
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.time.ZoneId

object AlarmChannel {
    const val NAME = "gentle_alarm/alarms"

    fun register(engine: FlutterEngine, context: Context) {
        val handler = AlarmChannelHandler(
            AlarmStore.from(context),
            AlarmScheduler.from(context),
            System::currentTimeMillis,
            ZoneId::systemDefault,
        )
        MethodChannel(engine.dartExecutor.binaryMessenger, NAME).setMethodCallHandler { call, result ->
            try {
                result.success(dispatch(handler, call))
            } catch (e: ChannelError) {
                result.error(e.code, e.message, null)
            } catch (e: ScheduleFailedException) {
                result.error("SCHEDULE_FAILED", e.message, null)
            } catch (e: Exception) {
                result.error("INTERNAL", e.message, null)
            }
        }
    }

    private fun dispatch(h: AlarmChannelHandler, call: MethodCall): Any? = when (call.method) {
        "listAlarms" -> h.list()
        "upsertAlarm" -> h.upsert(call.arguments as Map<*, *>)
        "deleteAlarm" -> {
            h.delete(call.argument<String>("id")!!)
            null
        }
        "setEnabled" -> h.setEnabled(call.argument<String>("id")!!, call.argument<Boolean>("enabled")!!)
        "setSkipNext" -> h.setSkipNext(call.argument<String>("id")!!, call.argument<Boolean>("skip")!!)
        else -> throw ChannelError("INTERNAL", "método desconocido: ${call.method}")
    }
}
