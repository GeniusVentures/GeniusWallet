# Banxa orders never enter the transaction store - and `View all` no longer exists to re-target

Filed by 260731-jx5 (Buy GNUS "Your orders" header rebuild). One file, not two: the orphaning of
`/buy/orders` below is strictly downstream of the blocker in this same file — it only happens if
and when `View all` is re-targeted — so it is recorded here rather than as its own item, to keep
the two from being actioned in isolation (which would cause the very orphaning it warns about).

## SUPERSEDED 2026-07-31 - the link was DELETED, not re-targeted

Later the same day Jakub replaced the earlier instruction ("re-point `View all` at the Transactions
tab with `Purchased` preselected") with a different one: *"Usun 'View all' ... Bedzie maksymalnie
takiej wysokosci, jak ten po lewej stronie ... A jesli jest za duzo transakcji, to po prostu trzeba
zrobic infinite scrolling."* 260731-ti5 executed it: the rail's `View all` affordance is gone from
BOTH header branches, the four-row cap with it, and the rail now takes its height from the form card
beside it and scrolls its whole in-memory list.

Three consequences for this file, in order of how much they change:

1. **The re-target is moot and the blocker below is DISSOLVED, not still open.** There is no link
   left to point anywhere. Do NOT implement the re-target. The evidence below is kept because it is
   still the map for the product question in the section after next, which the deletion does not
   answer.
2. **"The orphaning, as a consequence (not yet true today)" is TRUE TODAY.** The rail's link was the
   only in-app `push` to `/buy/orders`, and `order_details_page.dart:132` is a `go` BACK from a page
   only that list reaches, so it is not an entry point. `/buy/orders` and its detail page are now
   reachable by direct URL only. Its two options - re-home an entry point, or delete the screen with
   its route and tests - are LIVE questions for Jakub, not hypothetical ones. 260731-ti5 deliberately
   took neither as a side effect of the deletion.
3. **The preselection mechanism below is still accurate** and still the cheapest route if a fiat
   purchase ever does belong in the transaction history. It just has no caller now.

## The blocker (as recorded 2026-07-31 by 260731-jx5, before the deletion)

Jakub asked for `View all` on the Buy GNUS "Your orders" panel to open the Transactions tab with
the `Purchased` filter preselected. Traced from the code first: **the destination is empty by
construction, not by accident.** Banxa orders never become `Transaction`s.

Evidence:

1. `Filters.purchase` (`lib/dashboard/home/widgets/transactions_slim_view.dart:56,97`) matches
   exactly `tx.type == TransactionType.purchase`.
2. `TransactionType.purchase` is assigned in exactly **two** places in the entire repo, both dev
   fixtures: `lib/dev/dev_mock_transactions.dart:128` and `:197`.
3. `grep -rn "Transaction" lib/banxa` returns exactly two hits, both `TransactionStatus` colour
   lookups inside drawer content (`buy_success_drawer_content.dart:31`,
   `buy_cancelled_drawer_content.dart:25`). **No file under `lib/banxa/` constructs a
   `Transaction` or calls `addTransaction`.** `banxa_order_cubit.dart` has zero references to
   either.
4. `TransactionsCubit` is fed by exactly two doors: `loadInitial(walletAddress)` (reads
   `TransactionStorageService`) and `addTransaction`. Its four non-dev callers are
   `handle_dapp_requests.dart:198`, `swap_screen.dart:353`, `bridge_screen.dart:346` and
   `dev_overrides.dart:65`. None is Banxa.
5. `dev_mock_transactions.dart` is imported by exactly one file, `dev_tools_bubble.dart`, gated
   behind `kShowDevTools = bool.fromEnvironment('GW_DEV_TOOLS')` (`dev_flags.dart:15`).

**Therefore:** in any build without `--dart-define=GW_DEV_TOOLS=true`, `Filters.purchase` matches
zero transactions, always. Re-targeting `View all` today would send the user to the
filtered-empty state — "No purchased transactions. You have N transactions, but none match this
filter." — which is worse than today's behaviour (a real, populated Banxa orders list).

## What was asked and not built, and why

Jakub's re-target of `View all` to the Transactions tab with `Purchased` preselected. **Not a
descope** — the destination is empty by construction and the link would be strictly worse than
what ships today. `View all` kept its `/buy/orders` destination
(`lib/screens/banxa_buy_screen.dart`'s `_OrdersRail`).

**Overtaken by events on 2026-07-31:** 260731-ti5 deleted the link entirely, so this is no longer a
thing that was asked and not built - it is a thing that was asked, then unasked. See the SUPERSEDED
section at the top.

## The preselection mechanism, ready to use when the blocker clears

Simpler than it sounds, and there is only one source of truth to thread. `/transactions` is
`const TransactionsScreen()` (`router.dart:225`) -> `TransactionsStream(page: true)`
(`transactions_screen.dart:119`) -> `TransactionsSlimView(page: true)`. The filter lives in
exactly one place: `_TransactionsSlimViewState.selectedFilter`
(`transactions_slim_view.dart:186`), default `Filters.all`, shared by the panel bar and the page
rail. Preselection is a nullable `initialFilter` threaded through those three widgets and seated
in `initState`. No second source of truth, no cubit — the route would read it from `state.extra`,
following the `/swap` precedent at `router.dart:227-240`.

## The product question that has to be answered first — CORRECTED from this plan's own research

This plan's original finding claimed `OrderStatus` "has no on-chain transaction hash." **That is
not quite right, and the corrected version is the more useful one for whoever picks this up:**
both `OrderStatus` (`banxa_model.dart:136`) and `Order` (`banxa_model.dart:354`) DO carry a
nullable `transactionHash` field, populated straight from Banxa's own JSON response
(`banxa_model.dart:187`/`:402`) when Banxa provides one.

The real open question is narrower and still real: `transactionHash` is presumably only populated
once Banxa's crypto leg has actually settled on-chain — a `declined`, `cancelled`, or `expired`
order plausibly never gets one (nothing settled). Nobody has confirmed this against Banxa's real
API responses. So the mapping question becomes: **does every order status Banxa returns
eventually carry a `transactionHash`, or does the mapper still need to mint a synthetic identity
(e.g. `banxa:$orderId`) for the statuses that never settle?** `Transaction.hash` is
`TransactionsCubit`'s dedupe/storage identity (`Set<Transaction>`,
`TransactionStorageService.removeTransaction` keys on `txHash`), so this has to be answered before
a mapper is written, not discovered by it.

Underneath that is the real product question, unchanged from this plan's original framing:
**should a fiat purchase appear in the wallet's on-chain transaction history at all?** That is
Jakub's call, not an implementation detail — recommend asking before anyone writes the mapper.

## The orphaning - NO LONGER a consequence, TRUE as of 2026-07-31

`lib/screens/banxa_buy_screen.dart`'s `_OrdersRail` WAS the only `push` to `/buy/orders` (via
`GWViewAllLink`). `order_details_page.dart:132` is a `go` BACK from the order-details page,
reachable only through that list, so it is not an entry point.

260731-ti5 deleted the link. The order-history screen and its detail page are therefore unreachable
except by direct URL, **today, in the tree as it stands** - this section was written as a
conditional and the condition has fired, by a different route than the one it anticipated. Two
options, neither taken by 260731-jx5 or by 260731-ti5: re-home an entry point for `/buy/orders`
elsewhere, or delete the screen along with its route and its tests. Deleting a screen is a separate
decision Jakub has not made - it was not taken as a side effect of deleting the link, and it should
not be taken as a side effect of reading this file either. This is now a live question for him.
