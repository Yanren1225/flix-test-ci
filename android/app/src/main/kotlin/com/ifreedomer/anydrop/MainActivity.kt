package com.ifreedomer.anydrop

import android.net.wifi.WifiManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity : FlutterActivity() {
    companion object {
        const val MULTICAST_LOCK_CHANNEL = "com.ifreedomer.anydrop/multicast-lock"
    }

    private var multicastLock: WifiManager.MulticastLock? = null


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            MULTICAST_LOCK_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method.equals("aquire")) {
                result.success(aquireMulticastLock());
            } else if (call.method.equals("release")) {
                result.success(releaseMulticastLock());
            } else {
                result.notImplemented();
            }
        }
    }


    protected fun aquireMulticastLock(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.DONUT) {
            return false
        }
        val wifi = context.getSystemService(WIFI_SERVICE) as WifiManager
        multicastLock = wifi.createMulticastLock("discovery-multicast-lock")
        multicastLock?.acquire()
        return true
    }

    protected fun releaseMulticastLock(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.DONUT) {
            return false
        }
        multicastLock?.release()
        return true
    }
}
