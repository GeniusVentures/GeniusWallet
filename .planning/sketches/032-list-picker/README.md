---
sketch: 032
name: list-picker
question: "How should a searchable, selectable list drawer read — row anatomy, search, and selection state?"
winner: "A"
tags: [drawers, list, picker, network, search, selection]
---
# Sketch 032: List Picker

## Design Question
Every "pick one of these" drawer — Select Network (hero), the wallet/account switcher,
the token selector, Search Coins — is currently a bare, inconsistent list. This sketch
asks how one list-picker archetype should read: what a row is made of, when search
belongs, and how the current selection is shown.

## How to View
open .planning/sketches/032-list-picker/index.html

Reuses the 030 drawer shell verbatim (420px right-edge panel, shell variant A · Framed:
centered title + close ✕, 20px body padding). Tabs switch variants, the theme toggle
flips dark/light, tapping a row moves the selection, and B's search filters live.

## Variants
- **A · Plain list** — full-width rows, hairline dividers, leading coin-dot avatar +
  name/symbol, trailing check on the selected row (Ethereum). No search — matches the
  current simple network list. Tapping highlights the row and toasts the choice.
- **B · Search-first** — a sticky search field pinned under the header; typing filters
  the rows live on name and symbol, with a "No networks match" empty state. Built for
  the token selector / Search Coins case where the list is long.
- **C · Rich cards + selection state** — each choice is a bordered card with a trailing
  meta column (chain id / balance); the selected card gets a brand ring + subtle
  brand-fill. A secondary footer button ("+ Add network") stands in for the
  account-switcher's add affordance.

## What to Look For
- Row anatomy: is avatar + name/symbol enough (A/B), or does the trailing meta column (C)
  earn its keep?
- Does search need to be always-visible (B), or is it noise for a 6-item network list (A)?
- Selection legibility: a trailing check (A/B) vs. a full brand ring + fill (C) — which
  reads faster at a glance?
- Whether one archetype can flex across all four cases, or search (B) and add-action (C)
  should be composable options on top of the plain list.

## Covers
Select Network (hero), Wallet/account switcher, Token selector, Search Coins.

## Round 2 — A fine-tunes

Round 1 picked **A · Plain list** (tappable rows, check on the selected one — not the
search-first B). Round 2 refines the plain-list direction into three density/mark
fine-tunes over the refined **030 B1 "Quiet band"** shell (60px header, LEFT title,
close ✕ top-right, 1px `--brand-primary-subtle` hairline). No search field, no footer
button — rows fill the body. Default network selected is Ethereum; tapping a row moves
the check + highlight and fires a toast. Tabs: **A1** (default), **A2**, **A3**, plus a
**baseline · chosen A** for round-1 comparison.

- **A1 · Comfortable** — 64px rows, full-bleed `--border-subtle` hairline dividers, 36px
  solid coin-dot avatar, name + symbol stacked. Selected row fills `--brand-primary-subtle`
  with a trailing brand check; hover lifts the row to `--surface-elevated`. The polished
  version of round-1.
- **A2 · Compact + leading bar** — 52px rows, inset dividers that begin after the 28px
  avatar, name + symbol on one line (symbol muted, right-aligned). Selected = a 3px
  `--brand-primary` leading bar + check, no background fill. Densest — scales to a long
  token list.
- **A3 · Airy, no dividers** — 64px rows separated by whitespace only (no hairlines);
  each avatar carries a 1px ring. Selected row becomes a `--brand-primary-subtle` rounded
  pill with a `--brand-primary` inset ring + check. The calmest.

**Recommendation: A1 · Comfortable** for Select Network and the account switcher — six
short items read best with generous 64px rows and an unmistakable filled selection.
A2's density is the right call only when a case (token selector / Search Coins) actually
has a long list; keep it as the composable dense variant rather than the default.
