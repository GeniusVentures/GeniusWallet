# `TokenDetailHero` has no consumers left

**Found:** 2026-07-28, at the end of quick 260728-u8p (sketch 071-B).
**Type:** dead code, created deliberately and reported rather than swept.

## What happened

`lib/tokens/widgets/token_detail_hero.dart` (a ~200-line widget from sketch 152: 52px round token
icon, name, symbol · network, big price, change pill, plus a `stacked` flag for the <360 layout) had
exactly one consumer: `token_info_screen.dart`, twice - inline in the desktop main card and inside a
`GWCard` in the mobile 152-D stack.

071-B moves identity and price into `GWPageHeader`, so **both uses are gone** and the file now has
none. `grep -rn "TokenDetailHero" lib/` returns only its own definition.

## Why it was not deleted in the same task

Two reasons, both arguable:

1. **It is the only implementation of the stacked identity block**, which is what the <360 layout
   used. `GWPageHeader` handles narrow widths by wrapping text, not by restacking an icon + price -
   nobody has walked the coin page at 360 since the change.
2. Deleting 200 lines of a sketch-152 design asset inside a task about page structure is the kind of
   scope creep this project keeps writing todos about.

## The decision to make

- **Delete it** if the `GWPageHeader` treatment is confirmed good at 360 on a walk. That is the lazy
  answer and the one CLAUDE.md's "deletion over addition" points at.
- **Keep and re-consume it** if the walk finds the header too quiet on a phone, in which case the
  mobile branch takes the hero back and this note closes.

Either way it should not sit unused indefinitely - an unused widget rots and then gets copied.

## Related

- `.planning/quick/260728-u8p-coin-page-071b-stat-rail/SUMMARY.md`
- `.planning/sketches/071-coin-page-whole-screen/README.md`
