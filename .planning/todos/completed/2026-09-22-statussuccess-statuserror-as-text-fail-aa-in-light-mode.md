# statusSuccess/statusError read as plain text fail WCAG AA in light mode

**Filed:** 2026-09-22, while measuring the status-pill light-mode fix (quick 260922-deo).
**Status:** open.
**Severity:** accessibility.

## What

Roughly 40 call sites read `gw.statusSuccess` / `gw.statusError` directly as a
text colour on a plain surface (not composited over their own translucent
wash the way the status pill is). Those tokens are fill-tuned, not
text-tuned, and measure under the 4.5:1 body-text floor in light mode:

| Tone | surfaceMenu | surfaceBase |
|---|---|---|
| success | 4.03 | 3.42 |
| error | 4.29 | 3.63 |

Same defect shape as the status-pill labels this session fixed — the fill
token doubling as label text — just without a wash between the label and the
surface.

## Out of scope for the pill fix

`statusSuccessText` / `statusErrorText` (added by this session) are not the
right fix here without measurement: they are tuned for the fill's own
translucent wash as a backdrop, not for a plain opaque surface. Re-tune or
reuse per call site once this is picked up.

## Upgrade path

Repoint each call site to an AA-safe token for its actual backdrop, verifying
each pairing individually rather than a blanket find-and-replace — a much
larger pass than a single quick task.

## Closed 2026-09-26

Fixed by Phase 32 (PR #248), commits 63cf3fbb..dc95f5c8: every text use moved to `statusSuccessText`/`statusErrorText`; the 43 remaining raw reads are washes, borders, icons and chart lines, pinned by `test/theme/status_text_color_invariant_test.dart`. Residual: `ColorScheme.error` is still #FF4D4D, so a raw Material `TextField.errorText` fails AA in light mode; the only such site is the WalletConnect URI field, which Phase 10 replaces with `GWTextField`.
