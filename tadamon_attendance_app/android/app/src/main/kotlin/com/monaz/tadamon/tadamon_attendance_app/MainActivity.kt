package com.monaz.tadamon.tadamon_attendance_app

import android.os.Build
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.net.NetworkInterface

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.monaz.tadamon/device_hardware",
        ).setMethodCallHandler { call, result ->
            if (call.method != "getHardwareComponents") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            result.success(
                mapOf(
                    "processorId" to processorId(),
                    "motherboardId" to Build.BOARD,
                    "storageSerial" to Settings.Secure.getString(
                        contentResolver,
                        Settings.Secure.ANDROID_ID,
                    ),
                    "networkAdapterId" to networkAdapterId(),
                ),
            )
        }
    }

    private fun processorId(): String = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        "${Build.SOC_MANUFACTURER}:${Build.SOC_MODEL}"
    } else {
        Build.HARDWARE
    }

    private fun networkAdapterId(): String {
        val address = NetworkInterface.getNetworkInterfaces()?.toList()
            ?.asSequence()
            ?.filterNot { it.isLoopback }
            ?.mapNotNull { it.hardwareAddress }
            ?.firstOrNull { it.isNotEmpty() }
        return address?.joinToString("") { byte -> "%02X".format(byte) }
            ?: "${Build.DEVICE}:${Build.HARDWARE}"
    }
}
