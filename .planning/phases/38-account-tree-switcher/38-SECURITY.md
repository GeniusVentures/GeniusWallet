---
phase: 38
slug: account-tree-switcher
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: 2026-09-30
---

# Phase 38 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.

Verified against HEAD `985962ac`, including the post-plan fixes. "Run node as this" is now "Earn with this account" and the "On node" tag is now "Earning"; controls were verified by function.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| Drawer -> SDK via registry | Synchronous reads of the user's own accounts' registrations through `ownRegistrations()`; the widget makes no SDK call | Public only: child addresses, names, linked wallets, GNUS balances |
| Row menu -> SDK | Node switch, payout address, recovery phrase / QR, account delete | Payout address; recovery phrase read at build time for the on-node row only |
| Nested row menu -> SDK writes | Fund, Recover, Revoke via `start*` and the registry | Amounts in minions, child and main addresses |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-38-01 | DoS | `buildAccountTree` | medium | mitigate | Single `visited` set across the walk; cycles placed once (`account_tree.dart:118-215`); cycle and self-listing tests | closed |
| T-38-02 | DoS | drawer build | low | mitigate | Registrations read only when the cache key (incl. wallets and links) changes (`account_drawer.dart:226-246`) | closed |
| T-38-03 | Tampering | foreign leaf actions | medium | mitigate | Same `start*` flows, locks, `ensureRunningAs` and `submit` re-checks as the Child wallets screen | closed |
| T-38-04 | Info disclosure | `ownRegistrations` | low | accept | See accepted risks | closed |
| T-38-05 | Elevation | merged and nested menus | high | mitigate | One `sdkRowActions(isSelected: onNode)` gates payout, phrase, QR, child wallets, delete (`account_drawer.dart:881-963`) | closed |
| T-38-06 | Info disclosure | Copy recovery phrase / QR | high | mitigate | Only mnemonic read is a build local for the on-node row (`account_drawer.dart:880`); clipboard clear; QR in `SecureScreen`; key-logging scan clean | closed |
| T-38-07 | Tampering | node switch item | high | mitigate | Single `SelectSDKAccount` site, disabled when on node, switching or locked (`account_drawer.dart:891-895`) | closed |
| T-38-08 | Spoofing | tags | medium | mitigate | Selected and Earning derived and rendered independently (`account_drawer.dart:423-536,713-721`); merge matches type + address | closed |
| T-38-09 | Tampering | delete items | medium | mitigate | Separate Delete wallet / Delete account items; dialogs name what goes; blocks enforced | closed |
| T-38-10 | Elevation | nested own row actions | high | mitigate | Only on depth >= 1 rows with a child; locks via `balanceLockReason` / `isPending` (`account_drawer.dart:970-1012`) | closed |
| T-38-11 | Tampering | wrong-side submit | high | mitigate | `ensureRunningAs` before every flow; `submit` refuses a wrong-side runner with no SDK call | closed |
| T-38-12 | DoS | preset listener | low | mitigate | Add/remove under the same const dev gate (`account_drawer.dart:199-212`) | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-38-01 | T-38-04 | Reads only the user's own accounts, the same boundary `/child-wallets` already crosses; `ChildWallet` holds public data only | plan 38 | 2026-09-30 |

Observation, not registered: while an SDK switch is pending, row state follows the lagging `selectedSDKAccount`, so the row being left keeps phrase/QR/payout and the target row keeps Delete account enabled. Same as before this phase; SDK and `sdkDeleteBlock` still guard deletes. Closing it means gating actions on `!switching`.

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-09-30 | 12 | 12 | 0 | gsd-security-auditor |

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-09-30
