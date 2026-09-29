# Phase 35: Unified header switcher - Research

**Researched:** 2026-09-29
**Domain:** Flutter self-custody wallet, bloc/cubit composition over existing FFI-backed state — no new FFI, no new bloc events
**Confidence:** HIGH (every callsite/test claim below is a direct `Read`/`Grep` this session; the only LOW item is the exact plumbing for `fromWalletName` in Send, flagged as Claude's discretion in CONTEXT.md)

## Summary

This phase is a **merge and relabel**, not new plumbing. `35-CONTEXT.md` (D-01..D-14, LOCKED) and
`35-UI-SPEC.md` already resolve every visual and copy decision — this document exists to pin the
exact call graph the planner needs to sequence tasks safely: every caller of the two widgets being
deleted, every test that pins strings this phase changes, the mechanism behind D-07's "View
balance," and the two injection points on Send/Swap.

**Primary recommendation:** Build `AccountSwitcher`/`AccountSwitcherDrawer` as new files that
compose the *existing* `_AccountDrawerBody` row-building code and `sdk_account_manager.dart`'s
`_buildAccountRow`/`sdkRowActions`/dialogs, re-point all 4 `AccountDrawer.show` callers plus the 2
desktop chip callsites to the new entry, delete `SDKAccountManagerButton` +
`AccountDropdownSelector`, and update the 2 test files that pin now-renamed section headers/footer
copy. No `AppBloc`/`AppState` change is needed — `_mergeSgnusWallet` and `WalletType.sgnus` rows
already exist in `AppState.wallets` today; D-07 only changes which UI surface reads them.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Desktop switcher chip (trigger) | Frontend (Flutter widget) | — | Pure composition over `AppBloc`/`WalletDetailsCubit`, no new state |
| Mobile switcher trigger (`WalletPill`) | Frontend (Flutter widget) | — | Unchanged trigger, only `onTap` destination moves |
| Switcher drawer body (2 sections) | Frontend (Flutter widget) | — | Reuses existing row builders from both source files |
| Active-wallet selection | Bloc/Cubit (`WalletDetailsCubit`) | — | Existing owner, unchanged — `selectWallet` |
| SDK-wallet selection | Bloc/Cubit (`AppBloc`) | — | Existing owner, unchanged — `SelectSDKAccount` |
| "View balance" (D-07) | Bloc/Cubit (`WalletDetailsCubit.selectWallet`) | — | Same call the drawer's own row tap already makes; no new API |
| Send/Swap "From" wallet naming | Frontend (Flutter widget) | — | Cosmetic addition over data already in `WalletDetailsCubit.state.selectedWallet` |

## Package Legitimacy Audit

Not applicable — this phase adds no new dependency. `pubspec.yaml` is unchanged by this work.

## User Constraints

See `35-CONTEXT.md` (D-01..D-14, LOCKED) and `35-UI-SPEC.md` (approved design contract, binding) —
both already read this session and are the controlling documents for scope, copy, and layout. This
research does not restate them; it verifies the code they assume against the current tree.

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| SWT-01 | Desktop shows one switcher (SDK + active wallet), old two menus gone | Caller/deletion map below; `responsive_overlay.dart:22-87` is the one edit site |
| SWT-02 | Change each selection independently | Confirmed today's separate calls (`walletCubit.selectWallet` vs `SelectSDKAccount`) are already independent — D-06 just relocates the taps into one drawer |
| SWT-03 | Same switcher opens on mobile | `WalletPill.onTap` (`mobile_header.dart:432`) is the one edit site; sizing/trigger untouched (D-02) |
| SWT-04 | Create/import/delete from the switcher | All three dialogs already exist (`_AddAccountDialog`, `/landing_screen`, both delete confirm flows) — this phase relocates them, invents none |
| SWT-05 | Send/Swap name the active wallet; switcher labels which selection does what | `send_transaction_details.dart:78`, `swap_screen.dart:1112` injection points confirmed below; D-14 labels confirmed against no other consumer |

## Caller Map — what must move

### `AccountDrawer.show` — 4 callers found (`Grep`, this session)

| Caller | File:line | Disposition |
|---|---|---|
| Desktop wallet chip | `lib/account/account_dropdown_selector.dart:40` | File deleted whole (D-11) — its only job was opening this drawer |
| Mobile `WalletPill.onTap` | `lib/components/overlay/mobile_header.dart:432` | Repoint to `AccountSwitcherDrawer.show(context, includeNetwork: true)` — same signature, same `includeNetwork` contract (D-02, UI-SPEC "Mobile header") |
| More-sheet "Accounts" row | `lib/components/overlay/more_sheet.dart:69` | Repoint to `AccountSwitcherDrawer.show(context)` — row's own title/subtitle ("Accounts"/"SDK accounts and your wallets") is unrelated UI, unchanged |
| Compute panel "Switch wallet" link | `lib/components/wallet_overview.dart:112` | Repoint to `AccountSwitcherDrawer.show(context)` — result already ignored (`unawaited`), no change to that behavior |

`AccountDrawer.show`'s own static entry (`account_drawer.dart:36-110`) is superseded by
`AccountSwitcherDrawer.show` per D-11 — once all 4 callers move, `AccountDrawer` has no caller left
and is deletable, but `AccountAvatar`, `WalletSDKBadge`/`walletSDKBadge()`,
`_AccountSectionHeader`/`_AccountSectionNote`/`_RowBadge` in the same file are still needed —
promote per D-08 to `lib/account/account_section_widgets.dart` rather than deleting the file outright.

### `SDKAccountManagerButton` / `AccountDropdownSelector` — 1 caller each

Both are wired only from `responsive_overlay.dart:_buildActionRowWidgets` (lines 22-87) — the
conditional wrapper (`if (context.watch<AppBloc>().state.sdkAccounts.isNotEmpty)` at line 69) and
the two `Flexible` chips at lines 70/73 are replaced by one `Flexible(child: AccountSwitcher())`
with **no** `isNotEmpty` guard (D-04 — always renders), closing the `ponytail:` note at lines 37-41.

## Test Impact Map — pinned strings this phase breaks

Both files below pin section-header/footer text that D-07/D-08/D-09/D-14 rename. **These are not
regressions to avoid; they are required edits** — the planner must schedule them as part of the same
plan that ships the renamed copy, not discover them via a red `flutter test` afterward.

| Test file | Pinned assertion (verbatim) | Line | Why it breaks | Required new assertion |
|---|---|---|---|---|
| `test/account/account_drawer_show_test.dart` | `expect(find.text('YOUR ACCOUNTS'), findsOneWidget);` | 362 | D-14 renames section to "Sending from" | `find.text('SENDING FROM')` (header renders `.toUpperCase()`, confirmed `account_drawer.dart:805`) |
| `test/account/account_drawer_show_test.dart` | `expect(find.text('SDK ACCOUNTS'), findsNothing);` | 366 | Section renamed to "Node running as"; **also** D-04 means this section no longer disappears when empty — the empty-sdkAccounts case in this test now renders `_AccountSectionNote('Node not running')` or `'No SDK accounts yet'`, not nothing | Update the empty-state assertion to expect the D-04 note text, not absence |
| `test/account/account_drawer_show_test.dart` | `expect(find.text('Add Wallet'), findsOneWidget);` | 369 | D-09 changes capitalization to "Add wallet" | `find.text('Add wallet')` |
| `test/account/account_drawer_network_section_test.dart` | `expect(find.text('YOUR ACCOUNTS'), findsOneWidget);` | 284, 315 | Same D-14 rename, two call sites in this file | `find.text('SENDING FROM')` |
| `test/account/account_drawer_network_section_test.dart` | `expect(find.text('Add Wallet'), findsOneWidget);` | 317 | Same D-09 rename | `find.text('Add wallet')` |
| `test/account/account_drawer_network_section_test.dart` | `expect(find.text('Accounts'), findsOneWidget);` (desktop title) / `'Wallet and network'` (mobile title) | 279-311 | **Unaffected** — UI-SPEC "Screen Contracts" explicitly keeps both title strings unchanged so this exact assertion survives | No change needed |

**Confirmed unaffected (no edit needed, re-run only):**
- `desktop_top_bar_text_scale_test.dart` — asserts no overflow, not chip text; chip merge changes
  measured widths, needs re-run only.
- `mobile_header_brand_and_pill_test.dart` — pins `WalletPill`'s fixed `kHeaderControlSize` square
  (D-02 unchanged); its `find.text('Accounts')` at line 595 is `more_sheet.dart:65`'s own row label,
  unrelated to the drawer title.
- `nav_chip_style_test.dart`, `wallet_identity_test.dart` — no reference to either deleted widget or
  renamed string (`Grep`, no match).
- `sdk_account_rows_test.dart`, `sdk_account_delete_coupling_test.dart`,
  `sdk_start_account_delete_test.dart`, `sdk_add_account_test.dart` — exercise
  `_buildAccountRow`/`sdkRowActions`/delete-confirm/add-account logic that this phase **relocates,
  not rewrites**; each must be re-pointed at the new host widget (they currently pump
  `SDKAccountManagerButton`/its drawer directly), but their assertions don't change.

## D-07 mechanics — concretely how "View balance" works today and tomorrow

**Today:** `AppBloc._mergeSgnusWallet()` (`app_bloc.dart:837-857`) builds one
`Wallet(walletType: WalletType.sgnus, address: <sdk address>, ...)` per SDK account and prepends
them into `AppState.wallets` — untouched by this phase. `_AccountDrawerBody.build()`
(`account_drawer.dart:580-585`) locally splits that list into `sdkWallets`/`ownWallets` purely for
its own row rendering. Tapping an sgnus row calls `Navigator.of(context).pop(wallet)`
(`account_drawer.dart:402-404`), which `AccountDrawer.show`'s caller feeds into
`await walletCubit.selectWallet(selected)` (`account_drawer.dart:106`) — the **entire** mechanism
that makes an sgnus wallet "the active view." `WalletDetailsCubit.selectWallet`
(`wallet_details_cubit.dart:156-164`) just emits `selectedWallet: wallet` and persists it; nothing
sgnus-specific happens there. Three screens branch on `selectedWallet.walletType == WalletType.sgnus`
(`dashboard_screen.dart:449`, `transactions_screen.dart:31`, `wallet_details_cubit.dart:263`) — none
of these change, since `selectWallet` is called with the same kind of `Wallet` object either way.

**Tomorrow (D-07):** the sgnus `Wallet` objects keep being computed by `_mergeSgnusWallet`
unchanged — **no `AppBloc`/`AppState` edit needed.** Only the UI moves: the "Node running as"
section's rows are driven by `sdk_account_manager.dart`'s `_buildAccountRow` (iterating
`state.sdkAccounts`, plain address strings), and its menu gains one more `MenuItemButton` whose
`onPressed` finds the matching sgnus `Wallet` by address (`appState.wallets.firstWhere((w) =>
w.walletType == WalletType.sgnus && w.address.toLowerCase() == account.toLowerCase())`) and calls
`context.read<WalletDetailsCubit>().selectWallet(sgnusWallet)` — the same call the drawer's row tap
already makes today, reached from a menu item instead.

## Mobile constraints

- `WalletPill` (`mobile_header.dart:379-479`) is a fixed 44×44 circle (`kHeaderControlSize`, lines
  439-440) holding only `WalletIdentityAvatar` — no text, no caret. D-02 keeps this exactly; the only
  edit is the `onTap` destination (line 432). The header cluster's fixed 100px total width (CONTEXT.md
  D-02) is a **separate, load-bearing constant** this phase must not touch.
