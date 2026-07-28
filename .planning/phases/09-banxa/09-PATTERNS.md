# Phase 9: Banxa - Pattern Map

**Mapped:** 2026-07-27
**Files analyzed:** 10 (7 D-04/addendum files + `handle_banxa_drawer.dart` per D-07, plus 3 new test files)
**Analogs found:** 10 / 10 (every in-scope file has at least a role-match analog; none are "no analog")

**Reading order note:** This is a re-skin phase. Every analog below is itself a **post-redesign file
from phases 5/7/8/12/15**, not a generic Flutter pattern — the planner should copy the shipped
paint job, not invent a new one. `09-CONTEXT.md` D-01/D-02/D-06 and `09-UI-SPEC.md`'s Component
Inventory remain the authoritative *what*; this file is the *copy-from-where*.

---

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `lib/screens/banxa_buy_screen.dart` | screen (form) | request-response (buy form → cubit) | `lib/dashboard/news/view/crypto_news_screen.dart` (page shell/header/CTA) + `lib/squid_router/swap_settings_drawer.dart` (button/field re-skin idiom) | role-match |
| `lib/banxa/banxa_orders_history.dart` | screen (list) | CRUD (list + filter + refetch) | `lib/dashboard/news/view/crypto_news_screen.dart` (list/empty/error screen shell) | exact (same shape: AppBar/header → filter → `FutureStateWidget`-class error/empty → grid) |
| `lib/banxa/banxa_components/order_card.dart` | component (card) | CRUD (per-item display + actions) | `lib/dashboard/home/widgets/transaction_displays.dart`'s `TransactionRow`/`_statusPill` + `lib/dashboard/home/widgets/transaction_badge.dart` | role-match (status-pill + action-buttons pattern) |
| `lib/banxa/banxa_components/order_details_card.dart` | component (detail list) | CRUD (read-only detail rows + banner) | `lib/dashboard/home/widgets/transaction_displays.dart`'s `_buildRow`/`_buildDetailsCard` (label/value rows) + `gw_error_state.dart`'s tinted-banner recipe | role-match |
| `lib/banxa/banxa_components/quote_card.dart` | component (card, dead code) | transform (derived quote display) | `lib/squid_router/swap_settings_drawer.dart`'s `_SlippageForm`-style card-in-form pattern, or simply `GWCard` wrap per UI-SPEC | role-match (thin, no strong precedent needed — pure `GWCard` wrap) |
| `lib/screens/order_details_page.dart` | screen (host) | request-response (fetch-by-id + action routing) | `lib/tokens/token_info_screen.dart` (back-arrow AppBar + `FutureStateWidget`-hosting screen) | exact (AppBar convention identical use case) |
| `lib/banxa/checkout_qr.dart` | screen | streaming (QR + polling status) | `lib/tokens/token_info_screen.dart` (back-arrow AppBar) + `banxa_payment.dart`'s sibling Linux-fallback recipe for the "waiting" status block idiom | role-match |
| `lib/banxa/banxa_payment.dart` | screen (webview host) | event-driven (webview navigation + Linux fallback) | (paired with `kyc_registration.dart` — near-identical shape) `lib/dashboard/feedback/gw_empty_state.dart`'s icon-in-circle recipe for the fallback layout | role-match |
| `lib/banxa/user_kyc/kyc_registration.dart` | screen (webview host) | event-driven (webview navigation + Linux fallback) | Same as `banxa_payment.dart` — its own twin is the strongest analog | exact (sibling file, same author intent) |
| `lib/banxa/handle_banxa_drawer.dart` | component (bottom sheet) | request-response (action sheet) | `lib/squid_router/swap_settings_drawer.dart` (`ResponsiveDrawer.show` shell + footer) and `transaction_displays.dart`'s `showTransactionDetails` (`ResponsiveDrawer.show` caller) | role-match (structural pattern only — see note below on scope) |
| `test/banxa/order_card_test.dart` (new) | test | CRUD (fixture-driven status-bucket assertions) | `test/squid_router/route_details_card_test.dart` | exact |
| `test/banxa/order_details_card_test.dart` (new) | test | CRUD | `test/squid_router/route_details_card_test.dart` | exact |
| `test/banxa/banxa_buy_screen_cta_test.dart` (new) | test | request-response (CTA enabled/disabled) | `test/components/gw_empty_state_anchor_test.dart` (two-mode pump-helper shape) + `test/squid_router/route_details_card_test.dart` (`_host` MaterialApp wrapper) | role-match |
| `test/banxa/fixtures.dart` (new) | test helper | — | `test/squid_router/route_details_card_test.dart`'s `_token()` factory | exact (same factory-function idiom) |

