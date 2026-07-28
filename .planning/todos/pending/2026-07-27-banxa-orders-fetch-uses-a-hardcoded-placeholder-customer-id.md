# The Banxa order list fetches with a hardcoded placeholder customer id

**Found:** 2026-07-27, while analysing the Banxa flow for sketch 157.
**Type:** stub left in shipping code. Silent - it produces an empty list, not an error.
**Blocks:** judging any design of the order list against real data.

## What is wrong

`lib/banxa/banxa_orders_history.dart`, two call sites:

```dart
// :33  - initState
BlocProvider.of<OrdersCubit>(context).fetchOrders('your-cust-id');

// :122 - the Refresh action
context.read<OrdersCubit>().fetchOrders('your-cust-id');
```

`'your-cust-id'` is a placeholder literal. **No real customer id is ever passed**, so the list can never show
a real user's orders in any build.

## Why it matters beyond the obvious

The failure is silent and looks like a legitimate state. The page renders

```
Total Orders: 0
No orders found.
```

which is indistinguishable from "this user has never bought anything". Anyone judging the empty state, the
filters, the pagination or the row layout is judging them against **a stub, not an empty account**.

`Order.externalCustomerId` exists on the model (`banxa_model.dart:339`) and `OrderStatus` carries it too
(`:113`), so the field the API expects is understood - it simply is not wired to anything on this end.

## To resolve when fixing

1. **Where does the customer id come from?** Nothing in the wallet currently owns one. Candidates: the
   selected wallet address, a Banxa-side id returned at KYC registration (`user_kyc/kyc_registration.dart`),
   or a value stored at first order creation. This is a question for Braian, not a code lookup.
2. **`OrderLinker`** already maps `externalOrderId` to `orderId` for the deep-link return path
   (`router.dart:122`) - worth checking whether the same store should hold the customer id.
3. Both call sites must change together, and the Refresh one is easy to miss.

## Note on scope

`lib/banxa/` is marked auto-generated in `CLAUDE.md`. This is a two-literal change inside that fence, so it
either needs the fence lifted for this file or the id has to be injected from outside (e.g. passed into
`OrdersCubit` at provider construction, which lives in the router).

## Related

- `.planning/sketches/157-buy-gnus-page/README.md` - defect 2 of 14