- `AccountDrawer.show(context, includeNetwork: true)` prepends a `NetworkSelectField` section and
  retitles the sheet to "Wallet and network" (`account_drawer.dart:82,608-618`) —
  `AccountSwitcherDrawer.show` must honor the same `includeNetwork` parameter/title-swap.
- `ResponsiveDrawer.show` (`lib/components/bottom_drawer/responsive_drawer.dart:91`) renders a side
  panel at `GeniusBreakpoints.medium`+, bottom sheet below — no new drawer-shell work needed.

## Send / Swap injection points

### Send review drawer (D-12)

- `send_screen.dart:275-284` constructs `SendTransactionDetails(fromAddress: cubit.walletAddress,
  ...)` inside `_review()` (line 251). The active wallet's name is available via
  `WalletDetailsCubit.state.selectedWallet?.walletName` in the same scope — planner's call on the
  exact accessor (CONTEXT.md: "not a visual question").
- `send_transaction_details.dart` builds `GWCopyRow(label: 'From', value: fromAddress)` at **line
  78**. `GWCopyRow` (`gw_copy_row.dart:46-64`) has no `caption` field today — constructor is
  `const GWCopyRow({super.key, required this.label, required this.value, this.shorten = true})`.
  Adding an optional `caption` (default `null`) is additive — every other call site renders unchanged.
