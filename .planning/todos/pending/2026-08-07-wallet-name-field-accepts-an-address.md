# The wallet name field accepts an address, so a wallet can be named after itself

Captured 2026-08-07 by quick task `20260807-mobile-header-brand-and-wallet-pill`.

## The defect

`lib/onboarding/existing_wallet/view/import_security_screen.dart:236` writes

```dart
walletName: walletNameController.text
```

with **no validation of any kind**. Whatever is in that free-text field is stored as the wallet's
name, including a 42-character `0x...` address pasted by a user who thought the field wanted one.

## What changed on 2026-08-07, and what did not

The phone header used to render `walletName` on one line and
`WalletUtils.getAddressForDisplay(wallet.address)` on a second. On a wallet imported this way both
lines were the same value, so the header printed the address **twice** - once whole-ish, once
truncated - which read as a rendering bug rather than as a data problem.

The new wallet pill shows **the name only**, with no second line and no address. So an
address-shaped name now renders **once**, as an odd-looking name.

**The symptom is halved. The cause is untouched.** The fix is validation on that import field:
reject or warn on input matching an address shape, or fall back to a generated name.

## Three things any fix has to respect

1. **SDK wallets are unaffected.** `app_bloc.dart:616` names them `Super Genius Wallet` or
   `Super Genius Wallet N`, so they never reach the free-text path.
2. **No code anywhere derives a name from an address, and none should be added.** That heuristic
   would disagree with the account drawer rows, which show name and address as two separate lines
   and legitimately need both to disambiguate two wallets with the same name.
3. The header's 236px cap with ellipsis is what keeps a 350px address-shaped name from eating the
   brand block. That cap is a condition of the current header, not a tuning knob, and it stays
   whatever happens to the import field.

## Where to fix

`lib/onboarding/existing_wallet/view/import_security_screen.dart` - the field, not the header.
