---
phase: 34
slug: account-linking
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: 2026-09-30
---

# Phase 34 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.

Verified against HEAD `985962ac`. Commit `6ef490f2` deleted plan 04's SDK-only add dialog and its whole surface; T-34-12, T-34-13 and T-34-15 are closed by removal. A future SDK-secret entry form reopens them.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| Secure storage, on-device | Link map `__sdk_links__` beside the stored wallets, same trust level | SDK address, wallet address, wallet name (public) |
| Key material into FFI | Keys decrypted only in `_initSDK` / `_addToSDK` and handed to the SDK | Mnemonic or private key, one way |
| AppState / bloc -> UI | Widgets render public addresses and names from `sdkAccountLinks` | Addresses, names, badge status |
| Destructive user action -> AppBloc | Delete taps enforced in the bloc, not the widget | Wallet and SDK addresses |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-34-01 | Info disclosure | link record, `sdkAccountLinks`, logs | high | mitigate | Link holds address + name only; no key field on `AppState`; added logs are value-free | closed |
| T-34-02 | Spoofing | wrong wallet name on an SDK account | medium | mitigate | Links written only from start address, single-new-address diff, or `backfillLinks`; else "Unlinked" (`genius_api.dart:503-718`) | closed |
| T-34-03 | Tampering | `__sdk_links__` edited on device | low | accept | See accepted risks | closed |
| T-34-04 | DoS | link save throws during import | medium | mitigate | Every save in try/catch; failing queue task never blocks the next | closed |
| T-34-05 | Spoofing | row title naming the wrong wallet | medium | mitigate | One naming rule `AppBloc.sdkAccountName`; short address always shown | closed |
| T-34-06 | Info disclosure | SDK row phrase and QR | high | mitigate | `isSelected && hasMnemonic` gate; mnemonic read only for the running row, matched on SDK address | closed |
| T-34-07 | Repudiation | pending SDK account looks like none | low | mitigate | "Setting up" badge while the SDK is not running (hidden on the selected row since phase 38) | closed |
| T-34-08 | Info disclosure | re-add decrypts unlinked keys | high | mitigate | `_addToSDK` returns only a status; no log, state or store receives key material | closed |
| T-34-09 | DoS | SDK account list inflated by re-adds | high | mitigate | Only unlinked wallets re-added; pass stops on a jump above one; test pins it | closed |
| T-34-10 | Spoofing | wrong name via elimination | medium | mitigate | Needs `RET_OK`, one candidate, one unclaimed leftover; tested | closed |
| T-34-11 | Tampering | account deleted by an older build returns | low | accept | See accepted risks | closed |
| T-34-12 | Info disclosure | secret in event, outcome, toasts | high | mitigate | Vector removed (`6ef490f2`); no secret field on events or state | closed |
| T-34-13 | Tampering | malformed secret | medium | mitigate | Vector removed; surviving imports return before save on a null key | closed |
| T-34-14 | DoS | SDK half fails after wallet saved | high | mitigate | Key saved first; SDK half in try/catch; backfill links it later | closed |
| T-34-15 | Tampering | duplicate wallet via the form | low | mitigate | Vector removed; storage key is the lowercased address | closed |
| T-34-16 | DoS | SDK delete removes a wallet's key | high | mitigate | Bloc refuses default, active and last wallet (`app_bloc.dart:809-957`); dialogs name the wallet; tested | closed |
| T-34-17 | Elevation | widget calls API delete directly | high | mitigate | Only `app_bloc.dart` calls `deleteWallet` / `deleteAccount` | closed |
| T-34-18 | Repudiation | unclear what a delete removed | medium | mitigate | Dialog names the wallet; toast only after the address leaves the list | closed |
| T-34-19 | Tampering | concurrent SDK and wallet deletes | low | accept | See accepted risks | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-34-01 | T-34-03 | Editing the link map needs the device access that already exposes the wallets. Since plan 05 the link also picks which wallet an SDK-account delete removes; the confirmation names that wallet | plan 34-01 | 2026-09-30 |
| AR-34-02 | T-34-11 | Restores the one-account-per-wallet rule; the key never left the device | plan 34-03 | 2026-09-30 |
| AR-34-03 | T-34-19 | Both delete events are `sequential()`; a race needs two modal confirmations at once | plan 34-05 | 2026-09-30 |

Observations, not registered: `_initSDK` does not reject the SDK's `0xUNVAILABLE` placeholder when recording the start link (can leave the start account "Unlinked" until next start); `_freezeLinkNames` writes links outside `_linksLock` (could drop one label update); `_addToSDK` builds the private-key hex as a `String` (pre-existing, AGENTS.md prefers `Uint8List`).

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-09-30 | 19 | 19 | 0 | gsd-security-auditor |

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-09-30
