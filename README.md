# amount_localizer

Locale-aware amount formatter for Flutter, with a small native bridge that
reads the device's **true Region setting** (iOS) / format-locale country
(Android) — the setting that actually drives the numeric keyboard's decimal
key.

Flutter's `PlatformDispatcher.instance.locale` only exposes the *language*
locale. On an English-language iPhone with Region = Brazil, Dart sees `en_US`,
but the numeric keyboard emits `,` for the decimal. This plugin closes that
gap so amount fields format and parse against the correct locale.

## What's inside

- **`AmountInputLocale`** — canonical enum of numeric formats
  (`1,234.56` / `1.234,56` / `1 234,56` / Indian lakhs / …), with country and
  `Locale` resolvers.
- **`AmountLocalizer`** — cached `intl`-backed formatter with sensible banking
  defaults and a `.localizedAmount` extension on `Object`. Also owns the
  one-shot native bridge via [`AmountLocalizer.ensureInitialized`].

## Setup

Add the dependency:

```yaml
dependencies:
  amount_localizer: ^2.0.1
```

Or:

```bash
flutter pub add amount_localizer
```

Initialize once, early in `main()` (before `runApp`):

```dart
import 'package:amount_localizer/amount_localizer.dart';

await AmountLocalizer.ensureInitialized();
```

Idempotent and best-effort — any native failure is swallowed and the
plugin falls back to Flutter's language locale. Never throws.

## Formatting

```dart
100.5.localizedAmount;                       // "100.50" on en_US, "100,50" on pt_BR
AmountLocalizer.format(1234.5);              // "1,234.50" / "1.234,50" / …
AmountLocalizer.tryFormat(json['amount']);   // safe; returns fallback ("—") on failure
```

## Channel

Method channel: `com.sri.amount_localizer/region`, single method
`getFormatRegion` returning an ISO 3166-1 alpha-2 country code (or `null`).
