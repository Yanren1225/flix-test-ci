package com.ifreedomer.flix

import android.net.wifi.WifiManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import android.content.Intent
import android.content.Context


class MainActivity : FlutterActivity() {
    companion object {
        const val MULTICAST_LOCK_CHANNEL = "com.ifreedomer.flix/multicast-lock"
        const val PAY_CHANNEL = "com.ifreedomer.flix/pay"
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


}
