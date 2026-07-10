import 'dart:ui';

/// The canonical numeric format used by an amount field.
///
/// Each value carries three things: a canonical [locale] tag that `intl`
/// has number-symbol data for, plus the [decimalSeparator] and
/// [groupSeparator] characters that pattern uses.
///
/// ### What drives actual formatting
/// **Only [locale] is passed to `intl`.** [decimalSeparator] and
/// [groupSeparator] are exposed as metadata for callers that need the
/// separators without re-deriving them from `intl` — for example when
/// constructing companion input formatters, writing golden tests, or
/// building display strings outside this package. They are guaranteed to
/// agree with `intl`'s symbols for the paired [locale] at the CLDR version
/// this package is built against.
///
/// Callers normally don't pick a value directly — they resolve one via
/// [fromCountry], [fromLocale], or [fromPlatform]. Country coverage below is
/// based on Unicode CLDR defaults with a bias toward the format most
/// commonly seen in financial UIs for each region.
enum AmountInputLocale {
  /// `1,234,567.89` — comma grouping, dot decimal.
  ///
  /// Used by en_US, en_GB, en_CA, en_AU, en_NZ, en_IE, en_SG, en_HK, en_MY,
  /// en_ZA, en_PH, ja_JP, ko_KR, zh_CN, zh_TW, zh_HK, th_TH, and most
  /// Arabic-language regions when Western digits are preferred.
  commaGroupDotDecimal(locale: 'en_US', groupSeparator: ',', decimalSeparator: '.'),

  /// `1.234.567,89` — dot grouping, comma decimal.
  ///
  /// Used by de_DE, es_ES, it_IT, nl_NL, pt_PT, pt_BR, tr_TR, id_ID, vi_VN,
  /// and most of continental & southern Europe plus Latin America.
  dotGroupCommaDecimal(locale: 'de_DE', groupSeparator: '.', decimalSeparator: ','),

  /// `1 234 567,89` — (non-breaking) space grouping, comma decimal.
  ///
  /// Used by fr_FR, ru_RU, sv_SE, fi_FI, nb_NO, pl_PL, cs_CZ, sk_SK, hu_HU,
  /// and other Slavic / Nordic regions.
  spaceGroupCommaDecimal(locale: 'fr_FR', groupSeparator: '\u00A0', decimalSeparator: ','),

  /// `1'234'567.89` — apostrophe grouping, dot decimal.
  ///
  /// Used by de_CH and it_CH (Switzerland, German- and Italian-speaking).
  apostropheGroupDotDecimal(locale: 'de_CH', groupSeparator: '\u2019', decimalSeparator: '.'),

  /// `1 234 567.89` — (non-breaking) space grouping, dot decimal.
  ///
  /// Used by fr_CH (Switzerland, French-speaking) and some international
  /// scientific/technical formats.
  spaceGroupDotDecimal(locale: 'fr_CH', groupSeparator: '\u00A0', decimalSeparator: '.'),

  /// `12,34,567.89` — Indian lakh/crore grouping, dot decimal.
  ///
  /// Used by en_IN, hi_IN, bn_IN, ta_IN, and neighbouring South-Asian
  /// scripts that follow the same convention.
  indianGrouping(locale: 'en_IN', groupSeparator: ',', decimalSeparator: '.'),

  /// `١٬٢٣٤٬٥٦٧٫٨٩` — Arabic-Indic digits with Arabic-Indic separators.
  ///
  /// **Display-only.** Only returned when a caller explicitly selects it;
  /// country resolution defaults Arabic-speaking regions to
  /// [commaGroupDotDecimal] because most banking UIs in the region
  /// present Western digits.
  arabicIndicDigits(locale: 'ar', groupSeparator: '\u066C', decimalSeparator: '\u066B');

  const AmountInputLocale({required this.locale, required this.groupSeparator, required this.decimalSeparator});

  /// Canonical locale tag `intl` has number-symbol data for. **This is
  /// the value that actually drives formatting.**
  final String locale;

  /// Character used to group thousands (or lakhs) in this format.
  /// Metadata only — see the class-level doc for how this relates to
  /// what `intl` actually uses at format time.
  final String groupSeparator;

