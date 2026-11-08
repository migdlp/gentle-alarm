package com.migdlp.gentlealarm.channel

import android.Manifest
import android.app.Activity
import android.app.AlarmManager
import android.app.NotificationManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat
import android.content.Intent
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.OpenableColumns
import android.util.Log
import com.migdlp.gentlealarm.ring.Resolved
import com.migdlp.gentlealarm.ring.SoundResolver
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class SystemChannel(private val activity: Activity) {
    private val handler = Handler(Looper.getMainLooper())
    private var pickResult: MethodChannel.Result? = null
    private var notifResult: MethodChannel.Result? = null
    private var preview: MediaPlayer? = null
    private var previewToken = 0

    fun register(engine: FlutterEngine) {
        MethodChannel(engine.dartExecutor.binaryMessenger, NAME).setMethodCallHandler { call, result ->
            try {
                handle(call, result)
            } catch (e: Exception) {
                result.error("INTERNAL", e.message, null)
            }
        }
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "pickAudio" -> {
                if (pickResult != null) {
                    result.error("INTERNAL", "pickAudio en curso", null)
                    return
                }
                pickResult = result
                val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = "audio/*"
                    addFlags(
                        Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION,
                    )
                }
                @Suppress("DEPRECATION")
                activity.startActivityForResult(intent, REQUEST_PICK_AUDIO)
            }
            "previewSound" -> {
                startPreview(call.argument<String>("soundId") ?: "birds_dawn", call.argument<String>("uri"))
                result.success(null)
            }
            "stopPreviewSound" -> {
                stopPreview()
                result.success(null)
            }
            "canReadUri" -> result.success(canRead(call.argument<String>("uri")))
            "getPermissionStatus" -> result.success(permissionStatus())
            "requestNotificationPermission" -> requestNotifications(result)
            "openNotificationSettings" -> open(
                Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                    .putExtra(Settings.EXTRA_APP_PACKAGE, activity.packageName),
                result,
            )
            "openExactAlarmSettings" -> open(
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM, packageUri())
                } else detailsIntent(),
                result,
            )
            "openFullScreenSettings" -> open(
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                    Intent("android.settings.MANAGE_APP_USE_FULL_SCREEN_INTENT", packageUri())
                } else detailsIntent(),
                result,
            )
            "openBatterySettings" -> open(detailsIntent(), result)
            else -> result.notImplemented()
        }
    }

    private fun packageUri() = Uri.parse("package:${activity.packageName}")

    private fun detailsIntent() = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, packageUri())

    private fun open(intent: Intent, result: MethodChannel.Result) {
        try {
            activity.startActivity(intent)
        } catch (e: Exception) {
            Log.w(TAG, "No se pudo abrir los ajustes", e)
            try {
                activity.startActivity(detailsIntent())
            } catch (_: Exception) {
            }
        }
        result.success(null)
    }

    private fun permissionStatus(): Map<String, Any> {
        val sdk = Build.VERSION.SDK_INT
        val am = activity.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val nm = activity.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        return mapOf(
            "notifications" to NotificationManagerCompat.from(activity).areNotificationsEnabled(),
            "exactAlarms" to (sdk < Build.VERSION_CODES.S || am.canScheduleExactAlarms()),
            "fullScreen" to (sdk < Build.VERSION_CODES.UPSIDE_DOWN_CAKE || nm.canUseFullScreenIntent()),
            "sdkInt" to sdk,
            "manufacturer" to Build.MANUFACTURER.lowercase(),
        )
    }

    private fun requestNotifications(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(NotificationManagerCompat.from(activity).areNotificationsEnabled())
            return
        }
        if (activity.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED
        ) {
            result.success(true)
            return
        }
        if (notifResult != null) {
            result.error("INTERNAL", "solicitud en curso", null)
            return
        }
        notifResult = result
        activity.requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), REQUEST_NOTIFICATIONS)
    }

    fun onRequestPermissionsResult(requestCode: Int, grantResults: IntArray): Boolean {
        if (requestCode != REQUEST_NOTIFICATIONS) return false
        notifResult?.success(grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED)
        notifResult = null
        return true
    }

    /** Devuelve true si el resultado era de este canal. */
    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_PICK_AUDIO) return false
        val result = pickResult ?: return true
        pickResult = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return true
        }
        try {
            activity.contentResolver.takePersistableUriPermission(uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
        } catch (e: SecurityException) {
            Log.w(TAG, "Sin permiso persistente para $uri", e)
            result.success(null)
            return true
        }
        val name = activity.contentResolver.query(uri, null, null, null, null)?.use { c ->
            val i = c.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            if (c.moveToFirst() && i >= 0) c.getString(i) else null
        } ?: uri.lastPathSegment ?: "audio"
        result.success(mapOf("uri" to uri.toString(), "name" to name))
        return true
    }

    private fun canRead(uri: String?): Boolean {
        if (uri == null) return false
        return try {
            activity.contentResolver.openFileDescriptor(Uri.parse(uri), "r")?.use { true } ?: false
        } catch (e: Exception) {
            false
        }
    }

    private fun startPreview(soundId: String, uri: String?) {
        stopPreview()
        val resolved = SoundResolver.resolve(soundId, uri, ::canRead)
        val token = ++previewToken
        val p = MediaPlayer()
        try {
            p.setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build(),
            )
            when (resolved) {
                is Resolved.Raw -> {
                    val id = activity.resources.getIdentifier(resolved.name, "raw", activity.packageName)
                    activity.resources.openRawResourceFd(id).use {
                        p.setDataSource(it.fileDescriptor, it.startOffset, it.length)
                    }
                }
                is Resolved.Uri -> p.setDataSource(activity, Uri.parse(resolved.uri))
            }
            p.prepare()
            p.setVolume(0f, 0f)
            p.start()
        } catch (e: Exception) {
            Log.w(TAG, "No se pudo previsualizar", e)
            p.release()
            return
        }
        preview = p
        val t0 = System.currentTimeMillis()
        val fade = object : Runnable {
            override fun run() {
                if (token != previewToken || preview !== p) return
                val v = ((System.currentTimeMillis() - t0) / 1000f).coerceIn(0f, 1f)
                p.setVolume(v, v)
                if (v < 1f) handler.postDelayed(this, 50)
            }
        }
        handler.post(fade)
        handler.postDelayed({ if (token == previewToken) stopPreview() }, 10_000)
    }

    fun stopPreview() {
        previewToken++
        handler.removeCallbacksAndMessages(null)
        preview?.let {
            try {
                it.stop()
            } catch (_: IllegalStateException) {
            }
            it.release()
        }
        preview = null
    }

    companion object {
        const val NAME = "gentle_alarm/system"
        private const val TAG = "SystemChannel"
        private const val REQUEST_PICK_AUDIO = 4201
        private const val REQUEST_NOTIFICATIONS = 4202
    }
}
