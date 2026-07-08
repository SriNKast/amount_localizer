import 'package:flutter/services.dart';

import 'amount_input_locale.dart';

/// Library-private bridge that reads the device's Region setting (iOS) /
/// FORMAT locale country (Android) via a platform `MethodChannel` and
/// applies it to [AmountInputLocale.regionOverride].
///
/// Not exported from the public barrel. Consumers call
/// [AmountLocalizer.ensureInitialized] instead of talking to this
/// directly.
class RegionBridge {
  RegionBridge._();

  /// The `MethodChannel` used to talk to the native side. Exposed at the
  /// library level so [AmountLocalizer.debugChannel] can hand it to tests.
  static const MethodChannel channel = MethodChannel('com.sri.amount_localizer/region');

  /// Reads the platform region code and writes it to
  /// [AmountInputLocale.regionOverride]. Returns the resolved code, or
  /// `null` if the platform did not provide one. Never throws — any
  /// channel error is swallowed and returns `null`.
  static Future<String?> readAndApply() async {
    final code = await _read();
    AmountInputLocale.regionOverride = code;
    return code;
  }

  static Future<String?> _read() async {
    try {
      return await channel.invokeMethod<String>('getFormatRegion');
    } catch (_) {
      return null;
    }
  }
}
