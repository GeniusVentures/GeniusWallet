---
phase: 05-dashboard
verified: 2026-07-21T12:00:00Z
status: gaps_found
score: 3/5 must-haves verified (criterion 3 closed by 05-07 and walked; criterion 5 newly FAILED on a live defect)
behavior_unverified: 2
overrides_applied: 0
reverification_of: 2026-07-20T21:15:00Z
reverification_reason: >-
  The 2026-07-20 report was taken at baseline `7a95e68`, which did NOT contain the
  seven approved-but-uncommitted quick tasks. PR #210 merged them (`0bcf3df`), so two
  of that report's three gaps were measured against code that no longer exists. This
  re-verification re-derives all five criteria against the merged HEAD.
gaps:
  - truth: "Walking the dashboard with long values, empty symbols and a filtered transaction list produces no RenderFlex overflow and no crash, and the transaction count footer is present (findings 30, 31, 32, 33, 34)"
    status: failed
    discovered: 2026-07-21
    reason: >-
      NEW defect, observed live on the first Windows debug run of this branch and confirmed
      visually by the user — not a regression of the previously-reported 6.3px chart overflow,
      which is genuinely fixed. `GWEmptyState`'s Column (`gw_empty_state.dart:32`) overflows its
      slot inside `TransactionsSlimView` by 19px on first layout and 34px on a later pass.
      Creator chain: Column <- Padding <- Center <- GWEmptyState <- Expanded <- Column <-
      ConstrainedBox <- TransactionsSlimView <- BlocListener<TransactionsCubit,...>. Constraints
      are `h<=125.0`; the content needs roughly 144. `mainAxisSize: min` is already set, so the
      content genuinely does not fit.
      It fires on an EMPTY WALLET at default window size — the fresh-install state, and the
      first screen a new user sees. Every prior dashboard walk used the `cw8`/`jvr` mock
      injectors to get a populated wallet, and a populated transactions list renders rows rather
      than `GWEmptyState`, so the overflowing widget was never on screen during any walk. The
      fixtures that made walking possible also made one entire state invisible.
    artifacts:
      - path: "lib/components/feedback/gw_empty_state.dart"
        issue: "Line 32 — Column overflows by 19px/34px when given a 125px slot; needs ~144."
      - path: "lib/dashboard/home/widgets/transactions_slim_view.dart"
        issue: "The ConstrainedBox that caps the panel and leaves GWEmptyState 125px."
    missing:
      - "A diagnosed fix — see `.planning/todos/pending/2026-07-21-gwemptystate-overflows-in-transactions-slim-view.md` for the three candidate directions and why 'just clip it' is the worst of them."
      - "Re-walk in BOTH appearance modes and at more than one window height (the 19/34 pair suggests the deficit varies with available space), plus a release build — release clips silently where debug paints stripes."
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
| 3 | Dashboard shows an error message with a working retry — never an endless spinner — and the hero balance does not render before the account has loaded (findings 8, 9, 29) | ✓ **VERIFIED** (was ✗ FAILED) | Closed by plan **05-07** (`64fa92d`) and **walked & approved 2026-07-21 in both appearance modes**. A `GWButton` "Retry" now sits beside the byte-for-byte-preserved `'Something went wrong!'`, dispatching `FetchAccount()` **and** the shared reload — both gating statuses, not just one. Walk observed: fault armed → error branch rendered → Retry pressed → dashboard fully recovered. Finding 8's markets retry also exercised and approved (Part B), closing the "never exercised by any walk" gap. **No override was recorded and the criterion was not reworded** — see the note below on why the §6 conflict was illusory. |
| 4 | Market data refreshes once a minute, not every 20 seconds (finding 14) | ✓ VERIFIED | `Timer.periodic(const Duration(minutes: 1), ...)` at `lib/components/coins/view/coins_screen.dart:55` (line moved from `:47` by the vwj Assets redesign; the constant is unchanged). Single unambiguous constant. Behaviourally corroborated by 05-01's CoinGecko 429. |
| 5 | Walking the dashboard with long values, empty symbols and a filtered transaction list produces no RenderFlex overflow and no crash, and the transaction count footer is present (findings 30, 31, 32, 33, 34) | ✗ **FAILED — new, live defect** | Count footer re-confirmed at `transactions_slim_view.dart:160`; findings 30–34 present; the old 6.3px chart overflow is genuinely fixed (uhe's guard, walked). **But a NEW RenderFlex overflow was observed live on 2026-07-21** and confirmed visually by the user: `GWEmptyState` inside `TransactionsSlimView` overflows by **19px then 34px** on an **empty wallet at default window size** — the fresh-install state. `gw_empty_state.dart:32`, constraints `h<=125.0`, content needs ~144. See the gap below. |

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
| Project compiles / analyze delta | `flutter analyze lib` | **61 issues, 0 new** — baseline held. **CORRECTED 2026-07-21:** an earlier revision of this row said the toolchain "could not be located". That was wrong. Flutter **3.41.9 / Dart 3.11.5** is installed at `C:\Users\User\Documents\Projects\GNUS\flutter\flutter\bin\flutter.bat` (the GeniusVentures thirdparty submodule checkout) — it is simply not on `PATH`, and it sits one level deeper than the depth-4 sweep that "found" nothing reached. The search was too shallow; the conclusion drawn from it was not warranted. Re-run during quick task `260721-d5s`. | ✓ PASS (gate only) |
| Pull-to-refresh reloads (tx, news) | — | no harness; requires a run | ? SKIP → human |
| Forced-failure retry | — | no harness; requires a run | ? SKIP → human |
| Release-build chart bottom edge | — | requires a release build | ? SKIP → human |

**On the analyze gate.** The 07-20 report recorded 61 issues / 0 errors with a zero Phase-5 delta on the macOS box. This report initially claimed that figure was not re-derivable here because the toolchain was missing — **that claim was wrong and has been corrected above.** Flutter 3.41.9 is installed at `Documents\Projects\GNUS\flutter\flutter\bin`, off `PATH` and one level below the depth-4 search that reported nothing. Re-run on Windows during `260721-d5s`: **61 issues, unchanged.** It remains a gate, not evidence.

> **A note on that mistake, because it is the third of its kind today.** "I searched and found nothing" was written up as "the toolchain is unavailable," and a real capability was recorded as absent for several hours. The same shape produced the other two: a UI-SPEC file count that balanced only because two errors cancelled, and a §6 "conflict" that existed only in a second-hand summary of §6. In each case a stated conclusion outran the evidence actually gathered. The cheap defence is the same every time — re-derive the number, or read the source, before writing it down as fact.

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
