# `BanxaApiService.fetchAllOrders` fetches only the first 100 orders, silently

Filed by 260731-ti5 (Buy GNUS "Your orders" rail: bounded height, internal scroll). **This is a
deferral, not a bug report against that task.** Jakub's decision the same day was explicit: scroll
what is already in memory, do NOT add pagination here. The ceiling below is pre-existing and
untouched; it is filed so that removing the rail's four-row cap does not silently inherit it.

## The evidence

1. `BanxaApiService.fetchAllOrders` (`lib/banxa/banxa_api_services.dart:247-276`) is misnamed. It
   issues exactly ONE `GET https://api.banxa.com/$_partnerCode/v2/orders` with `limit: 100`
   defaulted in the signature, no cursor, no offset parameter, and no paging loop, then returns
   `OrdersResponse.fromJson` of that single response.
2. `OrdersResponse` (`banxa_model.dart:309-328`) carries `total` and `pageTotal` alongside the
   `orders` list, so the response itself knows whether there is more. Nothing in the app reads
   either field for paging - `OrdersCubit` stores the response and `banxa_order_state.dart` derives
   `totalOrderCount` and `statusCounts` from the orders it already has.
3. There is no second call site and no retry-with-offset anywhere: `fetchAllOrders` is called only
   from `OrdersCubit.fetchOrders`.

## The consequence, and why it matters more today than yesterday

A user with 300 orders sees 100, and is told nothing - no "showing 100 of 300", no end-of-list
marker. That was effectively invisible while the rail rendered four of them behind a `View all`
link: the truncation was 96 rows past anything the user could see without leaving the page.

260731-ti5 deleted both the cap and the link. The rail now scrolls the whole in-memory list inside a
box as tall as the form card beside it, so the bottom of that list is a place a heavy user actually
reaches - by scrolling, in the ordinary course of using the page. The 100 ceiling is now the first
wall they hit, and it is unlabelled.

## Explicitly NOT decided here

The open question for whoever picks this up, left open on purpose:

- a paging loop INSIDE `fetchAllOrders` (fetch until `orders.length >= total`), which keeps the
  cubit and every call site unchanged but makes one method call unboundedly slow; or
- an incremental fetch driven by scroll position, which is faster to first paint but needs the rail
  to report scroll extent to the cubit - a coupling 260731-ti5 deliberately did not create (D-03:
  the BOX scrolls, it does not fetch);
- and, underneath both, whether `OrdersCubit` should expose a loading-more state at all, or whether
  a truncation NOTICE ("showing the most recent 100 orders") is the honest cheap answer that makes
  the paging question wait for a user who actually has 300 orders.

Do not answer these as a side effect of some other task.