---

## Pattern Assignments

### `lib/screens/banxa_buy_screen.dart` (screen/form, request-response)

**Analogs:** `lib/dashboard/news/view/crypto_news_screen.dart` (screen shell + header + `GWCard`), `lib/squid_router/swap_settings_drawer.dart` (button/field swap idiom), UI-SPEC's own Component Inventory row (already gives exact target).

**Live GWColors read** (every re-skinned file, verbatim idiom — copy this line into every StatelessWidget/State `build`):
```dart
// Source: crypto_news_screen.dart:224, swap_settings_drawer.dart:86, transaction_displays.dart:210 (all identical)
final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
```

**Gradient CTA button swap** (the exact anti-pattern removal Phase 8 already did — apply verbatim to "Create Order"):
```dart
// Target shape, from swap_settings_drawer.dart:96-105 (GWButton usage, gradient variant + disabled)
GWButton(
  variant: GWButtonVariant.gradient,
  size: GWButtonSize.lg,
  expand: true,
  label: 'Create Order', // UI-SPEC: copy preserved regardless of state
  onPressed: state.canCreateOrder ? () => /* existing create-order call */ : null,
)
```

**Secondary button ("Get Quote")** — same file's `GWButtonVariant.secondary` idiom (`transaction_displays.dart:517-528`'s "View on Explorer" footer button is the clearest example of `secondary` + `expand: true` + leading icon):
```dart
GWButton(
  onPressed: () { /* existing get-quote call */ },
  label: 'Get Quote',
  variant: GWButtonVariant.secondary,
  expand: true,
)
```

**Quote card wrap** — `crypto_news_screen.dart`'s `GWCard(hoverLift: ..., padding: ..., child: ...)` shows the "drop the manual Padding/Column, let `GWCard`'s own `padding` param cover it" idiom the UI-SPEC asks for on the inline quote card (`banxa_buy_screen.dart:236-262`):
```dart
// Source pattern: crypto_news_screen.dart:435-473 (GWCard wrapping a ClipRRect/Column)
GWCard(
  padding: const EdgeInsets.all(GeniusWalletConsts.space8),
  child: /* existing quote Column, Padding removed */,
)
```

**Snackbar color swap:** `Colors.red` → `GeniusWalletColors.statusError` — no analog needed, this is the one-line substitution UI-SPEC already names at `banxa_buy_screen.dart:69`.

---

### `lib/banxa/banxa_orders_history.dart` (screen/list, CRUD)

**Analog:** `lib/dashboard/news/view/crypto_news_screen.dart` — same screen shape: `GWPageHeader`/back-arrow AppBar → filter row → `FutureStateWidget`'s `error`/`onData` branches → empty-state check → grid.

