# Changelog — `ui-redesign-3.514`

What moved in this branch, so a developer integrating it knows exactly what changed and where.

| | |
|---|---|
| **Branch** | `ui-redesign-3.514` |
| **Base (merge-base)** | `0495436` on `dev_logsubmissions` |
| **Commits since base** | 73 (`git rev-list --count 0495436..HEAD`) |
| **Current HEAD** | `254a480` |

> This supersedes the frozen metrics in `HANDOFF.md` §1 (written at ~commit 45). Note also that
> `HANDOFF.md` §1's "no SDK or build-system work" is now slightly off: `pubspec.yaml`'s SDK floor was
> bumped (see below). The redesign is still UI/Dart-only otherwise.

The bulk of the branch is the **GNUS UI redesign + polish** documented in `HANDOFF.md` and
`DESIGN_SYSTEM.md`. The entries below are the **post-review fixes** (after the original review HEAD
`1b83a67`) — they close items raised in `REVIEW_FINDINGS.md` and prepare the remaining work as
`WIRING.md`.

---

## Post-review fixes

### `a0c6825` — fix(swap): honest demo, no fabricated transaction
The Swap confirm called no API yet showed the success drawer and **persisted a fake
`TransactionStatus.completed` swap** to Hive (`hash:""`, not mock-gated, reachable via the global
Swap FAB). It now shows a `Swap submitted (demo)` notice and persists nothing — matching the Send/Buy
demos. Marked the Squid mock service + real-flow restore path with `WIRE-1`.
Closes `REVIEW_FINDINGS.md §B1`. _Real Squid wiring still pending — see `WIRING.md` WIRE-1._

### `75d2ba2` — chore(wiring): markers, QR fixes, handoff docs
- **`extractWalletAddress`** (`lib/components/qr_scanner/gw_qr_scanner.dart`) now returns the EIP-681
  transfer **payee** (`?address=`) instead of the token contract. Closes the EIP-681 half of §C2.
- **QR scanner** got an `errorBuilder` (permission-denied / no-camera recovery UI instead of a blank
  black screen). Closes §E3.
- **Greppable `WIRE-1..11` markers** added at every remaining integration point
  (`grep -rn "WIRE-" lib/`), mapped 1:1 to `WIRING.md`.
- Added **`REVIEW_FINDINGS.md`** (verified pre-production findings) and **`WIRING.md`** (the wiring
  checklist).

### `bc8dd7a` — feat(touch): type scale + ≥44/48 controls
Touchscreen legibility + tap-target pass (see `DESIGN_SYSTEM.md` migration **v1.4**):
- **Type scale:** `bodyMd` 14→16 (default body), `bodySm` 13→14, `labelMd` 12→13, bottom-nav label
  11→12.
- **Tap targets:** Assets/NFTs segmented tabs 36→48; GNUS/Minions `ToggleButtons` 40→48; swap
  token-flip FAB 40→48 (`mini`→`.small`).

### `254a480` — fix(a11y): contrast, tap targets, input guard, SDK floor
- **Button contrast:** `GWButton` `primary`/`gradient` foreground + dark `ColorScheme.onPrimary` →
  `textOnBrand` (white failed WCAG AA on the bright brand fill). `GWButtonSize.sm` 36→44. Closes the
  first half of §E4.
- **Tap targets:** `GWSwitch`/`GWCheckbox` dropped `shrinkWrap`/compact so they keep Flutter's 48px
  min tap target; Send recipient icons 18→22; Buy quick-amount chip gap 8→12.
- **Amount input:** `SingleDecimalSeparatorFormatter` (`lib/utils/formatters.dart`) on the Send/Buy
  amount fields blocks junk + a second separator. _(Lone grouping comma `"1,000"`→`1.0` still open —
  `WIRING.md` WIRE-4.)_
- **Toolchain:** `pubspec.yaml` SDK floor `>=3.0.0` → `>=3.4.0 <4.0.0`, `flutter: ">=3.22.0"`.
  Closes §E2. **Run `flutter pub get` after merging.**

---

## What is still open (not changed here)

These remain as documented — start from `REVIEW_FINDINGS.md` §G and `WIRING.md`:

- 🔴 Send recipient-address **validation** (§C2); `WALLET_PK` is the real signing key (§C1).
- 🟠 **Rebase** onto current `dev_logsubmissions` (now +96 commits, Banxa conflicts — §A1); red
  **tests** + `build_runner` (§C5/C6); Sentry PII + hardcoded secrets (§C3/C4).
- 🟠 The **wiring** itself — Swap/Send/Buy/Currency/NFT/AI (`WIRING.md` WIRE-1/2/5–11).
- ⚪ Inter font runtime fetch (§E1); `textSecondary` light-canvas contrast; locale-aware amount
  parsing (WIRE-4); camera permission native config (§A3, `HANDOFF.md` §5a).
