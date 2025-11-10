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
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    // ⚠️ Chuỗi channel này PHẢI trùng với bên Dart:
    // const MethodChannel('com.fidobox/diagnostics')
    private val CHANNEL = "com.fidobox/diagnostics"

    private var lastDbm: Int? = null
    private var headsetPlugged: Boolean? = null

    private var telephonyManager: TelephonyManager? = null
    private var signalListener: PhoneStateListener? = null
    private var headsetReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // === Lắng nghe cắm/rút tai nghe có dây ===
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
        // ACTION_HEADSET_PLUG deprecated ở API mới, nhưng vẫn dùng được cho mục đích đơn giản
        registerReceiver(headsetReceiver, IntentFilter(Intent.ACTION_HEADSET_PLUG))

        // === Lắng nghe cường độ sóng di động (dBm) ===
        telephonyManager = getSystemService(TELEPHONY_SERVICE) as TelephonyManager
        signalListener = object : PhoneStateListener() {
            @Suppress("DEPRECATION")
            override fun onSignalStrengthsChanged(signalStrength: SignalStrength) {
                super.onSignalStrengthsChanged(signalStrength)
                try {
                    // Lấy cột sóng đầu tiên (có thể null tùy máy)
                    lastDbm = signalStrength.cellSignalStrengths.firstOrNull()?.dbm
                } catch (_: Exception) {
                    // ignore
                }
            }
        }
        @Suppress("DEPRECATION")
        telephonyManager?.listen(signalListener, PhoneStateListener.LISTEN_SIGNAL_STRENGTHS)

        // === MethodChannel: trả lời các lời gọi từ Flutter ===
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {

                // SIM: số khe
                "getSimSlotCount" -> {
                    val count = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        telephonyManager?.phoneCount ?: 1
                    } else 1
                    result.success(count)
                }

                // SIM: trạng thái từng khe (READY/ABSENT/UNKNOWN)
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

                // Sóng di động: dBm (có thể null nếu không có quyền/hệ thống chặn)
                "getSignalStrengthDbm" -> {
                    result.success(lastDbm)
                }

                // Loại sóng: NR/LTE/HSPA/EDGE/GPRS/UNKNOWN
                "getMobileRadioType" -> {
                    val type = telephonyManager?.dataNetworkType ?: TelephonyManager.NETWORK_TYPE_UNKNOWN
                    val name = when (type) {
                        TelephonyManager.NETWORK_TYPE_NR -> "NR"          // 5G
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

                // Tai nghe có dây cắm chưa? (true/false/null)
                "isWiredHeadsetPlugged" -> {
                    result.success(headsetPlugged)
                }

                // Màn hình có đang khoá không? (Keyguard)
                "isScreenLocked" -> {
                    val km = getSystemService(KEYGUARD_SERVICE) as KeyguardManager
                    result.success(km.isKeyguardLocked)
                }

                // Nguồn sạc hiện tại: usb/ac/wireless/unknown
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

                // S-Pen có hỗ trợ không (ước lượng theo hãng)
                "isSPenSupported" -> {
                    val supported = Build.MANUFACTURER.equals("samsung", true)
                    result.success(supported)
                }

                // Bắt phím vật lý (placeholder — muốn làm thật thì cài Activity/Overlay nhận keyevent)
                "waitForKeyEvent" -> {
                    result.success(null)
                }

                // ===== NEW: RAM/ROM =====
                "getRamInfo" -> {
                    result.success(getRamInfo())
                }
                "getRomInfo" -> {
                    result.success(getRomInfo())
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            headsetReceiver?.let { unregisterReceiver(it) }
        } catch (_: Exception) { /* ignore */ }
        @Suppress("DEPRECATION")
        telephonyManager?.listen(signalListener, PhoneStateListener.LISTEN_NONE)
    }

    // ====== NEW: Helpers lấy RAM/ROM ======
    private fun getRamInfo(): Map<String, Any?> {
        return try {
            val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val mi = ActivityManager.MemoryInfo()
            am.getMemoryInfo(mi)

            val total = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                mi.totalMem
            } else null
            val free = mi.availMem

            mapOf(
                "freeBytes" to free,
                "totalBytes" to total
            )
        } catch (e: Exception) {
            mapOf(
                "freeBytes" to null,
                "totalBytes" to null
            )
        }
    }

    private fun getRomInfo(): Map<String, Any?> {
        return try {
            val dataDir = Environment.getDataDirectory() // /data
            val stat = StatFs(dataDir.path)

            val blockSize = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
                stat.blockSizeLong
            } else {
                @Suppress("DEPRECATION") stat.blockSize.toLong()
            }
            val totalBlocks = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
                stat.blockCountLong
            } else {
                @Suppress("DEPRECATION") stat.blockCount.toLong()
            }
            val availBlocks = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
                stat.availableBlocksLong
            } else {
                @Suppress("DEPRECATION") stat.availableBlocks.toLong()
            }

            val totalBytes = blockSize * totalBlocks
            val freeBytes  = blockSize * availBlocks

            mapOf(
                "freeBytes" to freeBytes,
                "totalBytes" to totalBytes
            )
        } catch (e: Exception) {
            mapOf(
                "freeBytes" to null,
                "totalBytes" to null
            )
        }
    }
}