  /// Character used to separate the fractional part in this format.
  /// Metadata only — see the class-level doc for how this relates to
  /// what `intl` actually uses at format time.
  final String decimalSeparator;

  /// ISO 3166-1 alpha-2 country code → format mapping.
  ///
  /// Unlisted countries fall back to [commaGroupDotDecimal]. Choices favour
  /// each country's dominant-language CLDR default with a bias toward the
  /// format most commonly seen in financial UIs. Multilingual countries
  /// (CH, BE, CA, LU, …) resolve by majority convention; callers that know
  /// the language can pick a specific enum value directly.
  static const Map<String, AmountInputLocale> _byCountry = {
    // ---------- commaGroupDotDecimal — 1,234.56 ----------
    // North & Central America
    'US': commaGroupDotDecimal,
    'CA': commaGroupDotDecimal,
    'MX': commaGroupDotDecimal,
    'GT': commaGroupDotDecimal,
    'HN': commaGroupDotDecimal,
    'NI': commaGroupDotDecimal,
    'PA': commaGroupDotDecimal,
    'SV': commaGroupDotDecimal,
    'BZ': commaGroupDotDecimal,
    // Caribbean
    'PR': commaGroupDotDecimal,
    'DO': commaGroupDotDecimal,
    'BS': commaGroupDotDecimal,
    'BB': commaGroupDotDecimal,
    'JM': commaGroupDotDecimal,
    'TT': commaGroupDotDecimal,
    'HT': commaGroupDotDecimal,
    'KY': commaGroupDotDecimal,
    'BM': commaGroupDotDecimal,
    'TC': commaGroupDotDecimal,
    'VG': commaGroupDotDecimal,
    'VI': commaGroupDotDecimal,
    'AI': commaGroupDotDecimal,
    'MS': commaGroupDotDecimal,
    'DM': commaGroupDotDecimal,
    'LC': commaGroupDotDecimal,
    'VC': commaGroupDotDecimal,
    'KN': commaGroupDotDecimal,
    'AG': commaGroupDotDecimal,
    'GD': commaGroupDotDecimal,
    // Dutch Caribbean — USD or ANG (USD-pegged); financial UIs use US format.
    'BQ': commaGroupDotDecimal,
    'CW': commaGroupDotDecimal,
    'SX': commaGroupDotDecimal,
    // South America (dot-decimal)
    'PE': commaGroupDotDecimal,
    'GY': commaGroupDotDecimal,
    // Anglophone Europe
    'GB': commaGroupDotDecimal,
    'IE': commaGroupDotDecimal,
    'MT': commaGroupDotDecimal,
    'GI': commaGroupDotDecimal,
    'IM': commaGroupDotDecimal,
    'JE': commaGroupDotDecimal,
    'GG': commaGroupDotDecimal,
    // Oceania
    'AU': commaGroupDotDecimal,
    'NZ': commaGroupDotDecimal,
    'PG': commaGroupDotDecimal,
    'FJ': commaGroupDotDecimal,
    'SB': commaGroupDotDecimal,
    'VU': commaGroupDotDecimal,
    'KI': commaGroupDotDecimal,
    'TV': commaGroupDotDecimal,
    'WS': commaGroupDotDecimal,
    'TO': commaGroupDotDecimal,
    'NR': commaGroupDotDecimal,
    'MH': commaGroupDotDecimal,
    'FM': commaGroupDotDecimal,
    'PW': commaGroupDotDecimal,
    'NU': commaGroupDotDecimal,
    'CK': commaGroupDotDecimal,
    'TK': commaGroupDotDecimal,
    'AS': commaGroupDotDecimal,
    'GU': commaGroupDotDecimal,
    'MP': commaGroupDotDecimal,
    // East & Southeast Asia (dot-decimal)
    'JP': commaGroupDotDecimal,
    'KR': commaGroupDotDecimal,
    'CN': commaGroupDotDecimal,
    'TW': commaGroupDotDecimal,
    'HK': commaGroupDotDecimal,
    'MO': commaGroupDotDecimal,
    'SG': commaGroupDotDecimal,
    'MY': commaGroupDotDecimal,
    'PH': commaGroupDotDecimal,
    'TH': commaGroupDotDecimal,
    'KH': commaGroupDotDecimal,
    'LA': commaGroupDotDecimal,
    'MM': commaGroupDotDecimal,
    'MN': commaGroupDotDecimal,
    'BN': commaGroupDotDecimal,
    'MV': commaGroupDotDecimal,
    // Arabic-language regions default to Western digits in financial UIs.
    'AE': commaGroupDotDecimal,
    'SA': commaGroupDotDecimal,
    'EG': commaGroupDotDecimal,
    'KW': commaGroupDotDecimal,
    'QA': commaGroupDotDecimal,
    'BH': commaGroupDotDecimal,
    'OM': commaGroupDotDecimal,
    'JO': commaGroupDotDecimal,
    'LB': commaGroupDotDecimal,
    'IQ': commaGroupDotDecimal,
    'YE': commaGroupDotDecimal,
    'SY': commaGroupDotDecimal,
    'PS': commaGroupDotDecimal,
    'IL': commaGroupDotDecimal,
    'DJ': commaGroupDotDecimal,
    'KM': commaGroupDotDecimal,
    'MR': commaGroupDotDecimal,
    // Anglophone / dot-decimal Africa
    'ZA': commaGroupDotDecimal,
    'NG': commaGroupDotDecimal,
    'GH': commaGroupDotDecimal,
    'KE': commaGroupDotDecimal,
    'TZ': commaGroupDotDecimal,
    'UG': commaGroupDotDecimal,
    'ZM': commaGroupDotDecimal,
    'ZW': commaGroupDotDecimal,
    'MW': commaGroupDotDecimal,
    'SS': commaGroupDotDecimal,
    'SD': commaGroupDotDecimal,
    'ET': commaGroupDotDecimal,
    'ER': commaGroupDotDecimal,
    'RW': commaGroupDotDecimal,
    'BW': commaGroupDotDecimal,
    'NA': commaGroupDotDecimal,
    'SZ': commaGroupDotDecimal,
    'LS': commaGroupDotDecimal,
    'LR': commaGroupDotDecimal,
    'SL': commaGroupDotDecimal,
    'GM': commaGroupDotDecimal,
    'MU': commaGroupDotDecimal,
    'SC': commaGroupDotDecimal,
    'SO': commaGroupDotDecimal,
    // Overseas territories / remote
    'FK': commaGroupDotDecimal,
    'GS': commaGroupDotDecimal,
    'SH': commaGroupDotDecimal,
    'PN': commaGroupDotDecimal,
    'IO': commaGroupDotDecimal,
    'AQ': commaGroupDotDecimal,
    'HM': commaGroupDotDecimal,

    // ---------- dotGroupCommaDecimal — 1.234,56 ----------
    // Germanic / Iberian / Italian Europe
    'DE': dotGroupCommaDecimal,
    'AT': dotGroupCommaDecimal,
    'ES': dotGroupCommaDecimal,
    'IT': dotGroupCommaDecimal,
    'PT': dotGroupCommaDecimal,
    'NL': dotGroupCommaDecimal,
    'BE': dotGroupCommaDecimal,
    'LU': dotGroupCommaDecimal,
    'GR': dotGroupCommaDecimal,
    'CY': dotGroupCommaDecimal,
    'DK': dotGroupCommaDecimal,
    'IS': dotGroupCommaDecimal,
    'FO': dotGroupCommaDecimal,
    'GL': dotGroupCommaDecimal,
    'AD': dotGroupCommaDecimal,
    'SM': dotGroupCommaDecimal,
    'VA': dotGroupCommaDecimal,
    // Balkans / Anatolia
    'TR': dotGroupCommaDecimal,
    'RO': dotGroupCommaDecimal,
    'HR': dotGroupCommaDecimal,
    'SI': dotGroupCommaDecimal,
    'RS': dotGroupCommaDecimal,
    'BA': dotGroupCommaDecimal,
    'ME': dotGroupCommaDecimal,
    'MK': dotGroupCommaDecimal,
    // South America (comma-decimal)
    'BR': dotGroupCommaDecimal,
    'AR': dotGroupCommaDecimal,
    'CO': dotGroupCommaDecimal,
    'CL': dotGroupCommaDecimal,
    'VE': dotGroupCommaDecimal,
    'EC': dotGroupCommaDecimal,
    'BO': dotGroupCommaDecimal,
    'PY': dotGroupCommaDecimal,
    'UY': dotGroupCommaDecimal,
    'CR': dotGroupCommaDecimal,
    'SR': dotGroupCommaDecimal,
    // Southeast Asia (comma-decimal)
    'ID': dotGroupCommaDecimal,
    'VN': dotGroupCommaDecimal,
    'TL': dotGroupCommaDecimal,
    // Caucasus / Central Asia (dot-comma per CLDR)
    'AZ': dotGroupCommaDecimal,
    // Dutch Caribbean (nl_AW)
    'AW': dotGroupCommaDecimal,

    // ---------- spaceGroupCommaDecimal — 1 234,56 ----------
    // French / Romance Europe
    'FR': spaceGroupCommaDecimal,
    'MC': spaceGroupCommaDecimal,
    // French overseas collectivities & territories
    'GF': spaceGroupCommaDecimal,
    'MF': spaceGroupCommaDecimal,
    'BL': spaceGroupCommaDecimal,
    'PM': spaceGroupCommaDecimal,
    'RE': spaceGroupCommaDecimal,
    'YT': spaceGroupCommaDecimal,
    'NC': spaceGroupCommaDecimal,
    'PF': spaceGroupCommaDecimal,
    'WF': spaceGroupCommaDecimal,
    'TF': spaceGroupCommaDecimal,
    // Nordic (space grouping)
    'SE': spaceGroupCommaDecimal,
    'FI': spaceGroupCommaDecimal,
    'AX': spaceGroupCommaDecimal,
    'NO': spaceGroupCommaDecimal,
    'BV': spaceGroupCommaDecimal,
    // Slavic Europe
    'RU': spaceGroupCommaDecimal,
    'PL': spaceGroupCommaDecimal,
    'CZ': spaceGroupCommaDecimal,
    'SK': spaceGroupCommaDecimal,
    'HU': spaceGroupCommaDecimal,
    'BG': spaceGroupCommaDecimal,
    'UA': spaceGroupCommaDecimal,
    'BY': spaceGroupCommaDecimal,
    'LT': spaceGroupCommaDecimal,
    'LV': spaceGroupCommaDecimal,
    'EE': spaceGroupCommaDecimal,
    'MD': spaceGroupCommaDecimal,
    // Albania / Kosovo
    'AL': spaceGroupCommaDecimal,
    'XK': spaceGroupCommaDecimal,
    // Caucasus
    'GE': spaceGroupCommaDecimal,
    'AM': spaceGroupCommaDecimal,
    // Central Asia
    'KZ': spaceGroupCommaDecimal,
    'KG': spaceGroupCommaDecimal,
    'UZ': spaceGroupCommaDecimal,
    'TJ': spaceGroupCommaDecimal,
    'TM': spaceGroupCommaDecimal,
    // French-speaking / French-influenced Africa
    'MA': spaceGroupCommaDecimal,
    'DZ': spaceGroupCommaDecimal,
    'TN': spaceGroupCommaDecimal,
    'LY': spaceGroupCommaDecimal,
    'SN': spaceGroupCommaDecimal,
    'CI': spaceGroupCommaDecimal,
    'CM': spaceGroupCommaDecimal,
    'MG': spaceGroupCommaDecimal,
    'BJ': spaceGroupCommaDecimal,
    'BF': spaceGroupCommaDecimal,
    'ML': spaceGroupCommaDecimal,
    'NE': spaceGroupCommaDecimal,
    'TG': spaceGroupCommaDecimal,
    'TD': spaceGroupCommaDecimal,
    'CF': spaceGroupCommaDecimal,
    'CG': spaceGroupCommaDecimal,
    'CD': spaceGroupCommaDecimal,
    'GA': spaceGroupCommaDecimal,
    'GQ': spaceGroupCommaDecimal,
    'BI': spaceGroupCommaDecimal,
    // Portuguese-speaking Africa
    'MZ': spaceGroupCommaDecimal,
    'AO': spaceGroupCommaDecimal,
    'CV': spaceGroupCommaDecimal,
    'GW': spaceGroupCommaDecimal,
    'ST': spaceGroupCommaDecimal,

    // ---------- apostropheGroupDotDecimal — 1'234.56 ----------
    // Switzerland is multilingual; the German-majority convention wins by
    // default. Callers who know the user is in Suisse Romande can pick
    // `spaceGroupDotDecimal` directly.
    'CH': apostropheGroupDotDecimal,
    'LI': apostropheGroupDotDecimal,

    // ---------- indianGrouping — 12,34,567.89 ----------
    'IN': indianGrouping,
    'PK': indianGrouping,
    'BD': indianGrouping,
    'LK': indianGrouping,
    'NP': indianGrouping,
    'BT': indianGrouping,
  };

