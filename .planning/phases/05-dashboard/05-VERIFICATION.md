---
phase: 05-dashboard
verified: 2026-07-21T18:00:00Z
status: passed
previous_status: gaps_found
score: 2/5 truths verified outright (C3, C4); C1, C2, C5 PASSED (override) — see overrides below, applied 2026-07-21 by explicit user decision after live app inspection. No criterion's underlying evidence changed; only the sign-off disposition did.
behavior_unverified: 1
overrides_applied: 3
overrides:
  - must_have: >-
      Walking the dashboard produces no RenderFlex overflow — the crypto_live_chart.dart:315
      zoom/pan-row overflow (ROADMAP criterion 5)
    reason: >-
      User inspected the Bitcoin Chart card in the running app 2026-07-21 and confirmed the
      planner's finding directly: "it's just that the current size of the app being opened it
      does not have space for the bitcoin chart, we may want to drop that size, but again that
      is a todo item for later, let's close the phase 5 and set it as valid and continue." The
      34px overflow at crypto_live_chart.dart:315 is a card-height problem
      (dashboard_screen.dart's vertical budget for the Bitcoin Chart card), not a component
      defect — the identical widget is given a much larger slot at token_info_screen.dart:130
      and is fine there. The considered stopgap (quick 260721-gx1, hiding the zoom/pan row
      below a 112px threshold) was deliberately NOT executed: it would have cleared the
      overflow while leaving a card containing only a 6.5px chart hairline — "a non-overflowing
      broken card, not a fixed one," in the stopgap plan's own words — trading an honest FAIL
      for a cosmetic, dishonest PASS.
    closes_when: >-
      A dashboard_screen.dart sizing decision gives the Bitcoin Chart card real vertical room
      (new todo: 2026-07-21-bitcoin-chart-card-height-dashboard-vertical-budget.md), and/or the
      zoom/pan-row product decision (2026-07-21-chart-zoom-pan-row-overflows-34px.md) resolves
      whether the row survives at all.
    accepted_by: "user (braianxde), live app inspection"
    accepted_at: "2026-07-21T20:00:00Z"
  - must_have: >-
      Balances, holdings, transactions, markets and news all render in the redesign skin and
      match the Release exe at GeniusWallet-3514 (ROADMAP criterion 1, clause 2 — the
      side-by-side comparison)
    reason: >-
      Every code-level gap behind this criterion is resolved and walked (badge contrast,
      Markets error/empty skin, WalletsOverview overflow, GWEmptyState overflow — see the
      `gaps:` block below, all `status: resolved`). Only the side-by-side walk against the
      reference Release exe has never been performed, though the reference exe is present and
      built on this machine
      (`GNUS-compare\GeniusWallet-3514\build\windows\x64\runner\Release\genius_wallet.exe`).
      This is an unscheduled walk, not a known defect — closed by explicit user decision to
      proceed rather than block the phase on a comparison walk with no evidence against it.
    closes_when: >-
      The side-by-side walk in
      `.planning/todos/pending/2026-07-21-side-by-side-walk-dashboard-vs-release-exe.md` is
      performed.
    accepted_by: "user (braianxde), phase closeout decision"
    accepted_at: "2026-07-21T20:00:00Z"
  - must_have: >-
      Pull-to-refresh works on the dashboard, the transactions list and the news feed, and each
      reloads its data (ROADMAP criterion 2)
    reason: >-
      Wiring is confirmed byte-identical to develop's shipped `RefreshIndicator`/`onRefresh`
      callbacks at all three sites (`dashboard_screen.dart:231`,
      `transactions_screen.dart:16-18`, `crypto_news_screen.dart:72`). The dashboard leg has
      been directly observed reloading (05-01 walk). The transactions and news legs' reload
      completion is a state transition with no automated harness and has never been directly
      observed by a human watching a live reload — behavior-unverified, not known-broken.
    closes_when: >-
      A human performs the pull-to-refresh walk recorded under `behavior_unverified_items` /
      `human_verification` below and observes both lists actually re-fetch.
    accepted_by: "user (braianxde), phase closeout decision"
    accepted_at: "2026-07-21T20:00:00Z"
reverification_of: 2026-07-21T12:00:00Z
reverification_reason: >-
  05-08's Task 4 (blocking human-verify walk) was performed and APPROVED 2026-07-21 on a
  Windows debug build, closing gaps B1 and B2 below and the outstanding 260721-e3r
  (GWEmptyState) re-walk in the same session. This re-verification moves those three items
  to resolved/resolved-and-walked and records a NEW criterion-5 finding the walk itself
  surfaced: a third, distinct RenderFlex overflow at crypto_live_chart.dart:315 (the zoom/pan
  IconButton row, 34px), which 05-08 did not introduce and is not accountable for fixing.
gaps:
  - truth: "Walking the dashboard ... produces no RenderFlex overflow (findings 30-34) — SECOND site: WalletsOverview"
    status: resolved
    discovered: 2026-07-21
    resolved: 2026-07-21
    source: ".planning/reference/AUDIT-260721-parallel-investigation.md (B1), derived at 87a7715"
    reason: >-
      CLOSED by plan 05-08 (Task 1 fixture + Task 2 structural fix), walked and APPROVED
      2026-07-21 on a Windows debug build. `wallet_overview.dart`'s build() now wraps the
      unchanged six-child Column in LayoutBuilder -> SingleChildScrollView ->
      ConstrainedBox(minHeight: incoming bound) — no threshold constant, pixel-identical
      where there is room, scrolls instead of overflowing where there is not. The dev bubble
      gained two MOCK buttons ("SGNUS idle" / "SGNUS busy", lib/dev/dev_mock_sgnus.dart) that
      make WalletType.sgnus + isProcessing reachable for the first time in this project's
      history. Walked: both idle and processing states, both appearance modes, multiple
      window sizes (including a deliberately cramped one to confirm inner scrolling, and a
      wide one to confirm the unchanged-where-there-is-room regression gate), plus the
      nested-scroll interaction with the outer RefreshIndicator. Zero RenderFlex overflow
      lines attributable to WalletsOverview across the whole walk.
    artifacts:
      - path: "lib/components/wallet_overview.dart"
        issue: "RESOLVED — LayoutBuilder/SingleChildScrollView/ConstrainedBox wrapper, walked clean."
      - path: "lib/dev/dev_mock_sgnus.dart"
        issue: "RESOLVED (new file) — the fixture that made this state walkable at all."
    missing: []
  - truth: "Balances, holdings, transactions, markets and news all render in the redesign skin — Markets error/empty branches"
    status: resolved
    discovered: 2026-07-21
    resolved: 2026-07-21
    source: ".planning/reference/AUDIT-260721-parallel-investigation.md (B2), derived at 87a7715"
    reason: >-
      CLOSED by plan 05-08 (Task 3), walked and APPROVED 2026-07-21. Both the error branch
      ("Failed to load market coins" + exactly one Retry) and the empty branch ("No market
      data available") now render inside DashboardScrollContainer, keeping the card, border
      and padding that all four sibling panels have. Develop's strings survive byte-for-byte
      (UI-SPEC §6). Reached during the walk via a NEW dev fixture built in the same session
      (Mkt error / Mkt empty bubble buttons, commit 3364259, DevFaultInjector.marketsFault) —
      CoinGecko was 429-rate-limited for the whole session, so the app's real fallback to
      cached data meant neither branch was otherwise reachable at all. Walked at a short
      two-column window (the shape the error chrome could not fit before the scroll-safe
      wrapper) with no overflow, and Retry re-confirmed to re-issue the fetch.
    artifacts:
      - path: "lib/dashboard/home/view/dashboard_screen.dart"
        issue: "RESOLVED — both branches now inside DashboardScrollContainer, walked."
    missing: []
  - truth: "Walking the dashboard with long values, empty symbols and a filtered transaction list produces no RenderFlex overflow and no crash, and the transaction count footer is present (findings 30, 31, 32, 33, 34) — GWEmptyState/TransactionsSlimView site"
    status: resolved
    discovered: 2026-07-21
    resolved: 2026-07-21
    reason: >-
      CLOSED by quick task 260721-e3r (`2e82ec2`) and walked & APPROVED 2026-07-21 as part of
      05-08's Task 4 Part D — this had been the outstanding item since the fix landed
      (previously `fixed_walk_pending`). `GWEmptyState` now adapts below a finite-height
      threshold, following the CryptoLiveChart compact-mode precedent. Walked on an empty
      wallet at default window size (the fresh-install state that had never been walked
      before): the Transactions empty state rendered with no overflow, and the message was
      fully readable, not ellipsised. Regression gate held — the Assets empty state (pinned
      at 300px) stayed full-size and visually unchanged, confirming Assets and Transactions
      now look deliberately different rather than both having shrunk. Console evidence: zero
      overflow lines on boot, where the pre-fix 2026-07-20 run logged 19px within seconds
      under identical conditions. Re-walked across multiple window shapes per the plan's Part
      D step 15.
    artifacts:
      - path: "lib/components/feedback/gw_empty_state.dart"
        issue: "RESOLVED — adaptive compact tier below a finite maxHeight threshold, walked clean."
      - path: "lib/dashboard/home/widgets/transactions_slim_view.dart"
        issue: "RESOLVED — the ConstrainedBox that caps the panel is unchanged; the child now adapts to it."
    missing: []
  - truth: "Walking the dashboard produces no RenderFlex overflow — THIRD, newly-discovered site: crypto_live_chart.dart zoom/pan row"
    status: failed
    discovered: 2026-07-21
    source: ".planning/todos/pending/2026-07-21-chart-zoom-pan-row-overflows-34px.md — surfaced live during 05-08 Task 4's walk"
    reason: >-
      Observed live on the 2026-07-21 Windows debug walk, on the plain dashboard at ordinary
      window size, with NO fixture armed: `crypto_live_chart.dart:315`'s inner Column is
      handed `h=6.5` and needs ~40.5, because its Row of four zoom/pan IconButtons (48x48
      Flutter defaults) cannot fit. 34px overflow. This is a THIRD, distinct site — not a
      regression of the two sites just closed above (WalletsOverview and GWEmptyState both
      produced zero overflow lines all session), and not a re-appearance of the already-fixed
      6.3px chart overflow at the old `:206` (uhe's guard, still holding). It was present in
      the 2026-07-20 log but recorded "unattributed" — Flutter suppresses the creator chain
      for repeat errors and only dumps it for the run's first few unique failures — and only
      printed its full chain here because the other two sites were fixed, making this one the
      run's first error. Likely origin: quick 260721-dws's re-skin of this file consumed the
      vertical budget the zoom/pan row used to have; dws's own glow overlay is confirmed
      layout-neutral and not the cause.
      This gap is explicitly OUT OF SCOPE for 05-08 — that plan's file list did not include
      crypto_live_chart.dart, and Phase 7's ROADMAP entry already inherits this file's
      residue (see ROADMAP.md's "Inherits from Phase 5" note). It blocks Phase 5's ROADMAP
      criterion 5 regardless of which phase eventually fixes it.
    artifacts:
      - path: "lib/chart/crypto_live_chart.dart"
        issue: "Line 315 — inner Column handed h=6.5, needs ~40.5; the Row of 4 zoom/pan IconButtons (lines 453-482) cannot fit."
    missing:
      - "A product decision on whether zoom/pan survives, tied to the already-filed 'wire real timeframe ranges' todo (deleting the row closes this AND the raw-Colors.white finding AND the redundancy question at once)."
      - "If it survives: a layout fix (give the Row its own height, or an adaptive compact mode like CryptoLiveChart's existing price-text handling) plus the token migration for the same four IconButtons' raw Colors.white."
      - "A walk in both appearance modes and at more than one window height, plus a release-build check (release clips silently where debug paints stripes)."
  - truth: "When wallet or account load fails the dashboard shows an error message with a working retry — never an endless spinner — and the hero balance does not render before the account has loaded (findings 8, 9, 29)"
    status: resolved
    resolved: 2026-07-21
    reason: >-
      CLOSED by plan 05-07 (`64fa92d`), walked and approved 2026-07-21 in both appearance
      modes. The dashboard failure branch now renders a `GWButton` "Retry" beside the
      byte-for-byte-preserved `'Something went wrong!'`.
      **The "conflict" that made this a decision was not real.** Both the 2026-07-20 report
      and the first 2026-07-21 re-verification described ROADMAP criterion 3 and UI-SPEC §6
      as documents that could not both be satisfied. Reading §6 at source disproved that:
      §6 is a *Copywriting Contract*. It locks the string and forbids substituting
      `GWErrorState` for the plain `Text` — it says nothing about adding a retry affordance
      *beside* the text. Its "no new user-facing copy" mandate is also satisfied, because
      `"Retry"` already ships on develop (`custom_future_builder.dart:49`,
      `gw_error_state.dart:14`). So both documents hold: **no override was recorded and
      criterion 3 was not reworded.**
      A second-hand summary of a constraint was treated as the constraint for two reporting
      cycles. Read the source before declaring a deadlock.
      Implementation note: reusing the existing `_onRefresh` alone would have shipped a DEAD
      button. `accountStatus` is written only inside `_onFetchAccount` (`app_bloc.dart:164,
      168,170`), and `_onLoadWallets` never emits `AppStatus.error` for
      `subscribeToWalletStatus` — so in shipped code this branch is reachable ONLY via
      `accountStatus == error`, the one leg `LoadWallets()` cannot clear. The retry therefore
      dispatches `FetchAccount()` **and** the shared reload. Caught at planning, independently
      confirmed by the plan-checker and again by the executor before any code was written.
      Finding 8's markets retry was also exercised in the same walk (Part B), closing the
      "never exercised by any walk" sub-gap that had stood since 05-01.
    artifacts:
      - path: "lib/dashboard/home/view/dashboard_screen.dart"
        issue: "RESOLVED — error branch now carries a working Retry dispatching both gating statuses."
    missing: []
resolved_since_last_verification:
  - was_gap: "Quick task k81 (`2c7db8a`) reverted 05-06's WCAG-motivated `textOnBrand` badge icon/border to `Colors.white` — 1.42:1 on brandGreen, 1.99:1 on lightBlueAccent, below even WCAG 1.4.11's 3:1 non-text floor."
    status: resolved
    evidence: >-
      At HEAD, `lib/dashboard/home/widgets/transaction_displays.dart` uses
      `GeniusWalletColors.textOnBrand` for BOTH the badge `Border.all(color:)` (line 90)
      and the badge `Icon(color:)` (line 97). The `Colors.white` pair is gone. 05-06's
      SUMMARY claim ("no Colors.white survives in transaction_displays.dart") is TRUE
      again at HEAD. Contrast restored to 13.97:1 / 9.95:1 / 6.05:1.
  - was_gap: "A 6.3px RenderFlex overflow fired on the plain dashboard at ordinary window height (`crypto_live_chart.dart:206`)."
    status: code_mitigated_walk_pending
    evidence: >-
      The 07-20 report measured baseline `7a95e68`, which predates the fix. Quick task
      `260720-uhe` (now in `0bcf3df`) added an explicit compact-mode guard to
      `CryptoLiveChart`: `isHeightBounded` (`:217`), a single `priceHeight * 3.5`
      threshold (`:225`), a clamped `priceFontSize` (`:227`), and a load-bearing
      `assert(!isCompact || priceFontSize * 1.5 <= constraints.maxHeight)` (`:229-230`).
      uhe was walked and approved in BOTH modes. Quick task `260721-dws` then rewrote
      the same file for sketch 006 A→ and deliberately made its glow a layout-neutral
      `Positioned(width/height) + IgnorePointer` inside a `Stack` specifically so it
      "cannot re-open the compact-mode overflow" (`:241`). NOT promoted to verified:
      the original human_verification item — inspecting the card's bottom edge in a
      **release** build, where clipping is silent — has still never been performed,
      and dws is the larger rewrite of the two and carries `status: awaiting-verification`.
deferred:
  - truth: "The dashboard chart area (ChartDashboardView -> CryptoLiveChart) wears the redesign skin"
    addressed_in: "Phase 5 (largely delivered) + Phase 7 (residue)"
    status: superseded
    evidence: >-
      The 07-20 report deferred this whole item to Phase 7 on the grounds that
      `crypto_live_chart.dart` was untouched by any 05-* plan and carried 8 raw
      `Colors.white`/`Colors.grey[400]` values. That is no longer true: quick task
      `260721-dws` re-skinned the file to sketch 006 A→ inside Phase 5. Re-counted at
      HEAD, **4 raw values survive, all `Colors.white`** — and all four are on the same
      widget: the zoom/pan `IconButton` row (`:455`, `:463`, `:471`, `:480`). Every
      `Colors.grey[400]` is gone. The deferral therefore shrinks from "the chart is
      unskinned" to the narrower residue below.
new_findings:
  - truth: "The chart's zoom/pan control row is still on raw `Colors.white`"
    status: open
    severity: minor
    reason: >-
      `260721-dws` deliberately KEPT zoom/pan (re-skin-never-restructure) but re-skinned
      around it, leaving four `const Icon(..., color: Colors.white)` on the zoom-in /
      zoom-out / pan-left / pan-right buttons. Keeping the BEHAVIOR did not require
      keeping the raw color. These are not the documented always-dark scrim exception
      (that exception covers text over a dark image scrim, e.g. `crypto_news_screen.dart:173,224`)
      — they are plain icons on the card surface, so they will wash out in light mode.
      Not a regression (the file was worse before), and not yet walked in light.
    artifacts:
      - path: "lib/chart/crypto_live_chart.dart"
        issue: "Lines 455, 463, 471, 480 — `color: Colors.white` on the zoom/pan IconButtons."
    missing:
      - "Migrate the four icons to `gw.textSecondary` (or the equivalent appearance-aware token) during the light-mode AA pass."
      - "Note: `260721-dws`'s own follow-up todo asks whether zoom/pan is redundant once real timeframe ranges are wired — if it is deleted, this finding dies with it. Sequence the two."
  - truth: "The Bitcoin Chart timeframe segment is visual-only"
    status: open_by_design
    severity: informational
    reason: >-
      `260721-dws` shipped `_TimeframeSegment` as a VISUAL-ONLY control by explicit user
      decision (2026-07-21): tapping a tab moves the selected chip but does not change
      the plotted series. Recorded here so it is not later mistaken for a defect.
      Tracked in `.planning/todos/pending/2026-07-21-wire-real-timeframe-ranges-in-crypto-live-chart.md`.
behavior_unverified_items:
  - truth: "Pull-to-refresh works on the transactions list and the news feed, and each reloads its data (findings 10, 18)"
    test: >-
      With GW_DEV_TOOLS=true, populate transactions via the dev bubble Mock-txns injector.
      Two-finger trackpad pull-down (macOS) / touch or trackpad gesture (Windows) on the
      transactions list, then on the news feed. Mouse click-drag does nothing — lib/ sets
      no dragDevices, so Flutter's desktop default excludes mouse. Walk-technique gotcha,
      not a defect.
    expected: >-
      Each list visibly re-fetches: transactions re-issues WalletDetailsCubit.getCoins(),
      news re-issues fetchCoinTelegraphNews(), and rendered items refresh.
    why_human: >-
      A refresh->reload is a state transition. Grep proves the RefreshIndicator and its
      onRefresh callback are present and byte-identical to develop's shipped wiring; it
      cannot prove the reload completes. No test harness exists. Wiring re-confirmed
      unchanged at HEAD after the merge.
human_verification:
  - test: >-
      Compare each of the five dashboard surfaces side by side against the
      GeniusWallet-3514 Release exe.
    expected: "Each matches the reference."
    status: NOW_POSSIBLE
    note: >-
      **This item was blocked and is no longer.** The 07-20 report recorded the reference
      as "a Windows path, absent from this machine" — true of the macOS session that wrote
      it. On the Windows machine the reference IS present and built:
      `C:\Users\User\Documents\Projects\GNUS-compare\GeniusWallet-3514\build\windows\x64\runner\Release\genius_wallet.exe`.
      Criterion 1's second clause is walkable here.
  - test: >-
      Pull-to-refresh on the transactions list and the news feed (see
      behavior_unverified_items for the full recipe).
    expected: "Each reloads its data."
    why_human: "State transition, no test harness."
  - test: >-
      [RESOLVED 2026-07-21 — retained for history] Force a market-data fetch failure and press
      the retry button.
    expected: "The fetch is re-issued and the grid populates on success."
    status: RESOLVED
    note: >-
      Walked as 05-08 Task 4 Part C, via the new `Mkt error`/`Mkt empty` dev fixture
      (commit `3364259`) built during the walk itself. The retry now lives inside `GWErrorState`
      (Task 3 Edit C), not appended by `FutureStateWidget`. With the fault still armed, Retry
      re-issued the fetch and failed again, still inside the card; with the fault cleared,
      Retry populated the grid. APPROVED.
  - test: >-
      Open the dashboard at a normal window height in a RELEASE build and inspect the
      Bitcoin Chart card's bottom edge AND the zoom/pan control row.
    expected: "No clipped content, no striped overflow marker, on either the card's bottom edge or the zoom/pan row."
    why_human: >-
      Release silently clips where debug paints stripes. uhe's guard (the old 6.3px site) was
      walked in debug and approved; dws then rewrote the file, and the 2026-07-21 debug walk
      found a NEW 34px overflow on the zoom/pan row (see the criterion-5 gap). Only a human
      comparing debug vs release can tell whether real content is being lost on either site.
  - test: >-
      Walk the Bitcoin Chart card and the zoom/pan control row in LIGHT mode.
    expected: "The zoom/pan icons are legible against the card surface."
    why_human: "Four raw Colors.white icons survive; the light pass is deferred and unwalked."
---

# Phase 5: Dashboard Verification Report (re-verification)

**Phase Goal:** The dashboard wears the redesign and keeps every behavior develop shipped
**Verified:** 2026-07-21 (18:00Z pass — post-05-08-Task-4 walk)
**Status:** PASSED WITH 3 OVERRIDES (recorded 2026-07-21, closing the phase on explicit user
authorization — see `## Acknowledged Gaps` below). **This is not an earned PASS on criteria 1, 2
and 5** — their underlying evidence is unchanged from the `gaps_found` pass below (still PARTIAL /
PRESENT_BEHAVIOR_UNVERIFIED / FAILED on their own merits). The user inspected the one live defect
(the chart-card overflow) directly, confirmed it is a real card-height limitation rather than a
component bug, rejected the considered stopgap as cosmetic, and authorized closing Phase 5 with
the three outstanding items recorded as overrides rather than passes. See `## Acknowledged Gaps`.
**Re-verification:** Yes — supersedes the 2026-07-21T12:00Z report
**Verified at:** `ui-redesign-port` @ HEAD (05-08's Tasks 1-3 in `2d18b85`, the markets walk-fixture in `3364259`, plus the untracked chart-overflow todo)
**Previously verified at:** `93f77d3` (12:00Z pass, code content from `0bcf3df` / PR #210)

> **Why this re-run exists.** Plan `05-08` closed gaps B1 and B2 below (WalletsOverview overflow,
> Markets error/empty skin) and walked-and-approved the outstanding `260721-e3r` (`GWEmptyState`)
> item, all in the same Task 4 human walk on 2026-07-21. That walk also surfaced a NEW, third
> RenderFlex overflow site (`crypto_live_chart.dart:315`, the zoom/pan row, 34px) that neither
> 05-08 nor any prior plan introduced or is accountable for. This re-verification moves the three
> closed items to `resolved`/`resolved`-and-walked and records the new site as an open criterion-5
> gap, rather than letting the closure of two gaps read as the closure of the whole criterion.

> **Why the 2026-07-20 re-run before this one exists (carried forward).** The 2026-07-20 report was
> written while seven walked-and-approved quick tasks were still sitting uncommitted in the working
> tree behind the CLAUDE.md gate. The verifier correctly measured the committed baseline `7a95e68`
> — but that baseline did not contain the fixes. Two of its three gaps were therefore measured
> against code that no longer exists at HEAD. Nothing in the original report was wrong when
> written; it simply expired the moment PR #210 merged.

> **Standing constraint, carried forward unchanged.** `flutter test` does not compile on this
> branch; there is no automated test harness. `flutter analyze` is a gate, never evidence. A
> human running the app is the only real behavioural evidence available. No criterion below is
> marked VERIFIED on the strength of analyze or of a SUMMARY claim.
>
> **Platform note (updated).** The 07-20 report was the phase's first macOS run and flagged all
> prior walks as Windows-only single-platform evidence. This re-verification was performed on the
> **Windows** machine. Flutter is **not installed here**, so the analyze gate could not be re-run
> — see Behavioral Spot-Checks. Every code-level claim below is derived by direct file reading at
> HEAD, not from a SUMMARY.

## Goal Achievement

### Observable Truths (ROADMAP Success Criteria)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Balances, holdings, transactions, markets and news all render in the redesign skin and match the Release exe at `GeniusWallet-3514` | ⚠️ PARTIAL (unchanged verdict, narrower gap) | **Clause 1 now fully clean.** The k81 badge regression is gone (`textOnBrand` restored). B2 — the Markets error/empty branches losing their card — is now RESOLVED by plan **05-08** (Task 3) and **walked & approved 2026-07-21**: both branches render inside `DashboardScrollContainer` with the same chrome as the four sibling panels, strings byte-exact, exactly one Retry. All five surfaces, in every reachable state including error/empty, are re-skinned and walked. **Clause 2 (side-by-side vs the Release exe) is the ONLY remaining gap** — still unevidenced, though no longer blocked (the reference exe is present on this machine; see `.planning/todos/pending/2026-07-21-side-by-side-walk-dashboard-vs-release-exe.md`). Stays PARTIAL, not because of any known defect, but because that one walk hasn't been run. |
| 2 | Pull-to-refresh works on the dashboard, the transactions list and the news feed, and each reloads its data (findings 10, 17, 18) | ⚠️ PRESENT_BEHAVIOR_UNVERIFIED (unchanged) | All three re-confirmed wired at HEAD: `dashboard_screen.dart:231`, `transactions_screen.dart:16-18` (`WalletDetailsCubit.getCoins()`), `crypto_news_screen.dart:72`. Dashboard leg directly observed (05-01 walk). Transactions and news legs still rest on walk claims, not observation. 05-08's Task 4 additionally re-confirmed the nested-scroll interaction between the new WalletsOverview scroll view and the outer `RefreshIndicator` does not break this. |
| 3 | Dashboard shows an error message with a working retry — never an endless spinner — and the hero balance does not render before the account has loaded (findings 8, 9, 29) | ✓ **VERIFIED** (unchanged) | Closed by plan **05-07** (`64fa92d`) and **walked & approved 2026-07-21 in both appearance modes**. A `GWButton` "Retry" now sits beside the byte-for-byte-preserved `'Something went wrong!'`, dispatching `FetchAccount()` **and** the shared reload — both gating statuses, not just one. Finding 8's markets retry also exercised and approved. |
| 4 | Market data refreshes once a minute, not every 20 seconds (finding 14) | ✓ VERIFIED (unchanged) | `Timer.periodic(const Duration(minutes: 1), ...)` at `lib/components/coins/view/coins_screen.dart:55`. Single unambiguous constant. Behaviourally corroborated by 05-01's CoinGecko 429. |
| 5 | Walking the dashboard with long values, empty symbols and a filtered transaction list produces no RenderFlex overflow and no crash, and the transaction count footer is present (findings 30, 31, 32, 33, 34) | ✗ **STILL FAILED — resolved on two sites, newly failed on a third** | Count footer re-confirmed at `transactions_slim_view.dart:160`; findings 30–34 present. **Three of four known/newly-found overflow sites are now clean and walked:** the old 6.3px chart overflow (uhe's guard, walked), `WalletsOverview`'s B1 overflow (05-08 Task 2, walked idle+processing at multiple slot heights, zero overflow), and `GWEmptyState`'s 19px/34px overflow (`260721-e3r`, walked 2026-07-21, empty-wallet fresh-install state, zero overflow, Assets regression gate held). **But the SAME 2026-07-21 walk surfaced a fourth, brand-new site**: `crypto_live_chart.dart:315`'s zoom/pan `IconButton` row overflows by **34px** on the plain dashboard, no fixture armed, ordinary window size. Not a regression of any of the three sites just closed (all three produced zero overflow lines across the whole walk) and not the same defect re-appearing — a genuinely new, fourth site. Criterion 5 therefore stays FAILED, now exclusively on this one open item; see the gap below and `.planning/todos/pending/2026-07-21-chart-zoom-pan-row-overflows-34px.md`. |

**Score:** 2/5 truths verified outright (C3, C4) — unchanged from the 12:00Z pass in raw count, but the shape of the remaining 3 improved materially: C1 narrowed from a code gap + a walk gap to a walk-only gap; C5's known sites all closed, replaced by one new site rather than staying open on the old ones; C2 unchanged.
Breakdown: 2 verified outright (C3, C4), 1 partial narrowed to a single pending walk (C1), 1 behavior-unverified unchanged (C2), 1 failed on a newly-substituted single site (C5).

## Acknowledged Gaps

**Phase 5 closes on 2026-07-21 with three items recorded as explicit user-authorized overrides,
not as passes.** The frontmatter `overrides:` block above carries the machine-readable form; this
section is the human-readable record of the same three decisions. Nothing below was re-tested or
newly fixed to produce this closure — the user reviewed the open items and chose to accept them
rather than block the phase further.

| # | Criterion | Real status (unchanged) | Not met | Authorized by | Reason | Closes when |
|---|-----------|--------------------------|---------|----------------|--------|-------------|
| 1 | ROADMAP C5 — "no RenderFlex overflow" | ✗ FAILED (see gap below) | The 34px overflow at `crypto_live_chart.dart:315` (zoom/pan `IconButton` row) still fires on the plain dashboard at ordinary window size | User, 2026-07-21, live app inspection | The chart card genuinely has no vertical room at the app's current window size. User's words: *"it's just that the current size of the app being opened it does not have space for the bitcoin chart, we may want to drop that size, but again that is a todo item for later, let's close the phase 5 and set it as valid and continue."* The considered stopgap (quick `260721-gx1`, hiding the zoom/pan row below a 112px slot threshold) was deliberately **abandoned, not executed** — it would have cleared the overflow while leaving a card containing only a 6.5px chart hairline, which the stopgap plan itself called "a non-overflowing broken card, not a fixed one." | A `dashboard_screen.dart` sizing decision gives the card real height (new todo filed), and/or the zoom/pan-row product decision resolves whether the row survives |
| 2 | ROADMAP C1 clause 2 — "match the Release exe at GeniusWallet-3514" | ⚠️ PARTIAL (code gaps resolved; walk clause open) | The side-by-side comparison against the reference Release exe has never been performed | User, 2026-07-21, phase closeout decision | All code-level gaps behind criterion 1 are resolved and walked (badge contrast, Markets error/empty skin, WalletsOverview overflow, GWEmptyState overflow). Only the comparison walk itself is outstanding, and the reference exe is present and buildable on this machine — this is a scheduling gap, not a known defect | The side-by-side walk (`.planning/todos/pending/2026-07-21-side-by-side-walk-dashboard-vs-release-exe.md`) is performed |
| 3 | ROADMAP C2 — "pull-to-refresh ... each reloads its data" | ⚠️ PRESENT_BEHAVIOR_UNVERIFIED | Transactions-list and news-feed reload completion has never been directly observed (dashboard leg IS observed) | User, 2026-07-21, phase closeout decision | Wiring is confirmed byte-identical to develop's shipped `RefreshIndicator`/`onRefresh` at all three sites. A reload completing is a state transition with no automated harness; only a human watching a live pull-to-refresh can confirm it | A human performs the pull-to-refresh walk recorded under `human_verification` below |

**What this closure is NOT.** It is not a claim that these three criteria pass. The Observable
Truths table below is left exactly as the `gaps_found` pass recorded it — PARTIAL / FAILED /
PRESENT_BEHAVIOR_UNVERIFIED, unchanged. The phase closes *despite* these three items, on the
strength of an explicit, recorded user decision, not because the evidence changed.

### What Changed Since 2026-07-20

| Item | 07-20 status | HEAD status (18:00Z, post-05-08-walk) | Cause |
|------|-------------|-------------|-------|
| Badge contrast (`transaction_displays.dart`) | Gap 1 — FAILED, 1.42:1 | **Resolved**, `textOnBrand` restored | Merge of the approved batch |
| 6.3px RenderFlex overflow (`crypto_live_chart.dart:206`) | Gap 3 — FAILED, confirmed open | **Resolved and walked** | `260720-uhe` guard + assert, walked & approved |
| WalletsOverview overflow (B1, `wallet_overview.dart`) | Not yet found | **Resolved and walked** | Plan `05-08` (Tasks 1-2), Task 4 Part A APPROVED |
| Markets error/empty skin (B2, `dashboard_screen.dart`) | Not yet found | **Resolved and walked** | Plan `05-08` (Task 3), Task 4 Part C APPROVED |
| `GWEmptyState` overflow (19px/34px, `TransactionsSlimView`) | Not yet found | **Resolved and walked** | Quick `260721-e3r` (`2e82ec2`), walked as 05-08 Task 4 Part D |
| Dashboard retry | Gap 2 — PARTIAL | **Resolved and walked** | Plan `05-07` (`64fa92d`), walked & approved both modes |
| Chart zoom/pan row overflow (34px, `crypto_live_chart.dart:315`) | Not yet found | **NEW — open, FAILED** | Surfaced live during 05-08's Task 4 walk; third distinct site, out of 05-08's scope |
| Chart skin | Deferred wholly to Phase 7, 8 raw values | Largely delivered in Phase 5, 4 raw values left | `260721-dws` (sketch 006 A→) |
| Reference Release exe | "absent from this machine" | Present on the Windows box | Different machine, not a code change |
| UI-SPEC §3.1's 1.96:1 pairing | Flagged as the finding that should outlive the report | **Corrected** | Quick `260721-bb3` |

### Required Artifacts (re-checked at HEAD)

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `lib/dashboard/home/widgets/transaction_displays.dart` | Overflow guards + no raw colors | ✓ VERIFIED | Badge border `:90` and icon `:97` both `GeniusWalletColors.textOnBrand`; zero `Colors.white` in file |
| `lib/dashboard/home/view/dashboard_screen.dart` | Gate/refresh/getCoins intact, retry present, Markets error/empty skinned | ✓ VERIFIED (was ⚠️ PARTIAL) | `RefreshIndicator` `:231` intact; error branch retry now present (05-07, walked); Markets error/empty branches now inside `DashboardScrollContainer` via `GWErrorState`/`GWEmptyState` (05-08 Task 3, walked) |
| `lib/components/wallet_overview.dart` | No RenderFlex overflow at any slot height, unchanged where there is room | ✓ VERIFIED (new row) | `LayoutBuilder -> SingleChildScrollView -> ConstrainedBox(minHeight:...)` (05-08 Task 2), walked idle+processing at multiple slot heights, zero overflow |
| `lib/components/feedback/gw_empty_state.dart` | Adaptive compact tier below a finite height threshold | ✓ VERIFIED (new row) | Quick `260721-e3r` (`2e82ec2`), walked on an empty wallet at default window size, Assets regression gate held |
| `lib/components/coins/view/coins_screen.dart` | Holdings re-skin, 60s timer intact | ✓ VERIFIED | `Duration(minutes: 1)` `:55` |
| `lib/dashboard/home/widgets/transactions_slim_view.dart` | Count footer kept | ✓ VERIFIED | `:160` verbatim |
| `lib/dashboard/transactions/transactions_screen.dart` | Refresh wiring intact | ✓ VERIFIED | `:16-18` `getCoins()` |
| `lib/dashboard/news/view/crypto_news_screen.dart` | Refresh wiring intact | ✓ VERIFIED | `:72` |
| `lib/chart/crypto_live_chart.dart` | (was: not in any plan's scope) | ⚠️ **NEW OVERFLOW FOUND**, 4 raw whites | Old compact guard `:217-230` still holds (walked, clean); layout-neutral glow `:241`; zoom/pan icons still `Colors.white` `:455,463,471,480`; **NEW: the zoom/pan Row itself overflows its slot by 34px at `:315`** — see the gap |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Badge contrast (WCAG 2.x relative luminance) | `textOnBrand` `#000B18` vs brandGreen / lightBlueAccent / statusError | 13.97:1 / 9.95:1 / 6.05:1 | ✓ PASS (was ✗ FAIL) |
| Raw-color census, `crypto_live_chart.dart` | `grep -nE "Colors\.(white\|grey\|black\|red\|green)"` | 4 matches, all `Colors.white` on zoom/pan icons | ⚠️ PARTIAL |
| Raw-color census, `transaction_displays.dart` | `grep -n "Colors.white"` | zero matches | ✓ PASS |
| Reference worktree availability | `Test-Path C:\Users\User\Documents\Projects\GNUS-compare\GeniusWallet-3514` | present; `Release\genius_wallet.exe` built | ✓ AVAILABLE (was ? SKIP) |
| Project compiles / analyze delta | `flutter analyze lib` | **61 issues, 0 new** — baseline held. **CORRECTED 2026-07-21:** an earlier revision of this row said the toolchain "could not be located". That was wrong. Flutter **3.41.9 / Dart 3.11.5** is installed at `C:\Users\User\Documents\Projects\GNUS\flutter\flutter\bin\flutter.bat` (the GeniusVentures thirdparty submodule checkout) — it is simply not on `PATH`, and it sits one level deeper than the depth-4 sweep that "found" nothing reached. The search was too shallow; the conclusion drawn from it was not warranted. Re-run during quick task `260721-d5s`. | ✓ PASS (gate only) |
| Pull-to-refresh reloads (tx, news) | — | no harness; requires a run | ? SKIP → human |
| Forced-failure retry | — | no harness; requires a run | ? SKIP → human |
| Release-build chart bottom edge | — | requires a release build | ? SKIP → human |

**On the analyze gate.** The 07-20 report recorded 61 issues / 0 errors with a zero Phase-5 delta on the macOS box. This report initially claimed that figure was not re-derivable here because the toolchain was missing — **that claim was wrong and has been corrected above.** Flutter 3.41.9 is installed at `Documents\Projects\GNUS\flutter\flutter\bin`, off `PATH` and one level below the depth-4 search that reported nothing. Re-run on Windows during `260721-d5s`: **61 issues, unchanged.** It remains a gate, not evidence.

> **A note on that mistake, because it is the third of its kind today.** "I searched and found nothing" was written up as "the toolchain is unavailable," and a real capability was recorded as absent for several hours. The same shape produced the other two: a UI-SPEC file count that balanced only because two errors cancelled, and a §6 "conflict" that existed only in a second-hand summary of §6. In each case a stated conclusion outran the evidence actually gathered. The cheap defence is the same every time — re-derive the number, or read the source, before writing it down as fact.

## Gaps Summary

Phase 5 has closed every gap this report has ever carried **except one**, and that one is a
brand-new site discovered in the very walk that closed the rest.

**Everything that was open at the 12:00Z pass today is now resolved and walked.** Plan `05-08`
closed **B1** (`WalletsOverview`'s unscrollable Column, overflowing its SGNUS-wallet branch) and
**B2** (the Markets error/empty branches losing their card) — both structurally fixed, both made
reachable for the first time by dev-bubble fixtures built for exactly that purpose, and both walked
and approved in the same session. The outstanding `260721-e3r` re-walk (`GWEmptyState`'s adaptive
compact tier) was folded into that same Task 4 checklist rather than left as a second, competing
one, and it too is now walked and approved — the Assets empty-state regression gate held. The
dashboard-retry criterion (ROADMAP criterion 3), closed by `05-07` in an earlier session, remains
resolved and walked; its own "conflict" with UI-SPEC §6 was previously shown to be illusory (§6
locks the string, not the presence of a retry beside it) — restated here only because this
report's own prose had drifted stale on that point in an earlier pass.

**One new gap survives, and it is the reason criterion 5 stays FAILED.** The same 2026-07-21 walk
that confirmed WalletsOverview and `GWEmptyState` clean surfaced a **third, distinct** RenderFlex
overflow: `crypto_live_chart.dart:315`'s zoom/pan `IconButton` row, 34px, on the plain dashboard
with no fixture armed. It is not a regression of anything closed above — both of this walk's own
sites logged zero overflow — and not a reappearance of the already-fixed 6.3px chart overflow at
the old `:206`. Plan `05-08`'s file scope never included `crypto_live_chart.dart`, so this is
correctly out of that plan's accountability, but it is squarely inside ROADMAP criterion 5's
"no RenderFlex overflow" and blocks Phase 5 sign-off regardless of which future plan fixes it. It
is filed with three candidate directions, the leading one being a product decision (does zoom/pan
survive once real timeframe ranges are wired?) that would close this finding, the raw-`Colors.white`
finding, and a redundancy question all at once.

**Two items remain walk-only, not code gaps.** Criterion 1's "match the Release exe" clause has
still never been tested side by side (the reference exe is present and buildable on this machine;
see the filed todo). And the release-build chart-edge check remains open for BOTH the old 6.3px
site and the new 34px site: uhe's guard and the new overflow have only been observed in debug,
which clips visibly where release clips silently.

**The finding that outlived the last report is still alive.** UI-SPEC §3.1 still carries the
1.96:1 pairing. 05-02 measured it, fixed it in code, and asked twice for the source to be
corrected. It was not, and the same white-on-bright-brand-fill defect then reappeared on the
transaction badge by a different route — the very gap this re-verification just closed for the
second time. It will return a third time unless the contract itself is edited. That is a
five-minute change and it is the highest-leverage item in this report.

**One structural lesson stands unchanged** from the 07-20 report and is worth restating, because
this re-run is itself an instance of it: quick tasks landing after a plan's walk can undo that
plan's verified deliverables, and nothing in the current process re-checks the plan's own
done-criteria afterwards. k81 did exactly that to 05-06. It was caught only because a verifier
ran afterwards.

---

## Phase Closure (2026-07-21, post-verification)

**Phase 5 is closed as of 2026-07-21** on explicit user authorization, with the three items above
recorded as overrides (see frontmatter `overrides:` and `## Acknowledged Gaps`). The user inspected
the Bitcoin Chart card live, confirmed the criterion-5 overflow is a genuine card-height limitation
at the app's current window size (not a component defect), explicitly rejected the considered
stopgap (`260721-gx1`) as merely cosmetic, and directed that Phase 5 close with the gap recorded
honestly rather than hidden or patched over. Two follow-ups were filed as a direct result:
`.planning/todos/pending/2026-07-21-bitcoin-chart-card-height-dashboard-vertical-budget.md` (new —
the actual root cause) and the existing chart zoom/pan todo was updated in place to record the
override. The quick task `260721-gx1` (the stopgap plan) was abandoned, not executed; see its
`260721-gx1-SUMMARY.md`. Phase advances to Phase 6 (Onboarding) per ROADMAP.md / STATE.md.

---

_Re-verified: 2026-07-21 — supersedes 2026-07-20T21:15:00Z_
_Verifier: Claude (Opus 4.8), goal-backward, code-level re-derivation at HEAD; no walk performed_
_Closed: 2026-07-21 — status flipped `gaps_found` → `passed` with 3 recorded overrides, all authorized by the user directly; see `## Acknowledged Gaps`_
