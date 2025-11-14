package com.example.kdtd_ver2_1

import android.app.ActivityManager
import android.app.KeyguardManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.wifi.WifiManager
import android.os.BatteryManager
import android.os.Build
import android.os.Environment
import android.os.StatFs
import android.telephony.PhoneStateListener
import android.telephony.SignalStrength
import android.telephony.TelephonyManager
import android.view.KeyEvent
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    // Trùng với bên Dart (MethodChannel)
    private val CHANNEL = "com.fidobox/diagnostics"

    private var lastDbm: Int? = null
    private var headsetPlugged: Boolean? = null

    private var telephonyManager: TelephonyManager? = null
    private var signalListener: PhoneStateListener? = null
    private var headsetReceiver: BroadcastReceiver? = null

    // EventChannel sink để stream key events về Flutter
    private var keyEventSink: EventChannel.EventSink? = null

    // Result cho gọi "đợi một lần" (waitForKeyEvent)
    private var oneShotWaitResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // === Headset plug/unplug (có dây) ===
        headsetReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == Intent.ACTION_HEADSET_PLUG) {
                    val state = intent.getIntExtra("state", -1)
                    headsetPlugged = when (state) {
                        0 -> false
                        1 -> true
                        else -> null
                    }
                }
            }
        }
        registerReceiver(headsetReceiver, IntentFilter(Intent.ACTION_HEADSET_PLUG))

        // === Cường độ sóng di động (dBm) ===
        telephonyManager = getSystemService(TELEPHONY_SERVICE) as TelephonyManager
        signalListener = object : PhoneStateListener() {
            @Suppress("DEPRECATION")
            override fun onSignalStrengthsChanged(signalStrength: SignalStrength) {
                super.onSignalStrengthsChanged(signalStrength)
                try {
                    lastDbm = signalStrength.cellSignalStrengths.firstOrNull()?.dbm
                } catch (_: Exception) { }
            }
        }
        @Suppress("DEPRECATION")
        telephonyManager?.listen(signalListener, PhoneStateListener.LISTEN_SIGNAL_STRENGTHS)

        // === MethodChannel: các API đồng bộ ===
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getSimSlotCount" -> {
                        val count = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            telephonyManager?.phoneCount ?: 1
                        } else 1
                        result.success(count)
                    }

                    "getSimStates" -> {
                        val states = mutableListOf<String>()
                        val count = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            telephonyManager?.phoneCount ?: 1
                        } else 1
                        for (i in 0 until count) {
                            @Suppress("DEPRECATION")
                            val state = telephonyManager?.simState
                            val s = when (state) {
                                TelephonyManager.SIM_STATE_READY -> "READY"
                                TelephonyManager.SIM_STATE_ABSENT -> "ABSENT"
                                else -> "UNKNOWN"
                            }
                            states.add(s)
                        }
                        result.success(states)
                    }

                    "getSignalStrengthDbm" -> {
                        result.success(lastDbm)
                    }

                    "getMobileRadioType" -> {
                        val type = telephonyManager?.dataNetworkType ?: TelephonyManager.NETWORK_TYPE_UNKNOWN
                        val name = when (type) {
                            TelephonyManager.NETWORK_TYPE_NR -> "NR"
                            TelephonyManager.NETWORK_TYPE_LTE -> "LTE"
                            TelephonyManager.NETWORK_TYPE_HSPAP,
                            TelephonyManager.NETWORK_TYPE_HSPA,
                            TelephonyManager.NETWORK_TYPE_HSDPA,
                            TelephonyManager.NETWORK_TYPE_HSUPA -> "HSPA"
                            TelephonyManager.NETWORK_TYPE_EDGE -> "EDGE"
                            TelephonyManager.NETWORK_TYPE_GPRS -> "GPRS"
                            else -> "UNKNOWN"
                        }
                        result.success(name)
                    }

                    "isWiredHeadsetPlugged" -> {
                        result.success(headsetPlugged)
                    }

                    "isScreenLocked" -> {
                        val km = getSystemService(KEYGUARD_SERVICE) as KeyguardManager
                        result.success(km.isKeyguardLocked)
                    }

                    "getChargingSource" -> {
                        val ifilter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
                        val bs = registerReceiver(null, ifilter)
                        val plugged = bs?.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1) ?: -1
                        val src = when (plugged) {
                            BatteryManager.BATTERY_PLUGGED_USB -> "usb"
                            BatteryManager.BATTERY_PLUGGED_AC -> "ac"
                            BatteryManager.BATTERY_PLUGGED_WIRELESS -> "wireless"
                            else -> "unknown"
                        }
                        result.success(src)
                    }

                    "isSPenSupported" -> {
                        val supported = Build.MANUFACTURER.equals("samsung", true)
                        result.success(supported)
                    }

                    // Chờ 1 phím vật lý, trả về đúng 1 lần
                    "waitForKeyEvent" -> {
                        if (oneShotWaitResult != null) {
                            result.error("BUSY", "Already waiting for a key event", null)
                        } else {
                            oneShotWaitResult = result
                        }
                    }

                    // Thông tin RAM/ROM
                    "getRamInfo" -> result.success(getRamInfo())
                    "getRomInfo" -> result.success(getRomInfo())

                    // Marketing Name
                    "getMarketingName" -> {
                        val marketingName = getDeviceMarketingName()
                        result.success(marketingName)
                    }

                    // Check if WiFi is enabled
                    "isWifiEnabled" -> {
                        try {
                            val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
                            result.success(wifiManager.isWifiEnabled)
                        } catch (e: Exception) {
                            result.success(null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }

        // === EventChannel: stream key events liên tục ===
        val KEY_EVENT_CHANNEL = "com.fidobox/diagnostics_keyevents"
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, KEY_EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    keyEventSink = events
                }
                override fun onCancel(arguments: Any?) {
                    keyEventSink = null
                }
            })
    }

    // Bắt key từ Activity và forward về Flutter
    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        try {
            val map = mapOf(
                "keyCode" to event.keyCode,
                "action" to if (event.action == KeyEvent.ACTION_DOWN) "down" else "up",
                "unicodeChar" to event.unicodeChar,
                "isRepeat" to (event.repeatCount > 0)
            )

            // Stream cho EventChannel
            keyEventSink?.success(map)

            // Nếu đang có caller chờ one-shot, trả về và clear
            oneShotWaitResult?.let { res ->
                res.success(map)
                oneShotWaitResult = null
            }
        } catch (_: Exception) { }
        return super.dispatchKeyEvent(event)
    }

    override fun onDestroy() {
        super.onDestroy()
        try { headsetReceiver?.let { unregisterReceiver(it) } } catch (_: Exception) {}
        @Suppress("DEPRECATION")
        telephonyManager?.listen(signalListener, PhoneStateListener.LISTEN_NONE)
        keyEventSink = null
        oneShotWaitResult = null
    }

    // ===== Helpers RAM/ROM =====
    private fun getRamInfo(): Map<String, Any?> {
        return try {
            val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val mi = ActivityManager.MemoryInfo()
            am.getMemoryInfo(mi)
            val total = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) mi.totalMem else null
            val free = mi.availMem
            mapOf("freeBytes" to free, "totalBytes" to total)
        } catch (e: Exception) {
            mapOf("freeBytes" to null, "totalBytes" to null)
        }
    }

    private fun getRomInfo(): Map<String, Any?> {
        return try {
            val dataDir = Environment.getDataDirectory()
            val stat = StatFs(dataDir.path)

            val blockSize = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) stat.blockSizeLong else @Suppress("DEPRECATION") stat.blockSize.toLong()
            val totalBlocks = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) stat.blockCountLong else @Suppress("DEPRECATION") stat.blockCount.toLong()
            val availBlocks = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) stat.availableBlocksLong else @Suppress("DEPRECATION") stat.availableBlocks.toLong()

            val totalBytes = blockSize * totalBlocks
            val freeBytes  = blockSize * availBlocks
            mapOf("freeBytes" to freeBytes, "totalBytes" to totalBytes)
        } catch (e: Exception) {
            mapOf("freeBytes" to null, "totalBytes" to null)
        }
    }

    // Get device marketing name (e.g., "Galaxy S21" instead of "SM-G991N")
    private fun getDeviceMarketingName(): String {
        val model = Build.MODEL.uppercase()
        val brand = Build.MANUFACTURER.uppercase()
        
        // Samsung devices
        if (brand.contains("SAMSUNG")) {
            return when {
                // Galaxy S Series
                model.contains("SM-G991") -> "Galaxy S21 5G"
                model.contains("SM-G996") -> "Galaxy S21+"
                model.contains("SM-G998") -> "Galaxy S21 Ultra"
                model.contains("SM-G990") -> "Galaxy S21 FE"
                model.contains("SM-S901") -> "Galaxy S22"
                model.contains("SM-S906") -> "Galaxy S22+"
                model.contains("SM-S908") -> "Galaxy S22 Ultra"
                model.contains("SM-S911") -> "Galaxy S23"
                model.contains("SM-S916") -> "Galaxy S23+"
                model.contains("SM-S918") -> "Galaxy S23 Ultra"
                model.contains("SM-S921") -> "Galaxy S24"
                model.contains("SM-S926") -> "Galaxy S24+"
                model.contains("SM-S928") -> "Galaxy S24 Ultra"
                
                // Galaxy A Series
                model.contains("SM-A536") -> "Galaxy A53 5G"
                model.contains("SM-A546") -> "Galaxy A54 5G"
                model.contains("SM-A556") -> "Galaxy A55 5G"
                model.contains("SM-A336") -> "Galaxy A33 5G"
                model.contains("SM-A346") -> "Galaxy A34 5G"
                model.contains("SM-A356") -> "Galaxy A35 5G"
                model.contains("SM-A736") -> "Galaxy A73 5G"
                model.contains("SM-A146") -> "Galaxy A14"
                model.contains("SM-A156") -> "Galaxy A15"
                model.contains("SM-A256") -> "Galaxy A25"
                model.contains("SM-A056") -> "Galaxy A05"
                
                // Galaxy Z Series (Foldable)
                model.contains("SM-F936") -> "Galaxy Z Fold4"
                model.contains("SM-F946") -> "Galaxy Z Fold5"
                model.contains("SM-F956") -> "Galaxy Z Fold6"
                model.contains("SM-F731") -> "Galaxy Z Flip5"
                model.contains("SM-F741") -> "Galaxy Z Flip6"
                
                // Galaxy Note Series
                model.contains("SM-N986") -> "Galaxy Note20 Ultra"
                model.contains("SM-N981") -> "Galaxy Note20"
                
                else -> "Samsung ${Build.MODEL}"
            }
        }
        
        // Xiaomi devices
        if (brand.contains("XIAOMI")) {
            return when {
                model.contains("2201123G") || model.contains("2201123C") -> "Xiaomi 12"
                model.contains("2206123SC") -> "Xiaomi 12 Pro"
                model.contains("2211133C") -> "Xiaomi 13"
                model.contains("2210132C") -> "Xiaomi 13 Pro"
                model.contains("23013RK75C") -> "Xiaomi 14"
                model.contains("23116PN5BC") -> "Xiaomi 14 Pro"
                model.contains("M2012K11AG") -> "Redmi Note 10 Pro"
                model.contains("21091116AG") -> "Redmi Note 11"
                model.contains("22101316G") -> "Redmi Note 12"
                model.contains("23021RAAEG") -> "Redmi Note 13"
                model.contains("M2101K6G") -> "POCO X3 Pro"
                model.contains("22101320G") -> "POCO X5 Pro"
                else -> "Xiaomi ${Build.MODEL}"
            }
        }
        
        // Oppo devices
        if (brand.contains("OPPO")) {
            return when {
                model.contains("CPH2451") -> "Oppo Find X5 Pro"
                model.contains("CPH2525") -> "Oppo Find X6 Pro"
                model.contains("CPH2437") -> "Oppo Reno8 Pro"
                model.contains("CPH2481") -> "Oppo Reno9 Pro"
                model.contains("CPH2531") -> "Oppo Reno10 Pro"
                model.contains("CPH2415") -> "Oppo A77"
                model.contains("CPH2565") -> "Oppo A78"
                else -> "Oppo ${Build.MODEL}"
            }
        }
        
        // Vivo devices
        if (brand.contains("VIVO")) {
            return when {
                model.contains("V2227") -> "Vivo X90 Pro"
                model.contains("V2250") -> "Vivo X80 Pro"
                model.contains("V2231") -> "Vivo V27 Pro"
                model.contains("V2254") -> "Vivo V25 Pro"
                model.contains("V2207") -> "Vivo Y35"
                else -> "Vivo ${Build.MODEL}"
            }
        }
        
        // Apple devices (iOS won't reach here, but just in case)
        if (brand.contains("APPLE")) {
            return "iPhone ${Build.MODEL}"
        }
        
        // Google Pixel
        if (brand.contains("GOOGLE")) {
            return when {
                model.contains("PIXEL 8 PRO") -> "Pixel 8 Pro"
                model.contains("PIXEL 8") -> "Pixel 8"
                model.contains("PIXEL 7 PRO") -> "Pixel 7 Pro"
                model.contains("PIXEL 7") -> "Pixel 7"
                model.contains("PIXEL 6 PRO") -> "Pixel 6 Pro"
                model.contains("PIXEL 6") -> "Pixel 6"
                else -> Build.MODEL
            }
        }
        
        // Default: return brand + model
        return "${Build.MANUFACTURER} ${Build.MODEL}"
    }
}
