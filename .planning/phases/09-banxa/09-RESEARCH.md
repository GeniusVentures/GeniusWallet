# Phase 9: Banxa - Research

**Researched:** 2026-07-27
**Domain:** Flutter re-skin of an existing fiat on-ramp (buy/KYC/checkout/order-history/order-details) onto the shipped `gw_*` design system. No new packages, no behaviour change.
**Confidence:** HIGH (all claims verified directly against the working tree — this is a re-skin of code that already exists, not a new integration)

## Summary

Phase 9 re-skins seven files (six named in 09-CONTEXT.md D-04 plus the UI-SPEC's `order_details_page.dart` addendum) that together implement Banxa's buy form, order history, order details, checkout QR, and two webview/KYC screens with Linux-browser fallbacks. Every one of the four findings flagged by the UI researcher is confirmed true against the live code (see `<phase_requirements>` and Common Pitfalls below). This is a pure paint job: every screen already renders correctly today against `banxa-sandbox.com`; the only thing wrong is that it uses raw `Colors.*`/`GeniusWalletColors.deepBlue*`/`GeniusWalletColors.lightGreenSecondary` literals, hand-rolled `ElevatedButton`/`Card`/`Ink+BoxDecoration` widgets, and Material-default `AppBar`s instead of the `GWCard`/`GWButton`/`GWColors`/back-arrow-AppBar vocabulary every other phase (5, 7, 8) already uses.

No new library needs to be added, verified, or vetted — every primitive the plan will call (`GWCard`, `GWButton`, `GWPageHeader`, `GWErrorState`, `GWEmptyState`, `FutureStateWidget`, `GWColors`) already ships in `lib/components/` and `lib/theme/` and was read directly during this research. There is no Package Legitimacy Audit to perform because zero external packages are introduced.

The single highest-value planning fact: **`quote_card.dart` has zero callers anywhere in `lib/`** (verified by grep — the only match for `QuoteCard(` is its own constructor). `banxa_buy_screen.dart` hand-rolls an equivalent `Card` inline at lines 236-262. Re-skinning `quote_card.dart` in isolation produces no visible change; the UI-SPEC already flags this and recommends replacing the inline block with a `QuoteCard(...)` call as the smaller diff. The plan must decide this explicitly, not silently re-skin dead code and call it done.

**Primary recommendation:** Six atomic per-file re-skins (buy screen, orders history, order card, order details card + its host page, quote card + its consolidation, checkout QR, payment webview, KYC webview — grouped into waves by shared state, see Wave Grouping below), zero new dependencies, zero cubit/service edits, and an explicit, recorded decision on `handle_banxa_drawer.dart` (in neither D-04 nor D-05 — see Common Pitfalls #2) before the plan is written.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Buy form (fiat/crypto/payment/amount entry, quote display, order creation) | Frontend (Flutter screen) | API/Backend (Banxa via `banxa_api_services.dart`, D-06 untouched) | `banxa_buy_screen.dart` is pure presentation over `MakeOrderCubit`; the re-skin only touches the widget tree |
| Order history + filtering | Frontend (Flutter screen) | API/Backend (`OrdersCubit`, D-06 untouched) | `banxa_orders_history.dart` renders `OrdersState`; filtering logic lives in the cubit, out of scope |
| Order card / order details card (display) | Frontend (Flutter widget) | — | Pure `StatelessWidget`/`StatefulWidget` presentation, no network calls of their own |
| Order details page (host + action routing) | Frontend (Flutter screen) | API/Backend (`BanxaApiService.getOrderById`, untouched) | Orchestrates `OrderDetailCard` + `FutureStateWidget`; only its `_buildActionButton` paint and `FutureStateWidget.error` param change |
| Checkout QR + polling | Frontend (Flutter screen) | API/Backend (`PollingCubit`, untouched) | QR generation and polling status are cubit-owned; only chrome/typography change |
| KYC / Payment webview chrome | Frontend (Flutter screen) | Browser/OS (system browser fallback on Linux) | `WebViewWidget` itself is native chrome (out of scope); only the Flutter-side AppBar/Linux-fallback layout is re-skinned |
| Checkout options bottom sheet (`handle_banxa_drawer.dart`) | Frontend (Flutter widget) | — | **Scope gap** — invoked by three in-scope files but is not itself in D-04 or D-05; see Common Pitfalls #2 |

## Package Legitimacy Audit

**Not applicable.** This phase introduces zero new packages. Every widget referenced (`GWCard`, `GWButton`, `GWPageHeader`, `GWErrorState`, `GWEmptyState`, `FutureStateWidget`) is first-party code already shipped in this repo (`lib/components/`), verified by direct `Read` during this research. `pubspec.yaml` is not touched by this phase's scope (D-04/D-05/D-06 name only `lib/` source files). No `npm view`/`pip index`/registry check applies — this is a Flutter/Dart monorepo re-skin with no ecosystem package additions.

## Per-File Inventory (D-04 + UI-SPEC addendum)

Verified by direct read of each file at HEAD, 2026-07-27. Sizes are line counts of the file as read.

| File | Lines | Renders today | Pre-redesign literals to replace |
|------|-------|----------------|-----------------------------------|
| `lib/screens/banxa_buy_screen.dart` | 373 | `Scaffold` + `AppBar(title: Text('Buy Crypto'))`; 3 `DropdownMenu`s (fiat/crypto/payment); 2 `TextField`s (amount, wallet); "Get Quote" `ElevatedButton` + retry `IconButton`; inline quote `Card` (duplicates `QuoteCard`); hand-rolled gradient "Create Order" button (`InkWell`+`Ink`+`BoxDecoration`); black-scrim boot/loading overlay | `Colors.red` (snackbar bg, L69); `GeniusWalletColors.deepBlue` (button text, L336); `Colors.black.withValues(alpha:0.4)` (disabled button text, L337); `Colors.grey.shade500/600` (disabled gradient, L321-323); `Colors.black45` (scrim, L352); `GeniusWalletGradient.greenBlueGreenGradient` (L317-318, replaced wholesale by `GWButton(variant: gradient)`); `Colors.blue` (`activeColor` on disclaimer dialog, L284) |
| `lib/banxa/banxa_orders_history.dart` | 241 | `Scaffold` + conditional-leading `AppBar` (KYC/Refresh/New-Order actions); status `DropdownMenu<String>`; date-range `OutlinedButton`; bare error `Text` in red; bare `Text("No orders found.")`; "Total Orders: N" ad hoc bold text; `GridView.builder` of `OrderCard` | `Colors.red` (error text, L147); `Colors.grey` (date-range caption, L187); ad hoc `fontSize:16/14, fontWeight.bold` literals (L186-195, replaced by `labelMd`/`textSecondary`) |
| `lib/banxa/banxa_components/order_card.dart` | 170 | `Card` w/ hand-set shape/border; status pill (`_getStatusColor` 4-branch); `OrderInfoRow`s (label/value pairs); conditional Complete-Payment/Retry-Order/See-Details buttons | `GeniusWalletColors.lightGreenSecondary` (card border, L58); `Colors.green/orange/red/grey` (`_getStatusColor`, L23-33 — **no tint, opaque fill only**); `Colors.grey[700]` (`OrderInfoRow` label, L164); `Colors.orange` (Complete Payment bg, L113); `Colors.red` (Retry Order fg+border, L124-125) |
| `lib/banxa/banxa_components/order_details_card.dart` | 108 | `ListView` of `ListTile`s (Status/Fiat/Crypto/Payment/Wallet/Created); wallet-address mask toggle; banner container (when `bannerText != null`); `actionButton` slot passed in | `o.status.toLowerCase() == 'completed' ? Colors.green : Colors.orange` (L53-56 — **confirmed: exactly a 2-way ternary, no error/declined branch at all**, matching finding 4 verbatim); `widget.bannerColor` painted as an **opaque** `Container` fill (L39-47, no alpha/tint) |
| `lib/banxa/banxa_components/quote_card.dart` | 39 | `Card` showing "You will receive"/"Receive" line + Gateway/Network fee `Wrap` | No hardcoded colors present — but **confirmed DEAD CODE**: grep for `QuoteCard(` across all of `lib/` returns only its own constructor declaration. `banxa_buy_screen.dart:236-262` hand-rolls an equivalent `Card` inline instead of calling it |
| `lib/screens/order_details_page.dart` (UI-SPEC addendum) | 137 | `Scaffold` + conditional-leading `AppBar('Order Details')`; `FutureStateWidget<Order>` (no `error:` override — falls back to bare icon); computes `_bannerColor`/`_bannerText` via `BanxaHelpers.getBannerInfo()` (out of scope, D-06) and hands them to `OrderDetailCard`; `_buildActionButton` two-branch (`pendingpayment`→Complete Payment, `declined`→Retry Order) | `Colors.orange` (Complete Payment bg, L74); `Colors.red` (Retry Order fg+border, L94-95) — same anti-pattern as `order_card.dart`'s twin buttons, same fix |
| `lib/banxa/checkout_qr.dart` | 132 | `StatelessWidget`, `Scaffold` + plain `AppBar('Scan to Continue')`; instruction text → white-backed QR → truncated selectable URL → "Copy Link" `ElevatedButton.icon` → polling status (`Loading()` + message) | `Colors.white` (QR backing container, L72 — **preserve verbatim per UI-SPEC**, this is the correct mode-invariant QR convention, NOT a literal to replace) — no other raw colors found; the ElevatedButton→GWButton swap is the only real color-token change |
| `lib/banxa/banxa_payment.dart` | 119 | `StatefulWidget`; Linux branch: `Icon`+headline+body+"Re-open in Browser"/"Done" buttons; live branch: plain `AppBar('Complete Payment')` + `WebViewWidget` + `Loading()` overlay | No raw `Colors.*` found in this file — the re-skin here is structural (Icon-in-circle recipe, `GWButton` swap for the two buttons, back-arrow AppBar), not literal-replacement |
| `lib/banxa/user_kyc/kyc_registration.dart` | 133 | `StatefulWidget`; Linux branch identical shape to `banxa_payment.dart`; live branch: plain `AppBar('Banxa KYC Flow')` + `WebViewWidget` + `Loading(text: "Loading Banxa KYC...")` overlay (**already GW-compliant per UI-SPEC note** — confirmed, this exact call already exists at L127) | No raw `Colors.*` found — same as `banxa_payment.dart`, structural-only re-skin. **D-02 applies directly**: `BanxaApiService.banxaKycUrl`/`redirectUrl` matching logic (L54, L60) must not be touched |

## Wave Grouping (shared state vs. independent)

Verified via import graph read of all seven files:

- **No two in-scope files import each other's private state.** `order_card.dart` and `order_details_card.dart` are siblings consumed by different hosts (`banxa_orders_history.dart` and `order_details_page.dart` respectively) and share no code.
- **Two file/host pairs cannot be split across waves:** `order_details_card.dart` + `order_details_page.dart` (the card is only ever instantiated by that one page, confirmed by grep — `OrderDetailCard(` appears at exactly one call site outside its own file) — its banner-severity plumbing decision (new enum param vs. re-deriving inside the card) spans both files and must land in the same task/commit. Likewise `quote_card.dart` + `banxa_buy_screen.dart` **if** the consolidation (UI-SPEC's recommended fix) is taken — re-skinning `quote_card.dart` alone and separately deciding whether to wire it in later would leave dead code re-skinned with no visible effect for a full wave.
- **Everything else is independently paintable in parallel:** `banxa_orders_history.dart` + `order_card.dart` (siblings, no cross-file coupling beyond the `OrderCard(...)` constructor call, which is additive-only), `checkout_qr.dart`, `banxa_payment.dart`, `kyc_registration.dart`, and `banxa_buy_screen.dart` (if the quote-card consolidation is deferred/declined) can each be re-skinned in their own task with zero risk of merge collision — none share a file, and D-06 fences off the only shared state (the cubits) from all of them.
- **Suggested wave shape:** Wave 1 — buy screen + quote-card decision (one task, since they may merge into one file edit); orders history + order card (one task, sibling pair); checkout QR (independent); payment webview + KYC webview (one task, near-identical Linux-fallback recipe, high copy-paste value in doing them together). Wave 2 — order details card + order details page (must land together per the coupling above), plus the back-arrow AppBar convention applied last across all six screens once the shared recipe is proven on one (Token screens' `token_info_screen.dart:96` is the existing precedent to copy from, not re-derive).

## Existing Test Coverage

**Zero.** Confirmed by search: no `test/**/*banxa*`, no `test/**/*order*` files exist anywhere in the repository. There is no `test/banxa/` directory. This mirrors the gap Phase 8 closed for `route_details_card.dart` with a new golden-value test (`test/squid_router/route_details_card_test.dart` — pumps the widget inside `MaterialApp(theme: ThemeData(extensions: [GWColors.dark()]))` and asserts the exact derived text strings survive the re-skin).

**What a re-skin can realistically pin with tests (per the Phase 8 precedent, applicable here):**
- A `order_card_test.dart` / `order_details_card_test.dart` widget test that constructs a fake `Order` for each of the four status buckets (`completed`, `pendingpayment`, `declined`, an unrecognized string) and asserts the status pill/text renders with the correct semantic token — this is exactly the "extends, never inverts" contract the UI-SPEC's Interaction rule 7 requires, and it is the one behavior this phase actually adds (the missing error/declined branch on `order_details_card.dart`).
- A value-preservation test on `banxa_buy_screen.dart`'s CTA ladder (disabled vs. `canCreateOrder` states) mirroring `08-03`'s CTA-state test pattern, since the button becomes `GWButton` and its enabled/disabled text must still read correctly.
- **What cannot be tested this phase:** anything requiring a live Banxa sandbox order, KYC data, or a payment method (D-03 fences this out entirely) — webview navigation-delegate behavior, the redirect-URL match, and the actual polling/order-creation network calls are untestable without violating D-01/D-02/D-03.

**Wave 0 gap:** no `test/banxa/` directory exists; the plan must create one (e.g., `test/banxa/order_card_test.dart`, `test/banxa/order_details_card_test.dart`) as part of Wave 1 rather than assuming Wave 2 will backfill it.

## Standard Stack

No new stack. This phase consumes only what phases 2-8 already shipped:

### Core (already shipped — no install needed)
| Component | File | Purpose | Why it's the standard here |
|-----------|------|---------|------------------------------|
| `GWCard` | `lib/components/cards/gw_card.dart` | Replaces every hand-rolled `Card`/`Container` decoration | Fail-soft `GWColors` read baked in, `radiusLg`/`borderSubtle`/elevation already correct — verified by direct read |
| `GWButton` (+`GWButtonVariant`) | `lib/components/buttons/gw_button.dart` | Replaces every `ElevatedButton`/`OutlinedButton`/hand-rolled `InkWell`+`Ink` gradient button | `gradient`/`secondary`/`tertiary` variants map 1:1 onto the UI-SPEC's CTA ladder; verified variants exist in the enum at L9-22 |
| `GWPageHeader` | `lib/components/scaffold/gw_page_header.dart` | Only if a screen has no back target (per UI-SPEC, `banxa_orders_history.dart` when NOT `canGoBack`) | Verified `title`/`trailing`/`subtitle`/`centered` params exist |
| `GWErrorState` / `GWErrorBanner` | `lib/components/feedback/gw_error_state.dart` | Replaces bare `Text("❌ ...")` error branches | `title`/`message`/`onRetry`/`retryLabel` params confirmed; internally uses `GeniusWalletColors.statusError.withAlpha(31)` tint — the exact "tinted banner" recipe the UI-SPEC's banner section asks for |
| `GWEmptyState` | `lib/components/feedback/gw_empty_state.dart` | Replaces bare `Text("No orders found.")` | `icon`/`title`/`message`/`actionLabel`/`onAction` confirmed; has a compact/full auto-layout tier (192px threshold) — relevant since Orders History's grid slot height is unknown until laid out, worth a height check during the walk |
| `FutureStateWidget<T>` | `lib/components/custom_future_builder.dart` | Already used by `order_details_page.dart` | Confirmed `error:` param exists but is unset today (defaults to a bare 48px icon) — UI-SPEC's fix is a one-line addition, not a new component |
| `GWColors` (ThemeExtension) | `lib/theme/gw_colors.dart` | Live appearance-aware color read | Confirmed fields: `surfaceBase/Elevated/Menu/Sunken/Overlay`, `textPrimary` (+ 9 alpha steps), `textSecondary`, `statusSuccess`, `statusError`, `borderSubtle/Strong`. **Confirmed: NO `statusWarning` field exists on `GWColors`** — the UI-SPEC is correct that `GeniusWalletColors.statusWarning` (`#FFC42E`, mode-invariant static) must be used directly for the warning/pending status bucket, not `gw.statusWarning` (which does not compile) |
| `GeniusWalletConsts` | `lib/theme/genius_wallet_consts.dart` | Spacing/radius tokens | Confirmed: `space2=4, space4=8, space6=12, space8=16, space10=20, space12=24, space16=32`; `radiusSm=8, radiusMd=12, radiusLg=15, radiusPill=48`; `borderRadiusCard = radiusLg`, `borderRadiusButton = radiusPill` — every value the UI-SPEC's Spacing table cites exists exactly as stated |
| Back-arrow AppBar convention | `lib/tokens/token_info_screen.dart:96-124` | Shared recipe to copy, not reinvent | Confirmed live: `toolbarHeight: 48, backgroundColor: gw.surfaceSunken, elevation: 0, titleSpacing: 0, automaticallyImplyLeading: false, centerTitle: false` + a 30×30 `InkWell` chevron calling `Navigator.of(context).maybePop()` |

### Alternatives Considered
None — this is a re-skin phase; the design system is already locked (PROJECT.md §64-65). There is no alternative component set to evaluate.

**Installation:** none. No `pubspec.yaml` change, no `flutter pub get` required for this phase's scope.

## Architecture Patterns

### System Architecture Diagram

```
User action (tap "Buy", "See Details", "Complete Payment", scan QR, open KYC)
        │
        ▼
go_router route (/createOrder, /buy, /orderDetails, /banxa/callback,
                  /checkoutQR, /kyc, /checkout)   [untouched, D-01/D-02]
        │
        ▼
Screen widget (banxa_buy_screen.dart / banxa_orders_history.dart /
               order_details_page.dart / checkout_qr.dart /
               banxa_payment.dart / kyc_registration.dart)
        │  reads state from   ┌─────────────────────────────┐
        ├───────────────────▶ │ Cubit (MakeOrderCubit,       │  [D-06, untouched]
        │                     │ OrdersCubit, PollingCubit)    │
        │                     └─────────────┬────────────────┘
        │                                   │ calls
        │                                   ▼
        │                     BanxaApiService → banxa-sandbox.com  [D-06, untouched]
        │
        ▼
Presentation widgets this phase re-skins:
  OrderCard / OrderDetailCard / QuoteCard  (banxa_components/*)
        │
        ▼
gw_* primitives (GWCard, GWButton, GWColors, GWErrorState, GWEmptyState)
        │
        ▼
Rendered screen (dark mode only, per D-03 — no live sandbox order created)
```

The re-skin boundary sits entirely between "Screen widget" and "gw_* primitives" — cubits, `BanxaApiService`, and `go_router` wiring are load-bearing and untouched (D-01/D-02/D-06).

### Recommended Task Grouping (mirrors Wave Grouping above)
```
Wave 1:
  - banxa_buy_screen.dart (+ quote_card.dart consolidation decision)
  - banxa_orders_history.dart + order_card.dart (sibling pair)
  - checkout_qr.dart
  - banxa_payment.dart + kyc_registration.dart (shared Linux-fallback recipe)
Wave 2:
  - order_details_card.dart + order_details_page.dart (coupled — banner plumbing)
  - Back-arrow AppBar convention applied last, once proven on one screen
```

### Pattern 1: Status-to-semantic-token ladder (order status badges)
**What:** A 4-bucket mapping (`completed`→success, `pendingpayment`/`pending`/`inprogress`→warning, `declined`/`cancelled`/`expired`/`failed`→error, anything else→neutral/`textSecondary`) reused across `order_card.dart`, `order_details_card.dart`, and `order_details_page.dart`'s banner.
**When to use:** Any place today's code does `status.toLowerCase() == X ? colorA : colorB`.
**Example (today's code, confirmed at order_card.dart:21-34):**
```dart
// Source: lib/banxa/banxa_components/order_card.dart (current, to be replaced)
Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'completed': return Colors.green;
    case 'pendingpayment':
    case 'pending': return Colors.orange;
    case 'declined':
    case 'cancelled': return Colors.red;
    default: return Colors.grey;
  }
}
```
The re-skin keeps the branch *shape* (case labels unchanged, D-01/D-02) and only swaps the returned `Color` for the tinted-token recipe the UI-SPEC's Color section specifies (`GeniusWalletColors.statusError.withAlpha(31)` background + `statusError` text, mirroring `GWErrorBanner`'s own recipe at `gw_error_state.dart:95-101`).

### Pattern 2: GWErrorState/GWEmptyState replacing bare Text
**What:** `banxa_orders_history.dart`'s bare `Text("❌ ${state.error}", style: TextStyle(color: Colors.red))` and `Text("No orders found.")` become `GWErrorState`/`GWEmptyState`.
**When to use:** Any list/detail screen's error or empty branch.
**Example (target shape, from the already-shipped component, `gw_error_state.dart:8-76`):**
```dart
// Source: lib/components/feedback/gw_error_state.dart (existing, verified)
GWErrorState(
  title: "Couldn't load your orders",
  message: state.error,
  onRetry: () => context.read<OrdersCubit>().fetchOrders('your-cust-id'),
)
```

### Anti-Patterns to Avoid
- **Hand-rolled gradient buttons (`InkWell`+`Ink`+`BoxDecoration(gradient:)`):** `banxa_buy_screen.dart:272-344`'s "Create Order" button is exactly the pattern Phase 8's UI-SPEC already flagged and removed from Swap. Do not re-paint it in place — replace the whole `InkWell`/`Ink` tree with `GWButton(variant: gradient, expand: true)`.
- **Re-skinning `quote_card.dart` in isolation without addressing its dead-code status:** produces zero visible effect and risks the plan closing a "done" task that changed nothing a user can see. Must be an explicit decision, not a silent no-op.
- **Painting `BanxaHelpers.getBannerInfo()`'s pastel `Color` as an opaque solid fill:** `order_details_card.dart:39-47` does exactly this today. The re-skin must classify the same status strings into the semantic ladder and render via the `GWErrorBanner` tinted-fill recipe, not repaint the same opaque `Container`.
- **Converting the checkout QR's white backing to `gw.surfaceElevated`:** `checkout_qr.dart:72`'s `Colors.white` container is the *correct*, mode-invariant convention (shipped in `drawers-final/README.md`) — this is the one literal in this phase's files that must NOT change.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Gradient CTA button | Custom `InkWell`+`Ink`+`BoxDecoration(gradient:)` | `GWButton(variant: GWButtonVariant.gradient)` | Already handles disabled-state paint, height, label style, and appearance-aware fail-soft read — hand-rolling re-introduces the exact anti-pattern Phase 8 removed |
| Status pill / semantic color | New ad hoc `Color` switch | The shared 4-bucket ladder (Color section, UI-SPEC) using `GeniusWalletColors.statusSuccess/Error` (appearance-aware via `GWColors`) + `GeniusWalletColors.statusWarning` (mode-invariant static, since no `GWColors.statusWarning` exists) | Keeps every screen's status vocabulary identical to Transactions' badge precedent (sketch 011) |
| Tinted banner container | Opaque `Container(color: bannerColor)` | `GWErrorBanner`'s recipe (≈12% alpha fill via `.withAlpha(31)`, `radiusMd`, colored icon+text) | Already-shipped, WCAG-considered pattern; a raw opaque pastel fill has no defined text-color contract and reads wrong on a dark card |
| Error/empty list states | Bare `Text` with manual styling | `GWErrorState`/`GWEmptyState` | Already handle icon-in-circle recipe, retry button wiring, and (for empty state) an auto compact/full layout tier that a hand-rolled `Center(child: Text(...))` cannot replicate |

**Key insight:** every "don't hand-roll" item in this phase already has a first-party, verified-present replacement in the same repo — there is no external library gap to fill, only a translation exercise from raw Material widgets to the shipped `gw_*` vocabulary.

## Runtime State Inventory

**N/A — not a rename/refactor/migration phase.** This is a re-skin (structure, IDs, keys, and stored/registered names are untouched per D-01/D-02). No database keys, service configs, OS registrations, secrets, or build artifacts are affected. Confirmed by reading all seven in-scope files: none write to Hive, SQLite, SOPS, or any OS-level registration; the only "state" touched is `_showFullWallet` (local `State` field, unaffected) and cubit-owned state (D-06, untouched).

## Common Pitfalls

### Pitfall 1: Re-skinning `quote_card.dart` as if it were live code
**What goes wrong:** A task re-skins `quote_card.dart`'s `Card`→`GWCard` and closes as "done," but nothing on screen changes because `banxa_buy_screen.dart` never calls it.
**Why it happens:** D-04 lists the file, so it looks in-scope and complete once its own diff is clean — the caller-side gap is invisible unless you grep for the constructor.
**How to avoid:** Confirmed via grep (`QuoteCard(` → 1 hit, the constructor itself) — the plan must explicitly choose: (a) re-skin `quote_card.dart` AND replace `banxa_buy_screen.dart:236-262`'s inline `Card` with `QuoteCard(state: state, compact: false)` (UI-SPEC's recommendation, smaller diff, removes duplicated literal), or (b) re-skin the inline block only and leave `quote_card.dart` dead — but never re-skin `quote_card.dart` alone and call the visual goal met.
**Warning signs:** A before/after screenshot of the buy screen shows no change to the quote block despite `quote_card.dart`'s diff.

### Pitfall 2: `handle_banxa_drawer.dart` — the scope gap between D-04 and D-05
**What goes wrong:** The plan either silently re-skins `handle_banxa_drawer.dart` (violating D-04's file-list-is-exhaustive rule the UI-SPEC states) or silently leaves it as the one visibly-unthemed sheet every buy/order flow passes through, without recording why.
**Why it happens:** It is invoked from all three in-scope buy/order surfaces (`banxa_buy_screen.dart` ×2, `banxa_orders_history.dart`, `order_details_page.dart` — confirmed via grep, 4 call sites across 3 files) but is named in NEITHER D-04's in-scope list NOR D-05's four-drawer Phase-21 fence.
**How to avoid:** The plan must record an explicit decision (leave untouched and file a todo pointing to Phase 21, since it is architecturally a bottom sheet in the drawer family even though it doesn't route through `ResponsiveDrawer`) rather than either touching it under an assumed authorization or silently absorbing the gap. This is a planning decision, not a research one — flagging it here so the planner sees the evidence.
**Warning signs:** A walk shows three raw `ElevatedButton`s in a bottom sheet mid-flow that don't match the rest of the re-skinned screens, and nobody can say whether that was intentional.

### Pitfall 3: Smuggling a behaviour fix under a "just a color change" commit
**What goes wrong:** While re-skinning `order_details_card.dart`'s status ternary (which today only has 2 branches, not 4), it is tempting to also "fix" the KYC redirect (finding 1) or adjust `getBannerInfo()`'s source pastel literals in `banxa_helpers.dart` since they're right there.
**Why it happens:** The two competing redirect definitions (`banxa_api_services.dart:17` const vs. `:146` inline `Uri`) and the banner's raw pastel source are adjacent to files this phase touches, making them look like small, in-scope fixes.
**How to avoid:** D-01/D-02 fence this hard. `banxa_helpers.dart` (D-06) stays byte-for-byte; only its *consumer*'s render recipe (in `order_details_page.dart`/`order_details_card.dart`) changes. The KYC redirect logic in `kyc_registration.dart` (L54, L60) must not be touched — confirmed these two lines are the exact redirect-matching logic finding 1 references.
**Warning signs:** A diff to `banxa_helpers.dart`, `banxa_api_services.dart`, `banxa_model.dart`, or any `banxa_order/*` cubit file — any of these appearing in the phase's diff is an automatic scope violation per D-06.

### Pitfall 4: Assuming `GWColors.statusWarning` compiles
**What goes wrong:** Following the "always read `gw.X`" convention reflexively for the pending/warning status bucket produces a compile error, because `GWColors` (the `ThemeExtension`) has no `statusWarning` field — confirmed by reading `gw_colors.dart` in full (only `statusSuccess`/`statusError` are appearance-aware; `borderSubtle/Strong`, `surfaceBase/Elevated/Menu/Sunken/Overlay`, and the `textPrimary*` ladder round out the class).
**Why it happens:** `statusSuccess`/`statusError` ARE on `GWColors`, so it's a reasonable but wrong assumption that `statusWarning` is too.
**How to avoid:** Use `GeniusWalletColors.statusWarning` (the mode-invariant static `Color(0xFFFFC42E)`) directly for the pending/warning bucket, exactly as the UI-SPEC's Color table already specifies — and verify its AA contrast against `surfaceElevated` in both modes before shipping it as text color (UI-SPEC's own flagged caveat; this token has not been vetted by any prior phase).
**Warning signs:** `The getter 'statusWarning' isn't defined for the type 'GWColors'` at analyze time.

### Pitfall 5: Testing against a live sandbox order to "confirm" a state
**What goes wrong:** To visually verify the `pendingpayment`/`declined`/`completed` status buckets all render correctly, it's tempting to actually create sandbox orders in each state.
**Why it happens:** It's the most direct way to see all four status colors live.
**How to avoid:** D-03 explicitly forbids this. Use a manufactured `Order` object (constructed directly in a dev fixture or a widget test, per the Existing Test Coverage section's recommended `order_card_test.dart`) for each status string instead. This is also the only way to exercise the currently-unreachable `declined`/`expired`/unknown-status branches at all, since a real sandbox buy flow would need to be walked, deliberately failed, and re-walked per status to see all four — which D-03 also forbids.
**Warning signs:** Any verification note that says "created a real order in [status] to check" rather than "constructed a fixture `Order` with status='[status]'".

## Code Examples

### Back-arrow AppBar (the exact recipe to copy)
```dart
// Source: lib/tokens/token_info_screen.dart:96-124 (existing, verified live)
appBar: AppBar(
  toolbarHeight: 48,
  backgroundColor: gw.surfaceSunken,
  elevation: 0,
  titleSpacing: 0,
  automaticallyImplyLeading: false,
  centerTitle: false,
  title: Padding(
    padding: EdgeInsets.symmetric(horizontal: /* space8 or space10 by breakpoint */),
    child: Row(
      children: [
        InkWell(
          onTap: () => Navigator.of(context).maybePop(),
          borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusSm),
          child: SizedBox(width: 30, height: 30, /* chevron icon */),
        ),
        // left-aligned title text
      ],
    ),
  ),
),
```

### GWErrorState with retry (target shape for orders-history error branch)
```dart
// Source: lib/components/feedback/gw_error_state.dart (existing, verified — constructor signature)
GWErrorState(
  title: "Couldn't load your orders",
  message: state.error,
  onRetry: () => context.read<OrdersCubit>().fetchOrders('your-cust-id'),
)
```

### GWEmptyState with two distinct empty situations (never-purchased vs. filtered-to-nothing)
```dart
// Source: lib/components/feedback/gw_empty_state.dart (existing, verified — constructor signature)
// Never purchased:
GWEmptyState(
  icon: Icons.receipt_long_outlined,
  title: "No orders yet",
  message: "Your Banxa purchases will show up here once you create one.",
  actionLabel: "New Order",
  onAction: () => context.push('/createOrder'),
)
// Filtered to nothing:
GWEmptyState(
  icon: Icons.receipt_long_outlined,
  title: "No orders match this filter.",
  actionLabel: "Clear Filter",
  onAction: () => /* reset selectedStatus/startDate/endDate + re-applyFilters */,
)
```

## State of the Art

| Old Approach (this phase's files, today) | Current Approach (post re-skin) | When Changed | Impact |
|--------------------------------------------|-----------------------------------|---------------|--------|
| Hand-rolled `InkWell`+`Ink`+`BoxDecoration(gradient:)` CTA buttons | `GWButton(variant: gradient)` | Phase 8 (Swap) already made this the standard; Phase 9 applies it | Consistent disabled-state handling, appearance-aware text color, single source of truth for the brand gradient |
| Bare `Text` error/empty states | `GWErrorState`/`GWEmptyState` | Phases 5, 7, 8 already established this | Retry affordance, consistent icon-in-circle recipe, WCAG-considered text color |
| 2-way status ternary (`Colors.green : Colors.orange`) | 4-bucket semantic ladder (success/warning/error/neutral) | This phase (order_details_card.dart specifically) | Closes finding 4 — a declined/expired order was previously painted the same amber as merely-pending |
| Opaque pastel banner fill | Tinted `GWErrorBanner`-style recipe (~12% alpha) | This phase | Matches the shipped error-banner convention app-wide instead of an undertinted one-off |

**Deprecated/outdated:** none of this phase's files use a deprecated Flutter API — the changes are purely design-token substitutions, not API migrations.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `flutter analyze lib` baseline is 59 issues and `flutter test` is 376 pass / 1 known pre-existing failure, as stated in the phase brief | Validation Architecture | These figures were supplied by the orchestrator, not independently re-run in this research session (a full `flutter analyze`/`flutter test` pass was not executed to avoid a multi-minute tool call on a large Flutter tree during research). If stale, the plan's "no new issues introduced" gate would compare against the wrong baseline — the planner should re-run both commands once at the start of execution to pin the true baseline before any commit. |
| A2 | `statusWarning`'s AA contrast against `surfaceElevated` in both modes has not yet been measured this phase (UI-SPEC's own flagged caveat, repeated here since it affects the order-card status pill this phase repaints) | Color / Pitfall 4 | If it fails AA as running text, the plan must fall back to using it as tint/icon color only and keep the label in `gw.textPrimary` — this is a live gate item for the walk, not a static code fact this research could resolve without rendering the app |

**If this table is empty:** N/A — two items above required flagging.

## Open Questions

1. **Should `quote_card.dart` be consolidated into `banxa_buy_screen.dart`, or re-skinned separately and left dead?**
   - What we know: `quote_card.dart` has zero callers (confirmed by grep); `banxa_buy_screen.dart:236-262` hand-rolls an equivalent block inline; the UI-SPEC recommends consolidation as "the smaller diff AND removes a duplicated literal," calling it "Claude's discretion."
   - What's unclear: whether the planner should treat this as a single combined task (safer, avoids the "re-skinned but invisible" trap) or two separate ones.
   - Recommendation: one task, touching both files, with the consolidation as an explicit sub-step — not left implicit.

2. **What should happen to `handle_banxa_drawer.dart` this phase?**
   - What we know: it's invoked by all three in-scope buy/order surfaces; it is in neither D-04 nor D-05's fence; it is the one remaining unthemed bottom sheet in the flow after this phase's re-skin lands.
   - What's unclear: whether Braian wants it explicitly left alone with a filed todo (matching D-04's "exhaustive list" framing) or wants the fence extended to include it this phase.
   - Recommendation: default to leaving it untouched and filing a todo pointing at Phase 21 (drawer language rollout) — this matches the UI-SPEC's own "not authorized" framing — but this is a decision for the plan/discuss step to confirm explicitly, not something research should decide unilaterally.

3. **Will the accepted-deviation typography table (5 sizes, 3 weights) need re-justifying to the plan-checker, or does the already-approved UI-SPEC override carry forward automatically?**
   - What we know: the UI-SPEC's checker already reviewed and overrode this (2026-07-27), citing 6 prior phases using the same ramp.
   - What's unclear: whether `gsd-plan-checker` (a different agent) will re-trigger the same generic 4-size/2-weight block independently of the UI-SPEC's recorded override.
   - Recommendation: the plan should cite the UI-SPEC's override explicitly in its own text so a downstream checker sees the reasoning without re-deriving it.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| `webview_flutter` | `banxa_payment.dart`, `kyc_registration.dart` live-webview branch | ✓ (already in pubspec, unchanged by this phase) | not re-verified (no version bump this phase) | Linux: already falls back to `url_launcher` (existing code, D-02 untouched) |
| `qr_flutter` | `checkout_qr.dart` | ✓ (already in pubspec, unchanged by this phase) | not re-verified | — |
| `url_launcher` | `banxa_payment.dart`, `handle_banxa_drawer.dart`, KYC Linux fallback | ✓ (already in pubspec, unchanged by this phase) | not re-verified | — |
| Network access to `banxa-sandbox.com` | Any live walk of buy/KYC/checkout | Not verified this research session (D-03 explicitly forbids exercising it) | — | Static/code-level verification only, per D-03 |
| Linux host | Verifying finding 7's browser fallback actually fires | ✗ (Windows host only) | — | Deferred per 09-CONTEXT.md `<deferred>` — no fallback available, explicitly OUTSTANDING |

**Missing dependencies with no fallback:**
- A Linux host to verify finding 7 — already recorded as an accepted, outstanding gap in 09-CONTEXT.md; not this phase's problem to solve.

**Missing dependencies with fallback:**
- None beyond the above — every package this phase's files depend on is already present and unchanged.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | `flutter_test` (bundled with Flutter SDK 3.41.9) |
| Config file | none — no `dart_test.yaml`; tests run via `flutter test` |
| Quick run command | `flutter test test/banxa/` (new directory this phase creates) |
| Full suite command | `flutter test` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| SCR-05 | Order status pill renders the correct semantic token for each of the 4 status buckets (completed/pending/declined/unknown) | widget | `flutter test test/banxa/order_card_test.dart` | ❌ Wave 0/1 |
| SCR-05 | `order_details_card.dart` gains the error/declined branch it lacks today (finding 4 closure) | widget | `flutter test test/banxa/order_details_card_test.dart` | ❌ Wave 0/2 |
| SCR-05 | Buy screen CTA ladder (disabled vs. `canCreateOrder`) renders correctly through `GWButton` | widget | `flutter test test/banxa/banxa_buy_screen_cta_test.dart` | ❌ Wave 0/1 |
| GAP-05 | No raw `Colors.*`/`GeniusWalletColors.deepBlue*`/`GeniusWalletColors.lightGreenSecondary` literal survives in the six in-scope files + the addendum | static (grep) | `grep -n "Colors\.\(red\|green\|orange\|grey\)\|GeniusWalletColors\.\(deepBlue\|lightGreenSecondary\)" lib/screens/banxa_buy_screen.dart lib/banxa/banxa_orders_history.dart lib/banxa/banxa_components/order_card.dart lib/banxa/banxa_components/order_details_card.dart lib/banxa/banxa_components/quote_card.dart lib/screens/order_details_page.dart` (expect zero matches, excluding `checkout_qr.dart`'s intentionally-preserved `Colors.white`) | ✅ (script, not a test file — can be a `tool/` check like Phase 6's `check_onboarding_seed_safety.sh`) |
| — | `flutter analyze lib` introduces no new issues vs. the stated 59-issue baseline | static | `flutter analyze lib` | ✅ (existing gate) |

### Sampling Rate
- **Per task commit:** `flutter test test/banxa/` (once the directory exists; before Wave 1's first task, just `flutter analyze lib` since no banxa tests exist yet)
- **Per wave merge:** `flutter test` (full suite) + `flutter analyze lib`
- **Phase gate:** Full suite green (376+N pass / 1 known pre-existing failure, unchanged) before `/gsd-verify-work`, plus the human dark-mode walk per D-03's scope (visual-only, no live sandbox order)

### Wave 0 Gaps
- [ ] `test/banxa/` directory does not exist — create it
- [ ] `test/banxa/order_card_test.dart` — covers SCR-05 (4-bucket status ladder), the one genuinely new behavior branch (error/declined) this phase adds
- [ ] `test/banxa/order_details_card_test.dart` — covers SCR-05, mirrors the order_card test for the twin ternary
- [ ] `test/banxa/banxa_buy_screen_cta_test.dart` — covers SCR-05's CTA-ladder paint, mirroring Phase 8's `bridge_cta_state_test.dart` pattern
- [ ] No shared fixture file exists for a manufactured `Order` object across these tests — worth a small `test/banxa/fixtures.dart` helper (a `testOrder({status: ...})` factory) so all three new test files build fixtures identically rather than duplicating `Order(...)` construction three times

## Security Domain

`security_enforcement: true`, `security_asvs_level: 1` (from `.planning/config.json`). This phase is a pure UI re-skin with D-01/D-02/D-03 locking all behavior, network calls, and data handling untouched — so the security surface is minimal, but ASVS categories are mapped for completeness per the standing project rule.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | No | This phase touches no auth/session code — KYC webview navigation logic (`kyc_registration.dart:51-68`) is untouched byte-for-byte per D-02 |
| V3 Session Management | No | No session state introduced or modified |
| V4 Access Control | No | No authorization logic in scope |
| V5 Input Validation | No (unchanged) | The buy form's `TextField`s (amount, wallet address) keep their existing validation exactly as-is (D-01/D-02) — the re-skin touches only their visual decoration, which is already theme-wired app-wide, not the input's `onChanged`/validation logic |
| V6 Cryptography | No | No cryptographic operation in any in-scope file |
| V14 Config/Deployment | Marginal | The webview `redirectUrl`/`banxaKycUrl` matching logic is security-relevant (it's the exact mechanism finding 1 flags as broken) but is explicitly NOT touched this phase (D-02) — any security review of that logic belongs to the deferred follow-up phase, not this one |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Webview navigation-delegate URL matching bypassed by a crafted redirect (relevant to finding 1, NOT fixed this phase) | Spoofing | `NavigationDelegate.onNavigationRequest`'s `request.url.contains(...)` substring match (current code, `kyc_registration.dart:60`, `banxa_payment.dart:51`) is a substring check, not an exact/prefix match — a documented weakness, but out of scope for a re-skin; recorded here so the follow-up phase inherits the observation rather than rediscovering it |
| Clipboard exposure of the checkout URL (`checkout_qr.dart`'s "Copy Link") | Information Disclosure | Not a new risk — the URL is already shown on-screen (`SelectableText`) before the copy button exists; re-skin does not change this exposure |

No new threat surface is introduced by this phase — every control point above already exists in the current code and is preserved verbatim per D-01/D-02.

## Sources

### Primary (HIGH confidence — direct file reads, this session)
- `lib/screens/banxa_buy_screen.dart`, `lib/banxa/banxa_orders_history.dart`, `lib/banxa/banxa_payment.dart`, `lib/banxa/checkout_qr.dart`, `lib/banxa/user_kyc/kyc_registration.dart`, `lib/banxa/banxa_components/{order_card,order_details_card,quote_card}.dart`, `lib/screens/order_details_page.dart`, `lib/banxa/handle_banxa_drawer.dart` — all seven in-scope files + the two boundary files, read in full
- `lib/components/cards/gw_card.dart`, `lib/components/buttons/gw_button.dart`, `lib/components/scaffold/gw_page_header.dart`, `lib/components/feedback/gw_error_state.dart`, `lib/components/feedback/gw_empty_state.dart`, `lib/components/custom_future_builder.dart`, `lib/theme/gw_colors.dart`, `lib/theme/genius_wallet_consts.dart` — every primitive the plan will call, read in full
- `lib/navigation/router.dart` (routes `/buy`, `/createOrder`, `/orderDetails`, `/banxa/callback`, `/checkoutQR`, `/kyc`, `/checkout`) and `lib/banxa/banxa_api_services.dart` (redirectUrl/banxaKycUrl definitions) — read to confirm routing/redirect facts cited in 09-CONTEXT.md
- `lib/tokens/token_info_screen.dart:85-124` — the back-arrow AppBar convention to copy
- `test/squid_router/route_details_card_test.dart` — the existing golden-value widget-test precedent from Phase 8

### Secondary (MEDIUM confidence)
- `.planning/phases/09-banxa/09-CONTEXT.md` and `09-UI-SPEC.md` — treated as authoritative per the task's own instruction ("do not re-derive the visual answers"); every claim in them checked against code was confirmed, none contradicted

### Tertiary (LOW confidence)
- `flutter analyze`/`flutter test` baseline figures (59 issues / 376 pass, 1 fail) — supplied by the orchestrator, not re-run this session (see Assumptions Log A1)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — every component read directly, zero new packages
- Architecture: HIGH — full import graph traced, no hidden coupling found beyond the two documented pairs
- Pitfalls: HIGH — all four UI-researcher findings independently confirmed against the live code, plus one additional pitfall (GWColors.statusWarning does not exist) discovered during this research

**Research date:** 2026-07-27
**Valid until:** 30 days (stable — this is existing shipped code with no external API surface changing; the only volatility is if a parallel in-flight phase edits one of the same files, which the dual-track STATE.md note says to check before executing)
