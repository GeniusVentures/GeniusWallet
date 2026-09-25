---
status: testing
phase: 32-contrast-and-text-scale-accessibility-pass
source: [32-VERIFICATION.md]
started: 2026-09-25
updated: 2026-09-25
---

## Current Test

1

## Tests

### 1. Switch outline
/settings in Light and Dark, every switch on and off. Expected: the outline is visible against both the ON and OFF track.
result: pending

### 2. Inter in the formerly unmapped slots
Onboarding recovery-phrase word chips and the disclaimer dialog title, both modes. Expected: Inter, not Roboto.
result: pending

### 3. Bottom bar at large text
Debug build, window under 1024px, OS text size 130%+. Expected: labels stop growing at about 1.23x; no overflow stripe.
result: pending

### 4. Price-change and timestamp labels
Light mode: dashboard, Markets, a token detail page, News. Expected: darker legible green/red; dark mode unchanged.
result: pending

### 5. Account, receive, settings, logs, Banxa labels
Light mode: receive "Copied", settings debug line, Feedback status, a Banxa form error. Expected: darker legible green/red.
result: pending

### 6. Forms, banners, swap, WalletConnect
Light mode: a swap refusal CTA, a form error, WalletConnect "Retry Connect", a route's Price Impact. Expected: legible darker red/green; dark mode unchanged.
result: pending

## Summary

total: 6
passed: 0
issues: 0
pending: 6

## Gaps
