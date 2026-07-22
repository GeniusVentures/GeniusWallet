# Session summaries — 2026-07-22, session A (Transactions)

Two documents, two audiences. Do not merge them.

---

# 6a · Message to Brian

**Nothing is blocked on you technically. Three things are blocked on a decision, and one of them is a spec defect that later plans will keep copying until it is settled.**

## Spec defect — the brand gradient disagrees in three places

Sketch mockups paint `#14C8FF → #2BF5B4`. The app's `GeniusWalletGradient.brandCta` is `[gradientGreen #0AD89C, gradientBlue #0AAEE6]` (`genius_wallet_gradient.dart:16-23`). And the comment at `genius_wallet_gradient.dart:15` claims it mirrors the website's `linear-gradient(270deg, #0c91cc, #06aa78)` — a third pair.

**Every gradient decision approved off a mockup was approved against colours the app does not paint.** Found when the Phase 15 plan-checker measured contrast against source and the numbers did not match the sketch's table. In that instance the conclusion survived — `#0AAEE6` on white measures **2.56:1**, still under the 3:1 WCAG 1.4.11 wants, so the degradation to `#0A6885` (**6.30:1**) was needed either way — but that was luck, not method. The pairs differ by up to 3 contrast points.

Logged: `.planning/todos/pending/2026-07-22-sketch-theme-gradient-mismatch.md`. Sketches carrying an approved gradient decision that may need re-measuring: 002, 005, 006, 008, 011-014, 020-022.

Phase 15 is unaffected, because its active mark was specified as *"whatever the navbar uses"*, which resolves to `brandCta` regardless of which pair wins.

## Process/tooling bugs

**1. The end-session signing guard fires for everyone, forever.** `/end-session` step 4 says `git diff --name-only origin/HEAD..HEAD | grep -E "pbxproj|AppDelegate|Info.plist|Podfile.lock"` must return nothing. It returns five files. They are **not from this session** — they came in via `d718996` (itsafuu, 2026-07-03), `dc1e752` (itsafuu, 2026-03-31), `20abc38` (Henrique, 2025-10-30), `6ffc35b` (itsafuu, 2025-10-28), `af01e3e` (TechUp24, 2025-10-24). Because the check diffs against `origin/main`, it covers every commit on the port branch by every author, so it can never answer *"did I do this?"*. Either scope it to the session's own commits or deal with those five.

**2. Sketch numbers collide when two sessions run — second occurrence.** `020-transactions-tab` (session A) vs `020-boot-mesh-depth` (session B), both in `MANIFEST.md`. The same happened at 016, and was fixed by renumbering to 019. Two sessions draw from one counter with no coordination; it will happen a third time.

**3. `HANDOFF.json` is a single-slot resume pointer.** It was still pointing at Phase 06 from 2026-07-21 while two sessions worked on 12/13/14/15. I repointed it at Phase 15 and carried Phase 06's blocker and both its pending human actions forward verbatim — but with concurrent sessions, one slot cannot be right for both.

## The expensive lesson, worth a process change

**Commit `37639d5` did not fix the drag-resize freeze. The app hung again the same afternoon, same screen, same stack.**

The morning fix quantised a height-derived font size. `AutoSizeText` then ran its **own** search to fit the available **width**, which a drag varies just as continuously — so it kept minting a distinct `TextStyle`, a distinct `ParagraphCacheKey`, per frame. Native profile: `SkLRUCache<ParagraphCacheKey>::remove` at **1580 samples**, main thread inside `-[NSWindow _resizeWithEvent:]`, one core pegged at 103%.

**The regression guard stayed green throughout**, because `test/chart/compact_price_font_size_test.dart` tests a **pure function** and never touches a widget. It tested the fix, not the bug.

Seven call sites are now converted to fixed styles with `overflow: ellipsis` — `crypto_simple_chart.dart` (1), `crypto_live_chart.dart` (1), `coin_card_row.dart` (**3 per row**, so ×coins), `gw_wallet_card.dart` (1). The new guard, `test/freeze_rule_test.dart`, scans dashboard-reachable sources and fails with a **file:line**; proved green → red → green.

Its stated ceiling: it scans only surfaces where the freeze was measured. Onboarding and the generated `*.g.dart` components still carry ~20 `AutoSizeText` uses and are equally capable of this hang.

## Verified vs awaiting verification

**Verified by test and measurement:**

- Phase 15 plans `15-01` … `15-05` — suite at **222 passing / 1 failing**, `flutter analyze` clean. Content width **1280.0** at 1600/2000/2560 viewports, against **736** before. `dashboard_screen.dart` byte-unchanged.
- The freeze fix — mutation-proven guard.

**Awaiting verification — not walked, therefore not verified:**

