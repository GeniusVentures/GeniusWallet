---
phase: 35
slug: unified-header-switcher
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: 2026-09-30
---

# Phase 35 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.

Phase 38 replaced several phase-35 components (the two sections became one Accounts tree, `SDKAccountRow` became `_AccountRowTile`, the SDK-only add dialog was deleted). Mitigations were verified against the code that implements them now.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| Drawer UI -> AppBloc / GeniusApi / clipboard | Account select, add, delete and recovery-phrase copy from the switcher | SDK and wallet addresses, the selected account's recovery phrase (clipboard or QR), select/delete events |
| App -> signer | Send review and Swap name the account whose key signs | Selected wallet name and address, signing address |
| Header chip -> switcher drawer | The only desktop entry point for account actions | Wallet and SDK account names (tooltip), no secrets |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-35-01 | Info disclosure | Recovery-phrase handling | high | mitigate | Mnemonic is a build-local read for the on-node row only (`account_drawer.dart:880`); confirm dialog + 60 s clipboard clear (`sdk_account_manager.dart:31-54`, `secret_clipboard.dart`); QR in `SecureScreen`; key-logging scan clean | closed |
| T-35-02 | Elevation | Deletes from the switcher | high | mitigate | Menu gate `!isSelected && !isStartAccount` (`sdk_account_manager.dart:296-307`); bloc re-checks `sdkDeleteBlock` / `canDeleteWallet` (`app_bloc.dart:679,948-958`); covered by three delete tests | closed |
| T-35-03 | Spoofing | Wrong selection changed | medium | mitigate | Row tap only selects the wallet; "Earn with this account" only dispatches `SelectSDKAccount` (`account_drawer.dart:99-103,663-672,888-902`); distinct Selected/Earning badges | closed |
| T-35-04 | Tampering | View balance lookup | low | accept | See accepted risks | closed |
| T-35-05 | Spoofing | Send From name | high | mitigate | Name shown only when the selected wallet is the signer (`send_screen.dart:266-288`); Swap says "Can't sign from…" when `canSendFrom` fails | closed |
| T-35-06 | Info disclosure | GWCopyRow caption | low | accept | See accepted risks | closed |
| T-35-07 | Tampering | Reown approval drawer | medium | mitigate | Caption is caller-supplied; Reown and dev call sites pass none (`handle_dapp_requests.dart:155-166`) | closed |
| T-35-08 | Spoofing | Chip tooltip | medium | mitigate | Tooltip names both selections (`account_switcher.dart:43-51`); tested in `desktop_top_bar_text_scale_test.dart` | closed |
| T-35-09 | Elevation | Removing the SDK chip | high | mitigate | Old chip has zero references; every SDK action reachable from the drawer row menu (`account_drawer.dart:895-964`) | closed |
| T-35-10 | Info disclosure | Build gate | low | accept | See accepted risks | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-35-01 | T-35-04 | Public addresses only; lowercased match; disabled with no match | plan 35-01 | 2026-09-30 |
| AR-35-02 | T-35-06 | Display only; clipboard keeps the full public address; no key material through this widget | plan 35-02 | 2026-09-30 |
| AR-35-03 | T-35-10 | Build only; no app launch, no wallet data read or written | plan 35-03 | 2026-09-30 |

Out of scope here: Fund/Recover/Revoke (phases 36-37) and Delete wallet on merged rows (phase 38) in the same row menu. The recovery phrase stays a `String` because the clipboard and QR APIs need one; unchanged from before this phase.

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-09-30 | 10 | 10 | 0 | gsd-security-auditor |

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-09-30