- **`SendTransactionDetails` has 3 callers (`Grep`):** `send_screen.dart:275` (Send flow — gets the
  new `fromWalletName`), `handle_dapp_requests.dart:155` (Reown dApp approval drawer), and
  `dev_tools_bubble.dart:966` (dev demo). Since the field is optional, the Reown drawer is
  **unaffected unless explicitly plumbed** — D-12 names only `send_screen.dart`, so pass
  `fromWalletName: null` (or omit) at the Reown call site to keep it exactly as today.

### Swap screen (D-13)

- `swap_screen.dart:736-780` is `_buildSwapCta(GWColors gw)`, invoked at **line 1112** inside a
  `Column`'s children, directly preceded by a `SizedBox(height: GeniusWalletConsts.space4)` at line
  1109. The new "Sending from {walletName} · Switch ›" line goes in that same `Column`, immediately
  above line 1112.
- The active wallet is available via `context.read<WalletDetailsCubit>().state.selectedWallet` —
  already read the same way in this file's `_submitSwap()` (lines 453-454).
- No confirm step is added (D-13, explicit) — `onPressed: _submitSwap` at line 777 is unchanged.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Two-section drawer body | A new row/section widget system | `GWSelectRow`, `_AccountSectionHeader`, `_AccountSectionNote`, `_RowBadge` (promote per D-08) | All four already exist, styled, tested; UI-SPEC forbids inventing a new visual language for this phase |
| "Which SDK account owns this sgnus wallet" lookup | A new map/index | `appState.wallets.firstWhere(...)` by lowercased address, same match style `walletSDKBadge()` already uses (`account_drawer.dart:139-144`) | One more list scan over an already-small list; no new state shape needed |
| Confirm-step for Swap | A new drawer/route | Nothing — D-13 explicitly keeps Swap's no-confirm-step behavior | Out of scope; adding one is a new capability the phase does not ask for |

