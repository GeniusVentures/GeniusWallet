---
status: complete
phase: 32-contrast-and-text-scale-accessibility-pass
source: [32-VERIFICATION.md]
started: 2026-09-25
updated: 2026-09-25
---

## Current Test

none, all 6 walked

## Tests

### 1. Switch outline
/settings in Light and Dark, every switch on and off. Expected: the outline is visible against both the ON and OFF track.
result: pass

### 2. Inter in the formerly unmapped slots
Onboarding recovery-phrase word chips and the disclaimer dialog title, both modes. Expected: Inter, not Roboto.
result: pass

### 3. Bottom bar at large text
Debug build, window under 1024px, OS text size 130%+. Expected: labels stop growing at about 1.23x; no overflow stripe.
result: pass
note: the phone bar stayed clean. The same run logged horizontal overflows in the DESKTOP top bar at 150%; filed as todo 2026-09-25-desktop-top-bar-overflows-horizontally-at-large-text (outside this phase's goal).

### 4. Price-change and timestamp labels
Light mode: dashboard, Markets, a token detail page, News. Expected: darker legible green/red; dark mode unchanged.
result: pass

### 5. Account, receive, settings, logs, Banxa labels
Light mode: receive "Copied", settings debug line, Feedback status, a Banxa form error. Expected: darker legible green/red.
result: pass

### 6. Forms, banners, swap, WalletConnect
Light mode: a swap refusal CTA, a form error, WalletConnect "Retry Connect", a route's Price Impact. Expected: legible darker red/green; dark mode unchanged.
result: pass

## Summary

total: 6
passed: 6
issues: 0
pending: 0

## Gaps

None in scope. Checks 4-6 were walked after a restart (the power cut ended the first session). WalletKit fails to initialise on Windows (MissingPluginException on walletconnect_pay); that is a platform gap, not a colour issue.

Found during the walk and fixed on this branch (re-walked, both modes): the light-mode Compute tiles read as a heavy grey block (now the soft menu grey), and a disabled gradient CTA looked like an enabled pastel one (now a flat ink tint with a muted label; loading keeps the faded gradient).
