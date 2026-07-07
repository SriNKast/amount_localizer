## 1.0.0

- First stable release. No API changes vs 0.1.1 — the public surface is now
  covered by semver, so any breaking change from here on will require a 2.0.0.

## 0.1.1

- README: switch install instructions to the published pub.dev version.

## 0.1.0

- Initial release.
- `AmountInputLocale` — canonical numeric-format enum with country/locale resolution.
- `AmountLocalizer` — cached, locale-aware amount formatter.
- `DeviceRegionService` — native bridge that reads the device's true Region /
  format-locale country and applies it to `AmountInputLocale.regionOverride`.
