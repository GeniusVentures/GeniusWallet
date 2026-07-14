# Design deliverables — GNUS UI redesign (`ui-redesign-3.514`)

Visual + token deliverables for the redesign, for designers and stakeholders.

## Files

- **`gnus-mockups.html`** — high-fidelity mockups of the 5 key screens (Dashboard, Send, Buy,
  Swap, Token detail) with a dark/light toggle and a design-token legend. Self-contained — open it
  in any browser (double-click). Reconstructed 1:1 from `../../DESIGN_SYSTEM.md` and the Flutter
  screen code; **not** live device captures (the app needs the native SuperGenius/GeniusSDK stack to
  build). All figures shown are demo/mock values.
- **`gnus-tokens.json`** — the design system as [Tokens Studio](https://tokens.studio) JSON. Import
  via the Tokens Studio Figma plugin: apply the `core` set, then pick the `Dark` or `Light` theme.
  Gives the exact colors, Inter type scale, spacing, radius and elevation as Figma variables/styles.
  Values mirror `lib/theme/*.dart` + `../../DESIGN_SYSTEM.md` (migration **v1.4**).

## Fonts

The mockup approximates **Inter** with a system grotesque stack (font CDNs were unavailable when it
was generated). The real Inter is the brand face — it comes in via `gnus-tokens.json` when you
import into Figma, and the app loads it through `google_fonts`.

## Real (device) screenshots

For pixel-true captures of the running app, build on a stable toolchain (a machine/CI that isn't
iCloud-evicting the SDK, and that completes the optimized native compile) and run:

```
flutter run -d macos --profile --dart-define=WALLET_PK=<any-hex-key>
# or an iOS simulator / Android emulator for the true mobile phone layout
```

`--profile` (or `--release`) is required — a `--debug` cold start of the UI-only stub trips a known
framework assertion (red screen); profile/release is clean (see `../../HANDOFF.md` §3/§9). The
`WALLET_PK` dart-define boots straight into the mock dashboard.

_An interactive copy of the mockups is also published as a private Artifact on claude.ai (link
shared in the working session)._
