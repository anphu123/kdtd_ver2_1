package com.example.kdtd_ver2_1

import android.app.ActivityManager
import android.app.KeyguardManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
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
}
