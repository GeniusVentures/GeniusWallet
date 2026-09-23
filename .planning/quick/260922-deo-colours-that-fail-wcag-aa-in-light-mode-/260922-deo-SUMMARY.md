---
quick_id: 260922-deo
status: complete
---

# Quick task 260922-deo: colours that fail WCAG AA in light mode

Two `statusWarningText`-shaped foreground tokens plus a `borderControl` retune fix
status-pill labels and disabled checkbox/switch contrast in light mode.

## Changes

1. `statusSuccessText` (`#065F46`) / `statusErrorText` (`#991B1B`) added to
   `GWColors`, dark unchanged. `orderStatusPaint()` and `txStatusColors()` repoint
   their success/error `fg:` to the new tokens; wash stays on the fill tokens.
   Light-mode label-on-wash: success 6.39/5.75/4.94, error 6.72/6.03/5.17
   (elevated/menu/base), up from 3.77/3.39/2.91 and 3.89/3.49/2.99.
2. `borderControl`'s light alpha moved 46%→48% (clears 3:1 on all four light
   surfaces, not just white). `GWCheckbox`/`GWSwitch` disabled chrome now reads
   `borderControl`/`textSecondary` instead of `borderSubtle`/`textTertiary`.
   `GWSwitch` gained stateful colour resolvers, disabled branch first. Measured:
   edge 3.09-3.33, thumb-vs-track 5.39+, disabled-vs-off thumb 2.95+.
3. Closed the status-pill todo (moved to `completed/`). Partially closed the
   disabled-state todo — UI-SPEC contrast-rule ask still open. Filed two new
   todos: `statusSuccess`/`statusError` as plain text fails AA (~40 sites), and
   the enabled switch's track outline is under 3:1.

## Commits

`197d6ada` pill-label tokens · `a90e3a0f` disabled checkbox/switch · `ea536d6e` todos.

## Verification

Format 0 changed; analyze clean; `flutter test` 1562/5/0 (+12; review later
removed 2, so 1565/5/0 on develop's newer base). Brace and raw-colour gates pass.

## Deviations

None. Every measured ratio met the plan's prediction or cleared its floor.
