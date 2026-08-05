---
created: 2026-07-21
derived_at_commit: 87a7715
branch: ui-redesign-port
method: 6 parallel read-only investigators → per-finding adversarial refutation → synthesis
agents: 67
findings_raw: 60
findings_surviving: 36
findings_refuted: 24
---

# Parallel investigation audit — 2026-07-21

**Derived at `87a7715`.** Every claim below was checked against code at that commit. If HEAD has
moved, re-check before acting — this document has an expiry, and today's session is a case study
in what happens when that is forgotten (`05-VERIFICATION.md` expired the moment PR #210 merged).

## Method, and why the refutation pass matters

Six investigators swept disjoint areas. **Every finding was then handed to a second agent
instructed to REFUTE it, defaulting to refuted if it could not confirm the claim from code it read
itself.** 24 of 60 findings — **40%** — did not survive.

That number is the point. An unverified finding is worse than no finding: it costs a person a day
proving a negative. Notable kills:

- **Chart `mainAxisExtent: 80` clipping** — real, but first *visible* clip needs textScale ≳1.71,
  and it is a silent descender clip, not a RenderFlex. Severity was overstated.
- **`GWSectionTitle` Assets trailing overflow** — a font-metric recount showed it needs a
  **$100B portfolio** at 375dp to trigger, via a `--dart-define`-gated debug fixture. Informational.
- **`tx.coinSymbol` long-value overflow** — the fixture citations were all correct, but the premise
  was not: `coinSymbol` is a chain identifier with a closed short domain (`ETH`/`BTC`/`GNUS`), never
  an arbitrary ERC-20 symbol.

Two findings survived but had their *arithmetic* corrected by the verifier — in one case in the
direction that made it **worse** (B1 below).

## Phase 05 — what actually still blocks it

The stated blocker (`GWEmptyState` overflow) is **fixed in code** at `2e82ec2`; it needs a walk.
Two findings add to the list. Everything else does not.

### B1 — `WalletsOverview` overflows its slot (criterion 5)

`lib/components/wallet_overview.dart:49` is a top-level `Column(mainAxisAlignment: center)` with
default `mainAxisSize: max`, no scroll view, and no `Flexible`/`Expanded` on any of its six
children — inside a hard `ConstrainedBox(maxHeight: 300)`
(`dashboard_screen.dart:270-273` and `:198-201`).

The investigator claimed it "passes by 3px". The verifier recomputed against Flutter SDK source and
found the SGNUS-wallet branch overflows by **~26px idle and ~55px processing**. The correction went
the wrong way — this is a real criterion-5 violation, not a near miss.

**Honest caveat:** it needs a live SGNUS connection and **there is no dev fixture**, so it has never
been walkable. Fixing the slot alone is not enough — without a MOCK bubble scenario forcing
`WalletType.sgnus` + `isProcessing`, criterion 5 becomes *unverifiable* rather than verified. This
is the same trap as the empty state: a state no fixture can reach is a state no walk will ever check.

### B2 — Markets error/empty branches lose the redesign skin (criterion 1)

`dashboard_screen.dart:392` (`error:`) and `:394-396` (empty) each return a bare
`Center(child: Text(...))` **outside** `DashboardScrollContainer`, while the success path wraps in
it. So in error or empty states the Markets tile loses its card, border and padding while all four
sibling panels keep theirs. `markets_screen.dart:98-105` already styles the identical strings, so
the correct treatment exists and simply is not used here.

### Explicitly NOT blocking Phase 05

Do not let these hold the phase:

- **All light-mode AA findings.** `STATE.md` records light-mode AA as deferred, dark-first; Phase 05's
  criteria say nothing about light mode and the dark walk was approved.
- **Chart zoom/pan raw whites** — already tracked in ROADMAP + a todo; dark mode is fine.
- **The `_basePath` double-init** — **verified pre-existing on `origin/develop`**. The implicated
  files (`packages/genius_api/lib/src/genius_api.dart`, `lib/screens/splash.dart`) are byte-identical
  to develop in the relevant regions. Not this milestone's bug. Raise upstream.

## Work queue

Ordered by (severity × visibility) / effort. **Bold = serialization point** (file touched by more
than one task, so those tasks cannot run concurrently).

| # | Task | Key files | Notes |
|---|------|-----------|-------|
| **Q1** | Phase 05 close-out | `wallet_overview.dart`, **`dashboard_screen.dart`**, `dev_tools_bubble.dart` | B1 + B2 + the SGNUS/processing fixture |
| **Q2** | Key-material hardening | `paste_field.dart`, **`sdk_account_manager.dart`**, `recovery_phrase_screen.dart` | security; disjoint from Q1 |
| **Q3** | Light-mode token foundation | **`genius_wallet_colors.dart`**, **`theme.dart`**, `nav_chip_style.dart`, **`gw_button.dart`** | the serialization point — Q4 depends on it |
| **Q4** | Light-mode fan-out (a/b/c) | `responsive_overlay.dart` / `reown_connect_button.dart` / `crypto_live_chart.dart` + others | 3 disjoint sub-tasks, concurrent after Q3 |
| **Q5** | Toast re-skin | `toast_widget.dart` | fully disjoint, any time |
| **Q6** | Trivia bundle | `settings_screen.dart`, `action_button.dart` | one commit, all disjoint |

### Q2 supersedes part of the just-committed Phase 6 plan

**The repo has ZERO IME hardening.** `grep -rn "autocorrect:|enableSuggestions:|enableIMEPersonalizedLearning:" lib/`
returns **0 matches** — verified directly.

`06-04-PLAN.md:99-100` prescribes only **two** of the four needed flags, and only for **one** of the
three key-bearing fields. It needs amending before execution:

- All four flags: `autocorrect:false`, `enableSuggestions:false`,
  **`enableIMEPersonalizedLearning:false`**, `textCapitalization:none`.
- `enableIMEPersonalizedLearning` is **not optional** — it, not `autocorrect`, is what maps to
  Android's `IME_FLAG_NO_PERSONALIZED_LEARNING`. Omitting it leaves the actual learning-store leak open.
- All three files, not one: `paste_field.dart:26-31`, `sdk_account_manager.dart:288-290,415-419,460-463`,
  `recovery_phrase_screen.dart:104`.
- Same task: clear the clipboard on a 30–60s timer after both seed copies, and add a confirm step to
  "Copy mnemonic" (there is none today).

### Q3 detail — the dark-mode AA failure nobody had found

`theme.dart:103`, `:116`, `:355` pair `textPrimary` (white in dark) on a `brandPrimaryStrong` fill =
**2.56:1**. `theme.dart:36-38` already rejects this exact pairing sixty lines above in the same file.

This is the **third recurrence** of the same white-on-brand-fill defect (after 05-02's toggle and
k81's transaction badge). Fixing it plus routing `:227`/`:304`/`:350`/`:84`/`:75` and
`gw_button.dart:132,134` through one appearance-aware token covers every `TextField`, dropdown and
checkbox app-wide in a single edit.

Also promote `connectBrandColor`'s light value `#0B6E8F` (`nav_chip_style.dart:63-67`) into
`GeniusWalletColors` — measured 5.77:1 on white, 4.35:1 on `#DCE0E6`, 4.9:1 on `#EFF2F6`, and it is
already guarded by `test/theme/nav_chip_style_test.dart:110-124`.

Three stale ratio comments to correct while in-file: `nav_chip_style.dart:61`,
`reown_connect_button.dart:501`, `wallet_overview.dart:142-144` (the 1.96/10.12 figures are against
the superseded `#14C8FF`).

### Q4b — the worst light-mode result found

`reown_connect_button.dart:517-544` status chips paint their label in the same colour as an 18% wash
of itself: **"Connecting"/"Timed Out" at 1.46:1**. Below `GeniusBreakpoints.small` the label drops
(`:582`), leaving an icon alone at 1.46:1. A light-mode `statusWarning` **does not exist yet** and
must be added in Q3.

### Q5 — `toast_widget.dart` imports no theme at all

Lines 1-2 import no theme file. It is 100% light-Material (`Colors.green.shade50` fills,
`Colors.black` text) rendering over the dark canvas, and it fires from four production flows
(`network_dropdown_selector.dart:75`, `bridge_screen.dart:220`, `swap_screen.dart:377`,
`submit_job_screen.dart:30,40,50`). Its success variant's icon/border measures **2.10:1**, under the
3:1 non-text floor. ~15 raw values in ~110 lines.

## Known blind spots of this sweep

Stated so nobody mistakes this for exhaustive:

- **The horizontal overflows observed live are unattributed.** The 2026-07-21 run logged
  `overflowed by 116 pixels on the right` ×1 and `37 pixels on the right` ×3, after
  `WalletKit initialized`. Flutter suppressed the creator chains (only the first few unique errors
  get full dumps), and this static sweep did not identify them. **They need a fresh run reproducing
  the same navigation** — the first occurrence in a new run will carry the chain.
- Pixel arithmetic was done from token values and Flutter SDK source, not from a running app. Two
  findings had their arithmetic materially corrected during refutation; assume others could be off.
- Light-mode ratios are computed, not observed. The light pass has never been walked.
- No investigator ran the app.
