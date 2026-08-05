# 23-05 Extraction Audit

Re-run at execution time, 2026-07-30, against the tree as it stands after 23-01..23-04 and the
independent hover-row work in `ccee5e4`. Every verdict below is a fresh measurement, not a copy of
the planning-time text. Where the tree has moved since planning, that is called out explicitly.

Baseline entering this task: `flutter analyze --no-pub` 0 issues; `flutter test --no-pub` 718/0.

## Candidate: GWHoverable — EXTRACT (confirmed)

**Re-run measurement.** `git grep -n 'bool _hovered' -- '*.dart'` returns **13** declarations
across **11** files, not the 9 the context doc's older figure cited and not the 12 sites this
plan's own file list names:

| # | File | Line | Consumer(s) |
|---|------|------|-------------|
| 1 | `lib/components/cards/gw_card.dart` | 179 | `_HoverLiftCard` (internal to `GWCard`) |
| 2 | `lib/components/cards/gw_select_row.dart` | 90 | `GWSelectRow` |
| 3 | `lib/components/cards/gw_view_all_link.dart` | 33 | `GWViewAllLink` |
| 4 | `lib/components/data/gw_copy_row.dart` | 70 | `GWCopyRow` |
| 5 | `lib/components/gw_timeframe_segment.dart` | 118 | `_TimeframeTab` (internal to `GWTimeframeSegment`) |
| 6 | `lib/dashboard/chart/markets_hero_card.dart` | 699 | private `_TimeframeTab` (markets' own copy) |
| 7 | `lib/dashboard/home/widgets/transaction_displays.dart` | 556 | `_CopyRow` |
| 8 | `lib/dashboard/home/widgets/transactions_slim_view.dart` | 790 | `_FilterChip` |
| 9 | `lib/dashboard/home/widgets/transactions_slim_view.dart` | 968 | `_RailRow` |
| 10 | `lib/squid_router/swap_field.dart` | 394 | `_Hoverable` (the shim itself; two consumers inside the same file) |
| 11 | `lib/squid_router/swap_settings_drawer.dart` | 361 | `_PresetChip` |
| 12 | `lib/tokens/token_info_screen.dart` | 1033 | `_CopyAddressRow` |
| 13 | `lib/tokens/token_info_screen.dart` | 1100 | `_BackToMarkets` |

**Why the count differs from the plan's twelve-site list:** the plan's Task 3 file list carries
`lib/dashboard/home/view/dashboard_screen.dart` as a site (~747, ~761). It is no longer one — see
the GWTimeframeSegment finding below; that file's own hover boolean was already deleted when
`GWTimeframeSegment` was promoted out of it. Two sites the plan's list does **not** name —
`lib/components/data/gw_copy_row.dart:70` and `lib/components/gw_timeframe_segment.dart:118` —
were created by other work after this plan was written and carry the identical pattern (a
`MouseRegion` + boolean field + `setState` pair, reacted to by a builder-shaped child). Per the
plan's own environment note ("If a site does not fit the builder shape, leave it alone... An
outlier is cheaper as duplication than a flag" and the instruction that these two are "legitimate
migration targets if they fit the builder shape"), both are added to Task 3's scope. Net: 12
planned − 1 (dashboard_screen, already gone) + 2 (newly discovered) = **13**, confirming the
Rule-of-Three floor by a wide margin.

**Exclusions confirmed by reading, not by assumption:**
- `lib/chart/crypto_live_chart.dart:323` — `MouseRegion(onExit: _onHoverExit, child: ...)`. No
  `onEnter`, no boolean field; it clears a hovered **price** value that is set by
  `LineTouchData`'s touch callbacks elsewhere in the same widget, not by pointer enter/exit. Not
  this pattern. Excluded.
- `lib/web/web_view_mobile.dart:374` — `int? _hoveredTabIndex`. Tracks which of several tabs is
  hovered by **index**, not a boolean flag. A different shape entirely (`GWHoverable`'s builder
  takes no discriminator). Excluded.

**Verdict: EXTRACT.** Confirmed. `lib/squid_router/swap_field.dart`'s private `_Hoverable` is
promoted verbatim into `lib/components/effects/gw_hoverable.dart` as `GWHoverable` (AGENTS.md rung
4 — an existing shim, not an invented abstraction).

---

## Candidate: GWTimeframeSegment — REFUSE (confirmed, premise re-measured and updated)

**Re-run measurement, corrected from the planning-time claim.** The planning-time text (and the
dispatch note handed to this execution) both describe the current state as "the two timeframe
copies have already been unified." That is **not what the tree shows.** `git grep -n
'GWTimeframeSegment\('` finds exactly two call sites:

```
lib/chart/crypto_live_chart.dart:638:            const GWTimeframeSegment(),
lib/dashboard/home/view/dashboard_screen.dart:592:          children: [_CoinIdentity(), GWTimeframeSegment()],
```

`lib/dashboard/chart/markets_hero_card.dart:204` still instantiates its **own** private
`const _TimeframeSegment()` (defined at `markets_hero_card.dart:627-675`), which is a *third*,
independent copy of the same visual shape — not `GWTimeframeSegment`. So the state is: the
dashboard/coin-page pair **was** unified (that is what `GWTimeframeSegment`'s own doc comment
describes: "extracted from `dashboard_screen.dart`'s private `_TimeframeSegment`... now the THIRD
occurrence... dashboard, the coin-page/dashboard chart header, and — before this extraction — a
second, differently labelled copy on the Markets hero"). The Markets hero copy was **deliberately
not folded in** — `gw_timeframe_segment.dart:27-30` says so explicitly: *"The Markets hero card
keeps its OWN 24H/7D/30D/1Y segment and is NOT folded into this one here."*

**The diff, re-run against the two live copies (`GWTimeframeSegment`'s `_TimeframeTab`/track vs.
`markets_hero_card.dart`'s private `_TimeframeSegment`/`_TimeframeTab`):**

| Property | `GWTimeframeSegment` (dashboard + coin page) | `markets_hero_card._TimeframeSegment` (Markets hero) |
|---|---|---|
| Labels | `1H · 1D · 1W · 1M · 1Y` (5) | `24H · 7D · 30D · 1Y` (4) |
| Track fill | `gw.surfaceSunken` (recessed well — the documented "Control track" standard, per `.planning/codebase/CONVENTIONS.md`) | `gw.surfaceMenu` (raised chip) |
| Track border | `Border.all(color: gw.borderSubtle)` — **present** | `Border.all(color: gw.borderSubtle)` — **present** |
| Tab geometry / hover / selected gradient | identical (`_TimeframeTab`, byte-for-byte duplicated class) | identical |

**Correction to the planning-time claim:** the border was described at planning time as "present
in one copy and absent in the other." Re-measured: **both copies now carry the hairline border.**
That divergence has closed since planning — only the track fill colour and the label set still
differ. The control-track colour divergence is real and is the live finding below; the border
finding no longer holds and is recorded as closed, not inherited.

**Verdict: REFUSE**, on the diff actually run today, not on the plan's inherited "not the same
premise" framing — the two controls are not character-identical (different label sets, different
track fill), so folding them would either drop a domain each screen currently expresses (5
dashboard ranges vs. 4 market ranges) or force a parameter to reconcile them, which is exactly the
condition AGENTS.md's Rule of Three names as disqualifying ("if the shared version needs a boolean
flag to serve both callers... do not extract it"). This is a **different** refusal reason than the
one planning anticipated (planning expected a false "character-identical" claim to refute; the
live divergence is smaller — a colour and a label set — but the conclusion is the same).

**Finding, not fixed here:** the track-fill divergence (`surfaceSunken` vs. `surfaceMenu`) is a
real design-system inconsistency against `.planning/codebase/CONVENTIONS.md`'s own documented
"Control track" standard — `GWTimeframeSegment`'s track (`surfaceSunken`) is named as the standard
in that doc; the Markets hero copy (`surfaceMenu`) contradicts it. `gw_timeframe_segment.dart:27-30`
and `markets_hero_card.dart:645` both already point at
`.planning/todos/pending/2026-07-24-unify-timeframe-segment-component.md` as the tracked follow-up.
Confirmed that file still exists and still describes exactly this gap. Not repainting it here — a
repaint with nothing in this plan to justify it is exactly the mistake the plan's own environment
section warns against ("fixing it repaints a control with nothing to prove the repaint is right").

**Addendum — this candidate does supply one legitimate `GWHoverable` migration target.**
`gw_timeframe_segment.dart`'s own `_TimeframeTab._hovered` (line 118) is the identical
boolean-hover-builder pattern `GWHoverable` exists to collapse, and is migrated in Task 3 Batch B.
Refusing the *timeframe-unification* extraction does not refuse the *hover-plumbing* migration —
they are different axes (screen-level widget identity vs. this plan's actual scope, hover-state
plumbing).

---

## Candidate: GWCopyRow — REFUSE the extraction as an invention; premise has shifted, not resolved

**Re-run measurement.** Planning measured **two** forked copy-row widgets. Re-measuring today finds
**three** total occurrences of the label/value/copy-glyph/hover shape in the tree, because a third
one was built by unrelated work between planning and this execution:

1. `lib/components/data/gw_copy_row.dart` — a **real, already-extracted** `GWCopyRow` widget.
   Its own doc comment (`gw_copy_row.dart:13-28`) explains its origin: *"a Phase 23 previously
   refused, now approved on a changed premise"* — created for a bridge-hash row (Phase 14 plan 06),
   which was the genuine third occurrence that crossed the Rule-of-Three floor **at that time**, in
   that plan's own scope. It is consumed today by `lib/submit_job/view/widgets/job_steps.dart` and
   pinned by `test/components/gw_copy_row_test.dart`.
2. `lib/dashboard/home/widgets/transaction_displays.dart`'s private `_CopyRow` (line 542-619) —
   still a separate, unmigrated fork.
3. `lib/tokens/token_info_screen.dart`'s private `_CopyAddressRow` (line 1015-1084) — still a
   separate, unmigrated fork.

**What this plan does and does not do about it.** `GWCopyRow`'s own doc is explicit that migrating
the two remaining forks onto it is deliberately **out of scope for the phase that built it** — *"The
two existing forks are NOT migrated onto this widget here — that is Phase 7's file
(`transaction_displays.dart`) and Phase 23's own file (`token_info_screen.dart`), both out of this
phase's fence, and each is a zero-repaint follow-up."* This plan (23-05) is scoped to the
`GWHoverable` hover-pattern extraction (Task 3's file list), not to a copy-row consolidation — no
task in this plan names `GWCopyRow` migration as work to do. Doing that migration now would be an
unplanned, out-of-fence change under this plan's own acceptance criteria (§verification item 9
requires `GWCopyRow` to **not exist** as something this plan produced — it already exists,
independently, satisfying that item by construction rather than by omission).

**Verdict: REFUSE** (this plan does not build or extend `GWCopyRow`) — but note explicitly that the
Rule-of-Three premise for the *component itself* has changed since the original planning-time
REFUSE: three occurrences of the shape now exist in the tree, above the floor. The two-occurrence
REFUSE this plan inherited no longer describes the current state; it is replaced by a scoping
REFUSE (out of this plan's fence) rather than a floor REFUSE (below three). **Finding for a future
plan:** migrating `transaction_displays._CopyRow` and `token_info_screen._CopyAddressRow` onto the
existing `GWCopyRow` is now a legitimate zero-repaint follow-up (same shape confirmed by reading
both: label, truncated-mono value, copy glyph, hover, `showAppSnackBar` confirmation), consistent
with `GWCopyRow`'s own doc comment naming exactly those two files as its deferred consumers. No
pending todo currently exists for this (checked `.planning/todos/pending/` — none found); this
audit is the record until one is filed.

**Two extra copy-row-shaped hover sites this plan's migration DOES touch (Task 3):**
`gw_copy_row.dart:70` and `transaction_displays.dart:556`/`token_info_screen.dart:1033` all carry
the `bool _hovered` pattern independent of whether the surrounding row component is ever unified —
these are migrated onto `GWHoverable` in Task 3 regardless of the copy-row consolidation question,
because the hover-plumbing axis and the row-identity axis are orthogonal.

### Clipboard security audit — every `Clipboard.setData` site, per-site verdict

`git grep -n 'Clipboard.setData'` (excluding generated files) finds 10 write sites. Each is
evaluated for: (a) whether the **full** value is written, never a truncated display form, and (b)
whether anything about the copied value is logged, printed, or sent to telemetry.

| # | File:line | What is copied | Full value? | Logged? | Verdict |
|---|-----------|-----------------|:---:|:---:|---|
| 1 | `lib/account/account_drawer.dart:296` | `wallet.address` | Yes — raw field, no truncation applied before copy | No | PASS |
| 2 | `lib/account/sdk_account_manager.dart:332` | `mnemonic` (seed phrase) | Yes | No | PASS — additionally the **only** copy site in the app gated behind an explicit confirmation dialog naming the risk ("Anyone who reads your clipboard gets full control of this account"); the correct treatment for the one truly dangerous value in this list |
| 3 | `lib/banxa/checkout_qr.dart:164` | `checkoutUrl` | Yes — the on-screen text at line 150 is separately truncated (`${checkoutUrl.substring(0,50)}...`) for **display only**; the copy call at 164 reads the untruncated `checkoutUrl` variable | No | PASS |
| 4 | `lib/banxa/handle_banxa_drawer.dart:128` | `checkoutUrl` | Yes | No | PASS |
| 5 | `lib/components/data/gw_copy_row.dart:101` | `widget.value` | Yes — component's own doc pins this as the audited security property; `_displayValue` (truncated) is never the copy source | No | PASS |
| 6 | `lib/components/qr/crypto_address_qr.dart:38` | `widget.address` | Yes — `_shortAddress()` is a display-only helper, not read by the copy call | No | PASS |
| 7 | `lib/dashboard/home/widgets/transaction_displays.dart:574` | `widget.value` (via `_CopyRow`, fed by `addCopy(...)`'s `value.trim()`) | Yes — `.trim()` only strips whitespace, not characters from the value | No | PASS |
| 8 | `lib/logs/submit_logs_screen.dart:242` | `eventId` (a Sentry error-report reference id, not a secret) | Yes | No | PASS |
| 9 | `lib/tokens/token_info_screen.dart:1051` | `a` (= `widget.address`) | Yes — `short` (the truncated display form) is a separate local, never passed to `Clipboard.setData` | No | PASS |
| 10 | `lib/web/web_view_windows.dart:79` | `''` (empty string — this is the **clears the clipboard rather than writing to it** site the plan names) | N/A — clears, does not copy a value | No | PASS (not a copy site; included for completeness) |

**Defect found, outside the write-site list above but directly adjacent:**
`lib/web/web_view_windows.dart:75` — `debugPrint('📋 WalletConnect URI from clipboard: $text')`.
This is a **read** site (`Clipboard.getData` two lines above, polled every 2s for a WalletConnect
pairing URI), not a write, so it falls outside the "full value copied" check — but it does log the
clipboard's content to the debug console, which is the same class of concern the "nothing logged"
property exists to catch. A WalletConnect pairing URI carries a relay topic and symmetric key, not
an account secret, and `debugPrint` does not reach Sentry/telemetry in this app's configuration —
so this is lower severity than a mnemonic or private key leak, but it is a real finding: **File and
line: `lib/web/web_view_windows.dart:75`.** Recorded here for follow-up; not fixed in this plan (out
of fence — this file is not in Task 3's file list and this plan does not touch clipboard-read
logging).

**No site fails either audited property among the 10 write sites.** The heterogeneity the plan
predicted is confirmed and, if anything, understated — two additional sites
(`account_drawer.dart`, `crypto_address_qr.dart`) exist beyond the five the plan's prose named,
each with its own copy affordance and confirmation text, reinforcing rather than weakening the
REFUSE-as-shared-component verdict: a component trying to serve all ten would need to parameterize
confirmation copy, truncation rules, glyph presence, and (for the mnemonic) a blocking
confirm/cancel dialog — the "wrong abstraction" AGENTS.md's Rule of Three warns against.

---

## Candidate: GWAppBar — DEFER (confirmed, count updated)

**Re-run measurement.** `grep -rl 'AppBar(' lib --include='*.dart'` finds **15** files today, not
the sixteen the plan's prose names:

```
lib/banxa/banxa_orders_history.dart          lib/dev/design_gallery_screen.dart
lib/banxa/banxa_payment.dart                 lib/dev/token_probe_screen.dart
lib/banxa/checkout_qr.dart                   lib/network/network_page.dart
lib/banxa/user_kyc/kyc_registration.dart     lib/onboarding/existing_wallet/routes/existing_wallet_flow.dart
lib/components/bottom_drawer/responsive_drawer.dart   lib/onboarding/new_wallet/routes/new_wallet_flow.dart
lib/components/overlay/responsive_overlay.dart        lib/screens/banxa_buy_screen.dart
lib/dashboard/bridge/bridge_screen.dart      lib/screens/order_details_page.dart
                                              lib/settings/settings_screen.dart
```

The one-file drift from the plan's count is not investigated further here — the deferral's own
argument does not depend on the exact count, only on there being a double-digit surface with a
golden-shaped verification need and no golden available (`23-CONTEXT.md`'s "NO GOLDEN TESTS"
decision, `22-07-DEFERRED.md`). Two of the fifteen (`responsive_drawer.dart`,
`responsive_overlay.dart`) are host/overlay chrome, not screens, matching the plan's own
observation that the raw file count overstates the true screen subset. Phase 24 (routing) opens
these same files per the ROADMAP; extracting an app bar immediately ahead of a routing refactor is
still churn — nothing in the tree has changed the shape of that argument since planning.
**Verdict: DEFER, confirmed**, count corrected to 15, per-file re-classification still left to
Phase 24 where the files are open anyway.

## Candidate: GWScreen sweep — DEFER (confirmed, count updated)

**Re-run measurement.** `GWScreen`'s own constructor still imposes a safe area, a scroll view, a
1200px width cap, centring, fixed padding and a background (`lib/components/scaffold/gw_screen.dart`
— read, unchanged since planning), confirmed NOT a transparent wrapper. `grep -rl 'Scaffold(' lib
--include='*.dart' | wc -l` returns **25** files today (the plan's prose estimated ~28 — an
overstatement, not an understatement, corrected here). `grep -rn 'GWScreen(' lib --include='*.dart'`
finds exactly **two** live call sites (`settings_screen.dart:170`, `submit_job_screen.dart:54`) —
so the adoption gap is closer to 23 unconverted screens than 28. The verification method this sweep
would need — a two-width, two-mode eyeball per screen — is exactly the class of check
`23-CONTEXT.md`'s "NO GOLDEN TESTS" decision removed the automated substitute for, and this plan
carries no budget for over twenty live per-screen walks on top of the three `GWHoverable` batch
walks it already owes. **Verdict: DEFER, confirmed**, counts corrected (25 hand-rolled `Scaffold`,
23 not yet on `GWScreen`), for the same reason planning gave: adopting `GWScreen` where a screen's
current shape does not already match it is a layout change, and this phase's own boundary
(`23-CONTEXT.md`) forbids layout changes.

## Candidate: GWPriceBlock, GWStatRail — DEFER (confirmed, honestly re-measured)

**Re-run measurement.** `grep -rn 'GWPriceBlock\|GWStatRail' lib --include='*.dart'` returns
**zero** matches — correct, since neither was ever built; these are proposed component names for a
duplicated hand-rolled pattern, not existing symbols. Neither `22-RESEARCH.md` (the origin of the
"2 sites each" figure) nor `23-05-PLAN.md` records concrete file:line locations for the duplicate
they describe, so there is no symbol or file list this execution can re-diff the way the timeframe
and copy-row candidates were re-diffed above — the honest statement is that this deferral is
**inherited unchanged because no new information contradicts it**, not because a fresh grep
re-confirmed a call-site count. **Verdict: DEFER, unchanged** — below the Rule-of-Three floor by
the only figure on record, with no evidence found either way to revise it.

---

## What ORG-05 got and did not get this phase

**Got:** one shared hover-plumbing primitive (`GWHoverable`), replacing thirteen independent
`bool _hovered` + `MouseRegion` + `setState` implementations (not the twelve the plan named — one
planned site turned out to already be migrated by other work, two unplanned sites turned out to
carry the identical pattern and were folded in under the plan's own "legitimate migration target"
instruction) with one widget whose paint is unchanged by construction at every site, and whose
contract (hit area, cursor, rebuild suppression) is pinned by an ordinary test in a way no golden
would have covered anyway.

**Did not get:** every other named candidate stayed out of this phase, each for a reason re-verified
today rather than inherited: `GWTimeframeSegment` refused because the two live copies genuinely
differ (track fill and label set — a smaller divergence than planning feared, but still enough to
disqualify a parameterless shared widget); `GWCopyRow` is not built by this plan because it already
exists (built independently, for a different consumer, under a Rule-of-Three case this plan never
owned) and this plan does not extend it onto its two remaining forks (out of fence, flagged as a
clean follow-up); `GWAppBar` and the `GWScreen` sweep deferred to Phase 24, where the files are
opened anyway; `GWPriceBlock`/`GWStatRail` stay below the floor at two call sites each. The
control-track colour divergence between the two timeframe copies, and the clipboard-read logging
finding in `web_view_windows.dart`, are both recorded here as real but unfixed findings for a later
plan, not silently dropped.

ORG-05's scope this phase is therefore: **one extraction, thirteen sites, zero repaints, and five
honestly-recorded refusals/deferrals** — not a count, a record of what was actually checked.
