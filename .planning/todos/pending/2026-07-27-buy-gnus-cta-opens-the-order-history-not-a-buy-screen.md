# "Buy GNUS" opens the order history, not a buy screen

**Found:** 2026-07-27, while analysing the Banxa flow for sketch 157.
**Type:** defect, user-visible today. Not a design gap.
**Independent of:** every layout decision in sketch 157. Fixable on its own, in any order.

## What is wrong

`lib/components/coins/view/coins_screen.dart:349`:

```dart
onPressed: () => context.push('/buy'),   // label: 'Buy GNUS'
```

`lib/navigation/router.dart:80`:

```dart
GoRoute(path: '/buy', builder: (context, state) => const OrdersPage()),
```

`OrdersPage` is the **order history**. The screen that actually buys something is `BanxaBuyScreen` at
`/createOrder`, and the only way to reach it is a small text action in the AppBar labelled **"+ New Order"**.

So a user with no orders taps a full-gradient CTA that promises a purchase, and lands on:

```
Total Orders: 0
No orders found.
```

## Why it is not cosmetic

This is the zero-balance path - the exact case the CTA exists for. A wallet with no funds shows the
Receive / Buy GNUS footer (`coins_screen.dart:322`), so **the only users who see this button are the ones
for whom it fails hardest.**

## The fix

Smallest version, one line: point `/buy` at `BanxaBuyScreen`.

```dart
GoRoute(path: '/buy', builder: (context, state) => const BanxaBuyScreen()),
```

Then either move the history to `/buy/orders`, or leave `OrdersPage` where the "+ New Order" action is today
and swap the two, so the AppBar action becomes "Order history".

To decide when fixing:

1. `BanxaBuyScreen` takes five optional `initial*` args, supplied by the Retry-order path
   (`banxa_orders_history.dart:92`). A no-arg construction is already legal - `router.dart:88` reads
   `state.extra as Map<String, dynamic>? ?? {}` - so nothing breaks.
2. `/buy` is currently reachable from **one** place. Grep before changing:
   `grep -rn "'/buy'" lib` returns only `coins_screen.dart:349` and the route itself.
3. Both routes sit **outside `ShellRoute`**, so neither has the navbar. Worth fixing together - see the
   separate todo on that.

## Related

- `.planning/sketches/157-buy-gnus-page/README.md` - the headline finding, plus 13 further defects
- The customer-id placeholder todo, filed the same day - until that is real, the order list cannot be
  judged on real data
