# HANDOFF — Web tab chrome (Phase 18)

**Session:** 2026-07-24 · sketch → phase → plan
**Branch:** `ui-redesign-port` · **Role:** executor (design + planning done; NO commits per CLAUDE.md)

## What happened
Designed the Web tab's in-app browser chrome (the URL bar + adding tabs) and turned it into Phase 18.

### Sketches (winners locked, all variants preserved)
- **035 web-address-bar** → **B · Scalony toolbar** (unified omnibox: back/fwd nested in field, favicon+lock+host, refresh right edge, ⋯ menu).
- **036 web-tab-strip** → **A · Stały pasek kart** (always-visible horizontal strip, brand-underline active mark, `+` adds DuckDuckGo tab).
- **037 web-chrome-combined** → **B · 035-B + 036-A** — the consolidated implementable spec.
- MANIFEST.md updated with all three winners.

### Phase 18 created + planned + verified
- ROADMAP.md: "### Phase 18" entry (redesign-track, parallel to 12-17); Surface ownership map row added (Web tab → Phase 18). STATE.md: redesign track 12→18, Roadmap Evolution note.
- `18-CONTEXT.md`: decisions D-01..D-09, success criteria, scope fence (chrome only; engine/JS/WC-poller untouched).
- Plans: **18-01** (macOS omnibox + shared `web_chrome_helpers.dart` + test) → Wave 1; **18-02** (tab strip 036-A + delete full-screen manager/upside-down thumbnails/all Screenshot code + `screenshot` dep) and **18-03** (Windows omnibox parity) → Wave 2, parallel (disjoint files).
- gsd-plan-checker: **PASSED** (line-level cross-checked). One warning fixed in 18-02 (active-underline color via `GeniusWalletColors` getters, NOT a new `GWColors`/Theme dependency).

## State
- Everything on disk, **UNCOMMITTED** (CLAUDE.md: agents don't commit).
- Primary target `lib/web/web_view_mobile.dart` (macOS); secondary `lib/web/web_view_windows.dart`.
- 18-02 is a net deletion; `web_view_mobile.dart` confirmed sole consumer of `screenshot: ^3.0.0`.

## Next
- `/gsd-execute-phase 18` (executor only — Wave 1 then Wave 2).
- Verification gate: `flutter analyze` clean + `flutter test test/web/web_chrome_helpers_test.dart` + human macOS walk (dark; light AA spot-check). Windows runtime deferred.