- **`15-06`** — Phase 15's human walk. Never attempted.
- **`12-06`** — Phase 12's human walk. Never attempted, carried from this morning.

Both are dark-mode only by Jakub's standing decision; light mode is backlog.

## Deliberately un-fixed — do not let anyone "helpfully" fix these

- **`RefreshIndicator` does not arm over the rail card.** The rail's `SingleChildScrollView` fits its content, so its position refuses the drag — **220px of a 1280px page is dead to pull-to-refresh.** Fixing it means restructuring on a guess.
- **`_panel`'s title row overflows below 413px** — pre-existing, and Phase 15 made it **8px better**.
- **A runtime `RenderFlex overflowed by 128 pixels on the right`.** This morning's handoff recorded an **82px** overflow at `responsive_overlay.dart:199` from before Phase 12. Same widget at a different width, or something new? **Not investigated — I am not claiming it is benign.**
- **Native SDK leak:** the node loops on `Blockchain not fully initialized` every ~5s and starts a new bootstrap health check each time without cancelling the last — **92 in 7 minutes**. Not the freeze, but unbounded.

## Shipped — pushed to `ui-redesign-port`, `fea77de..eca162c`

| | |
|---|---|
| `9c51478` | freeze fix — 7 `AutoSizeText` sites + the guard that tests the bug |
| `8cb4222` | Phase 12 rows/filters + Phase 15 the tab becomes a page |
| `29b183b` | Phase 13 boot sequence (parallel session's work, committed at Jakub's instruction) |
| `eca162c` | planning: phases 12-15, sketches 015-022, handoffs, todos |

`cmake/CommonBuildParameters.cmake` and `cmake/DownloadDependencies.cmake` are **deliberately not
committed** — Jakub's local-only build patches. Verified after the last commit that they are the
*only* thing left in the working tree.

Suite at **222 passing / 1 failing**, measured with `--concurrency=1`. The failure is
`local_wallet_storage_test.dart`, entirely commented out, failing at load — pre-existing.
`flutter analyze` has no `error`-severity issues; the 62 reported are info/warning and predate today.

## Answered

**The gradient question is settled** — Jakub, 2026-07-22: `brandCta` as it exists in the code is the
source of truth. The sketch theme now carries `--brand-cta-a: #0AD89C` / `--brand-cta-b: #0AAEE6`
additively, so no existing mockup changes appearance, and the misuse cannot silently repeat.

## Asks — one line each

1. Do you want the five signing files dealt with, or the end-session guard rescoped?
2. Should sketch numbers get a reservation convention, or should one session own the counter?
3. A PR against `develop`/`main` when the port is ready — or does `ui-redesign-port` stay long-lived?

---

# 6b · Standup note

**Transactions tab got rebuilt today. Nothing is merged — it is all uncommitted on `ui-redesign-port`.**

**What shipped.** The `/transactions` page was rendering the dashboard *panel* verbatim: a 736px column stranded in the middle of a 2000px window with a panel-sized title and no card. It is now a real page — 1280px wide, proper page header, and a filter rail down the left with live counts instead of a `⋯` popup. Empty states no longer float in the vertical middle of a tall panel. Failed and processing-job rows now show the real amount instead of a dash.

**What we touched that you might also touch:**

- **`GWEmptyState` changed for everyone.** Five call sites — Assets, Markets, Transactions ×2, the design gallery. If your empty state looks like it moved up, that is us: it now centres within the first 480px instead of the whole slot. Short panels are byte-identical to before.
- **`coin_card_row.dart`, `gw_wallet_card.dart`, `crypto_simple_chart.dart`, `crypto_live_chart.dart`** — every `AutoSizeText` in them became a plain `Text` with `overflow: ellipsis`.

**Two gotchas that will cost you an hour each if you hit them cold:**

1. **Do not use `AutoSizeText` or `FittedBox` in anything the dashboard mounts.** They pick a font size to fit the box, so dragging the window mints a new text style every frame, thrashes skia's paragraph cache, and **hangs the app permanently** — one core at 100%, window dead until you kill it. This ate real time twice today. `test/freeze_rule_test.dart` will fail with a file:line if one comes back.
2. **A silent black window on launch is a stale instance**, not a bug. It is holding the Hive container lock at `~/Library/Containers/ai.gnus.GeniusWallet.jakub/`. Kill the old process and relaunch.

Also: transactions render empty until you inject fixtures from the dev bubble ("Mock txns"), and under a loaded full-suite run a couple of transaction tests flake with a `tokens.json` 404 — re-run serially before believing a red.

**What's next.** A dark-mode walk of the new tab, then Phase 12's walk which is still outstanding. Nobody needs to pick those up — they are Jakub's.