**Error branch** (direct port of the shipped recipe — the exact target the UI-SPEC's Copywriting table specifies):
```dart
// Source: crypto_news_screen.dart:149-152 (GWErrorState usage inside FutureStateWidget.error)
error: GWErrorState(
  title: "Couldn't load your orders",
  message: state.error,
  onRetry: () => context.read<OrdersCubit>().fetchOrders('your-cust-id'),
),
```

**Two-situation empty state** — `crypto_news_screen.dart`'s single-situation empty state (`onData` callback checking `articles.isEmpty`) is the structural analog; Phase 12/15's "never-purchased vs. filtered-to-nothing" split (already worked out in `09-RESEARCH.md`'s Code Examples) is the content to port:
```dart
// Structural analog: crypto_news_screen.dart:158-166 (GWEmptyState inside onData, checked before building the grid)
if (articles.isEmpty) {
  return GWEmptyState(
    icon: Icons.article_outlined,
    title: 'No news right now',
    message: 'Try again in a moment.',
    actionLabel: 'Refresh',
    onAction: _retryNews,
  );
}
// Banxa target (from 09-RESEARCH.md Code Examples — the two-situation split):
// never-purchased -> GWEmptyState(icon: Icons.receipt_long_outlined, title: "No orders yet", ...)
// filtered-to-nothing -> same shell, title "No orders match this filter.", actionLabel "Clear Filter"
```

**"Total Orders: N" ad hoc bold text → labelMd/textSecondary:** copy the plain-`Text`-with-typography-token idiom from `transaction_displays.dart:399-402` (`_buildRow`'s label `Text`) — same substitution, no new pattern needed.

**Conditional AppBar (canGoBack)** — `order_details_page.dart` (read in RESEARCH.md, `:1-45` region) already carries this exact `canGoBack ? null : IconButton(...)` branch; UI-SPEC explicitly says "preserve it, just restyle." No new file needed as analog — `banxa_orders_history.dart`'s own existing conditional survives, only its true-branch becomes `token_info_screen.dart`'s back-arrow AppBar (below) and its false-branch keeps a plain `AppBar` with action icons.

---

### `lib/banxa/banxa_components/order_card.dart` (component/card, CRUD)

**Analogs:** `lib/dashboard/home/widgets/transaction_displays.dart` (`TransactionRow`, `_statusPill`) + `lib/dashboard/home/widgets/transaction_badge.dart` (`badgeSpec`, `TransactionBadge`) — this is the SAME "4-bucket semantic status ladder on a per-item card" problem Phase 12 already solved.

**Status pill — direct pattern to port** (order status has 4 buckets vs. transaction's 4 kinds; same tint recipe):
```dart
// Source: transaction_displays.dart:49-95 (_statusPill) — this is the EXACT recipe
// UI-SPEC's Color section describes in prose; copy the shape, swap the switch cases.
Widget _statusPill(String status, GWColors gw) {
  final (Color fg, Color bg) = switch (status.toLowerCase()) {
    'completed' => (gw.statusSuccess, gw.statusSuccess.withValues(alpha: 0.14)),
    'pendingpayment' || 'pending' || 'inprogress' => (
      GeniusWalletColors.statusWarning,
      GeniusWalletColors.statusWarning.withValues(alpha: 0.16),
    ),
    'declined' || 'cancelled' || 'expired' || 'failed' => (
      gw.statusError, gw.statusError.withValues(alpha: 0.14),
    ),
    _ => (gw.textSecondary, gw.surfaceMenu),
  };
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: GeniusWalletConsts.space4, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 6, height: 6, decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(/* capitalized status */, style: GeniusWalletTypography.labelMd.copyWith(fontWeight: FontWeight.w600, color: fg)),
    ]),
  );
}
```
This directly replaces `order_card.dart`'s `_getStatusColor()` (today: opaque `Colors.green/orange/red/grey`, RESEARCH.md line 41 confirms the exact anti-pattern lines).

**Card wrap:** `GWCard` replacing the hand-set `shape`/`BorderSide` — no dedicated analog needed beyond `crypto_news_screen.dart`'s `GWCard(...)` usage already shown above; same substitution.

**Row label/value typography:** port `transaction_displays.dart:399-419`'s `_buildRow` (label `bodySm`/`textPrimary70`, value `bodyMd`/`textPrimary`, `Flexible` + ellipsis) directly onto `OrderInfoRow`'s label (`Colors.grey[700]` → `gw.textSecondary`/`labelMd`).

**Action buttons ("Complete Payment"/"Retry Order"/"See Details"):** `GWButton` variant swap — `gradient`/`secondary`/`tertiary` respectively — same idiom as the buy screen's CTA above; no new analog, same `GWButton` API.

---

### `lib/banxa/banxa_components/order_details_card.dart` (component/detail-list, CRUD)

**Analogs:** `transaction_displays.dart`'s `_buildRow`/`_buildDetailsCard` (label/value row list) for the `ListTile` retyping, plus `GWErrorBanner`'s tinted-fill recipe (referenced directly in `09-UI-SPEC.md` and `09-RESEARCH.md`, component file `lib/components/feedback/gw_error_state.dart`) for the banner.

**Row retyping pattern** (structurally identical problem — a vertical list of label/value pairs, some conditionally hidden):
```dart
// Source: transaction_displays.dart:389-419 (_buildRow) — port this row shape onto
// order_details_card.dart's ListTile title/trailing text styles.
Widget _buildRow(BuildContext context, String label, String value, {Color? valueColor}) {
  final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: GeniusWalletTypography.bodySm.copyWith(color: gw.textPrimary70)),
      Flexible(child: Text(value, textAlign: TextAlign.right,
        style: GeniusWalletTypography.bodyMd.copyWith(color: valueColor ?? gw.textPrimary),
        maxLines: 1, overflow: TextOverflow.ellipsis)),
    ],
  );
}
```

**Tinted banner recipe** — `GWErrorBanner`'s own internal recipe (already used app-wide, cited directly by both RESEARCH.md and UI-SPEC as `gw_error_state.dart:95-101`, "≈12% alpha fill via `.withAlpha(31)`, `radiusMd`, colored icon+text"). This is a first-party component the planner should call, not re-derive — do not hand-roll the container. The severity classification (warning/error/success) is Claude's discretion per UI-SPEC, but the render container itself should reuse `GWErrorBanner`'s existing internal fill pattern rather than a new one.

**Status ternary → 4-bucket ladder:** identical port of `order_card.dart`'s new `_statusPill` switch shown above — same four cases, same tokens — this card's existing 2-way ternary (`RESEARCH.md:42`, `Colors.green : Colors.orange`) gains the missing `error`/neutral branches from the same table.

---

### `lib/banxa/banxa_components/quote_card.dart` (component/card, dead-code re-skin)

**Analog:** no strong dedicated precedent needed — this is the thinnest file in scope (39 lines, a `Card` with two `Text` lines and a `Wrap`). Treat as a miniature of the quote-card wrap already shown for `banxa_buy_screen.dart` (`GWCard` + `bodyLg`/`textPrimary` + `bodySm`/`textSecondary` for the fee `Wrap`). The consolidation decision (whether `banxa_buy_screen.dart` calls `QuoteCard(...)` instead of hand-rolling) is a planning decision per UI-SPEC/RESEARCH.md Pitfall 1, not a pattern-mapping one — flagging here so the planner does not look for a nonexistent "consolidation pattern" file.

---

### `lib/screens/order_details_page.dart` (screen/host, request-response) — UI-SPEC addendum

**Analog:** `lib/tokens/token_info_screen.dart` — the back-arrow AppBar convention this file must adopt is copied VERBATIM from here (RESEARCH.md already cites `token_info_screen.dart:96-124` as "the exact recipe to copy, not reinvent").

**Back-arrow AppBar** (copy exactly, only the title string changes):
```dart
// Source: lib/tokens/token_info_screen.dart:92-129 (live, confirmed)
appBar: AppBar(
  toolbarHeight: 48,
  backgroundColor: gw.surfaceSunken,
  elevation: 0,
  titleSpacing: 0,
  automaticallyImplyLeading: false,
  centerTitle: false,
  title: Padding(
    padding: EdgeInsets.symmetric(
      horizontal: MediaQuery.sizeOf(context).width > GeniusBreakpoints.medium
          ? GeniusWalletConsts.space10
          : GeniusWalletConsts.space8,
    ),
    child: Row(
      children: [
        InkWell(
          onTap: () => Navigator.of(context).maybePop(),
          borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusSm),
          child: SizedBox(width: 30, height: 30, child: Center(child: /* chevron icon */)),
        ),
        // left-aligned title text
      ],
    ),
  ),
),
```
Apply to every in-scope screen with a back target (`banxa_buy_screen.dart`, `order_details_page.dart`, `checkout_qr.dart`, `banxa_payment.dart`, `kyc_registration.dart`, and `banxa_orders_history.dart` when `canGoBack`) — this is the **single shared pattern** across the whole phase, listed again under Shared Patterns below.

**`FutureStateWidget.error` param:** `crypto_news_screen.dart:149-152`'s `error: GWErrorState(...)` usage (already shown above) is the direct analog for adding the currently-unset `error:` param here.

**Action button swap:** same `GWButton` gradient/secondary substitution as `order_card.dart`'s twin buttons — one fix, applied at both call sites (RESEARCH.md notes these are literally the same anti-pattern, same fix).

---

### `lib/banxa/checkout_qr.dart` (screen, streaming/polling)

**Analog:** `lib/tokens/token_info_screen.dart` for the back-arrow AppBar (same pattern as above); no dedicated "polling status" analog exists in the codebase, but the "Loading() + status Text" idiom already appears unchanged in `kyc_registration.dart`'s existing `Loading(text: "Loading Banxa KYC...")` call (RESEARCH.md line 47, "already GW-compliant") — copy that literal usage for the "Waiting for payment…" message's `bodyLg`/`textSecondary` restyle.

**"Copy Link" button:** `GWButton(variant: gradient, leading: Icon(...))` — same idiom as `transaction_displays.dart:517-528`'s "View on Explorer" footer button (secondary variant there, gradient here per UI-SPEC since Copy Link is the money-moving action on this screen).

**QR backing — the one literal that must NOT change:** `Colors.white` container stays exactly as-is (UI-SPEC hard rule + RESEARCH.md Anti-Patterns section) — flagging here so no analog search is wasted looking for a "themed QR backing" pattern; none should exist.

---

### `lib/banxa/banxa_payment.dart` + `lib/banxa/user_kyc/kyc_registration.dart` (screen/webview host, event-driven)

**Analogs:** each other (near-identical Linux-fallback shape per RESEARCH.md's Wave Grouping — "high copy-paste value in doing them together") + `lib/components/feedback/gw_empty_state.dart`'s icon-in-circle recipe (cited directly by UI-SPEC: "mirrors `GWEmptyState`'s icon-box recipe, 72px/32px glyph") for the Linux-fallback screen's icon treatment.

**Icon-in-circle recipe** — no in-scope file has this literally, but `GWEmptyState`'s own internal icon-circle pattern (the component both files' UI-SPEC entries cite as the model) is the one to read directly from `lib/components/feedback/gw_empty_state.dart` before implementing — do not hand-roll a new circle-decoration shape; port the existing one's `Container(decoration: BoxDecoration(shape: BoxShape.circle, color: gw.surfaceElevated), child: Icon(...))` structure (same shape as `TransactionBadge`'s circle-decoration idiom in `transaction_badge.dart:172-186`, scaled up from 18px to 72px).

**Back-arrow AppBar:** same `token_info_screen.dart` copy as above, applied to both live-webview branches.

**GWButton swap** (Re-open in Browser → secondary, Done → gradient): same `GWButton` variant idiom shown throughout this document.

**D-02 guard (hard rule, not a pattern):** `kyc_registration.dart`'s redirect-matching logic (`:54`, `:60` per CONTEXT.md/RESEARCH.md) must not be touched — no analog applies here because nothing should change; flagging so the executor does not "helpfully" normalize it while touching the surrounding AppBar.

---

### `lib/banxa/handle_banxa_drawer.dart` (component/bottom sheet, request-response) — D-07

**Scope note:** `09-CONTEXT.md` D-07 (dated after the UI-SPEC was written) brings this file INTO scope, superseding `09-UI-SPEC.md`'s "Boundary Note — NOT contracted this phase" section. The planner must treat D-07 as authoritative and either (a) get an updated UI-SPEC addendum for this file's visual contract before planning its re-skin, or (b) apply the same primitives (`ResponsiveDrawer`, `GWButton`) used everywhere else in this document by direct analogy, recording the extrapolation. This file currently uses `showModalBottomSheet` + three raw `ElevatedButton`s — structurally NOT a `ResponsiveDrawer` today.

**Two strong structural analogs for what it should become:**

1. `lib/squid_router/swap_settings_drawer.dart` — the `ResponsiveDrawer.show(context, title:, child:, footer:)` shell pattern, with the footer holding the primary `GWButton(variant: gradient)` action and a top hairline border:
```dart
// Source: swap_settings_drawer.dart:44-70 (the ResponsiveDrawer.show call shape)
ResponsiveDrawer.show<void>(
  context: context,
  title: 'Continue to checkout', // or similar per copywriting
  child: /* the sheet's option list */,
  footer: /* primary GWButton, gw.borderSubtle top hairline */,
).whenComplete(() { /* dispose any controllers */ });
```

2. `lib/dashboard/home/widgets/transaction_displays.dart`'s `showTransactionDetails` function (`:430-530`) — the simpler "just call `ResponsiveDrawer.show` with a `child:` and an optional `footer:`" shape, closer to this sheet's three-option-list structure (no form state to manage).

**Button swap:** the sheet's three raw `ElevatedButton`s ("Open in Browser" / "Show QR" / "Copy checkout link") map onto the same `GWButton` variant vocabulary — likely `secondary`/`tertiary`/`tertiary` respectively (Claude's discretion, no CTA here is the singular money-moving action the way "Create Order" is).

**Important:** if the plan/discuss step does NOT explicitly extend authorization to this file (see RESEARCH.md Pitfall 2 and CONTEXT.md D-07's own text), do not re-skin it — the planner must confirm D-07's scope grant is still live before writing a task against these patterns.

---

### Test files (new — `test/banxa/*`)

**Analog:** `test/squid_router/route_details_card_test.dart` — the exact "golden-value widget test that pumps inside `MaterialApp(theme: ThemeData(extensions: [GWColors.dark()]))`" shape.

**Two-mode pump helper (`_host`/`_boundedHost`+`_unboundedHost`)** — `test/components/gw_empty_state_anchor_test.dart` is the concrete precedent for testing a widget across multiple layout/constraint shapes; `route_details_card_test.dart`'s simpler single-mode `_host` helper is the one to copy for a straightforward status-bucket assertion test (no multi-constraint concern for order cards).

**`order_card_test.dart` / `order_details_card_test.dart` — direct copy-adapt of `route_details_card_test.dart`'s shape:**
```dart
// Source: test/squid_router/route_details_card_test.dart:1-30 (full file pattern)
Widget _host(Widget child, {GWColors? gw}) => MaterialApp(
  theme: ThemeData(extensions: [gw ?? GWColors.dark()]),
  home: Scaffold(body: child),
);

// Banxa target: one testWidgets per status bucket (completed/pendingpayment/declined/unknown),
// constructing a fixture Order via a shared `testOrder({status: ...})` factory
// (mirrors _token() at route_details_card_test.dart:15-25), then asserting the
// status pill's text/color match the semantic token — NOT a live sandbox order (D-03).
```

**`banxa_buy_screen_cta_test.dart`:** same `_host` MaterialApp wrapper, asserting the CTA's enabled/disabled paint mirrors `08-03`'s CTA-state test pattern (RESEARCH.md names this explicitly; that file was not located in this pass — the planner should grep `test/squid_router/` or `test/bridge/` for the literal `08-03` CTA-state test before writing this one, since it is the more precise analog than the generic `route_details_card_test.dart` shape).

**`fixtures.dart`:** direct port of `route_details_card_test.dart:15-25`'s `_token()` factory-function idiom — a `testOrder({status: ...})` factory function (not a class), same file-local placement convention.

---

## Shared Patterns

### Live GWColors read (every touched widget, hard rule)
**Source:** `crypto_news_screen.dart:224` / `swap_settings_drawer.dart:86` / `transaction_displays.dart:210` — identical one-liner everywhere.
**Apply to:** all 8 screen/component files in scope.
```dart
final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
```

### Back-arrow AppBar convention
**Source:** `lib/tokens/token_info_screen.dart:92-129` (live, confirmed).
**Apply to:** `banxa_buy_screen.dart`, `banxa_orders_history.dart` (when `canGoBack`), `order_details_page.dart`, `checkout_qr.dart`, `banxa_payment.dart`, `kyc_registration.dart`.
(Full excerpt under `order_details_page.dart`'s Pattern Assignment above — do not duplicate a second back-arrow style.)

### GWButton variant ladder (gradient/secondary/tertiary)
**Source:** `lib/squid_router/swap_settings_drawer.dart:96-105` (gradient), `transaction_displays.dart:517-528` (secondary, with leading icon).
**Apply to:** every hand-rolled `ElevatedButton`/`OutlinedButton`/`InkWell`+`Ink` gradient button across all 8 in-scope files — this is the single highest-count substitution in the whole phase.

### 4-bucket status-to-semantic-token ladder
**Source:** `transaction_displays.dart:49-95` (`_statusPill`) + `transaction_badge.dart:43-107` (`badgeSpec`) — Phase 12's shipped precedent for exactly this problem shape.
**Apply to:** `order_card.dart`'s `_getStatusColor()`, `order_details_card.dart`'s status ternary, `order_details_page.dart`'s banner classification.

### GWErrorState / GWEmptyState replacing bare Text
**Source:** `crypto_news_screen.dart:149-166` (both `error:` and empty-state `onData` branches in one file — the cleanest combined example in the codebase).
**Apply to:** `banxa_orders_history.dart`'s error/empty branches, `order_details_page.dart`'s `FutureStateWidget.error` param.

### GWCard replacing hand-rolled Card/Container decoration
**Source:** `crypto_news_screen.dart:435-473` and `:563-614` (`GWCard(hoverLift:, padding:, child:)`).
**Apply to:** `order_card.dart`, `order_details_card.dart` (banner container aside), `quote_card.dart`, the inline quote card in `banxa_buy_screen.dart`.

### ResponsiveDrawer.show shell (if D-07's grant is confirmed live)
**Source:** `swap_settings_drawer.dart:44-70` (form + footer variant), `transaction_displays.dart:490-529` (simpler list variant).
**Apply to:** `handle_banxa_drawer.dart` only, contingent on the scope note above.

---

## No Analog Found

None. Every in-scope file has at least a role-match analog from a prior re-skinned phase (5/7/8/12/15). The two items requiring planner judgment rather than direct copy:

| File/Concern | Role | Reason no *exact* analog exists |
|---|---|---|
| `quote_card.dart`'s dead-code consolidation | component | This is a planning/scope decision (per UI-SPEC + RESEARCH Pitfall 1), not a visual pattern — no codebase precedent for "re-skin a dead widget and decide whether to wire it in" exists to copy from. |
| `handle_banxa_drawer.dart`'s exact visual contract | component | D-07 brought it into scope after the UI-SPEC was finalized, so no per-file Component Inventory row exists for it (unlike the other 7 files). The structural `ResponsiveDrawer` pattern is a strong analog; the exact copy/spacing contract is not yet written down anywhere and should be confirmed before planning. |

---

## Metadata

**Analog search scope:** `lib/dashboard/`, `lib/squid_router/`, `lib/tokens/`, `lib/components/`, `lib/banxa/`, `test/squid_router/`, `test/components/`
**Files read in full:** `crypto_news_screen.dart`, `transaction_displays.dart`, `transaction_badge.dart`, `transaction_utils.dart`, `swap_settings_drawer.dart`, `route_details_card_test.dart`, `gw_empty_state_anchor_test.dart`, `handle_banxa_drawer.dart`, `token_info_screen.dart` (lines 85-130)
**Pattern extraction date:** 2026-07-27