**Key insight:** every "build" in this phase is a relocation of code that already ships. The
`Don't Hand-Roll` risk here is not "reinventing a library" but re-deriving row/section logic that
`account_drawer.dart` and `sdk_account_manager.dart` already have working and tested.

## Common Pitfalls

### Pitfall 1: Renamed section headers desync from their pinned tests mid-plan
**What goes wrong:** A plan ships the D-14 copy change without updating the two test files in the
Test Impact Map above, leaving `flutter test` red for a reason unrelated to the plan's own new code.
**How to avoid:** Schedule the test edits in the same task/commit as the copy change.
**Warning signs:** `flutter test` failing on `find.text('YOUR ACCOUNTS')`/`'SDK ACCOUNTS'`/`'Add
Wallet'` after the drawer body lands.

### Pitfall 2: D-04's "always renders" removes an empty-state test's only valid assertion
**What goes wrong:** `account_drawer_show_test.dart:366` currently asserts `findsNothing` for the
empty SDK case — under D-04 this becomes a real rendered note (`'Node not running'` or `'No SDK
accounts yet'`), so a mechanical string-swap still leaves a false `findsNothing` where a note now
renders.
**How to avoid:** Read the fixture's exact seeded state (`sdkAccounts: []`, connected vs
disconnected) to know which of the two D-04 notes applies, not just which label to substitute.

