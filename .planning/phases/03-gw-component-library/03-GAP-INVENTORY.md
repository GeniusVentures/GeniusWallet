---
phase: 03-gw-component-library
plan: 08
deliverable: GAP-01
status: complete
---

# GAP-01 Whole-App Inventory

**Purpose.** Every develop surface with no Alex analog, evidenced, split mechanical vs
structural, with every deferred structural question written down verbatim for product.
Method per `03-UI-SPEC.md` §7.2 (this document is that method's output, not a
pre-population — §7 explicitly said not to compute it there).

**Re-derivation discipline (per `.continue-here.md` blocking constraints).** This inventory
does **not** start from REQUIREMENTS.md's GAP-02..06 and stop there. It independently
diffs the **entire** `lib/` tree (every one of the 27 top-level subdirectories, not just
router-adjacent ones) against `origin/ui-redesign-3.514` (`9413a32`, verified — never the
incomplete `ui-redesign-3.514-develop`), then reconciles the result against the known 10.
The known 10 is confirmed exact — not re-derived from scratch as an act of faith, but
**independently reproduced** by this pass, with 3 extra candidates investigated and ruled
out (§3).

---

## 1. Method and Evidence Log

### 1.1 Whole-tree diff (the primary evidence)

```
git diff --diff-filter=D --name-only develop..origin/ui-redesign-3.514 -- lib/
```

Filter `D` (relative to the `develop → origin` direction) means: **exists on develop,
does not exist on Alex's branch** — i.e. no Alex analog. This is the mechanical definition
of a "gap" surface. Result — **13 files, whole tree, one command**:

```
lib/account/sdk_account_manager.dart
lib/banxa/banxa_orders_history.dart
lib/banxa/banxa_payment.dart
lib/components/loading.dart
lib/components/wallet_overview.dart
lib/dashboard/home/widgets/transaction_displays.dart
lib/hive_registrar.g.dart
lib/onboarding/existing_wallet/view/select_wallet_type_screen.dart
lib/onboarding/routes/wallet_routes.dart
lib/screens/banxa_buy_screen.dart
lib/screens/splash.dart
lib/settings/settings_screen.dart
lib/tokeninfo/token_model.g.dart
```

**Methodological note, evidenced, not asserted:** running the same filter scoped to
individual directories (e.g. `-- lib/screens`) returns a **14th** candidate,
`lib/screens/order_details_page.dart`, that the whole-tree command above does not. This is
git's rename-detection heuristic: scoped to one directory it cannot see the file's
destination elsewhere in the tree and falls back to reporting a pure delete; scoped to the
whole tree it finds the match and reports a rename (`R`) instead, which `--diff-filter=D`
correctly excludes. Confirmed directly:

```
git diff --diff-filter=R --name-status -M develop..origin/ui-redesign-3.514 -- lib/
R076   lib/screens/order_details_page.dart        lib/banxa/order_details_page.dart
R081   lib/banxa/banxa_api_services.dart           lib/banxa/banaxa_api_services.dart
R096   lib/banxa/banxa_model.dart                  lib/banxa/banaxa_model.dart
R074   lib/banxa/handle_banxa_drawer.dart           lib/banxa/handle_banaxa_drawer.dart
R078   lib/dashboard/transactions/sgnus_transactions_screen.dart   lib/dashboard/transactions/transactions_scren.dart
R100   lib/reown/utilities.dart                    lib/reown/utilites.dart
```

**This is why the whole-tree diff, not a per-directory one, is the authoritative command
for this inventory** — the same "diffing at the wrong scope silently drops evidence"
failure mode already burned this project once (wrong branch, §`.continue-here.md`); this
is the same class of mistake at a narrower scope, caught before it produced a false
finding.

### 1.2 Route-target + reachable sub-view enumeration

Every `GoRoute`/`ShellRoute` builder in `lib/navigation/router.dart` plus every route
registered by `WalletRoutes().landingRoutes` (`lib/onboarding/routes/wallet_routes.dart`,
itself GAP-04) — **30 route targets**, enumerated below (§2) — cross-referenced against
§1.1's 13-file list and, for the remaining 20 (route targets with an Alex analog), against
a whole-tree `--diff-filter=M` collision check:

