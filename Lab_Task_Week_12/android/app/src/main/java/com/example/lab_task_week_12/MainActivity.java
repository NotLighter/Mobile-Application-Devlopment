package com.example.lab_task_week_12

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Build

class MainActivity: FlutterActivity() {
    private val DEVICE_INFO_CHANNEL = "platformchannel.companyname.com/deviceinfo"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Create MethodChannel
        val methodChannel = MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                DEVICE_INFO_CHANNEL
        )

        // Set up method call handler
        methodChannel.setMethodCallHandler { call, result ->
            // Check for incoming method call name and return a result
            if (call.method == "getDeviceInfo") {
                val deviceInfo = getDeviceInfo()
                result.success(deviceInfo)
            } else {
                result.notImplemented()
            }
        }
    }

    // Method to get device information using Android Build
    private fun getDeviceInfo(): String {
        return """
            Device: ${Build.DEVICE}
            Manufacturer: ${Build.MANUFACTURER}
            Model: ${Build.MODEL}
            Product: ${Build.PRODUCT}
            Version Release: ${Build.VERSION.RELEASE}
            Version SDK: ${Build.VERSION.SDK_INT}
            Fingerprint: ${Build.FINGERPRINT}
        """.trimIndent()
    }
}