# Continue after /compact — Transactions empty state

**IMMEDIATE NEXT TASK: build sketch 028 for the Transactions EMPTY STATE, then open it in Jakub's
browser and show him. Do nothing else first — he asked for exactly this.**

## The task

There are two empty states. This is the **never-transacted** one (`scoped.isEmpty`), NOT the
filtered-empty one.

**Problem (Jakub's screenshot #19):** on a zero-transaction wallet the rail is hidden (correct —
locked 021/022 decision), leaving ONE full-width card ~1370px wide with a tiny "No transactions yet"
icon+text floating in a giant void. Reads as a big empty box.

**Jakub asked:** keep the Type rail on empty + make the box narrower? **My answer (he accepted, wants
to SEE it):** keeping the rail is wrong — on a never-transacted wallet every count is 0, a rail of
zeros looks more broken not less, and it reverses the locked "hide the filter when there's nothing to
filter" decision. Also the rail alone doesn't fix it: the list card stays ~1130px wide and empty. The
real fix is the box itself.

**Build sketch 028 — REAL SIZE, real navbar+page frame, per the `sketch-fidelity-real-size` memory
(NO scaled thumbnails, he called those "impoverished").** Variants:
- **E-a · narrow centred card** (~480–560px, short) instead of full-width
- **E-b · no card at all** — icon+text centred on the page surface (what many wallets do)
- **E-c · keep rail (zeros) + narrow box** — include ONLY so he can see why it reads worse
Recommend E-a or E-b. Provenance tags, contrast if relevant, one recommendation with cost.
Then: `open http://localhost:8899/028-transactions-empty-state/index.html` (server on :8899 in
`.planning/sketches/`; start it if down: `cd .planning/sketches && python3 -m http.server 8899`).

## Tree state (uncommitted, branch redesign/transactions-tab-260722, PR #211 open)

Transactions walk changes, all in working tree, **tests 225 green / 1 known-red** (commented-out
`local_wallet_storage_test.dart`):
- V3 hug + 496px list-card floor, page scrolls (`transactions_screen.dart`)
- cap **1600** (fullscreen fill)
- **gap 32px** (space16) navbar→title, Transactions-only (Markets/News still 8 — deliberate follow-up)
- rail: no All row, starts at Type; tap active row → clears to All
- no footer total anywhere (panel + page)
- amount column `Flexible` (full wide / ellipsis narrow) — fixed 31px @320px overflow
- freeze fix (7 AutoSizeText→Text) + `test/freeze_rule_test.dart`

## Open decisions (do NOT implement without Jakub)
- Header actions (sketch 025): Receive/Send/Export/toggle — B or B+C
- Page structure (sketch 026): S2 or S3-left-sidebar-as-a-phase (S1 title-drop REJECTED, he wants the title)
- App-wide gap alignment (Markets/News to 32) — follow-up

## Binding rules
- No commits without Jakub. Never `git add -A`. `cmake/*` stays uncommitted.
- Freeze rule: no AutoSizeText/FittedBox/constraint-derived font size in dashboard-reachable code
  (`test/freeze_rule_test.dart` guards it).
- App run: FIFO pattern; `setsid` does NOT exist on macOS; kill stale instance before relaunch (Hive
  lock at `~/Library/Containers/ai.gnus.GeniusWallet.jakub/`).
- `.planning/.continue-here.md` is a STALE Windows Phase-06 handoff — NOT this work. Do not act on it.
