import 'package:flutter/services.dart';

import 'amount_input_locale.dart';

/// Reads the device's Region setting (iOS) / FORMAT locale country
/// (Android) — the setting that actually drives the numeric keyboard's
/// decimal separator — and pushes it into [AmountInputLocale.regionOverride]
/// so amount fields format against the right locale.
///
/// Flutter's `PlatformDispatcher.instance.locale` only exposes the language
/// locale, so an English-language iPhone with Region = Brazil looks like
/// `en_US` to Dart. Without this bridge, users in that setup can't enter
/// a decimal because the keyboard emits `,` but the parser expects `.`.
class DeviceRegionService {
  DeviceRegionService._();

  static const MethodChannel _channel = MethodChannel('com.sri.amount_localizer/region');

  /// The `MethodChannel` used to talk to the native side. Exposed for tests
  /// so callers can set a mock handler via
  /// `TestDefaultBinaryMessengerBinding` without reaching into private state.
  static MethodChannel get debugChannel => _channel;

  /// Fetches the device's format-region country code (ISO 3166-1 alpha-2)
  /// and applies it to [AmountInputLocale.regionOverride].
  ///
  /// Returns the resolved code, or `null` if the platform did not return
  /// one. Any channel error is swallowed and returns `null` — this call
  /// is a UX best-effort and must never break app startup.
  static Future<String?> initializeAndApply() async {
    final code = await _read();
    AmountInputLocale.regionOverride = code;
    return code;
  }

  static Future<String?> _read() async {
    try {
      return await _channel.invokeMethod<String>('getFormatRegion');
    } catch (_) {
      return null;
    }
  }
}
