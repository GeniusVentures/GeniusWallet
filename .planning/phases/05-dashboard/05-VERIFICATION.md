---
phase: 05-dashboard
verified: 2026-07-21T00:00:00Z
status: gaps_found
score: 2/5 must-haves verified
behavior_unverified: 2
overrides_applied: 0
reverification_of: 2026-07-20T21:15:00Z
reverification_reason: >-
  The 2026-07-20 report was taken at baseline `7a95e68`, which did NOT contain the
  seven approved-but-uncommitted quick tasks. PR #210 merged them (`0bcf3df`), so two
  of that report's three gaps were measured against code that no longer exists. This
  re-verification re-derives all five criteria against the merged HEAD.
gaps:
  - truth: "When wallet or account load fails the dashboard shows an error message with a working retry — never an endless spinner — and the hero balance does not render before the account has loaded (findings 8, 9, 29)"
    status: failed
    reason: >-
      UNCHANGED from the 2026-07-20 report — the merge did not touch this branch.
      Findings 9 and 29 remain verified in code and the "never an endless spinner"
      clause is met. The "with a working retry" clause is still NOT met: the
      dashboard's failure branch is a bare `Center(child: Text('Something went
      wrong!'))` with no retry affordance and no RefreshIndicator (the error branch
      returns instead of, not alongside, OneColumnDashBoardView / ResponsiveDashboardView).
      A user whose account load fails has no in-app recovery short of restarting.
      This is develop's pre-existing behavior, deliberately locked by UI-SPEC §6 ("do
      not reconcile these"), so the phase met its own goal clause ("keeps every
      behavior develop shipped") while missing the roadmap's. Separately, the retry
      that DOES exist (finding 8, markets) has still never been exercised.
      **This gap is a DECISION, not code.** The roadmap criterion and UI-SPEC §6 are
      in direct conflict; no amount of implementation resolves that without a ruling
      on which document wins.
    artifacts:
      - path: "lib/dashboard/home/view/dashboard_screen.dart"
        issue: "Line 70 — error branch returns a retry-less `Center(child: Text('Something went wrong!'))`; no recovery path."
    missing:
      - "A ruling: either add a retry affordance to the dashboard failure branch (overriding UI-SPEC §6's lock), or record an override stating §6 intentionally descoped it and reword ROADMAP criterion 3."
      - "One forced-failure observation proving a retry press actually re-issues the fetch (markets leg, finding 8)."
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
      Force a market-data fetch failure (offline, or block api.coingecko.com) and press
      the retry button that FutureStateWidget appends.
    expected: "The fetch is re-issued and the grid populates on success."
    why_human: >-
      Never exercised by any walk. 05-01's D3 says so explicitly; 05-04's D3 marks the
      step NOT YET PERFORMED while still carrying status: pass.
  - test: >-
      Open the dashboard at a normal window height in a RELEASE build and inspect the
      Bitcoin Chart card's bottom edge.
    expected: "No clipped content, no striped overflow marker."
    why_human: >-
      Release silently clips where debug paints stripes. uhe's guard was walked in debug
      and approved; dws then rewrote the file. Only a human comparing debug vs release
      can tell whether real content is being lost.
  - test: >-
      Walk the Bitcoin Chart card and the zoom/pan control row in LIGHT mode.
    expected: "The zoom/pan icons are legible against the card surface."
    why_human: "Four raw Colors.white icons survive; the light pass is deferred and unwalked."
---

# Phase 5: Dashboard Verification Report (re-verification)

