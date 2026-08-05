# Eight routes sit outside `ShellRoute` and therefore have no navbar

**Found:** 2026-07-27, while reading `router.dart` for sketches 157 and 159. Sketch **061** found the
`/token-info` half of it a day earlier.
**Type:** navigation gap. One edit closes two open sketch findings.

## What is wrong

`lib/navigation/router.dart` declares `ShellRoute` at `:208`. Its children get the top navbar:
`/dashboard`, `/transactions`, `/swap`, `/web`, `/markets`, `/news`, `/logs`, `/settings`.

These do **not**, and all of them are real destinations a user reaches from inside the app:

| Route | Screen | Reached from |
|---|---|---|
| `/token-info` (`:244`) | coin detail | any Assets row, any Markets row |
| `/buy` (`:80`) | order history | the "Buy GNUS" CTA |
| `/createOrder` (`:86`) | the buy form | "+ New Order", Retry order |
| `/orderDetails` (`:100`) | order detail | "See Details" |
| `/banxa/callback` (`:114`) | order detail | the payment deep link |
| `/checkoutQR` (`:137`) | desktop hand-off | the checkout sheet |
| `/kyc` (`:169`) | KYC registration | the orders AppBar |
| `/bridge` (`:270`), `/submit_job` (`:280`), `/network` (`:187`) | - | various |

From a coin page there is no way to reach News without going back. From the order list there is no way to
reach anything at all except a back arrow.

## Not all of these should be fixed

Two groups, and they want opposite answers:

- **Should get the navbar:** `/token-info`, `/buy`, `/createOrder`, `/orderDetails`, `/network`. These are
  browsing destinations; leaving the shell is a dead end.
- **Should probably stay outside:** `/checkout`, `/checkoutQR`, `/kyc`, `/banxa/callback`. These are inside a
  payment or identity flow where wandering off mid-transaction is a real hazard - which is also why
  `GlobalSwapFabHost._hiddenPaths` already hides the FAB on exactly those four and no others.

`/bridge` and `/submit_job` are a judgement call and are not decided here.

## Why one edit closes two sketches

- Sketch **061** (coin page chrome) recommends variant **A**, whose first requirement is that
  `/token-info` returns to `ShellRoute`.
- Sketch **157** (Buy GNUS) lists this as defect 7 across all seven Banxa routes.

Both were found independently, a day apart, and they are the same edit. Fix them together.

## Watch when fixing

- `/token-info` currently carries its own Material `AppBar` with a breadcrumb (`token_info_screen.dart`).
  Moving it into the shell means **two** headers unless the AppBar goes at the same time - which is exactly
  what 061-A specifies, so take the sketch with the move rather than doing half of it.
- `OrdersPage` builds its own `Scaffold` with an `AppBar` too (`banxa_orders_history.dart:108`), and that file
  is under the `/banxa` do-not-change fence. Sketch 157 section 5 describes the way through: re-host the
  widget outside the fence over the same cubits.
- The shell's `builder` wraps children in `ResponsiveOverlay`; check that a pushed detail route inside the
  shell still gets a working back affordance, since the navbar has no back button.

## Related

- `.planning/sketches/061-coin-page-in-app-language/README.md` - variant A
- `.planning/sketches/157-buy-gnus-page/README.md` - defect 7
