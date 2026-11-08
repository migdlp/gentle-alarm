package com.migdlp.gentlealarm

import android.content.Intent
import com.migdlp.gentlealarm.channel.AlarmChannel
import com.migdlp.gentlealarm.channel.SystemChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var systemChannel: SystemChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        AlarmChannel.register(flutterEngine, applicationContext)
        systemChannel = SystemChannel(this).also { it.register(flutterEngine) }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (systemChannel?.onActivityResult(requestCode, resultCode, data) != true) {
            @Suppress("DEPRECATION")
            super.onActivityResult(requestCode, resultCode, data)
        }
    }

    override fun onDestroy() {
        systemChannel?.stopPreview()
        super.onDestroy()
    }
}
