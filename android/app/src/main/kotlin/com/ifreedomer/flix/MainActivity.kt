package com.ifreedomer.flix

import android.net.wifi.WifiManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import android.content.Intent
import android.content.Context
import android.os.PowerManager


class MainActivity : FlutterActivity() {
    companion object {
        const val MULTICAST_LOCK_CHANNEL = "com.ifreedomer.flix/multicast-lock"
        const val PAY_CHANNEL = "com.ifreedomer.flix/pay"
        const val LOCK_CHANNEL = "com.ifreedomer.flix/lock"
    }

    private var multicastLock: WifiManager.MulticastLock? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var wifiLock: WifiManager.WifiLock? = null


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

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            PAY_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method.equals("wechat_scan_qrcode")) {
                openWechatScanQrCode(applicationContext)
            } else {
                result.notImplemented();
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            LOCK_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method.equals("acquireWakeLock")) {
                result.success(acquireWakeLock());
            } else if (call.method.equals("releaseWakeLock")) {
                result.success(releaseWakeLock());
            } else if (call.method.equals("acquireWifiLock")) {
                result.success(acquireWifiLock());
            } else if (call.method.equals("releaseWifiLock")) {
                result.success(releaseWifiLock());
            } else {
                result.notImplemented();
            }
        }

    }


    private fun aquireMulticastLock(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.DONUT) {
            return false
        }
        val wifi = context.getSystemService(WIFI_SERVICE) as WifiManager
        multicastLock = wifi.createMulticastLock("discovery-multicast-lock")
        multicastLock?.acquire()
        return true
    }

    private fun releaseMulticastLock(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.DONUT) {
            return false
        }
        multicastLock?.release()
        return true
    }


    /**
     * 打开微信并跳入到二维码扫描页面
     *
     * @param context
     */
    fun openWechatScanQrCode(context: Context) {
        try {
            val intent: Intent? =
                context.getPackageManager().getLaunchIntentForPackage("com.tencent.mm")
            intent?.putExtra("LauncherUI.From.Scaner.Shortcut", true)
            context.startActivity(intent)
        } catch (e: Exception) {
        }
    }

    private fun acquireWakeLock(): Boolean {
        if (wakeLock != null && wakeLock?.isHeld == true) {
            return true
        }
        if (wakeLock != null) {
            wakeLock?.acquire()
            return true
        }

        wakeLock = (getSystemService(Context.POWER_SERVICE) as PowerManager).run {
            newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "com.ifreedomer.flix:WakeLock").apply {
                setReferenceCounted(false)
                acquire()
            }
        }
        return true
    }

    private fun releaseWakeLock(): Boolean {
        wakeLock?.release()
        return true
    }

    private fun acquireWifiLock(): Boolean {
        if (wifiLock != null && wifiLock?.isHeld == true) {
            return true
        }
        if (wifiLock != null) {
            wifiLock?.acquire()
            return true
        }

        wifiLock = (getSystemService(Context.WIFI_SERVICE) as WifiManager).run {
            createWifiLock(WifiManager.WIFI_MODE_FULL_HIGH_PERF, "com.ifreedomer.flix:WifiLock").apply {
                setReferenceCounted(false)
                acquire()
            }
        }
        return true
    }

    private fun releaseWifiLock(): Boolean {
        wifiLock?.release()
        return true
    }

}
