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
   `GWSwitch` gained stateful `thumbColor`/`trackColor` resolvers (disabled
   branch first) since the legacy shorthands never checked disabled. Measured:
   edge-vs-surface 3.09-3.29 light/3.23-3.33 dark, thumb-vs-track 5.61/5.39,
   disabled-thumb-vs-off-thumb 2.95/3.23.
3. Closed the status-pill todo (moved to `completed/`). Partially closed the
   disabled-state todo — UI-SPEC contrast-rule ask still open. Filed two new
   todos: `statusSuccess`/`statusError` as plain text fails AA (~40 sites), and
   the enabled switch's track outline is under 3:1.

## Commits

- `6d235e49` fix(colours): add statusSuccessText/statusErrorText for AA pill labels
- `1ac4675c` fix(colours): visible, distinct disabled states for checkbox and switch
- `ede25e02` docs(todos): close the status-pill AA todo, partially close disabled-state todo

## Verification

`dart format --set-exit-if-changed lib test`: 0 changed. `flutter analyze`: No
issues found! (exit 0). `flutter test`: 1562 passed / 5 skipped / 0 failed (was
1550/5/0, +12 new). `check_brace_style.sh` / `check_raw_colors.sh`: both pass.
`git ls-files --eol`: only the two pre-existing documented CRLF files.

## Deviations

None — plan executed as written; all measured ratios matched or exceeded the
plan's predicted numbers, except the checkmark-vs-disabled-fill dark-mode upper
bound (predicted up to 6.21:1, measured up to 5.91:1) — still far above the 3:1
floor, so the assertion threshold was unaffected.