  /// Resolves an input format for the given ISO 3166-1 alpha-2 [countryCode].
  ///
  /// Returns [commaGroupDotDecimal] when [countryCode] is null, empty, or
  /// not listed in the built-in table.
  static AmountInputLocale fromCountry(String? countryCode) {
    if (countryCode == null || countryCode.isEmpty) {
      return commaGroupDotDecimal;
    }
    return _byCountry[countryCode.toUpperCase()] ?? commaGroupDotDecimal;
  }

  /// Resolves from a Flutter [Locale] using its `countryCode`.
  static AmountInputLocale fromLocale(Locale locale) => fromCountry(locale.countryCode);

  /// App-supplied override for the device's Region / format-country code.
  ///
  /// Flutter's `PlatformDispatcher.instance.locale` only exposes the
  /// **language** locale, not the iOS Region or Android format locale that
  /// actually drives the numeric-keyboard decimal key. Call
  /// [DeviceRegionService.initializeAndApply] at startup to populate this
  /// via the platform channel.
  ///
  /// Accepts either a bare ISO 3166-1 alpha-2 country code (`'BR'`) or a
  /// BCP-47 / POSIX locale tag (`'pt-BR'`, `'pt_BR'`, `'zh-Hans-CN'`,
  /// `'en_US_POSIX'`); the setter extracts and stores only the country
  /// subtag, uppercased. Inputs from which no 2-letter country subtag can
  /// be extracted (bare language codes, empty strings, garbage) clear the
  /// override so [fromPlatform] falls back to the platform locale rather
  /// than silently landing on the wrong separators.
  static String? get regionOverride => _regionOverride;
  static set regionOverride(String? code) {
    _regionOverride = _extractCountry(code);
  }

