# GNUS Design System

> Single source of truth for the visual language used across the **GNUS marketing site** (gnus.ai) and the **GeniusWallet** Flutter app. Every new screen, component, or marketing page should consume the tokens defined here — no ad-hoc hex codes, font sizes, or spacings.

**Version:** 1.0
**Status:** Adopted
**Last review:** 2026-04-25

---

## Table of contents

1. [Principles](#1-principles)
2. [Brand identity](#2-brand-identity)
3. [Design tokens](#3-design-tokens)
   - [Color](#31-color)
   - [Typography](#32-typography)
   - [Spacing](#33-spacing)
   - [Radius](#34-radius)
   - [Elevation & shadows](#35-elevation--shadows)
   - [Gradients](#36-gradients)
   - [Motion](#37-motion)
4. [Platform mapping](#4-platform-mapping)
5. [Components](#5-components)
6. [Patterns](#6-patterns)
7. [Marketing material](#7-marketing-material)
   - [Audience segments](#71-audience-segments)
   - [Messaging hierarchy](#72-messaging-hierarchy)
   - [Logo & wordmark](#73-logo--wordmark)
   - [Color application](#74-color-application-in-marketing)
   - [Marketing typography scale](#75-marketing-typography-scale)
   - [Imagery & photography](#76-imagery--photography)
   - [Iconography & illustration](#77-iconography--illustration)
   - [Hero composition](#78-hero-composition)
   - [How-it-works pattern](#79-how-it-works-pattern)
   - [Social proof](#710-social-proof)
   - [Newsletter & email](#711-newsletter--email)
   - [Social media exports](#712-social-media-exports)
   - [Slide decks & PDFs](#713-slide-decks--pdfs)
   - [Asset checklist](#714-asset-checklist-for-new-campaigns)
8. [Accessibility](#8-accessibility)
9. [Do's and don'ts](#9-dos-and-donts)
10. [Governance & change process](#10-governance--change-process)
11. [References](#11-references)

---

## 1. Principles

| # | Principle | What it means in practice |
|---|-----------|---------------------------|
| 1 | **One palette, two surfaces** | The marketing site renders the brand on a light canvas (white/teal accents); the wallet app renders it on a dark canvas (`#1D3844` → `#0C0E14`). Tokens are identical — only the surface role flips. |
| 2 | **Tokens over values** | Never hardcode hex, px, or duration values. Reference the named token. If a token is missing, add it here first, then consume it. |
| 3 | **Inter, always** | Inter is the only typeface in the system, on both web and mobile. No exceptions. |
| 4 | **4-pt grid** | All spacing is a multiple of 4. The token names are the multiplier (`space4` = 8 px = 4 × 2). |
| 5 | **Gradient = signature** | The blue→green CTA gradient and the cyan→mint border gradient are reserved for primary actions and brand hero moments. Don't use them for chrome. |
| 6 | **Motion is short and snappy** | 120/200/320 ms with `easeOutCubic`. Anything slower feels sluggish; anything faster feels twitchy. |
| 7 | **Document, don't decorate** | Comments in code that reference the website CSS variable they map to (e.g. `// gnus.ai --radius: .625rem`) are mandatory when introducing a new token. |

---

## 2. Brand identity

### 2.1 Essence

**GNUS turns smart devices into a global AI engine.** Every piece of communication — UI, marketing, sales, support — should reinforce one of three pillars:

| Pillar | What it sounds like |
|--------|---------------------|
| **Open compute** | "Up to 80 % lower GPU cost", "scale instantly", "no vendor lock-in" |
| **Earn from idle hardware** | "Monetize your user base", "live revenue dashboard", "zero friction" |
| **Verifiable & decentralized** | "On-chain validation", "zero-knowledge proofs", "trustless" |

If a sentence on a hero, a button label, or a tweet doesn't ladder up to one of these pillars, rewrite it.

### 2.2 Logotype

| Asset | Web path | App path | Use |
|-------|----------|----------|-----|
| Wordmark + bug | `/gnus-logo-64.png`, `/logo.png` | `assets/images/logo.png` | Primary mark — top of every page, splash, business cards |
| Favicon | `/favicon.ico`, `/favicon-16x16.png`, `/favicon-32x32.png` | n/a | Browser tab |
| Apple touch icon | `/apple-touch-icon.png` (180 × 180) | iOS adaptive icons | Home-screen install |
| Social icon | `/linkedin-xs.png` | n/a | Reduced-size social bug |

**Clear-space:** at least **1 × cap-height** of the mark on every side. Don't tuck text or other graphics into the safe zone.

**Minimum size:**
- Digital: 24 px height (use `/gnus-logo-64.png` reduced; never below 24 px).
- Print: 12 mm height; below that, drop to bug-only.

**Acceptable backgrounds:** white, `surface/base` (`#1D3844`), `surface/elevated` (`#0C0E14`), or the `gradient/hero-wash`. Never on a brand-colored fill (the mark gets lost).

**Never:** recolor the mark, add drop shadows or outlines, distort the aspect ratio, animate the mark itself, place on photography without a scrim, or rebuild the wordmark in a different typeface.

### 2.3 Voice & tone

- **Confident, technical, friendly.** Audience: AI/ML teams, indie game devs, crypto-native users. Don't condescend — they know what a GPU is.
- **Specific over abstract.** "Up to 80 % lower GPU costs" beats "cost-effective". "Earn up to $2/month per user" beats "monetize your users".
- **Sentence case** for headings, buttons, navigation, labels. No Title Case.
- **No exclamation marks.** Confidence doesn't shout.
- **No emoji** in product UI. Use sparingly (≤ 1 per post) in social copy.
- **Numbers are factual.** Always use tabular figures (`numeric/*`) for amounts, addresses, timestamps.
- **Active voice.** "Your devices contribute compute" — not "compute is contributed by devices".

### 2.4 Tagline & messaging

| Level | Example | Where it lives |
|-------|---------|----------------|
| L1 — Tagline | "Turning smart devices into a global AI engine" | Homepage hero, OG description, deck title slide |
| L2 — Segment promise | (AI teams) "Scale your AI, ML, and rendering workloads with our distributed GPU network." / (App creators) "Connect users of your app to our network and earn revenue from their unused processing power." | Below the L1 on hero, segment landing pages |
| L3 — Three proof points | "Up to 80 % lower GPU costs", "Scale instantly without limitations in minutes", "24/7 expert support included" | Bullet list under the L2 |
| L4 — CTA | "Book a demo" (primary) / "Learn more" (secondary) | Buttons |

Don't write a new tagline for individual campaigns. Reframe L2/L3 instead.

---

## 3. Design tokens

### 3.1 Color

The palette is built from three brand hues plus a layered surface stack and a small set of semantic status colors.

> **Vibrant v1.1 (2026-05):** the brand hues and the app canvas were saturated/lifted for more pop. Hex values below reflect v1.1; token names and roles are unchanged. See the migration note in §10.

#### Brand

| Token | Hex | Web variable | App constant | Usage |
|-------|-----|--------------|--------------|-------|
| `brand/primary` | `#0AB4F5` | `--color-palette-primary` | `GeniusWalletColors.brandPrimary` | Primary action, links, focus rings |
| `brand/primary-strong` | `#0696D6` | — | `brandPrimaryStrong` | Hover/pressed for primary, gradient stop |
| `brand/primary-muted` | `#0AB4F5` @ 24 % | — | `brandPrimaryMuted` | Selected pill background, badges |
| `brand/primary-subtle` | `#0AB4F5` @ 12 % | — | `brandPrimarySubtle` | Tints, hovers on dark surfaces |
| `brand/secondary` | `#1FE0A4` | `--color-palette-secondary` | `brandSecondary` | Success states, secondary action |
| `brand/secondary-strong` | `#07C089` | — | `brandSecondaryStrong` | Gradient stop, "completed" |
| `brand/secondary-bright` | `#3DF7C0` | — | `brandSecondaryBright` | Border-gradient stop |
| `brand/tertiary` | `#B27CFF` | `--color-palette-tertiary` / `--accent` | `brandTertiary` | Marketing accents, highlights |

#### Surface (dark canvas — wallet app)

| Token | Hex | App constant | Role |
|-------|-----|--------------|------|
| `surface/base` | `#234453` | `surfaceBase` | Page background (teal) — equivalent to `--background` on the site |
| `surface/elevated` | `#0C0E14` | `surfaceElevated` | Cards, contained components — equivalent to `--card` |
| `surface/menu` | `#1A3242` | `surfaceMenu` | Sheets, drawers, menus |
| `surface/sunken` | `#06080C` | `surfaceSunken` | Deepest layer (e.g. inset code) |
| `surface/overlay` | `#000000` @ 60 % | `surfaceOverlay` | Modal scrim |

#### Surface (light canvas — marketing site)

| Token | Hex | Web variable | Role |
|-------|-----|--------------|------|
| `surface/light-base` | `#FFFFFF` | `--popover` / `--foreground` | Page background |
| `surface/light-sidebar` | `#FCFCFC` | `--sidebar` | Sidebar / footer bg |
| `surface/light-muted` | `#F7F7F8` | `--muted` / `--sidebar-accent` | Muted blocks |
| `surface/light-border` | `#E2E8F0` | `--border` / `--input` | Hairlines, dividers |

#### Text

| Token | Hex | Web variable | App constant | Use |
|-------|-----|--------------|--------------|-----|
| `text/primary` | `#FFFFFF` | `--foreground` (dark canvas) / `#2A2E3A` on light canvas | `textPrimary` | Body text on dark surfaces |
| `text/secondary` | `#8A8F9D` | `--muted-foreground` | `textSecondary` | Captions, meta, hints |
| `text/on-brand` | `#000B18` | — | `textOnBrand` | Text on top of bright brand fills (yellow/cyan/mint) |
| `text/disabled` | `#2A2B31` | — | `textDisabled` | Disabled controls |
| `text/primary-70` … `10` | white @ 70 % … 10 % | — | `textPrimary70`, `…60`, `…54`, `…38`, `…30`, `…24`, `…12`, `…10` | Decreasing emphasis on dark surfaces |

#### Border

| Token | Value | Use |
|-------|-------|-----|
| `border/subtle` | white @ 12 % | Default hairline on dark surfaces |
| `border/strong` | white @ 24 % | Emphasized divider, focused container |
| `border/brand` | `#0AB4F5` | Focus ring, selected card |

#### Status

| Token | Hex | Web variable | App constant |
|-------|-----|--------------|--------------|
| `status/success` | `#07C089` | derived | `statusSuccess` |
| `status/error` | `#EF3B3B` | `--destructive` | `statusError` |
| `status/warning` | `#FFB020` | — | `statusWarning` |
| `status/info` | `#0AB4F5` | — | `statusInfo` |

---

### 3.2 Typography

**Family:** Inter (variable), loaded via Google Fonts on web (`Inter:ital,opsz,wght@0,14..32,100..900`) and via the `google_fonts` package on Flutter.

**Fallback stack:** `ui-sans-serif, system-ui, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji"`.

| Token | Size | Line-height | Weight | Tracking | Web equivalent | Use |
|-------|------|-------------|--------|----------|----------------|-----|
| `display/lg` | 32 px | 40 px (1.25) | 700 | -0.4 | `text-3xl` + `tracking-tight` | Hero headline |
| `display/md` | 28 px | 36 px (1.286) | 700 | -0.4 | `text-2xl` + `tracking-tight` | Sub-hero |
| `headline/lg` | 24 px | 32 px (1.333) | 600 | -0.4 | `text-xl` (`--font-size-xl: 2.25rem` reference) | Section heads |
| `headline/md` | 20 px | 28 px (1.4) | 600 | — | `text-lg` | Card heads |
| `title/lg` | 18 px | 24 px (1.333) | 600 | — | `--font-size-lg: 1.75rem` | Subsection |
| `title/md` | 16 px | 22 px (1.375) | 500 | — | `--font-size-base: 1.125rem` | Card titles |
| `body/lg` | 16 px | 24 px (1.5) | 400 | — | `text-base` | Long-form body |
| `body/md` | 14 px | 20 px (1.428) | 400 | — | `text-sm` | Default body |
| `body/sm` | 13 px | 18 px (1.385) | 400 | — | between `text-sm` & `text-xs` | Captions (uses `text/secondary` by default) |
| `label/md` | 12 px | 16 px (1.333) | 500 | — | `text-xs` | Labels, badges |
| `numeric/display` | 32 px | 40 px | 700 | -0.4 | — | Balances (tabular figures) |
| `numeric/headline` | 24 px | 32 px | 600 | — | — | Large amounts (tabular) |
| `numeric/body` | 14 px | 20 px | 500 | — | — | Inline amounts, addresses (tabular) |

**Rules**

- Always use `numeric/*` styles when displaying balances, addresses, percentages, or anything that should align column-wise.
- Headings use **negative tracking** (`-0.4` letter-spacing) — body text never does.
- Don't introduce new sizes. If a design needs a new size, add it to this table first.

**Sanctioned off-scale exceptions** (deliberate, do not "fix" to a token):

- **Hero balance numerics — 48 px / 56 px.** The primary balance figure on the home and wallet-detail screens (`GeniusBalanceDisplay`, desktop containers) is an oversized focal display number, not type-scale text. It sits above `numeric/display` (32 px) on purpose.
- **Compact nav label — 11 px.** `gw_bottom_nav` overrides `label/md` down to 11 px so five tab labels fit without wrapping; this is a fixed-bar fit constraint, not a heading.

Everything else stays on the scale — inline amounts/body snap to the nearest rung (`14`/`16`/`20`), never `15`/`22`.

---

### 3.3 Spacing

A 4-pt grid. The number in the token is the *multiplier of 2* (so `space4` = 4 × 2 = 8 px, `space8` = 16 px). Yes, this is unusual — it is a deliberate pattern to make values memorable.

| Token | Value | Common use |
|-------|-------|-----------|
| `space2` | 4 px | Icon-to-text gap, hairline insets |
| `space4` | 8 px | Tight padding, dense lists |
| `space6` | 12 px | Compact card padding |
| `space8` | 16 px | **Default container padding** |
| `space10` | 20 px | Mobile horizontal page padding |
| `space12` | 24 px | Section padding |
| `space16` | 32 px | Major separators |
| `space20` | 40 px | **Desktop horizontal/vertical page padding** |
| `space24` | 48 px | Section margins |
| `space32` | 64 px | Hero sections, page breaks |

**Rules**

- Mobile page-edge padding: `space10` (20 px). Desktop: `space20` (40 px).
- Vertical rhythm between unrelated sections: `space16` (32 px) minimum.
- Inside a card: `space8` (16 px) all-around by default.
- Never use raw `EdgeInsets.all(13)` or arbitrary CSS `padding: 11px` — pick the nearest token.

---

### 3.4 Radius

The base is **10 px**, matching the website's `--radius: .625rem`.

| Token | Value | Use |
|-------|-------|-----|
| `radius/xs` | 4 px | Inputs in dense forms, search bar (`SearchBarTheme`) |
| `radius/sm` | 8 px | Tags, badges |
| `radius/base` | 10 px | **Default** — cards, modals, popovers |
| `radius/md` | 12 px | Medium components |
| `radius/lg` | 15 px | Buttons (`ElevatedButton`), text fields, password fields |
| `radius/2xl` | 16 px | Large cards |
| `radius/xl` / `radius/3xl` | 24 px | Hero panels |
| `radius/pill` | 48 px | Dropdowns, "filter" chips, the standard CTA button shape |

**Rule:** any rounded corner ≥ 4 px must use a token. Square corners (0) are fine and don't need a token.

---

### 3.5 Elevation & shadows

The wallet uses three elevation levels plus brand-glow effects. The marketing site uses softer, lighter shadows since it sits on a white canvas — when documenting a web component, prefix with `light/`.

| Token | Color & alpha | Blur | Offset | Use |
|-------|---------------|------|--------|-----|
| `elevation/card` | `#000000` @ 35 % | 16 px | 0, 4 | Standard card on dark surface |
| `elevation/dialog` | `#000000` @ 45 % | 32 px | 0, 8 | Modals, sheets |
| `glow/brand` | `brand/primary` @ 18 % | 24 px | 0, 0 | Selected primary action, focused brand button |
| `glow/gradient` | dual: `brand/primary` @ 15 % blur 28 / -6 8, `brand/secondary` @ 15 % blur 28 / 6 8 | — | — | Hero CTA glow (mirrors gnus.ai hero) |

---

### 3.6 Gradients

Three gradients. None are decorative — each has a defined role.

| Token | Stops | Direction | Use |
|-------|-------|-----------|-----|
| `gradient/cta` | `#06AA78` → `#0C91CC` | Left → right | **Primary CTA** ("Book a demo", "Continue", first-time create-wallet). Mirrors the website's `linear-gradient(270deg, #0c91cc, #06aa78)`. |
| `gradient/border` | `#18AEF0` → `#36EDB5` | Left → right | 1.5–2 px stroke around hero cards (gnus.ai bordered cards). |
| `gradient/hero-wash` | `surface/base` → `surface/elevated` | Top → bottom | Vertical wash behind dark hero sections in the app. |

**Rule:** never invent a new gradient. If a design needs one, raise it in the design-system review (see §9).

---

### 3.7 Motion

| Token | Duration | Curve | Use |
|-------|----------|-------|-----|
| `motion/fast` | 120 ms | `easeOutCubic` | Hover, tap feedback, color transitions |
| `motion/base` | 200 ms | `easeOutCubic` | **Default** — open/close, fade in/out |
| `motion/slow` | 320 ms | `easeOutExpo` | Hero entrances, drawer slides |

**Rules**

- Easing is **decelerative only**. Never `easeIn` or `linear` for interactive transitions.
- Skeleton loaders pulse on a 1.5 s loop (CSS `--animate-pulse` / Flutter `PulsingSketchton`).
- Spinner rotates 360° in 1 s linear (`--animate-spin`).

---

## 4. Platform mapping

The same token has different syntax per platform. Cross-reference table:

| Concept | Marketing site (Tailwind / CSS vars) | GeniusWallet (Flutter) |
|---------|--------------------------------------|------------------------|
| Brand primary | `var(--color-palette-primary)` → `#18AEF0` | `GeniusWalletColors.brandPrimary` |
| Default radius | `var(--radius)` → 10 px | `GeniusWalletConsts.radiusBase` |
| Default body | `text-base` (16 px / 1.5) | `GeniusWalletTypography.bodyLg` |
| Spacing 16 px | `p-4` / `gap-4` (`--spacing` × 4) | `GeniusWalletConsts.space8` |
| CTA gradient | `bg-gradient-to-r from-[#06AA78] to-[#0C91CC]` | `GeniusWalletGradient.brandCta` |
| Page background | white (`#FFFFFF`) on web, `--background: #1D3844` for dark sections | `GeniusWalletColors.surfaceBase` |
| Card background | `var(--card)` → `#0C0E14` (dark sections) / white (light sections) | `GeniusWalletColors.surfaceElevated` |
| Muted text | `var(--muted-foreground)` → `#8A8F9D` | `GeniusWalletColors.textSecondary` |
| Focus ring | `var(--ring)` → `#94A3B8` (light) / `--primary` (dark) | `brandPrimary`, 2 px |
| Motion default | `--default-transition-duration: .15s` + `--default-transition-timing-function: cubic-bezier(.4,0,.2,1)` | `GeniusWalletMotion.fast` (120 ms, `easeOutCubic`) |

**Note on motion mismatch:** the website's default 150 ms uses `cubic-bezier(.4,0,.2,1)` (an `easeInOut`); the app's default `motion/fast` uses `easeOutCubic` for snappier touch feedback. Both are intentional — touch needs more deceleration than mouse. Don't try to unify these.

---

## 5. Components

The wallet app's component library lives under `lib/components/`. Documented with their canonical name, file location, and key props.

### 5.1 Buttons

#### `GWButton` (`lib/components/buttons/`)

The unified button primitive. Use this for **every** new button.

| Variant | Use when |
|---------|----------|
| `primary` | The single most important action on the screen |
| `secondary` | Supporting action next to a primary |
| `tertiary` | Low-emphasis action (e.g. "Cancel") |
| `ghost` | Action embedded in dense UI (e.g. row trailing) |
| `destructive` | Delete, sign-out, remove-wallet |
| `icon` | Square icon-only button |
| `gradient` | Reserved for marquee CTAs — uses `gradient/cta` |

| Size | Height | Padding | Typography |
|------|--------|---------|------------|
| `sm` | 36 px | `space6` h, `space4` v | `body/sm` 600 |
| `md` (default) | 48 px | `space8` h, `space6` v | `body/md` 600 |
| `lg` | 56 px | `space10` h, `space8` v | `title/md` 600 |

States: `default`, `hover`, `pressed`, `disabled`, `loading`, `expanded`. Loading replaces the label with a `GWSpinner`.

**Don't:** stack two `gradient` variants on the same screen. There's only one hero CTA per surface.

#### `ActionButton` (`lib/components/action_button.dart`)

Icon-over-label button used in dashboard quick-actions (Send / Receive / Buy / Trade). Square. Default bg `surface/elevated`, icon color `brand/secondary-strong`.

#### `StringButton` (`lib/components/string_button.dart`)

The PIN-pad / numeric-pad button. 60 × 60 px, `radius/lg`, `headline/lg` typography. Don't repurpose for non-numeric input.

### 5.2 Cards

| Component | File | When to use |
|-----------|------|-------------|
| `GWCard` | `lib/components/cards/` | Default container — `space8` padding, `radius/lg`, `elevation/card` |
| `GWGradientBorderCard` | `lib/components/cards/` | Hero / featured card — applies `gradient/border` stroke |
| `GWWalletCard` | `lib/components/cards/` | Wallet balance summary |
| `GWTokenRow` | `lib/components/data/` | Token list row (icon + name + amount, tabular figures) |

### 5.3 Inputs

| Component | File | Notes |
|-----------|------|-------|
| `GWTextField` | `lib/components/inputs/` | Default text input. `radius/lg`, `surface/elevated` fill. Focused border = `brand/primary` 2 px. |
| `GWPasswordField` | `lib/components/inputs/` | Adds show/hide toggle (20 px, `text/secondary`) |
| `GWSearchField` | `lib/components/inputs/` | Prefix icon + clear-button. Web equivalent uses `radius/xs`. |
| `GWSelect` | `lib/components/inputs/` | Dropdown — `radius/pill` (48 px). Focus border `brand/primary` 2 px. |
| `GWCheckbox` | `lib/components/inputs/` | Selected: `brand/primary` fill. Unselected: transparent fill, `brand/primary` 1 px border. |
| `GWSwitch` | `lib/components/inputs/` | Toggle — uses `brand/primary` for on-state. |

### 5.4 Feedback & state

| Component | File | Role |
|-----------|------|------|
| `GWSpinner` | `lib/components/loading/` | Indeterminate. 18 × 18 px, 2 px stroke, `brand/primary`. |
| `GWLoadingState` | `lib/components/loading/` | Full-screen / area loader |
| `GWEmptyState` | `lib/components/loading/` | "Nothing here yet" |
| `GWErrorState` | `lib/components/loading/` | "Something went wrong" |
| `PulsingSketchton` | `lib/components/pulsing_skeleton.dart` | Skeleton placeholder for list/card while data loads |
| Toast | `lib/components/toast/toast_widget.dart` | Transient notification |

### 5.5 Layout

| Component | File | Role |
|-----------|------|------|
| `AppScreenView` | `lib/components/app_screen_view.dart` | Base screen container — applies `surface/base` |
| `AppScreenWithHeaderMobile` | `lib/components/app_screen_with_header_mobile.dart` | Mobile header + body |
| `AppScreenWithHeaderDesktop` | `lib/components/app_screen_with_header_desktop.dart` | Desktop header + body |
| `DesktopContainer` / `DesktopBodyContainer` | `lib/components/desktop_container.dart`, `desktop_body_container.dart` | Desktop max-width and padding |
| `ResponsiveOverlay` | `lib/components/overlay/responsive_overlay.dart` | Picks mobile bottom-sheet vs desktop dialog at runtime |

### 5.6 Specialist

| Component | File | Notes |
|-----------|------|-------|
| `NumberPad` | `lib/components/number_pad.dart` | 4-digit PIN entry; uses `StringButton` |
| `Splash` | `lib/components/splash.dart` | App splash; uses `gradient/hero-wash` |
| `CryptoAddressQR` | `lib/components/qr/crypto_address_qr.dart` | Wallet address QR |
| `CryptoLiveChart` / `CryptoMinimalChart` / `CryptoSimpleChart` | `lib/chart/` | Price charts |

---

## 6. Patterns

### 6.1 Forms

- Vertical stack, `space8` between fields, `space12` before the submit button.
- Label sits above the input. Use `label/md`.
- Inline error messages: `body/sm`, `status/error`. Place directly under the field.
- Submit button: `GWButton(variant: primary, size: lg, expanded: true)`.

### 6.2 Empty / loading / error triad

Every list or data-bound screen must support all three states:

| State | Component | Copy guideline |
|-------|-----------|----------------|
| Loading | `PulsingSketchton` (rows) or `GWSpinner` (single op) | No copy |
| Empty | `GWEmptyState` | "No <thing> yet" + primary CTA to create one |
| Error | `GWErrorState` | One-sentence problem + "Try again" secondary button |

Don't ship a screen that renders only the success state.

### 6.3 Modals & sheets

- **Mobile:** prefer bottom sheet (`bottom_drawer/`).
- **Desktop:** prefer centered dialog.
- `ResponsiveOverlay` picks for you — use it.
- Backdrop: `surface/overlay` (60 % black).
- Container: `surface/elevated`, `radius/2xl` (16 px), `elevation/dialog`.

### 6.4 Hero CTA (marketing & in-app onboarding)

The signature pattern: a `gradient/cta` button on top of `surface/base` (or white on web), wrapped by `glow/gradient` shadow stack. Used for "Book a demo" on the website and for "Create wallet" / "Continue" in onboarding.

Constraints:
- One per surface.
- Always `lg` size (or larger on marketing).
- Surrounding container needs `space20` minimum vertical breathing room.

### 6.5 Numbers & money

- Always wrap balances in `numeric/*` styles to get tabular figures.
- Format: 2 fractional digits for fiat, up to 8 for crypto, trailing zeros trimmed.
- Address truncation: `ABCD…WXYZ` (4 + 4) for inline; full-width with copy button on detail screens.

### 6.6 Status chips

- Background: matching `status/*` color @ 12 % alpha.
- Text & icon: matching `status/*` color (full).
- Padding: `space4` h × `space2` v. Radius: `radius/sm` (8 px).
- Typography: `label/md` (12 px / 500).

---

## 7. Marketing material

This section governs everything **outside** the product UI — landing pages, ads, social posts, email, decks, conference booths, swag. The product tokens in §3 still apply; this section adds rules specific to broadcast contexts where there is no Flutter widget tree to enforce them.

### 7.1 Audience segments

GNUS speaks to two distinct buyers. Every piece of marketing must be unambiguous about which it's targeting — never both in the same hero.

| Segment | Buys | Headline pattern | Primary proof point |
|---------|------|-------------------|---------------------|
| **AI / ML teams** | Compute | "Scale your AI, ML, and rendering workloads…" | "Up to 80 % lower GPU costs vs. cloud giants" |
| **App creators** | Revenue from idle hardware | "Connect users of your app to our network…" | "Earn up to $2/month per user" |

Pages that need to address both (e.g. the homepage) split the screen into two parallel half-cards rather than blending the messages.

### 7.2 Messaging hierarchy

Reuse the four levels defined in §2.4 (Tagline → Segment promise → Three proof points → CTA). On any new asset:

1. **Always start with L1**, even if it only appears in the OG image / metadata.
2. **L3 must be exactly three points.** Two feels thin, four feels listy. The website convention is `<icon> <bold-number> <supporting line>`.
3. **L4 = "Book a demo" by default.** Don't invent new CTAs ("Get started", "Try it now") without a reason — consistency builds recognition.

### 7.3 Logo & wordmark

See §2.2 for assets and clear-space rules. Marketing-specific reminders:

- **OG / preview images** must include the logo in the bottom-left corner with full clear-space.
- **Animated assets** (Lottie, video): the logo may fade in but its individual letterforms never deform.
- **Co-branding** (e.g. on partner case studies): logos sit on a neutral divider, separated by `space12` (24 px), each at the same cap-height. GNUS goes on the right when read left-to-right.

### 7.4 Color application in marketing

The product palette is the marketing palette. The only differences are *which colors dominate* by context:

| Context | Dominant | Accent | Background |
|---------|----------|--------|------------|
| Compute / AI-team pages | `brand/primary` (cyan) | `brand/secondary` (mint) | `surface/base` dark or white |
| App-creator / "earn" pages | `brand/secondary` (mint) | `brand/primary` (cyan) | `surface/base` dark or white |
| Featured / premium / leadership | `brand/tertiary` (purple) | `brand/primary` (cyan) | `surface/base` dark |
| Legal / policy / quiet pages | neutral text on white | — | white |

**Hard rules**

- One dominant brand color per surface. Don't ship a hero that uses cyan + mint + purple at equal weight.
- The **`gradient/cta`** is only ever used on the single hero CTA. Not on chrome, not on cards.
- The **`gradient/border`** outlines hero feature cards. Don't apply to body cards.
- The corner SVGs `/background/bottom-left.svg` and `/background/bottom-right.svg` are reserved for hero / footer corners. Don't repeat them mid-page.

### 7.5 Marketing typography scale

Marketing has bigger headlines than the product. The website extends the product scale at the top end:

| Marketing token | Size | Weight | Tracking | Web example |
|-----------------|------|--------|----------|-------------|
| `marketing/hero` | 60 px desktop / 48 px tablet / 36 px mobile | 700 | -0.04 em | `<h1>Turning smart devices into a global AI engine</h1>` |
| `marketing/section` | 36 px (light) | 500 | -1.25 px | `<h2>How it works</h2>` (with white→`#CFCFCF` gradient text) |
| `marketing/feature-head` | 32 px | 600 | tight | `<h3>Unlock top-tier GPU power</h3>` |
| `marketing/eyebrow` | 14 px UPPERCASE | 500 | 0.1 em (`tracking-widest`) | `<p>COMPANIES THAT ARE USING GNUS</p>` |
| `marketing/lead` | 18 px | 400 | — | Hero supporting paragraph |

Body, caption, and label sizes match §3.2. Don't introduce a marketing-only body size.

**Gradient text** (white → `#CFCFCF`) is allowed *only* on `marketing/section` headings — never on body or CTAs (illegible at small sizes).

### 7.6 Imagery & photography

| Type | Rules |
|------|-------|
| **Hero imagery** | Real product / device photography. Files: `hero_1x.webp` (current website hero). Always paired with a dark gradient scrim if text overlays it. |
| **Team photos** | Square crop (1:1), neutral or light-grey background, head-and-shoulders, friendly but professional. Files like `kenneth-hurley.jpg`, `michael-hara.jpg`. |
| **Product screenshots** | Real data, anonymized — no Lorem Ipsum, no placeholder addresses. Frame with a 1 px `border/subtle` and `radius/lg`. |
| **Step illustrations** | Abstract / iconic, not literal. WebP at 1× and 2×. Files: `step-1.webp` … `step-N.webp`. |
| **Client logos** | Monochrome (white at 60 % opacity on dark, black at 60 % on light). Files: `client_<name>.png`. |

**Don't use:** generic stock photos with smiling people pointing at screens, finger-on-glass clichés, photos with conflicting brand colors, AI-generated imagery without disclosure.

**Image format defaults**
- **WebP** for photographs (`q=80`, lossy).
- **PNG** for logos and graphics with transparency.
- **SVG** for icons and corner decorations.
- **AVIF** acceptable as an alternative `<source>` for photographs; ship WebP as fallback.

### 7.7 Iconography & illustration

- **Style:** line icons, 1.5 px stroke, rounded caps. The product uses Material Icons; marketing should match that visual weight.
- **Size:** 24 px default in body copy, 32 px in feature cards, 48 px+ in hero contexts.
- **Color:** monochrome by default (`text/primary` on dark, `#2A2E3A` on light). Brand color only when the icon *is* the emphasis (e.g. inside a stat block).
- **Filename pattern:** kebab-case verbs/nouns (`gpu-globe.svg`, `revenue-chart.svg`). Match the existing `/assets/graphics/` convention.
- **Don't** mix line and filled styles in the same composition.
- **Don't** use emoji as iconography.

### 7.8 Hero composition

The signature pattern across the site:

```
┌─────────────────────────────────────────────────────────────┐
│ [eyebrow: COMPUTE NETWORK]                                  │
│                                                             │
│ Turning smart devices into a                  ┌──────────┐ │
│ global AI engine                              │  hero    │ │
│                                               │  image   │ │
│ Scale your AI, ML, and rendering workloads    │ (right)  │ │
│ with our distributed GPU network. Pay only    │          │ │
│ for what you use.                             └──────────┘ │
│                                                             │
│ ✓ Up to 80 % lower GPU costs                                │
│ ✓ Scale instantly, in minutes                               │
│ ✓ 24/7 expert support included                              │
│                                                             │
│ [Book a demo]   Learn more →                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
   bottom-left.svg                          bottom-right.svg
```

Constraints:
- **Eyebrow** is optional but recommended (`marketing/eyebrow`, color = `brand/primary` or `text/secondary` depending on dominant color).
- **Headline** uses `marketing/hero`. Maximum 2 lines on desktop.
- **Subhead** uses `marketing/lead`. Maximum 2 sentences.
- **Bullets** are exactly three (see §7.2). Each starts with a check / dot, not a bare word.
- **Primary CTA** uses `gradient/cta` `GWButton` size `lg`. **Exactly one** per hero.
- **Secondary CTA** is `ghost` variant or text-link with arrow; never a second filled button.
- **Hero image** sits to the right on ≥ 1024 px breakpoint, stacks below on mobile.
- **Corner SVGs** (`bottom-left.svg`, `bottom-right.svg`) anchor the section.

### 7.9 How-it-works pattern

The website uses a 4-step explainer (`Collecting GPU power → Workload distribution → On-chain validation → Mutual benefit`). Reuse this structure for any process explanation:

- **Section heading:** "How it works" or imperative equivalent — use `marketing/section` with the white→`#CFCFCF` gradient text.
- **4 cards** in a row on desktop, 2 × 2 on tablet, stacked on mobile.
- Each card: numbered step badge → illustration (`step-N.webp`) → title (`marketing/feature-head` at 20 px) → 1-sentence description (`body/md`).
- Step numbers use `numeric/headline`.
- Don't go above 4 steps. If you need more, you're describing two processes.

### 7.10 Social proof

**Logo strip pattern** (used on the homepage):

- Eyebrow: `marketing/eyebrow`, copy = `COMPANIES THAT ARE USING GNUS` (uppercase, tracking-widest).
- 5–8 client logos, monochrome, 60 % opacity on dark surfaces / 100 % black on light.
- Each logo capped at 32 px height; the strip auto-scrolls or wraps gracefully.
- Files: `/assets/graphics/client_<name>.png`. New clients added in alphabetical order unless one is a marquee partner (then it leads).

**Testimonial cards** (when used): `body/lg` quote + headshot (40 px circle) + name (`title/md` 600) + role (`body/sm` `text/secondary`).

### 7.11 Newsletter & email

- **Container width:** 600 px max, centered, white or `surface/base` background.
- **Header:** logo only, 32 px height, `space12` padding all sides.
- **Body:** Inter, sizes from §3.2. Body default `body/lg` (16 px / 24 px) — do not go smaller.
- **Buttons:** render as `<a>` styled to match `GWButton.primary`. Inline styles only — many email clients strip `<style>` tags.
- **Footer:** physical address (legal requirement), unsubscribe link, social icons (24 px, `linkedin-xs.png` style — pre-sized for email).
- **Subject lines:** sentence case, ≤ 50 chars, no emoji.
- **Preheader:** 80–120 chars, must complement the subject (don't repeat it).

### 7.12 Social media exports

Standard sizes — export at 2× density:

| Platform | Asset | Dimensions (px) | Recommended filename |
|----------|-------|-----------------|----------------------|
| Open Graph (Twitter/LinkedIn/Slack preview) | OG image | 1200 × 630 | `og-default.png` |
| LinkedIn | Company banner | 1128 × 191 | `banner-linkedin.png` |
| LinkedIn | Post image | 1200 × 627 | `post-linkedin.png` |
| LinkedIn | Personal banner | 1584 × 396 | `banner-linkedin-personal.png` |
| X / Twitter | Header | 1500 × 500 | `header-x.png` |
| X / Twitter | Post (single image) | 1200 × 675 | `post-x.png` |
| Instagram | Square post | 1080 × 1080 | `post-ig-square.png` |
| Instagram | Portrait post | 1080 × 1350 | `post-ig-portrait.png` |
| Instagram | Story / Reel cover | 1080 × 1920 | `story-ig.png` |
| YouTube | Thumbnail | 1280 × 720 | `thumb-yt.png` |
| Facebook | Cover | 820 × 312 | `cover-fb.png` |

**Format:** PNG for graphics with text/logos, JPEG `q=85` for photographic content. Always include the GNUS wordmark with full clear-space (§2.2). Verify text remains legible at 30 % size — that's how it appears in feeds.

### 7.13 Slide decks & PDFs

- **Aspect ratio:** 16 : 9 (1920 × 1080). Use 4 : 3 only when a venue projector requires it.
- **Title slide:** hero pattern (logo top-left + L1 tagline + presenter name).
- **Content slides:** one idea per slide. Body min 18 pt — assume the back row.
- **Charts:** use the brand palette in this order: `brand/primary` → `brand/secondary` → `brand/tertiary` → `status/warning` → `text/secondary`. Tabular figures for axis labels.
- **Numbers:** if it's a stat slide, the number is the slide. Render at 96–144 pt with `display/lg` styling, supporting line at 24 pt below.
- **Templates:** keep canonical `.key` / `.pptx` masters in `/marketing/templates/decks/` (TBD if not yet present — flag in §10).

### 7.14 Asset checklist for new campaigns

Before publishing any new marketing asset (page, ad, post, deck, email):

- [ ] Audience segment (§7.1) chosen and reflected in copy
- [ ] Messaging follows the L1 → L2 → L3 → L4 hierarchy (§2.4, §7.2)
- [ ] Logo placed per §2.2 (clear-space, min size, allowed background)
- [ ] One dominant brand color per surface (§7.4)
- [ ] Typography uses the marketing scale (§7.5), no off-grid sizes
- [ ] Imagery follows §7.6 (real, anonymized, branded)
- [ ] Icons are line-style, 1.5 px stroke, monochrome unless emphasized (§7.7)
- [ ] Exactly one `gradient/cta` button on the surface
- [ ] Color contrast checked (§8) — including overlay text on photography
- [ ] All required social-export sizes generated (§7.12)
- [ ] Reviewed by design + marketing leads before publish

---

## 8. Accessibility

- **Contrast:** `text/primary` on `surface/base` ≈ 11.7 : 1 (passes AAA). `text/secondary` on `surface/base` ≈ 4.7 : 1 (passes AA). Verify any new color pairing with a contrast checker before adopting.
- **Focus:** all interactive elements must show a 2 px `brand/primary` ring on keyboard focus. The Flutter theme handles this for native widgets; new custom widgets must wrap with `Focus` and render the ring explicitly.
- **Touch targets:** minimum 44 × 44 px (iOS HIG) / 48 × 48 dp (Material). `GWButton.sm` is 36 px height — only allow it inside a 44 px+ tappable container.
- **Semantics:** every actionable widget needs a `Semantics(label, button: true)` wrapper. The `GWButton` and `ActionButton` primitives do this for you. Custom `InkWell` instances need it added manually.
- **Text scaling:** components must respect `MediaQuery.textScaleFactor` (and the corresponding browser `rem` scaling). Don't lock font sizes in pixels in containers — let the layout reflow.
- **Motion sensitivity:** auto-playing animations (the brand glow pulse, hero wash) must be disabled when `MediaQuery.disableAnimations` is true on Flutter, or `prefers-reduced-motion: reduce` matches on web.
- **Color is never the only cue:** error states use both `status/error` color AND an explicit error icon / label.

---

## 9. Do's and don'ts

| ✅ Do | ❌ Don't |
|------|---------|
| Use `GeniusWalletColors.brandPrimary` | Use `Color(0xFF18AEF0)` directly |
| Use `space8` for default container padding | Use `EdgeInsets.all(16)` |
| Pick the nearest token if a design says "20 px" → `space10` | Add an in-between value |
| Use `gradient/cta` for the single hero CTA | Apply the gradient to multiple buttons on one screen |
| Use `numeric/*` for any money amount | Mix proportional and tabular figures in the same column |
| Cap line lengths at ~70 ch in body copy | Let body text run edge-to-edge on desktop |
| Follow the empty / loading / error triad on every list | Ship a screen with only the success state |
| Add new tokens here first, then code | Inline a new hex code "just for this one screen" |
| Reference the website CSS variable in code comments when adding a token | Introduce a token whose origin nobody can trace |
| Use `motion/base` (200 ms) as the default | Animate at 500 ms because "it looks smoother" |

---

## 10. Governance & change process

**Where the source of truth lives**

| Token category | File |
|----------------|------|
| Color | [lib/theme/genius_wallet_colors.dart](lib/theme/genius_wallet_colors.dart) |
| Typography | [lib/theme/genius_wallet_typography.dart](lib/theme/genius_wallet_typography.dart) |
| Spacing & radius | [lib/theme/genius_wallet_consts.dart](lib/theme/genius_wallet_consts.dart) |
| Elevation | [lib/theme/genius_wallet_elevation.dart](lib/theme/genius_wallet_elevation.dart) |
| Gradients | [lib/theme/genius_wallet_gradient.dart](lib/theme/genius_wallet_gradient.dart) |
| Motion | [lib/theme/genius_wallet_motion.dart](lib/theme/genius_wallet_motion.dart) |
| Material theme assembly | [lib/theme/theme.dart](lib/theme/theme.dart) |
| Web (gnus.ai) | `assets/root-*.css` (compiled — edit Tailwind config & rebuild) |

**Adding a token**

1. Open a design-review issue describing the gap (which screen, what the missing token is for, why an existing token won't do).
2. If approved, add it to **both** the Flutter theme file and the Tailwind config / CSS variables.
3. Update this document — table row + rationale.
4. Reference the new token from the consuming code in the same PR.

**Changing a token's value**

A breaking change. Requires:
- Sign-off from design + engineering leads.
- A migration note added at the bottom of this document.
- A grep across `lib/` and the marketing repo to confirm there are no hardcoded references.

**Deprecating a token**

Mark the legacy alias in `genius_wallet_colors.dart` (existing pattern: see the "Legacy constants" section at line 78). Don't delete until at least one release after consumers migrate.

---

## Migration notes

### v1.2 — Electric (2026-05, iterating)

v1.1 still read too muted in-app, so the brand hues were pushed toward electric and the canvas lifted noticeably more. Current values: `brandPrimary #14C8FF`, `brandSecondary #2BF5B4` (strong `#0AD89C`, bright `#5BFFD0`), `brandTertiary #C28FFF`, gradient `#0AD89C → #0AAEE6`, `surfaceBase #2A6275`, `surfaceMenu #224C5E`, `statusSuccess #0AD89C`, `statusError #FF4D4D`, `statusWarning #FFC42E`. Direction approved during QA; the §3.1 tables + web Tailwind vars get refreshed once the exact values are locked.

### v1.1 — Vibrant palette (2026-05)

Brand hues saturated and the app canvas lifted for more visual energy. **Token names and roles are unchanged** — every consumer that references the semantic tokens (`brandPrimary`, `surfaceBase`, …) picks up the new look automatically. Only the underlying hex values changed.

| Token | v1.0 | v1.1 |
|-------|------|------|
| `brand/primary` | `#18AEF0` | `#0AB4F5` |
| `brand/primary-strong` | `#0C91CC` | `#0696D6` |
| `brand/secondary` | `#3BCDA1` | `#1FE0A4` |
| `brand/secondary-strong` | `#06AA78` | `#07C089` |
| `brand/secondary-bright` | `#36EDB5` | `#3DF7C0` |
| `brand/tertiary` | `#A66CFF` | `#B27CFF` |
| `gradient/cta` stops | `#06AA78 → #0C91CC` | `#07C089 → #0696D6` |
| `surface/base` | `#1D3844` | `#234453` |
| `surface/menu` | `#14283A` | `#1A3242` |
| `status/success` | `#06AA78` | `#07C089` |
| `status/error` | `#DC2626` | `#EF3B3B` |

`surface/elevated` (`#0C0E14`) and `surface/sunken` (`#06080C`) were intentionally **not** lifted — keeping cards deep against the brighter canvas preserves the layered look and contrast.

Follow-up for the web side: the marketing Tailwind config / CSS variables (`--color-palette-primary`, `--color-palette-secondary`, `--background`) should be updated to match before the next site build, so web and app stay in lockstep (§1 principle 1).

---

## 11. References

- Marketing site CSS: `https://gnus-website.fess.workers.dev/assets/root-2bGbf9Nk.css`
- Inter font: `https://fonts.googleapis.com/css2?family=Inter:ital,opsz,wght@0,14..32,100..900;1,14..32,100..900`
- Material 3 spec: https://m3.material.io
- WCAG 2.1 AA: https://www.w3.org/WAI/WCAG21/quickref/
