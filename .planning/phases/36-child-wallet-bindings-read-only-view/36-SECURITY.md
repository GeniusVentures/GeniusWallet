---
phase: 36
slug: child-wallet-bindings-read-only-view
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: 2026-09-30
---

# Phase 36 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| native SDK -> Dart | SDK-allocated registration array and uint64 balances cross into Dart | Registration entries (public addresses, sequence, metadata strings), raw uint64 balances, SDK-owned array pointer |
| Dart caller -> native SDK | Strings and amounts marshalled into fixed-size C buffers and uint64 params | Metadata strings (128-byte fields), GNUS amount strings (22-byte field), token ids, amounts, addresses |
| dev fixtures -> child-wallet screen | Synthetic data replaces SDK reads in dev-tools debug builds only | Fake registrations, balances, `0xDEV...` addresses |
| SDK row menu -> local read | UI-only gate on a local CRDT read | The selected SDK account's own address |
| cubit state -> logs/observers | Bloc state is printable and reaches `BlocObserver` logs | Public addresses, wallet names, balance strings |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-36-01 | Tampering | collectChildRegistrations | high | mitigate | Copy-then-free-once; inner finally frees non-null entries once, outer finally releases out-params (`genius_api.dart:171-205`); tests in `child_wallet_ffi_test.dart:90-218` | closed |
| T-36-02 | Tampering | struct layout drift | high | mitigate | Structs match `GeniusSDK.h:81-108`; sizes 392/664 asserted (`child_wallet_ffi_test.dart:80-86`) | closed |
| T-36-03 | Info disclosure | ChildWalletsState | high | mitigate | State holds only addresses, names, `Wallet?`, balance strings (`child_wallets_cubit.dart:21-71`); `Wallet` has no key field; key-logging gate clean on child-wallet files | closed |
| T-36-04 | Elevation | menu gate | low | accept | See accepted risks; gate present anyway (`sdk_account_manager.dart:306`, `account_drawer.dart:943`) | closed |
| T-36-05 | DoS | 10 s poll | low | mitigate | Timer cancelled in `close()` (`child_wallets_cubit.dart:90,232`); route closes cubit; poll-stop test in `child_wallets_screen_test.dart:469-506` | closed |
| T-36-06 | DoS | getPubSubHandle | high | mitigate | Returns an int address, never freed (`genius_api.dart:1576-1582`); no other callers | closed |
| T-36-07 | Tampering | writeRegistrationMetadata, writeTokenValue | high | mitigate | UTF-8 byte-length checks (127 / 21) before write (`genius_api.dart:217-246`); false maps to INVALID_ARGUMENT; boundary tests | closed |
| T-36-08 | DoS | char-array reads | medium | mitigate | Bounded read, byte mask, `allowMalformed: true` (`genius_api.dart:43-57`) | closed |
| T-36-09 | Tampering | fund/recover amounts | medium | mitigate | `uint64Arg` range check before any native call (`genius_api.dart:257-262,1640-1696`) | closed |
| T-36-10 | Elevation | write wrappers | low | accept | See accepted risks | closed |
| T-36-11 | Spoofing | DevMockChildWallets | medium | mitigate | Every read gated by `kDebugMode && kShowDevTools` (const define); only the dev bubble arms presets | closed |
| T-36-12 | DoS | preset listener | low | mitigate | add/removeListener under the same gate (`child_wallets_cubit.dart:95,233-235`) | closed |
| T-36-13 | Spoofing | synthetic addresses | low | mitigate | `0xDEV…` addresses are non-hex, distinct in last four chars (`dev_mock_child_wallets.dart:159-172`) | closed |
| T-36-14 | Info disclosure | build gate | low | accept | See accepted risks | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-36-01 | T-36-04 | UI-only gate on a local read; querying another address's children exposes nothing secret | plan 36-01 | 2026-09-30 |
| AR-36-02 | T-36-10 | No UI caller this phase. Superseded by phase 37, which calls the wrappers; boundary checks (T-36-07, T-36-09) still hold | plan 36-02 | 2026-09-30 |
| AR-36-03 | T-36-14 | Build-only step; no app launch, no wallet data read or written | plan 36-03 | 2026-09-30 |

Notes: `account_drawer.dart:234` reads the dev preset outside the gate as a memo key; it is always null outside a dev-tools build. `check_no_new_key_logging.sh` defaults to one file; it was run against the child-wallet files manually.

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-09-30 | 14 | 14 | 0 | gsd-security-auditor |

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-09-30
