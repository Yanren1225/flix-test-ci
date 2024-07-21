package com.ifreedomer.flix

import android.app.DownloadManager
import android.content.ClipboardManager
import android.net.wifi.WifiManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import android.content.Intent
import android.content.Context
import android.os.Bundle
import android.os.PowerManager
import android.util.Log
import com.crazecoder.openfile.FileProvider
import android.provider.DocumentsContract
import android.net.Uri
import java.io.File





class MainActivity : FlutterActivity() {
    companion object {
        const val MULTICAST_LOCK_CHANNEL = "com.ifreedomer.flix/multicast-lock"
        const val PAY_CHANNEL = "com.ifreedomer.flix/pay"
        const val CLIPBOARD_CHANNEL = "com.ifreedomer.flix/clipboard"
        const val LOCK_CHANNEL = "com.ifreedomer.flix/lock"
        const val FILE_CHANNEL = "com.ifreedomer.flix/file"
        const val TAG = "MainActivity"

        const val FROM = "from"
        const val FROM_CLIPBOARD_NOTIFICATION = "send_clipboard_action"
        var clipboardChannel: MethodChannel? = null
        fun notifyClipboardCopy(context: Context) {
            val clipboardManager =
                context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            Log.i(TAG, "notifyStartClipboardCopy ${clipboardManager.text}", Exception())
            clipboardChannel?.invokeMethod("return_send_clipboard", clipboardManager.text)
        }
    }

    private var multicastLock: WifiManager.MulticastLock? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var wifiLock: WifiManager.WifiLock? = null
    private var isFromNotification = false
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.i(TAG,"onCreate action = ${intent.action}")
        isFromNotification = isFromNotification(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        Log.i(TAG,"onCreate action = ${intent.action}")
        isFromNotification = isFromNotification(intent)
    }

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


        clipboardChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CLIPBOARD_CHANNEL
        )

        clipboardChannel?.setMethodCallHandler { call, result ->
            if (call.method.equals("send_clipboard")) {
                startActivity(Intent(applicationContext, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    putExtra(FROM, FROM_CLIPBOARD_NOTIFICATION)
                })
                result.success("")
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

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            FILE_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "openFile"){
                val path = call.argument<String>("path")
                Log.i(TAG, "openFile path = $path")
                if (path.isNullOrEmpty()) {
                    return@setMethodCallHandler result.success(false)
                }
                try {
                    // var uri: android.net.Uri? = android.net.Uri.parse("content://com.android.externalstorage.documents/document/primary:" + path)
                    val file = File(path)
                    val type = getFileType(path)
                    val uri = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
                        FileProvider.getUriForFile(applicationContext, applicationContext.packageName + ".fileProvider.com.crazecoder.openfile", file)
                    } else {
                        Uri.fromFile(file)
                    }
                    Log.i(TAG, "openFile uri = $uri type = $type")
                    //DownloadManager.ACTION_VIEW_DOWNLOADS
                    val intent = Intent(Intent.ACTION_VIEW)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    intent.setDataAndType(uri, type)
                    intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, uri)
                    intent.addCategory(Intent.CATEGORY_DEFAULT)
                    Log.i(TAG, "openFile intent action = ${intent.action}")
                    startActivity(intent)
                    return@setMethodCallHandler result.success(true)
                }catch (e: Exception) {
                    e.printStackTrace()
                    return@setMethodCallHandler result.success(false)
                }

            }

        }

    }

    private fun isFromNotification(curIntent:Intent) :Boolean{
        val from = curIntent.action
        return FROM_CLIPBOARD_NOTIFICATION == from
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

    private fun getFileType(filePath: String): String? {
        val fileStrs = filePath.split("\\.")
        val fileTypeStr: String = fileStrs[fileStrs.size - 1].toLowerCase()
        return when (fileTypeStr) {
            "3gp" -> "video/3gpp"
            "torrent" -> "application/x-bittorrent"
            "kml" -> "application/vnd.google-earth.kml+xml"
            "gpx" -> "application/gpx+xml"
            "apk" -> "application/vnd.android.package-archive"
            "asf" -> "video/x-ms-asf"
            "avi" -> "video/x-msvideo"
            "bin", "class", "exe" -> "application/octet-stream"
            "bmp" -> "image/bmp"
            "c" -> "text/plain"
            "conf" -> "text/plain"
            "cpp" -> "text/plain"
            "doc" -> "application/msword"
            "docx" -> "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
            "xls", "csv" -> "application/vnd.ms-excel"
            "xlsx" -> "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            "gif" -> "image/gif"
            "gtar" -> "application/x-gtar"
            "gz" -> "application/x-gzip"
            "h" -> "text/plain"
            "htm" -> "text/html"
            "html" -> "text/html"
            "jar" -> "application/java-archive"
            "java" -> "text/plain"
            "jpeg" -> "image/jpeg"
            "jpg" -> "image/jpeg"
            "js" -> "application/x-javascript"
            "log" -> "text/plain"
            "m3u" -> "audio/x-mpegurl"
            "m4a" -> "audio/mp4a-latm"
            "m4b" -> "audio/mp4a-latm"
            "m4p" -> "audio/mp4a-latm"
            "m4u" -> "video/vnd.mpegurl"
            "m4v" -> "video/x-m4v"
            "mov" -> "video/quicktime"
            "mp2" -> "audio/x-mpeg"
            "mp3" -> "audio/x-mpeg"
            "mp4" -> "video/mp4"
            "mpc" -> "application/vnd.mpohun.certificate"
            "mpe" -> "video/mpeg"
            "mpeg" -> "video/mpeg"
            "mpg" -> "video/mpeg"
            "mpg4" -> "video/mp4"
            "mpga" -> "audio/mpeg"
            "msg" -> "application/vnd.ms-outlook"
            "ogg" -> "audio/ogg"
            "pdf" -> "application/pdf"
            "png" -> "image/png"
            "pps" -> "application/vnd.ms-powerpoint"
            "ppt" -> "application/vnd.ms-powerpoint"
            "pptx" -> "application/vnd.openxmlformats-officedocument.presentationml.presentation"
            "prop" -> "text/plain"
            "rc" -> "text/plain"
            "rmvb" -> "audio/x-pn-realaudio"
            "rtf" -> "application/rtf"
            "sh" -> "text/plain"
            "tar" -> "application/x-tar"
            "tgz" -> "application/x-compressed"
            "txt" -> "text/plain"
            "wav" -> "audio/x-wav"
            "wma" -> "audio/x-ms-wma"
            "wmv" -> "audio/x-ms-wmv"
            "wps" -> "application/vnd.ms-works"
            "xml" -> "text/plain"
            "z" -> "application/x-compress"
            "zip" -> "application/x-zip-compressed"
            else -> "*/*"
        }
    }

}
