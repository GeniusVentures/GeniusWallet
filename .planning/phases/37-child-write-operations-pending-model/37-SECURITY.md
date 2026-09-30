---
phase: 37
slug: child-write-operations-pending-model
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: 2026-09-30
---

# Phase 37 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.

Verified against HEAD `985962ac` (after phase 38). Line numbers without a file refer to `lib/child_wallets/child_operations_cubit.dart`.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| User input -> registry | A typed amount and a chosen child become an SDK write | Amount text -> BigInt minions; child and main addresses |
| Registry -> SDK | Fire-and-forget write; `RET_OK` means submitted, not confirmed | Canonical GNUS string; public addresses; empty metadata |
| User -> SDK account switch (`ensureRunningAs`) | A tap changes which account the node signs as | Public address; `SelectSDKAccount` |
| Typed main address -> SDK | Free text becomes the main a registration binds to | `0x` + 128-hex string |
| Switcher tap -> SDK account switch | Changes the account a pending op was submitted from | Public address |
| Dev fixtures -> registry | Simulated writes replace SDK writes in dev-tools debug builds only | Simulated registrations, balances, outcomes |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-37-01 | Elevation | `submit` | high | mitigate | Refuses unless running account equals the required side (356-361); write wrappers called only from the cubit (428-447); every dialog calls `ensureRunningAs` first | closed |
| T-37-02 | Tampering | `parseGnusAmount` / `submit` | high | mitigate | Base-unit BigInt parse, 6-decimal cap, >0, balance cap (603-630); re-checked in `submit` (384-391); no doubles | closed |
| T-37-03 | Repudiation | Row menu / `submit` | high | mitigate | Registry refuses on `balanceLockReason` / `isPending` before any SDK call (378-383); menus lock with tooltip | closed |
| T-37-04 | Spoofing | `resolve` / toasts | high | mitigate | Success toast only from `resolve()`; signal checked before timeout; expired/switchedAway/mocked block resolution (483-538) | closed |
| T-37-05 | Info disclosure | `ChildOperationsState` | medium | mitigate | Public addresses, minions, flags only (44-115); key-logging scan clean | closed |
| T-37-06 | DoS | Registry timer | low | mitigate | Created after `RET_OK`, cancelled when idle and in `close()` (464-467, 515-518, 593-597) | closed |
| T-37-07 | Tampering | `ensureRunningAs` | high | mitigate | Refuses with a pending op from the running account; confirm first; true only on observed switch (`child_operation_switch_dialog.dart:34-110`) | closed |
| T-37-08 | Elevation | Recover / revoke submit | high | mitigate | Main-side check (25-28, 356-361); `ensureRunningAs` first | closed |
| T-37-09 | Spoofing | Revoke resolution | medium | mitigate | Failed read never resolves; case-insensitive compare (549-551, 576-590) | closed |
| T-37-10 | Tampering | Recover amount | high | mitigate | Cap is child balance less held amounts (310-315), re-checked in `submit` | closed |
| T-37-11 | Tampering | `isSdkAddress` / picker | medium | mitigate | Strict 128-hex regex; self/excluded refused; `submit` backstop against self-referential register/move (365-377) | closed |
| T-37-12 | Elevation | Register / detach submit | high | mitigate | Child-side kinds require running as target (357); `ensureRunningAs` first | closed |
| T-37-13 | Spoofing | Register resolution | medium | mitigate | Resolves only on an OK read listing the target under main (552-553) | closed |
| T-37-14 | Info disclosure | Foreign mains | low | accept | See accepted risks | closed |
| T-37-15 | Tampering | Switcher row tap | high | mitigate | Only two `SelectSDKAccount` dispatch sites; drawer item disabled when locked (`account_drawer.dart:892-895`) | closed |
| T-37-16 | Spoofing | Move resolution | medium | mitigate | Needs both old-main absence and new-main presence (554-558) | closed |
| T-37-17 | Elevation | Move submit | high | mitigate | Child-side check (357); `ensureRunningAs` first | closed |
| T-37-18 | DoS | Lock never releasing | medium | mitigate | `notConfirmed` ops release the switcher lock; fund/recover lock expires at 6 min (D-18) | closed |
| T-37-19 | Tampering | Registry write seam | high | mitigate | Single seam `_devMocked ? mock : SDK` (425-448); source change blocks resolution (528) | closed |
| T-37-20 | Spoofing | `DevMockChildWallets` | medium | mitigate | `kDebugMode && _devTools && preset != null`; `_devTools` defaults to const `kShowDevTools` | closed |
| T-37-21 | DoS | Simulated timers | low | mitigate | `clear()` cancels scheduled writes (`dev_mock_child_wallets.dart:83-92`) | closed |
| T-37-22 | Info disclosure | Build gate | low | accept | See accepted risks | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-37-01 | T-37-14 | A main registered by someone else stays undiscoverable; the SDK has no by-child query (CONTEXT D-04, `ponytail:` in `child_wallets_cubit.dart`) | plan 37 | 2026-09-30 |
| AR-37-02 | T-37-22 | Build only; no app launch, no wallet data read or written | plan 37-05 | 2026-09-30 |
| AR-37-03 | T-37-04 | Known false-done ceilings: a fund on a zero baseline read before the child synced, and unrelated movement on the child within the 6-minute window, can read as landed (`ponytail:` comments) | CONTEXT D-18 | 2026-09-30 |

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-09-30 | 22 | 22 | 0 | gsd-security-auditor |

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-09-30
