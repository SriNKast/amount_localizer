import 'package:intl/intl.dart';

import 'amount_input_locale.dart';

/// Locale-aware amount formatter for banking-style monetary values.
///
/// The default formatting locale is **region-aware**: it resolves through
/// [AmountInputLocale.fromPlatform] so grouping and decimal separators
/// match the device's Region (iOS) / format locale (Android), not just the
/// UI language. Pass `locale:` explicitly to override.
///
/// Behaviour (decimalDigits = 2, resolved locale `'en_US'`):
///   - `100`      → `"100"`
///   - `100.00`   → `"100"`
///   - `100.5`    → `"100.50"`
///   - `100.49`   → `"100.49"`
///   - `"1,234"`  → `"1,234"`
///   - `"1234.5"` → `"1,234.50"`
///
/// On a comma-decimal region (e.g. `pt_BR`) the same values render as
/// `"100,50"`, `"1.234,50"`, etc.
///
/// Rules:
///   - Whole values render without any fractional part.
///   - Non-whole values are padded/truncated to exactly [decimalDigits] digits.
///   - Grouping and decimal separators follow the resolved locale.
///   - Inputs may be [int], [double], [num] or [String]. Strings are parsed
///     using `.` as the decimal separator and `,` / whitespace as grouping
///     separators (matching the standardized numeric-input contract used by
///     KAST forms).
class AmountLocalizer {
  AmountLocalizer._();

  static final RegExp _groupingChars = RegExp(r'[,\s]');

  /// Process-wide cache of [NumberFormat] instances, keyed by
  /// `'<pattern>|<locale>'`. See [clearCache] for lifecycle notes.
  static final Map<String, NumberFormat> _formatterCache = <String, NumberFormat>{};

  /// String returned by [tryFormat] (and therefore by the [localizedAmount]
  /// extension) when the input is `null`, of an unsupported type, or
  /// otherwise fails to format. Defaults to the em-dash placeholder used in
  /// finance UIs. Override at app boot to change app-wide behaviour.
  static String fallback = '—';

  /// Default formatting locale. Sourced from [AmountInputLocale.fromPlatform]
  /// so it honours the app-supplied device Region override.
  static String get _platformLocale => AmountInputLocale.fromPlatform().locale;

  /// Drops every entry from the internal formatter cache.
  ///
  /// Call this when cached formatters could become stale — typically after a
  /// runtime locale change — or from `tearDown` in tests to keep cases
  /// isolated. Subsequent [format] / [tryFormat] calls will lazily rebuild
  /// the formatters they need, so this is safe to call at any time.
  static void clearCache() => _formatterCache.clear();

  /// Formats [amount] using banking display rules.
  ///
  /// When [locale] is omitted, the region-aware default from
  /// [AmountInputLocale.fromPlatform] is used.
  ///
  /// Throws [FormatException] if [amount] is a [String] that cannot be parsed,
  /// or [ArgumentError] if [amount] is not [num] / [String].
  static String format(Object amount, {int decimalDigits = 2, String? locale}) {
    final value = _toNum(amount);
    final resolvedLocale = locale ?? _platformLocale;
    final isWhole = value == value.truncateToDouble();

    final pattern = isWhole || decimalDigits <= 0 ? '#,##0' : '#,##0.${'0' * decimalDigits}';

    return _formatterFor(pattern, resolvedLocale).format(value);
  }

  /// Returns a cached [NumberFormat] for the given `pattern` + `locale` pair,
  /// constructing and storing one on the first call.
  static NumberFormat _formatterFor(String pattern, String locale) {
    return _formatterCache.putIfAbsent('$pattern|$locale', () => NumberFormat(pattern, locale));
  }

  /// Same as [format] but returns [fallback] (or [orElse], when provided)
  /// instead of throwing when [amount] is invalid, of an unsupported type, or
  /// causes the underlying formatter to fail for any reason. Safe to call from
  /// a widget build path.
  static String tryFormat(Object? amount, {int decimalDigits = 2, String? locale, String? orElse}) {
    final fallbackValue = orElse ?? fallback;
    if (amount == null) return fallbackValue;
    try {
      return format(amount, decimalDigits: decimalDigits, locale: locale);
    } catch (_) {
      return fallbackValue;
    }
  }

  static num _toNum(Object amount) {
    if (amount is num) return amount;
    if (amount is String) {
      final sanitized = amount.trim().replaceAll(_groupingChars, '');
      if (sanitized.isEmpty) {
        throw const FormatException('Amount string is empty');
      }
      final parsed = num.tryParse(sanitized);
      if (parsed == null) {
        throw FormatException('Invalid amount string', amount);
      }
      return parsed;
    }
    throw ArgumentError.value(amount, 'amount', 'Expected num or String, got ${amount.runtimeType}');
  }
}

/// Single, type-agnostic accessor that formats any value as a banking amount.
///
/// Works for typed `num` / `String` and for untyped sources (e.g.
/// `Map<String, dynamic>` JSON payloads, BLoC state held as `Object`).
///
/// Returns [AmountLocalizer.fallback] (default `'—'`) when the receiver is a
/// non-numeric / non-string value or a string that cannot be parsed as a
/// number — so it is safe to drop directly into a `Text` widget without
/// try/catch.
///
/// For nullable inputs, use `?.localizedAmount ?? AmountLocalizer.fallback`
/// or call [AmountLocalizer.tryFormat] which accepts `null`.
///
/// Usage (assuming the device resolves to `en_US`):
///   - `100.5.localizedAmount` → `"100.50"`
///   - `100.localizedAmount` → `"100"`
///   - `"1234.5".localizedAmount` → `"1,234.50"`
///   - `json['amount'].localizedAmount` → `"1,234.50"` or `"—"`
///
/// For custom locale / precision, use [AmountLocalizer.format] (throws) or
/// [AmountLocalizer.tryFormat] (returns fallback).
extension AmountLocalizerExt on Object {
  String get localizedAmount => AmountLocalizer.tryFormat(this);
}