### Pitfall 3: Merging the chip loses the `context.watch<AppBloc>()` divider-visibility logic
**What goes wrong:** `responsive_overlay.dart:69` uses `context.watch<AppBloc>()` (not `read`)
specifically so the SDK chip's divider disappears live when the account list empties. A merged
`AccountSwitcher` reading `AppBloc` with `context.read` would stop rebuilding on SDK state changes.
**How to avoid:** Use two `BlocBuilder`s (or `context.watch`) — one for `AppBloc`, one for
`WalletDetailsCubit` — per the UI-SPEC Component Inventory ("no merged state class").

### Pitfall 4: `SendTransactionDetails`'s new `caption` silently changes the Reown approval drawer
**What goes wrong:** Wiring `fromWalletName` from `AppBloc`/`WalletDetailsCubit` *inside*
`SendTransactionDetails` itself (rather than as a plain caller-supplied param) would make
`handle_dapp_requests.dart:155`'s dApp approval drawer gain a caption nobody decided on.
**How to avoid:** Keep it a plain constructor parameter, no internal Provider read — consistent with
the file's own doc comment ("every value arrives already formatted from its caller").

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | `flutter_test` (bundled with Flutter SDK), no `dart_test.yaml` |
| Quick run command | `"C:/Users/User/Documents/Projects/GNUS/flutter/flutter/bin/flutter" test test/account/ test/components/desktop_top_bar_text_scale_test.dart test/components/mobile_header_brand_and_pill_test.dart` |
| Full suite command | `"C:/Users/User/Documents/Projects/GNUS/flutter/flutter/bin/flutter" test` |

Flutter is not on `PATH` — use the full path above. Baseline: 1943 passed/5 skipped/0 failed
(`34-05-SUMMARY.md`).

### Phase Requirements → Test Map
| Req ID | Test Type | Automated Command | File Exists? |
|--------|-----------|-------------------|-------------|
| SWT-01 (one switcher, old chips gone) | widget | `flutter test test/components/desktop_top_bar_text_scale_test.dart` (re-run) | ✅ existing |
| SWT-02 (independent selection) | widget | New test mirroring `account_drawer_show_test.dart`'s pattern | ❌ Wave 0 |
| SWT-03 (mobile opens switcher) | widget | `flutter test test/components/mobile_header_brand_and_pill_test.dart` (re-run) | ✅ existing |
| SWT-04 (create/import/delete) | widget | `flutter test test/account/sdk_add_account_test.dart sdk_account_delete_coupling_test.dart sdk_start_account_delete_test.dart` (re-point host widget) | ✅ existing, needs re-pointing |
| SWT-05 (Send/Swap name wallet) | widget | New tests — check `test/reown/`/`test/send/`/`test/squid_router/` first for existing coverage to extend | ❌ Wave 0 |

### Sampling Rate
Per task commit: the targeted file(s) above. Per wave merge: full `flutter test`. Phase gate: full
suite green before `/gsd-verify-work`; VER-02's live-testnet walk stays a recorded-pending human item.

