# Phase 34: Account linking - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-09-29
**Phase:** 34-account-linking
**Areas discussed:** SDK-only adds, Delete coupling, Old-account backfill, How a link reads

---

## SDK-only adds

| Question | Options | Selected |
|---|---|---|
| What the SDK Accounts add form does | Also save the wallet / Remove the form / Keep SDK-only | Also save the wallet |
| Seed/key already a wallet | Link, don't duplicate / Refuse | Link, don't duplicate |
| Naming a wallet saved via the form | Same as normal import / Ask in the form / You decide | Same as normal import |
| Selection after an add | Nothing changes / SDK wallet switches / Same as normal import | Nothing changes |
| Two ways in | Keep both for now / Fold into one | Keep both for now |
| Half-failed add | Keep what worked, link later / All or nothing | Keep what worked, link later |
| Adding while the node is down | Yes, link when it's up / Block SDK-form adds only | Yes, link when it's up |

## Delete coupling

| Question | Options | Selected |
|---|---|---|
| Delete wallet with a linked SDK account | Delete both / Ask each time / Keep SDK account | Keep SDK account |
| Delete SDK account | Delete both / SDK account only | Delete both |
| Warn if funded or has children | Warn with the balance / Block while funded / No extra warning | No extra warning |
| Label after its wallet is deleted | Keep old name, marked / Plain Unlinked | Keep old name, marked |
| SDK delete would remove the active wallet | Block with reason / Fall back automatically | Block with reason |
| Fix the drawer delete bug here | Fix it in 34 / Leave it to 35 | Fix it in 34 |
| SDK delete confirmation text | Say it removes both / Existing text | Say it removes both |

## Old-account backfill

| Question | Options | Selected |
|---|---|---|
| When to link old accounts | Once, automatically / Every start / User-triggered | Once, automatically |
| If re-adding creates duplicates | Skip backfill, show Unlinked / Backfill then delete dupes | Skip backfill, show Unlinked |
| Accounts matching no wallet | Unlinked + short address / Prompt to import | Unlinked + short address |
| Start-up account | Link it directly / Treat like the rest | Link it directly |

## How a link reads

| Question | Options | Selected |
|---|---|---|
| Linked row label | Name + short SDK address / Name + 'SDK' / Name only | Name + short SDK address |
| "Super Genius Wallet N" rows | Relabel with the link / Remove now | Relabel with the link |
| SDK marker on ETH wallet rows | Leave for Phase 35 / Small SDK marker now | Small SDK marker now |
| UI name for the start-up account | 'Start account' / 'Default account' / You decide | 'Default account' |

**Note:** the rename of the start-account concept was scoped to Dart identifiers only; the persisted storage key string is unchanged, so no migration is needed.

## Claude's Discretion

- Link map storage location and shape (public addresses only).
- How "SDK account pending" and "Unlinked" are surfaced within existing row components.

## Deferred Ideas

- Where add/import lives, and folding the SDK form into normal import: Phase 35.
