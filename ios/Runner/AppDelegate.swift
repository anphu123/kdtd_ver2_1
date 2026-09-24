import AVFoundation
import CoreTelephony
import Flutter
import MediaPlayer
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  // Trùng với bên Dart (MethodChannel) và bản Android (MainActivity.kt)
  private let channelName = "com.fidobox/diagnostics"
  private let keyEventChannelName = "com.fidobox/diagnostics_keyevents"

  // Mã phím dùng chung với Android để phía Dart không phải phân nhánh nền tảng
  private let keyCodeVolumeUp = 24
  private let keyCodeVolumeDown = 25

  // Mức âm lượng neo giữa dải, để phím tăng/giảm luôn còn khoảng trống thay đổi
  private let anchorVolume: Float = 0.5

  private var keyEventSink: FlutterEventSink?
  private var oneShotWaitResult: FlutterResult?
  private var volumeObservation: NSKeyValueObservation?
  private var hiddenVolumeView: MPVolumeView?
  private var isRestoringVolume = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let messenger = engineBridge.applicationRegistrar.messenger()
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }

    let keyEvents = FlutterEventChannel(
      name: keyEventChannelName, binaryMessenger: messenger)
    keyEvents.setStreamHandler(self)
  }

  // Các case tương ứng với những method mà bản Android (MainActivity.kt) hỗ trợ
  // và có public API iOS tương đương. Những method còn lại (getChargingSource,
  // isScreenLocked, getSignalStrengthDbm, getSimSlotCount/States,
  // isWifiEnabled, getDeviceId) không có API công khai trên iOS — phía Dart
  // (device_info_helper.dart) đã tự xử lý fallback riêng cho iOS. RAM/ROM thì
  // đọc được thật (physicalMemory, volumeTotalCapacity) nên xử lý ở đây.
  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isWiredHeadsetPlugged":
      result(isWiredHeadsetPlugged())

    case "getRamInfo":
      result(getRamInfo())

    case "getRomInfo":
      result(getRomInfo())

    case "getMobileRadioType":
      result(getMobileRadioType())

    case "isSPenSupported":
      // S-Pen là phụ kiện độc quyền của Samsung, không tồn tại trên iOS
      result(false)

    case "openWifiSettings", "enableWifi":
      // iOS không cho phép app bật/tắt Wi-Fi hay mở thẳng màn hình Wi-Fi;
      // mở trang Cài đặt của app là cách được App Store chấp nhận
      openAppSettings()
      result(true)

    case "waitForKeyEvent":
      if oneShotWaitResult != nil {
        result(FlutterError(code: "BUSY", message: "Already waiting for a key event", details: nil))
      } else {
        oneShotWaitResult = result
        startVolumeObserver()
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func isWiredHeadsetPlugged() -> Bool {
    let outputs = AVAudioSession.sharedInstance().currentRoute.outputs
    return outputs.contains { $0.portType == .headphones }
  }

  private func getRamInfo() -> [String: Any?] {
    // iOS không cho đọc RAM trống một cách đáng tin cậy, chỉ có tổng.
    return ["freeBytes": nil, "totalBytes": ProcessInfo.processInfo.physicalMemory]
  }

  private func getRomInfo() -> [String: Any?] {
    let url = URL(fileURLWithPath: NSHomeDirectory())
    let values = try? url.resourceValues(forKeys: [
      .volumeTotalCapacityKey, .volumeAvailableCapacityKey,
    ])
    return [
      "freeBytes": values?.volumeAvailableCapacity,
      "totalBytes": values?.volumeTotalCapacity,
    ]
  }

  private func getMobileRadioType() -> String {
    let networkInfo = CTTelephonyNetworkInfo()
    guard let tech = networkInfo.serviceCurrentRadioAccessTechnology?.values.first else {
      return "UNKNOWN"
    }

    if #available(iOS 14.1, *) {
      if tech == CTRadioAccessTechnologyNRNSA || tech == CTRadioAccessTechnologyNR {
        return "NR"
      }
    }

    switch tech {
    case CTRadioAccessTechnologyLTE:
      return "LTE"
    case CTRadioAccessTechnologyHSDPA, CTRadioAccessTechnologyHSUPA:
      return "HSPA"
    case CTRadioAccessTechnologyEdge:
      return "EDGE"
    case CTRadioAccessTechnologyGPRS:
      return "GPRS"
    default:
      return "UNKNOWN"
    }
  }

  private func openAppSettings() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(url)
  }
}

