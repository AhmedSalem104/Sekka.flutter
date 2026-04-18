package com.sekka.sekka

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.sekka.sekka/dnd"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

                when (call.method) {
                    "hasAccess" -> {
                        result.success(nm.isNotificationPolicyAccessGranted)
                    }
                    "requestAccess" -> {
                        if (!nm.isNotificationPolicyAccessGranted) {
                            val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
                            startActivity(intent)
                        }
                        result.success(null)
                    }
                    "enableDnd" -> {
                        if (nm.isNotificationPolicyAccessGranted) {
                            nm.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_NONE)
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    }
                    "disableDnd" -> {
                        if (nm.isNotificationPolicyAccessGranted) {
                            nm.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_ALL)
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
