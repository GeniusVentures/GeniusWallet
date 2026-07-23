# Session summary — 2026-07-23 (News + Markets + page frame)

Window: 2026-07-22 20:00 → 2026-07-23 ~13:40 (~15h). Branch
`redesign/transactions-tab-260722`. Standup note in the team's flat-bullet chat
format below; paste as plain text.

```
Since last night:
 • Locked planning for Phases 12–15 + sketches 015–022 and the parallel-sessions
   working agreement (one executor commits / runs flutter run / writes the shared
   planning files; sketch ranges reserved 000–099 / 100–149 / 150–199; every session
   writes its own HANDOFF-<topic>.md; design sessions that touch code get a worktree).
   Written after two sessions collided five ways on 07-22.

Today (built, tested live, now committed on redesign/transactions-tab-260722):
 • Integrated two finished redesign phases from their worktrees into the main tree
   for visual testing (no rebuild): Phase 16 Markets, Phase 17 News.
 • News (Phase 17): B2 photo-magazine — lead hero + "Next up" band + even photo grid.
 • News search reworked so it never reshapes the hero band. Hero + "Next up" stay
   frozen on the latest stories; matches now populate the bottom section, retitled
   "More news" → "Results". A no-match shows an inline "No headlines match …" under
   Results instead of blanking the whole page.
 • Killed a hard UI-thread freeze in News. A search narrowing to one result returned
   a bare wide hero Row (stretch) into the page's vertical scroll — unbounded height
   → "BoxConstraints forces an infinite height" → 1600+ cascading LayoutBuilder
   slot==null errors → frozen window. Self-bounded the hero (IntrinsicHeight) and
   stopped returning a bare wide hero; the Results-in-grid design removes the trigger.
 • News polish: timestamps → green relative "2h ago" (statusSuccess, AA both themes),
   clock icon dropped; search got the brand gradient focus ring, a 220ms debounce
   (fixes dropped keystrokes + half-typed queries matching nothing), a working clear,
   and no scrollbar; header carries an always-visible "Updated Xm ago" stamp +
   refresh on its own 30s ticker so only the stamp re-renders, never the magazine.
 • Markets (Phase 16): native-token hero over a sortable "All Markets" table. Fixed
   two blank-page bugs — non-data states returned a bare Center into an unbounded
   Column slot (no size → blank), and the hero Row needed IntrinsicHeight (fl_chart
   collapses with no bounded height).
 • Unified the content page frame so Transactions / Markets / News titles land at the
   same X. First pass left-aligned everything, which stripped the left padding on a
   wide window (title flush to the bezel). Corrected to centered (topCenter) with
   symmetric margins, a shared xxl(1536) cap, and the 64px navbar→title gap. Feedback
   left alone — being redesigned separately.
 • Transactions: wide rows gained a Status column (right-aligned pill, right edges on
   one line, gap = the time↔coin gap); amounts made flush-right; amount honesty on
   fee/failed/cancelled rows.
 • Dev note: the dev-tools bubble (mock transactions/holdings) is gated behind
   --dart-define=GW_DEV_TOOLS=true. Relaunching without it compiles the control out —
   looks "removed" but zero code changed. Any run this session needs that define.
 • flutter analyze clean of errors. Added shortTimeAgo + markets-sort tests. Full
   suite NOT re-run this session — no fresh baseline number.

Design exploration (parallel sessions, sketches only — not in the app):
 • Drawers redesign (030–034 + drawers-final), Feedback tab (150), Coin detail page
   (104), Markets (103). See each session's HANDOFF-<topic>.md.
```

## Status / caveats
- Today's app work is committed as 4 logical commits (`651541c`, `aa78eec`,
  `99a8913`, `5ab34bd`) — see `HANDOFF-2026-07-23-news-markets-frame.md` for the
  file-by-file breakdown.
- `cmake/CommonBuildParameters.cmake` + `DownloadDependencies.cmake` are deliberately
  left uncommitted (Jakub's local build patches). macOS signing files untouched.
- Not pushed / no PR — awaiting Jakub's explicit go, per the commit gate.
