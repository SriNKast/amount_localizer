import Flutter
import UIKit

/// Exposes the iOS Region setting — the setting that actually drives the
/// numeric-keyboard decimal key — to Flutter.
///
/// Flutter's `PlatformDispatcher` only reports the *language* locale. On a
/// device set to English language with Brazil region, Flutter sees `en_US`
/// while the numeric keyboard emits `,`. Reading `Locale.current.region`
/// (iOS 16+) / `Locale.current.regionCode` (older) closes that gap.
public class AmountLocalizerPlugin: NSObject, FlutterPlugin {
  private static let channelName = "com.sri.amount_localizer/region"
  private static let methodGetFormatRegion = "getFormatRegion"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    let instance = AmountLocalizerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == AmountLocalizerPlugin.methodGetFormatRegion {
      let code: String?
      if #available(iOS 16.0, *) {
        code = Locale.current.region?.identifier
      } else {
        code = Locale.current.regionCode
      }
      result(code)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }
}
