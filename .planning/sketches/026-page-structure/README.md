# 026 · Transactions — whole-page structure (navbar + title + section)

**Design question:** not "where does the tab's header sit" but the level above it — how does the page
title relate to the app's shared chrome? The navbar (`_DesktopTopBar`, 68px, `responsive_overlay.dart`)
already names the page: the active tab reads **Transactions**, underlined. The page then repeats
**Transactions** at 24px below it. That duplication, floating under a full-width bar while the content
is centred, is the actual defect.

**Status:** four structures, awaiting Jakub's direction.
**Recommendation:** **S1 now, S3 as its own phase later.**

Each mockup shows the **shared navbar**, because that is the thing the title has to relate to. This
matters for scope: the navbar is shared by every tab (Dashboard, Markets, News, Swap, Web, Feedback,
Settings) and was already redesigned in sketches 002/005 — anything that touches it is an app-wide
decision, not a Transactions-page one.

| Option | Structure | Scope |
|---|---|---|
| **Today** | navbar names it → page repeats it 24px → repeat floats top-left of a centred block | — |
| **S1** *(rec)* | **drop the 24px repeat.** The active nav tab IS the title (macOS Finder / browser-tab model). A slim contextual toolbar takes its place: quiet context line left (`Showing all activity · 0x1d9b…4a87`), actions right. Content rises ~90px. | **Transactions page only.** No shared-chrome risk. Reversible. ~1 day. |
| **S2** | **full-width page-header band** under the navbar (title left, actions right, edge to edge), cards centred below. The classic global-nav → page-header → content shell. | New shared `PageHeaderBar`, applied app-wide. A design-system decision. |
| **S3** | **left sidebar navigation.** Tabs move from the top to a left rail; the top bar shrinks to logo + wallet cluster + Buy GNUS. The title then sits top-left of the content, aligned, and the sidebar eats the left width so a fullscreen window **stops looking empty by construction**. | Full shell rewrite, every tab, both platforms (mobile keeps bottom nav). Milestone. |

## Why S1 now

It removes the **actual** defect — the duplicated title — at zero risk to the shared navbar. The
navbar already names the page, so a second 24px title is noise; dropping it is what a browser or
Finder does, and it is trivially reversible. The slim toolbar then puts the actions (Receive / Send /
Export / view toggle) where a scanning eye expects them, and the content rises to fill more of the
window. It touches one file.

## Why S3 is the real answer to "fullscreen looks empty" — but later

The wide-empty-page complaint has a structural cause: a top nav leaves the entire width to a single
centred content column, so any short content floats. A **left sidebar** fixes this by construction —
the shell spans the width with nav-rail + content, and nothing floats. That is the genuinely correct
desktop-app structure. But it rewrites the whole shell, changes every tab, and must not regress the
mobile bottom nav — that is a roadmap phase with its own walk, not a decision made inside the
Transactions tab. Recording it as the frontier direction.

## S2 is the middle path

Only if you specifically want a consistent header band on every page. It gives the title a home
without the sidebar rewrite, at the cost of a new shared component and an app-wide rollout.

## Decision needed

**S1, S2, or "plan S3 as a phase".** If S1: confirm the toolbar actions (same four as sketch 025 —
Receive · Send · Export · view toggle) and whether the context subtitle stays.
