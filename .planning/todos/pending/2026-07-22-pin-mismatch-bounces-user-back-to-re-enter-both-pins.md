---
created: 2026-07-22T00:00:00.000Z
title: A PIN confirmation mismatch discards BOTH entries and restarts at step one
area: ux
severity: minor
files:
  - lib/onboarding/new_wallet/routes/new_wallet_flow.dart
  - lib/onboarding/existing_wallet/routes/existing_wallet_flow.dart
  - lib/onboarding/view/create_pin_screen.dart
---

## Observation (06-05 walk, 2026-07-22)

Mistype the confirmation PIN and you are returned to **"Create a PIN"** and must enter **both** PINs
again from scratch. Most wallets let you retry just the confirmation step.

**This is develop's shipped design, working as intended — not a defect and not something 06-05
introduced.** Verified during the walk:

- `new_wallet_flow.dart:79` dispatches `PinConfirmFailed()` on mismatch, which routes back to
  `NewWalletStep.createPin`.
- `create_pin_screen.dart`'s `BlocListener` watches `NewPinCubit` for `PinConfirmStatus.failed` and
  calls `PinCubit.pinConfirmFailed()`, which sets `displayIncorrectPin`.
- So the "Incorrect PIN" message renders on the **Create** screen you land on, not on the confirm
  screen where the mistake happened. Walk-confirmed: the message does appear and is legible.

## Why it was not changed in 06-05

Changing it means altering the flow's failure routing — a restructure, which 06-05's §1 explicitly
forbids ("re-skin, never restructure"). Filed rather than smuggled into a re-skin, by explicit
decision 2026-07-22.

## What a fix would look like

Keep the user on the confirm step, clear only the confirmation field, and show "Incorrect PIN"
there. That needs a new state transition (`PinConfirmFailed` that does not pop back a step) plus a
way to clear one `pinController` without discarding the first PIN — genuinely a flow change, not a
one-liner, which is why it belongs in its own scoped work.

Worth pairing with a decision on whether repeated mismatches should be rate-limited at all; nothing
currently counts them.