  static String? _regionOverride;

  /// Regex matching a 2-letter alphabetic subtag (the shape of an ISO
  /// 3166-1 alpha-2 country code).
  static final RegExp _alpha2 = RegExp(r'^[A-Za-z]{2}$');

  /// Pulls an alpha-2 country code out of a locale-like input, following
  /// BCP-47 subtag order (`language[-script]-region-…`). Returns `null`
  /// when no plausible country subtag is present.
  static String? _extractCountry(String? input) {
    if (input == null) return null;
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    final parts = trimmed.split(RegExp(r'[-_]'));

    if (parts.length == 1) {
      return _alpha2.hasMatch(parts[0]) ? parts[0].toUpperCase() : null;
    }

    final regionIdx = parts[1].length == 4 ? 2 : 1;
    if (regionIdx >= parts.length) return null;
    final candidate = parts[regionIdx];
    return _alpha2.hasMatch(candidate) ? candidate.toUpperCase() : null;
  }

  /// Best-effort resolution using (in order): [regionOverride] if set,
  /// otherwise `PlatformDispatcher.instance.locale.countryCode`.
  ///
  /// Caveat: without an override this falls back to the *language* locale.
  /// On iOS with English language + Brazil region it will resolve to `US`,
  /// not `BR`. Call [DeviceRegionService.initializeAndApply] at app startup
  /// to fix that case.
  static AmountInputLocale fromPlatform() {
    final override = _regionOverride;
    if (override != null) {
      return fromCountry(override);
    }
    return fromLocale(PlatformDispatcher.instance.locale);
  }
}