**Phase Goal:** The dashboard wears the redesign and keeps every behavior develop shipped
**Verified:** 2026-07-21
**Status:** gaps_found — 1 open gap (a decision), 5 human-walk items
**Re-verification:** Yes — supersedes the 2026-07-20T21:15Z report
**Verified at:** `ui-redesign-port` @ `93f77d3` (code content from `0bcf3df`, merged as PR #210 / `a34d1f1`)
**Previously verified at:** `7a95e68` — a baseline that predates the merge

> **Why this re-run exists.** The 2026-07-20 report was written while seven walked-and-approved
> quick tasks were still sitting uncommitted in the working tree behind the CLAUDE.md gate. The
> verifier correctly measured the committed baseline `7a95e68` — but that baseline did not
> contain the fixes. Two of its three gaps were therefore measured against code that no longer
> exists at HEAD. Nothing in the original report was wrong when written; it simply expired the
> moment PR #210 merged.

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
| 1 | Balances, holdings, transactions, markets and news all render in the redesign skin and match the Release exe at `GeniusWallet-3514` | ⚠️ PARTIAL (was ✗ FAILED) | **Clause 1 now clean.** The k81 badge regression that failed this criterion is gone — `transaction_displays.dart:90,97` are back on `textOnBrand`. All five surfaces are re-skinned and walked. **Clause 2 still unevidenced** but no longer blocked: the reference Release exe IS present on this machine. Downgraded from FAILED to PARTIAL because the code defect is resolved and only a walk remains. |
| 2 | Pull-to-refresh works on the dashboard, the transactions list and the news feed, and each reloads its data (findings 10, 17, 18) | ⚠️ PRESENT_BEHAVIOR_UNVERIFIED (unchanged) | All three re-confirmed wired at HEAD: `dashboard_screen.dart:231`, `transactions_screen.dart:16-18` (`WalletDetailsCubit.getCoins()`), `crypto_news_screen.dart:72`. Dashboard leg directly observed (05-01 walk). Transactions and news legs still rest on walk claims, not observation. |
| 3 | Dashboard shows an error message with a working retry — never an endless spinner — and the hero balance does not render before the account has loaded (findings 8, 9, 29) | ✗ FAILED (unchanged) | Findings 9 and 29 verified; "never an endless spinner" met. **"Working retry" still not met** — `dashboard_screen.dart:70` is a bare retry-less `Text`. The merge did not touch this branch. **See the one open Gap.** |
| 4 | Market data refreshes once a minute, not every 20 seconds (finding 14) | ✓ VERIFIED | `Timer.periodic(const Duration(minutes: 1), ...)` at `lib/components/coins/view/coins_screen.dart:55` (line moved from `:47` by the vwj Assets redesign; the constant is unchanged). Single unambiguous constant. Behaviourally corroborated by 05-01's CoinGecko 429. |
| 5 | Walking the dashboard with long values, empty symbols and a filtered transaction list produces no RenderFlex overflow and no crash, and the transaction count footer is present (findings 30, 31, 32, 33, 34) | ⚠️ PARTIAL (was ✗ FAILED) | Count footer re-confirmed: `"Transactions: ${txs.length}"` at `transactions_slim_view.dart:160` (moved from `:141` by baz's GWSectionTitle unification). Findings 30–34 still present. **The 6.3px overflow that failed this criterion is code-mitigated** by uhe's compact-mode guard + assert, walked and approved in both modes; dws's glow is deliberately layout-neutral. Not promoted to VERIFIED — the release-build bottom-edge check has never been done, and dws rewrote the file after uhe's walk. |

**Score:** 2/5 truths verified — was 1/5.
Breakdown: 1 verified outright (C4), 1 verified-with-walk-pending (C5), 2 partial/behavior-unverified (C1, C2), 1 failed (C3).

### What Changed Since 2026-07-20

| Item | 07-20 status | HEAD status | Cause |
|------|-------------|-------------|-------|
| Badge contrast (`transaction_displays.dart`) | Gap 1 — FAILED, 1.42:1 | **Resolved**, `textOnBrand` restored | Merge of the approved batch |
| 6.3px RenderFlex overflow | Gap 3 — FAILED, confirmed open | **Code-mitigated**, walk pending | `260720-uhe` guard + assert (was uncommitted at 07-20) |
| Dashboard retry | Gap 2 — PARTIAL | **Unchanged, still open** | Untouched by the merge; needs a ruling |
| Chart skin | Deferred wholly to Phase 7, 8 raw values | **Largely delivered in Phase 5**, 4 raw values left | `260721-dws` (sketch 006 A→) |
| Reference Release exe | "absent from this machine" | **Present** on the Windows box | Different machine, not a code change |
| UI-SPEC §3.1's 1.96:1 pairing | Flagged as the finding that should outlive the report | **Still uncorrected** | Nobody has edited the contract |

### Required Artifacts (re-checked at HEAD)

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `lib/dashboard/home/widgets/transaction_displays.dart` | Overflow guards + no raw colors | ✓ VERIFIED (was ⚠️ REGRESSED) | Badge border `:90` and icon `:97` both `GeniusWalletColors.textOnBrand`; zero `Colors.white` in file |
| `lib/dashboard/home/view/dashboard_screen.dart` | Gate/refresh/getCoins intact | ⚠️ PARTIAL | `RefreshIndicator` `:231` intact; error branch `:70` still retry-less |
| `lib/components/coins/view/coins_screen.dart` | Holdings re-skin, 60s timer intact | ✓ VERIFIED | `Duration(minutes: 1)` `:55` |
| `lib/dashboard/home/widgets/transactions_slim_view.dart` | Count footer kept | ✓ VERIFIED | `:160` verbatim |
| `lib/dashboard/transactions/transactions_screen.dart` | Refresh wiring intact | ✓ VERIFIED | `:16-18` `getCoins()` |
| `lib/dashboard/news/view/crypto_news_screen.dart` | Refresh wiring intact | ✓ VERIFIED | `:72` |
| `lib/chart/crypto_live_chart.dart` | (was: not in any plan's scope) | ⚠️ RE-SKINNED, 4 raw whites | Compact guard `:217-230`; layout-neutral glow `:241`; zoom/pan icons still `Colors.white` `:455,463,471,480` |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Badge contrast (WCAG 2.x relative luminance) | `textOnBrand` `#000B18` vs brandGreen / lightBlueAccent / statusError | 13.97:1 / 9.95:1 / 6.05:1 | ✓ PASS (was ✗ FAIL) |
| Raw-color census, `crypto_live_chart.dart` | `grep -nE "Colors\.(white\|grey\|black\|red\|green)"` | 4 matches, all `Colors.white` on zoom/pan icons | ⚠️ PARTIAL |
| Raw-color census, `transaction_displays.dart` | `grep -n "Colors.white"` | zero matches | ✓ PASS |
| Reference worktree availability | `Test-Path C:\Users\User\Documents\Projects\GNUS-compare\GeniusWallet-3514` | present; `Release\genius_wallet.exe` built | ✓ AVAILABLE (was ? SKIP) |
| Project compiles / analyze delta | `flutter analyze lib` | **NOT RUN — Flutter is not installed on this Windows machine** (searched PATH, `%LOCALAPPDATA%`, `C:\flutter`, `C:\src\flutter`, fvm, and a depth-4 sweep of `C:\Users\User`) | ? UNAVAILABLE |
| Pull-to-refresh reloads (tx, news) | — | no harness; requires a run | ? SKIP → human |
| Forced-failure retry | — | no harness; requires a run | ? SKIP → human |
| Release-build chart bottom edge | — | requires a release build | ? SKIP → human |

**On the missing analyze gate.** The 07-20 report recorded 61 issues / 0 errors with a zero Phase-5 delta, run on the macOS box. That figure is not re-derivable here. It is a gate, not evidence, and every code claim in this report comes from reading files at HEAD rather than from analyze — but the gate should be re-run on a machine that has Flutter before the phase is signed off.

## Gaps Summary

Phase 5 is in materially better shape than the 07-20 report reflects, and the difference is
almost entirely an artifact of *when* that report was taken. Two of its three gaps were fixed by
work that existed, was walked, and was approved — but was sitting uncommitted behind the commit
gate at the moment of measurement. Merging PR #210 did not fix anything new; it made already-done
fixes visible to the verifier.

**One gap survives, and it is not a code problem.** ROADMAP criterion 3 requires "a working
retry" on the dashboard failure branch. UI-SPEC §6 explicitly locks develop's error string and
forbids reconciling it to `GWErrorState`. The phase goal — "keeps every behavior develop shipped"
— sides with §6. These two documents cannot both be satisfied, and the phase honoured the one it
was written against. Implementing a retry would close the criterion and violate the spec;
recording an override would close the spec and require rewording the criterion. Either is
defensible. Neither is mine to choose.

**Two items are newly walkable rather than newly broken.** Criterion 1's "match the Release exe"
clause has never been tested, and the 07-20 report attributed that to the reference being absent —
correct for the macOS session, wrong for this machine, where the built Release exe is on disk. And
the release-build chart-edge check remains the honest reason criterion 5 is not promoted to a
clean pass: uhe's guard was walked in debug, dws rewrote the file afterwards, and release clips
where debug stripes.

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

_Re-verified: 2026-07-21 — supersedes 2026-07-20T21:15:00Z_
_Verifier: Claude (Opus 4.8), goal-backward, code-level re-derivation at HEAD; no walk performed_
