---
sketch: 105
name: swap-tab
question: "How should the Swap tab read as a whole — layout of the two fields, the flip, route details, and the CTA states — reusing the live Squid data the code already has?"
winner: "A1"
tags: [swap, squid, cross-chain, layout, fields, route, cta, states, presence, drawer]
---

# Sketch 105: Swap tab

## Winner

**Round 1 → A · Faithful.  Round 2 → A1 · Focused (bigger).** (chosen 2026-07-24)

The faithful two-card stack, sized up for presence on a wide page: **560px** column, 38px amounts,
56px CTA, a one-line subtitle under the fixed "Swap" page header, and a soft brand sheen behind the
card so the desktop width reads as intentional canvas — not a lost 500px column. Lowest-churn port;
still kills the `Transform.translate(-170)` flip hack and moves onto the live tokens + CTA state
ladder. A2 (companion) and A3 (canvas band) preserved below as alternatives.

## Design Question

The current Swap tab (`lib/squid_router/swap_screen.dart` + `swap_field.dart`,
`route_details_card.dart`, `token_flip_button.dart`, `token_selector_drawer.dart`,
`swap_settings_drawer.dart`) works but shows its age:

- The flip button is dragged into place with `Transform.translate(offset: Offset(0, -170))`
  (`swap_screen.dart:306`) while each `SwapField` carries a padded `bottom: 32` to leave a hole for
  it — a brittle magic-number layout.
- It still paints on the legacy palette (`deepBlueCardColor`, raw `Colors.greenAccent`) instead of
  today's tokens (`surfaceElevated`, the `brandCta` gradient).
- The CTA only appears when `canSwap` — there is no "Enter an amount", "Insufficient balance", or
  "Finding best route…" state.
- Balance is shown but not tappable (no MAX); no USD value under the amount.
- It's a cross-chain router (Squid) but the chain never shows on a token.

Which content direction should the redesign take? **"Swap" itself is fixed chrome** — the shared
`GWPageHeader` page label (left-aligned `headlineLg`, tune icon in its trailing slot), identical to
Transactions/Markets and unchanged across every variant. The variants below only re-compose the swap
content *beneath* that header, in the screen's real centred `maxWidth: 500` column.

## Grounding (what's reused, verbatim)

Every variant surfaces only what the code already has — no new API fields:

| Widget today | Data | Where it lands |
|---|---|---|
| `SwapField` × 2 | amount input, selected token, balance | You Pay / You Receive fields |
| `_fetchRoute` (500 ms debounce) | `toAmount`, live rate | receive read-back + loading state |
| `RouteDetailsCard` | Pricing, Slippage, Price Impact, Fees | route details block |
| `TokenSelectorDrawer` | logo, name, symbol, balance | token picker sheet |
| `SwapSettingsDrawer` | slippage tolerance (0.5% default) | tune icon / inline chips |
| `SquidTokenInfo.chainId` | token's chain | chain badges (esp. D) |

Rate model is faked (ETH ≈ $3,420.55) so the conversion, USD values, loading→resolve, MAX,
insufficient-balance, slippage, token picker, and flip all feel live.

## How to View

Serve the `sketches/` dir and open `/105-swap-tab/index.html`
(file:// is blocked for the Chrome extension):

```
cd .planning/sketches && python3 -m http.server 8751
# then open http://localhost:8751/105-swap-tab/index.html
```

Type an amount, hit MAX, flip, open a token pill, change slippage, toggle Dark/Light + Phone/Default
in the bottom-right toolbar. Type more than the balance (e.g. 2 ETH) to see the error state.

## Variants

**Round 1 (whole-tab directions) — Jakub chose A · Faithful.** The other three are archived here as
rationale; the live `index.html` now carries the Round-2 refinement of A.

- **A · Faithful refresh** ✅ *chosen* — today's two-card stack, re-skinned onto the live tokens. Flip
  *in the seam* (no `Transform.translate(-170)` hack), + MAX + USD + full CTA state ladder. Least churn.
- **B · Unified pane** — two fields fused into one surface, flip on the divider, inline slippage
  chips, rate row expands into route details.
- **C · Hero conversion** — the amount is the hero (big numerals) + live-rate pill.
- **D · Cross-chain forward** — network route bar + per-token chain badges + **Review swap** step.

**Round 2 (A's presence on a wide page).** A 500px column looks lost on a 1180px desktop (the same
"cavern" as the Transactions tab). The fix isn't to spread the card into filler — a centred, focused
swap is the correct pattern (every major DEX does it) — it's to give it deliberate *presence*:

- **A1 · Focused (bigger)** ⭐ *recommended* — the same stack sized up: **560px** column, 38px amounts,
  56px CTA, a one-line subtitle under "Swap" for header weight, and a soft brand sheen behind so the
  wide page reads as intentional canvas. Confident focused-DEX look, still the lowest-churn port.
- **A2 · Companion** — swap card (460px) + a right panel (live ETH/USDC quote + Recent swaps) so the
  desktop width is *used*, not padded. Collapses to the single card under ~1000px. Adds two small
  read-only widgets (a pair-rate line and a recent-swaps list from transaction history).
- **A3 · Canvas band** — the card centred on a full-width brand-mesh band (the boot-canvas language)
  with a hero title. Most dramatic, furthest from today; risks competing with the dashboard's own
  hero.

## What to Look For

- **The flip:** does the seam placement (A) / on-divider (B) / inline circle (C/D) feel more solid
  than today's floated FAB? Any of these kills the `-170` offset.
- **Route details:** flat card (A/D) vs tap-to-expand rate row (B) vs quiet summary strip + list (C)
  — how much should be visible before you commit?
- **CTA honesty:** the button now carries the state (empty / insufficient / finding route / swap /
  review). Which label set reads right?
- **Cross-chain:** how much chain to show. D goes all-in; A/B/C only badge the token logo. Jakub's
  steer: lean toward *lightly* exposing it, not building the whole layout around it.
- **Both themes:** toggle Light — cards, route text, and the gradient CTA should all hold AA.

## Notes / findings

- No new state or data is required for A, B, or C — they re-lay-out existing widgets. **D** wants the
  token's chain surfaced in the field (available on `SquidTokenInfo.chainId`) and an est-time value
  Squid returns on the route.
- Dead code spotted while reading: duplicated `if (fetchedRoute != null)` guard at
  `swap_screen.dart:310-311`, and the CTA uses raw `Colors.greenAccent` rather than a token.
- Light-mode watch: the tiny "BRIDGE" pill label in D is `brand-tertiary` on `surface-menu` — fine
  as a non-body micro-label (clears 3:1) but would fail AA as body text.
