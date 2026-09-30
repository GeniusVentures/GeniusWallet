---
phase: 39-banxa-integration-hardening
plan: 11
subsystem: banxa-orders
tags: [banxa, orders, drawer, checkout]
requires: [39-10]
provides:
  - "OrderDrawerFooter: status meaning plus the one next step, on every Buy order drawer"
key-files:
  created: [lib/banxa/banxa_components/order_drawer_footer.dart, test/banxa/order_drawer_footer_test.dart]
  modified: [lib/banxa/banxa_components/order_details_drawer.dart, test/dashboard/buy_orders_filter_test.dart]
status: complete
actuals: {tokens: 9000, tasks: 2, commits: 2}
---
# Phase 39 Plan 11: Order drawer footer Summary

Every Buy order drawer now says what its status means and offers the one action that status needs.

## Result
- Full `flutter test`: 2345 passed, 6 skipped, 0 failed (plan 10 ended at 2335; +9 footer tests, +1 drawer case). `flutter analyze lib test` exit 0. Format, brace, raw-colour and key-logging (`--scan-tree`) scripts exit 0. ID gate printed 0 on both commits. No trailers, email braianwegmann@hotmail.com.
- Commits: 9ea0fbdc (footer widget and tests), e78fafcb (wired into `showOrderDetails`, Transactions case). No checkpoints or tracer tasks. STATE.md and ROADMAP.md untouched; no flutter_tester left running.
- Mutation check: loosening the trusted-URL condition (`&&` to `||`) fails the untrusted-link and status-only tests.
- Not run: a live tap-through on a real Banxa order; the launcher and router are fakes in tests.

## Decisions
- Complete payment and Continue verification push the order's own `orderStatusUrl`, shown only when `isTrustedCheckoutUrl` accepts it; an untrusted link leaves the status line (and support for needs-ID) only.
- The router is read before the drawer pops, since the pop deactivates the footer's context.
- Support link opens in the external browser via `launchUrl`, not the in-app web view, so a support page never sits inside the wallet.

## Deviations from Plan
- None. The new file is not in the reskin literal gate's pinned list of four; it still reads `GWColors` live and uses no raw colour.

## Known Stubs
None.

## Self-Check: PASSED
Both new files exist, both commits are in `git log`, and no message carries a trailer.
