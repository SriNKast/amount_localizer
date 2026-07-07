package com.sri.amount_localizer

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.Locale

/**
 * Exposes the device's FORMAT locale country — the setting that actually
 * drives Gboard's decimal key — to Flutter.
 *
 * Flutter's PlatformDispatcher only reports the *language* locale. On a
 * device set to English language with Brazil format region, Flutter sees
 * `en_US` while the numeric keyboard emits `,`. Reading
 * `Locale.getDefault(Locale.Category.FORMAT).country` closes that gap.
 */
class AmountLocalizerPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == METHOD_GET_FORMAT_REGION) {
            val country = Locale.getDefault(Locale.Category.FORMAT).country
            result.success(if (country.isNullOrEmpty()) null else country)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private companion object {
        const val CHANNEL_NAME = "com.sri.amount_localizer/region"
        const val METHOD_GET_FORMAT_REGION = "getFormatRegion"
    }
}