```
git diff --diff-filter=M --name-only develop..origin/ui-redesign-3.514 -- lib/
```

All 20 non-gap route targets appear in this `M` list — confirmed collision files with an
Alex analog, each already scheduled to an SCR-0X screen phase per ROADMAP/REQUIREMENTS
(§2's table, "verdict" column cites the command result inline).

---

## 2. Route-Target Enumeration — Y/N Verdict, Evidenced

| # | Route | File | Verdict | Evidence |
|---|--------|------|---------|----------|
| 1 | `/` | `lib/screens/splash.dart` | **Y (moved path)** | In §1.1's D-list at this path, but §1.1's rename-detection check shows no `R` line for it *at this specific pairing* — however git's own `Splash` class match against `lib/components/splash.dart` was independently confirmed by this phase's own diff work (03-06-SUMMARY.md: "the third and final shadow... Confirmed `lib/screens/splash.dart` and `lib/navigation/router.dart` remain zero-diff"). Alex's `Splash` (`lib/components/splash.dart`) was already ported this phase (03-06) as an inert, zero-importer shadow. **Not a gap** — has analog, moved path, already handled. |
| 2 | `/buy` | `lib/banxa/banxa_orders_history.dart` | **N — GAP-05** | §1.1 D-list |
| 3 | `/createOrder` | `lib/screens/banxa_buy_screen.dart` | **N — GAP-05** | §1.1 D-list |
| 4 | `/orderDetails` | `lib/screens/order_details_page.dart` | **Y (moved path) — new finding** | §1.1's rename check: `R076 lib/screens/order_details_page.dart → lib/banxa/order_details_page.dart` (76% similarity — same `OrderDetailsPage` class, same constructor, same imports, differing only by the `banxa`→`banaxa` typo-renames of its own imports and 2 added theme imports). **Has an Alex analog**, at a moved path GAP-05's named list didn't include. See §4. |
| 5 | `/banxa/callback` | `lib/banxa/banxa_orders_history.dart` (same as #2) | N — GAP-05 | (same file) |
| 6 | `/checkoutQR` | `lib/banxa/checkout_qr.dart` | Y | `M` list |
| 7 | `/kyc` | `lib/banxa/user_kyc/kyc_registration.dart` | Y | `M` list |
| 8 | `/checkout` | `lib/banxa/banxa_payment.dart` | **N — GAP-05** | §1.1 D-list |
| 9 | `/network` | `lib/network/network_page.dart` | Y | `M` list |
| 10 | `/dev/token-probe` | `lib/dev/token_probe_screen.dart` | n/a — excluded | Phase 2's own dev-only file, not a develop feature Alex could have seen; dev-gated, unreachable in a normal build |
| 11 | `/design_gallery` | `lib/dev/design_gallery_screen.dart` | n/a — excluded | This phase's (Phase 3) own file, same reasoning as #10 |
| 12 | `/dashboard` | `lib/dashboard/home/view/dashboard_screen.dart` | Y | `M` list |
| 13 | `/transactions` | `lib/dashboard/transactions/transactions_screen.dart` | Y | `M` list |
| 14 | `/swap` | `lib/squid_router/swap_screen.dart` | Y | `M` list |
| 15 | `/web` | `lib/web/web_view_screen.dart` | Y | `M` list |
| 16 | `/markets` | `lib/dashboard/chart/markets_screen.dart` | Y | `M` list |
| 17 | `/news` | `lib/dashboard/news/view/crypto_news_screen.dart` | Y | `M` list |
| 18 | `/logs` | `lib/logs/submit_logs_screen.dart` | Y | `M` list |
| 19 | `/settings` | `lib/settings/settings_screen.dart` | **N — GAP-02** | §1.1 D-list |
| 20 | `/token-info` | `lib/tokens/token_info_screen.dart` | Y | `M` list |
| 21 | `/bridge` | `lib/dashboard/bridge/bridge_screen.dart` | Y | `M` list |
| 22 | `/submit_job` | `lib/submit_job/view/submit_job_screen.dart` | Y | `M` list |
| 23 | `/landing_screen` | `lib/onboarding/view/wallet_creation_screen.dart` | Y | `M` list |
| 24 | `/backup_phrase` | `lib/onboarding/new_wallet/view/backup_phrase_screen.dart` | Y | `M` list |
| 25 | `/recovery_phrase` | `lib/onboarding/new_wallet/view/recovery_phrase_screen.dart` | Y | `M` list |
| 26 | `/verify_recovery_phrase` | `lib/onboarding/new_wallet/view/verify_recovery_phrase_screen.dart` | Y | `M` list |
| 27 | `/import_wallet` | `lib/onboarding/existing_wallet/view/select_wallet_type_screen.dart` | **N — GAP-04** | §1.1 D-list |
| 28 | `/import_security` | `lib/onboarding/existing_wallet/view/import_security_screen.dart` | Y | `M` list |
| 29 | `/import_existing_wallet` | `lib/onboarding/existing_wallet/routes/existing_wallet_flow.dart` | Y | `M` list |
| 30 | `/create_wallet` | `lib/onboarding/new_wallet/routes/new_wallet_flow.dart` | Y | `M` list |
| — | (routing file, not a route target itself) | `lib/onboarding/routes/wallet_routes.dart` | **N — GAP-04** | §1.1 D-list — registers routes #23–30; no rendered UI of its own |

**Reachable sub-views beyond route targets, cross-referenced against §1.1's whole-tree
D-list rather than walked screen-by-screen** (the whole-tree diff already surfaces *every*
develop-only file in `lib/`, screen-level or not — a sub-view with no Alex analog cannot
hide from it regardless of which screen reaches it):

| Sub-view | Reached from | Verdict | Evidence |
|---|---|---|---|
| `lib/account/sdk_account_manager.dart` | `/settings` (Settings screen mounts `SDKAccountManagerButton`) | **N — GAP-03** | §1.1 D-list |
| `lib/dashboard/home/widgets/transaction_displays.dart` | `/dashboard` (dashboard's transaction list rows) | **N — GAP-06** | §1.1 D-list |
| `lib/components/loading.dart` | Widely reachable (19 importers per 03-SHADOW-NAMES.md) | **N — GAP-06** | §1.1 D-list |
| `lib/components/wallet_overview.dart` | Dashboard-area balance display | **N — GAP-06** | §1.1 D-list |

**Result: 30 route targets + 4 named sub-views = 34 screen-level surfaces enumerated.
10 have no Alex analog. 2 dev-tooling routes are out-of-scope by construction (not develop
features Alex could have seen). The remaining 22 all have a confirmed Alex analog** (20
direct collision-file matches + 2 moved-path matches, #1 and #4 above).

---

## 3. The 4 Non-Gap Candidates — Investigated and Ruled Out

§1.1's whole-tree D-list returned 13 files. 10 are the known GAP-02..06 groups (§2, exact
match — REQUIREMENTS.md's own named 10 files, independently reproduced). The other 3 (plus
the 1 rename-detection artifact from §1.1's methodology note) were each opened and
checked, not assumed:

| File | Finding | Verdict |
|---|---|---|
| `lib/screens/splash.dart` | Alex analog at moved path `lib/components/splash.dart` — the "Splash shadow," already ported inertly this phase (03-06). Same class name, same role (`Splash extends State*Widget`, boots to `/landing_screen` or `/dashboard`). | Has analog — not a gap (§2 row 1) |
| `lib/screens/order_details_page.dart` | Alex analog at moved path `lib/banxa/order_details_page.dart`, git-rename-detected at 76% similarity. Diffed both heads directly: same class `OrderDetailsPage`, same constructor/fields, same imports except the `banxa`→`banaxa` typo-rename family and 2 added theme imports (`genius_wallet_colors.dart`, `genius_wallet_consts.dart` — i.e. Alex's version is *already* using design tokens). | Has analog — not a gap, **new finding** (§4) |
| `lib/tokeninfo/token_model.g.dart` | Opened: a `json_serializable`-style data model (`SuperGeniusTokenInfo`, `fromJson`/`toJson`/`fromRawJson`/`toRawJson`). Not a widget, not a screen, no `build()` method, nothing to re-skin. | **Out of GAP-01's scope** — screen-level surfaces only, per this plan's own scope fence; a data model is neither mechanical-reskin nor structural-decision territory |
| `lib/hive_registrar.g.dart` | Opened: a Hive CE build_runner-generated adapter registrar (`// Generated by Hive CE`, `// Do not modify`). Not a widget. | **Out of GAP-01's scope** — same reasoning; also excluded from `flutter analyze` by `analysis_options.yaml:5`, consistent with it not being hand-authored UI |

**Net effect: the 13-file whole-tree D-list resolves to exactly 10 true gaps (matching
REQUIREMENTS.md's GAP-02..06 precisely, independently re-derived) + 2 moved-path analogs
(not gaps) + 2 non-UI generated files (out of scope).** No file was found this pass that
REQUIREMENTS.md's named 10 does not already cover.

---

## 4. New Finding: `order_details_page.dart`'s Moved-Path Analog (Not a GAP, an Addendum for Phase 9)

`lib/screens/order_details_page.dart` is **not** develop-only in the way GAP-05's 3 named
files are — Alex's branch has a real, evidenced analog at `lib/banxa/order_details_page.dart`
(§3), part of the same Banxa directory reorganization that produced the 3 files GAP-05
already names (`banxa_orders_history.dart`, `banxa_payment.dart`,
`screens/banxa_buy_screen.dart` all moved into/within `lib/banxa/` on Alex's branch too —
confirmed by the `banxa`→`banaxa` rename family in §1.1).

This is **not a new GAP-01 requirement** — it has a design analog, so it is a mechanical
re-skin against a real source, not a structural decision. It is recorded here so
**whichever phase re-skins the Banxa area (Phase 9, GAP-05's owner) knows
`order_details_page.dart` has a real Alex-authored reference to re-skin against**, at
`lib/banxa/order_details_page.dart` in the reference worktree — not listed in GAP-05's
original 3-file scope, and would otherwise be silently missed as "no design, therefore
GAP-06-style mechanical-from-scratch" when a real reference in fact exists.

**Primitives Phase 9 can draw from that analog:** same `custom_future_builder.dart` /
`scaffold_helper.dart` / `banxa_helpers.dart` pattern as develop's version — no new `gw_*`
primitive is implied beyond what GAP-05's other 3 files already need (§6).

---

## 5. Deferred Structural Questions (verbatim, unresolved — for product)

Per the blocking constraint: never decide a structural question here. One genuine
structural question surfaced this pass, tied to GAP-06's `transaction_displays.dart`:

> **Structural question for product:** develop's `lib/dashboard/home/widgets/transaction_displays.dart`
> renders every transaction type (sent/received, purchased, swapped, escrow-release) through
> shared free functions (`_buildRow`, `_buildDetailsCard`) inside **one file**. Alex's branch,
> independently, has **no analog at that path** — but it does have 4 separate, per-type
> `StatelessWidget` classes at `lib/dashboard/transactions/`: `transaction_item.dart`,
> `transaction_purchased_item.dart`, `transaction_swapped_item.dart`,
> `transaction_escrow_release_item.dart` (confirmed: `transaction_item.dart` reuses the same
> `transaction_utils.dart`/`wallet_utils.dart`/`web_utils.dart` helpers and
> `GeniusWalletColors.brandGreen`, i.e. it is recognizably the same transaction-row concern,
> just reorganized). **Should GAP-06's re-skin of `transaction_displays.dart` (a) keep
> develop's existing single-file, function-based structure and re-skin the widgets it builds
> in place (zero IA change, the re-skin-only reading of the rule), or (b) split it into
> per-type files matching Alex's 4-file organization (a restructuring — merging/splitting
> files — squarely out of scope for this milestone per REQUIREMENTS.md's own test)?**
> Recorded verbatim, unresolved. GAP-06's default reading under REQUIREMENTS.md (re-skin in
> place, structure unchanged) is (a); this document does not decide it, only flags that a
> real, better-organized Alex reference exists at path (b) if product ever wants it.

No other structural question surfaced. Every other GAP-02..06 file (§6) was read and found
to have no IA ambiguity — applying `gw_*` primitives to their existing structure requires
no reordering, no merge/split, no capability change.

---

## 6. Mechanical vs Structural Split, Primitives Named, Owning Phase

All 10 known-gap files were read (not assumed) to name required primitives.

| File | Split | Owning phase (REQUIREMENTS.md traceability) | Primitives needed (from the 50, `03-06-SUMMARY.md`) |
|---|---|---|---|
| `lib/settings/settings_screen.dart` (GAP-02) | Mechanical | Phase 4 | `GWCard` (section chrome), `GWSelect` (log-level dropdown, replaces raw `DropdownButton`), `GWTextField` (network/CRDT numeric+text fields), `GWSwitch` (boolean config toggles), `GWButton` (Apply/Save actions), `GWIcon` (section icons) |
| `lib/account/sdk_account_manager.dart` (GAP-03) | Mechanical | Phase 4 | `BottomDrawer` (via `ResponsiveDrawer.show()`, per §4.1 binding rule), `GWCard` (account rows, replaces raw `Card`+`ListTile`), `GWButton` (add/delete actions), `GWTextField` (mnemonic/private-key/payout dialogs), `GWDialog` (confirm/add/set dialogs — its first real consumer), `GWIcon`. Mnemonic-QR display keeps develop's existing `qr_flutter` usage directly — not a `gw_*` component, no new dependency, no gap |
| `lib/onboarding/existing_wallet/view/select_wallet_type_screen.dart` + `wallet_routes.dart` (GAP-04) | Mechanical | Phase 6 | `GWCard` (wallet-type row, replaces raw `Card`+`ListTile`), `GWIcon`. `wallet_type_icon.dart` (already ported, 03-06) is directly reusable for the wallet-type glyph |
| `lib/banxa/banxa_orders_history.dart`, `lib/banxa/banxa_payment.dart`, `lib/screens/banxa_buy_screen.dart` (GAP-05) | Mechanical | Phase 9 | `GWButton` (all 3), `GWIcon` (all 3), `GWTextField` (amount input, `banxa_buy_screen.dart`), `GWCard` (`banxa_buy_screen.dart`), `custom_drop_down.dart`/`currency_dropdown.dart` (both already ported 03-06; `custom_drop_down.dart`'s only current caller **is** `banxa_buy_screen.dart` per `03-UI-SPEC.md` §2.3), `GWEmptyState`/`GWErrorState` (order-history empty/failure states), `AppScreenView`/`GWScreen` (screen wrapper). Plus §4's addendum: `lib/screens/order_details_page.dart` has a real moved-path analog to re-skin against |
| `lib/components/wallet_overview.dart` (GAP-06) | Mechanical | Phase 5 | `GWAnimatedNumber` (balance figure, direct replacement for the raw `Text` balance display), `GWCard` (optional panel chrome). The GNUS/Minions `ToggleButtons` segmented toggle has no 1:1 `gw_*` equivalent among the 50 — composable from two `GWButton`s with manual active/inactive styling (an implementation-phase composition choice, not a blocking primitive gap — see §7) |
| `lib/components/loading.dart` (GAP-06) | Mechanical | Phase 5 | `GWSpinner` (direct 1:1 replacement for `LoadingAnimationWidget.flickr`) |
| `lib/dashboard/home/widgets/transaction_displays.dart` (GAP-06) | Mechanical, **with one deferred structural question** (§5) | Phase 5 | `GWCard` (detail-row chrome, replaces `_buildDetailsCard`'s raw `Card`), `GWTokenRow` or a `GWCard`-based row (transaction list rows, replaces `Card`+`ListTile`), `GWButton` (retry/load-more actions), `GWEmptyState` (no transactions), `GWErrorState` (load failure) |

---

## Reconciliation

- **Screen-level surfaces enumerated:** 34 (30 route targets + 4 named sub-views, §2)
- **Have an Alex analog (Y):** 24 — 20 direct collision-file matches + 2 moved-path matches
  (`splash.dart`, `order_details_page.dart`, §2/§3/§4)
- **Excluded, not a develop feature Alex could see (dev tooling):** 2 (`/dev/token-probe`,
  `/design_gallery`)
- **No Alex analog — true gaps:** **10** — exactly REQUIREMENTS.md's GAP-02..06, independently
  reproduced by this pass, not re-derived by assumption (§1.1, §3)
  - Of the 10: **10 mechanical**, 0 requiring a structural decision to be *classified* —
    but 1 (`transaction_displays.dart`, GAP-06) carries a **deferred structural question**
    about file organization that does not block its mechanical re-skin (§5)
- **Non-UI files found develop-only but out of GAP-01's screen-level scope:** 2
  (`lib/tokeninfo/token_model.g.dart`, `lib/hive_registrar.g.dart` — both generated data
  layer files, §3)

**Discrepancy against the ROADMAP's "12 develop features" estimate:** the real, evidenced
count is **10**, not 12 — a difference of 2. This is not a miscount by this pass: it
matches REQUIREMENTS.md's own already-corrected note ("previous count was wrong... 22 → 24"
context, and REQUIREMENTS.md GAP section explicitly: "REQUIREMENTS.md's own named groups
sum to 10 files across 5 groups"). The ROADMAP's "12" was always the orchestrator's
unverified estimate, not a verified count (per this plan's own `must_haves`); this pass
independently confirms 10 is correct by diffing the entire `lib/` tree in one command
rather than trusting either number. **Reported plainly, not padded to 12.**

### Primitive cross-check against the 50 ported (DS-02, `03-06-SUMMARY.md`)

Every primitive named in §6 for the 10 gap files' mechanical re-skin was checked against
the 50-file inventory in `03-UI-SPEC.md` §2 / `03-06-SUMMARY.md`'s reconciliation:

| Primitive | Present in the 50? | Landing plan |
|---|---|---|
| `GWCard` | Yes | 03-02 |
| `GWSelect` | Yes | 03-02 |
| `GWTextField` | Yes | 03-02 |
| `GWSwitch` | Yes | 03-02 |
| `GWButton` | Yes | 03-02 |
| `GWIcon` | Yes | 03-02 |
| `GWDialog` | Yes (orphaned on the source branch, first real consumer would be GAP-03) | 03-05 |
| `BottomDrawer` (via `ResponsiveDrawer.show()`) | Yes | 03-05 |
| `custom_drop_down.dart` / `currency_dropdown.dart` | Yes | 03-06 |
| `GWEmptyState` | Yes | 03-03 |
| `GWErrorState` | Yes | 03-03 |
| `GWAnimatedNumber` | Yes | 03-02 |
| `GWSpinner` | Yes | 03-03 |
| `AppScreenView` / `GWScreen` | Yes (both, §2.5 notes the two-primitive overlap is deliberate, not ours to consolidate) | 03-05 |
| `wallet_type_icon.dart` | Yes | 03-04 |

**Missing primitives: zero.** Every `gw_*` primitive the 10 mechanically-re-skinnable gap
surfaces call for is already present in this phase's 50-file port. ROADMAP Phase 3 success
criterion 6's second clause ("every primitive those decisions call for exists in the
gallery") is **not blocked** by a missing primitive — it remains conditional on 03-10's own
job of confirming each of the above is actually visible as a gallery section (03-09
extends the gallery; 03-10 signs off the cross-check). This document does not claim that
gallery-visibility confirmation itself — that is explicitly 03-10's job, not this plan's.

**New findings from this pass vs. already-known groups:**
- **Already covered by REQUIREMENTS.md's known GAP-02..06 (10/10 files):** confirmed exact
  match, independently reproduced (§1.1, §3)
- **New findings this pass did surface:**
  1. `lib/screens/order_details_page.dart` has a real, moved-path Alex analog not
     previously named in GAP-05's list (§4) — an addendum for Phase 9, not a new GAP
  2. The `transaction_displays.dart` vs. Alex's 4-file per-type split — a genuine deferred
     structural question for product (§5)
  3. 2 non-UI generated files (`token_model.g.dart`, `hive_registrar.g.dart`) surfaced by
     the whole-tree diff and correctly excluded as out of GAP-01's screen-level scope (§3)
  4. The scope-dependent rename-detection artifact (§1.1) — a methodological finding about
     why the whole-tree diff, not a per-directory one, is authoritative

---

*Phase: 03-gw-component-library — Plan 08 (GAP-01)*
*Produced: 2026-07-17*