// MARK: - Phát hiện phím âm lượng

// iOS không cho app nhận sự kiện phím cứng như `dispatchKeyEvent` của Android.
// Cách công khai duy nhất là quan sát HỆ QUẢ của cú bấm: mức âm lượng hệ thống
// đổi (KVO trên AVAudioSession.outputVolume). Sự kiện phát ra dùng chung mã phím
// với Android (24/25) nên phía Dart không cần phân nhánh nền tảng.
//
// Phím Back (keyCode 4) không tồn tại trên iOS nên không bao giờ phát ra.
extension AppDelegate: FlutterStreamHandler {
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    keyEventSink = events
    startVolumeObserver()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    keyEventSink = nil
    if oneShotWaitResult == nil { stopVolumeObserver() }
    return nil
  }

  private func startVolumeObserver() {
    guard volumeObservation == nil else { return }

    let session = AVAudioSession.sharedInstance()
    try? session.setCategory(.playback, options: [.mixWithOthers])
    try? session.setActive(true)

    installHiddenVolumeView()
    setSystemVolume(anchorVolume)

    #if DEBUG
      if hiddenVolumeView?.subviews.compactMap({ $0 as? UISlider }).first == nil {
        // Xảy ra trên Simulator: MPVolumeView không dựng slider, và
        // outputVolume cũng không bao giờ đổi -> bài test phím âm lượng
        // KHÔNG THỂ pass trên máy ảo, bắt buộc chạy máy thật.
        NSLog("[KeysTest] Không tìm thấy UISlider của MPVolumeView — nhiều khả năng đang chạy Simulator, phím âm lượng sẽ không được phát hiện.")
      }
    #endif

    volumeObservation = session.observe(\.outputVolume, options: [.new, .old]) {
      [weak self] _, change in
      guard let self,
        let newValue = change.newValue,
        let oldValue = change.oldValue
      else { return }
      self.handleVolumeChange(from: oldValue, to: newValue)
    }
  }

  private func stopVolumeObserver() {
    volumeObservation?.invalidate()
    volumeObservation = nil
    hiddenVolumeView?.removeFromSuperview()
    hiddenVolumeView = nil
    try? AVAudioSession.sharedInstance().setActive(false)
  }

  private func handleVolumeChange(from oldValue: Float, to newValue: Float) {
    #if DEBUG
      NSLog("[KeysTest] outputVolume \(oldValue) -> \(newValue), restoring=\(isRestoringVolume)")
    #endif

    // Bỏ qua thay đổi do chính app gây ra khi kéo âm lượng về mức neo
    guard !isRestoringVolume, newValue != oldValue else { return }

    let keyCode = newValue > oldValue ? keyCodeVolumeUp : keyCodeVolumeDown
    let event: [String: Any] = [
      "keyCode": keyCode,
      "action": "down",
      "unicodeChar": 0,
      "isRepeat": false,
    ]

    keyEventSink?(event)

    if let pending = oneShotWaitResult {
      pending(event)
      oneShotWaitResult = nil
    }

    // Kéo lại mức neo để cú bấm kế tiếp vẫn còn khoảng trống thay đổi —
    // nếu để chạm 0 hoặc 1 thì bấm tiếp sẽ không sinh sự kiện nào.
    setSystemVolume(anchorVolume)
  }

  /// Đặt âm lượng hệ thống qua slider của `MPVolumeView` (API công khai duy nhất).
  private func setSystemVolume(_ value: Float) {
    guard let slider = hiddenVolumeView?.subviews.compactMap({ $0 as? UISlider }).first else {
      return
    }

    isRestoringVolume = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
      slider.value = value
      slider.sendActions(for: .valueChanged)
      // Nhả cờ sau khi KVO của thay đổi tự gây ra đã kịp kích hoạt
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
        self.isRestoringVolume = false
      }
    }
  }

  /// `MPVolumeView` đặt ngoài màn hình: vừa cho phép chỉnh âm lượng, vừa chặn
  /// HUD âm lượng mặc định của hệ thống che mất giao diện bài test.
  private func installHiddenVolumeView() {
    guard hiddenVolumeView == nil else { return }

    let window = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }

    guard let window else { return }

    let view = MPVolumeView(frame: CGRect(x: -1000, y: -1000, width: 100, height: 100))
    view.isHidden = false
    view.alpha = 0.01
    window.addSubview(view)
    hiddenVolumeView = view
  }
}