### Wave 0 Gaps
- [ ] Independent-selection test (D-06) — the merged drawer doesn't exist yet, so no file asserts it
- [ ] Send review "From" wallet-name test (D-12) — confirm no existing `test/send/` coverage first
- [ ] Swap CTA-area "Sending from" line test (D-13) — confirm no existing `test/squid_router/` coverage first

## Security Domain

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V4 Access Control | yes | `sdkRowActions`/`sdkDeleteBlock` gating (unchanged, relocated verbatim per D-10) |
| V5 Input Validation | no | No new input surface — `_AddAccountDialog`/payout form relocated, not modified |
| V6 Cryptography | no | No key material flows through new widgets; `getSelectedAccountMnemonic()` calls unchanged |
| V2/V3 | no | Not touched |

| Pattern | STRIDE | Mitigation |
|---------|--------|-----------|
| Mnemonic/key reaching a new Bloc/Cubit state field | Information Disclosure | AGENTS.md rule already enforced (`_buildAccountRow`'s `mnemonic` is a local `final`, never `emit()`'d) — no new state class should store it |
| Wrong-account send (node account vs. active wallet confusion) | UX, not STRIDE | D-14's identical section labels everywhere — the mitigation `PITFALLS.md` Pitfall 7 names |

## Sources

### Primary (HIGH confidence — direct `Read`/`Grep` this session)
- `lib/account/account_drawer.dart`, `lib/account/sdk_account_manager.dart`,
  `lib/account/account_dropdown_selector.dart` (full files)
- `lib/components/overlay/responsive_overlay.dart:1-100`, `mobile_header.dart:330-490`,
  `more_sheet.dart:55-75`; `lib/components/wallet_overview.dart:95-120`
- `lib/bloc/app_bloc.dart:760-860` — `linkedWallet`, `sdkAccountName`, `sdkDeleteBlock`, `_mergeSgnusWallet`
- `lib/wallets/cubit/wallet_details_cubit.dart:140-180` — `selectWallet`, `restoreSelectedWallet`
- `lib/send/send_screen.dart:245-285`, `lib/reown/send_transaction_details.dart` (full file),
  `lib/components/data/gw_copy_row.dart` (full file)
- `lib/squid_router/swap_screen.dart:430-470,690-780,1100-1115`
- `test/account/account_drawer_show_test.dart` (full file), `account_drawer_network_section_test.dart`,
  `test/components/desktop_top_bar_text_scale_test.dart`, `mobile_header_brand_and_pill_test.dart`
- `Grep` across `lib/` for `WalletType.sgnus`, `AccountDrawer\.show`, `SendTransactionDetails\(`

### Secondary (MEDIUM confidence)
- `.planning/research/ARCHITECTURE.md` §(b)(c), `.planning/research/PITFALLS.md` pitfalls 6/7 —
  cross-checked against `app_bloc.dart:747-760` (no in-flight guard, confirmed still absent)

### Tertiary (LOW confidence)
None — every claim above traces to a file this session read or grepped.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | No existing `test/send/` or `test/squid_router/` test already covers the exact rows this phase adds (SWT-05's two new lines) | Validation Architecture — Wave 0 Gaps | Low — worst case the planner writes a duplicate test; verify by grepping those directories before writing Wave 0 tests |

**All other claims in this research are `[VERIFIED: file:line]` against code read this session** —
this table is intentionally short because the caller/test maps above were built from direct reads,
not inference.

## Metadata

**Confidence breakdown:**
- Standard stack: N/A — no new library
- Architecture: HIGH — every file/line cited was read this session
- Pitfalls: HIGH — cross-checked against both `ARCHITECTURE.md`/`PITFALLS.md` and live code

**Research date:** 2026-09-29
**Valid until:** Next `develop` merge that touches `lib/account/`, `lib/send/`, or
`lib/squid_router/swap_screen.dart` — this research pins exact line numbers, which drift fast
