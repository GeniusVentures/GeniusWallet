---
created: 2026-09-24T15:00:00.000Z
title: The Banxa orders page is still the pre-redesign layout
area: design
severity: minor
---

## Problem

`lib/banxa/banxa_orders_history.dart` (`OrdersPage`) is still a loose Column: a DropdownMenu status filter (:231), a "Pick Date Range" button (:250), "Total Orders: N" text (:261), then a GridView (:304). It is reached from /buy/orders (`router.dart:86`), the order-details back fallback (`order_details_page.dart:132`) and the /orderDetails no-order fallback (`router.dart:139`).

## Fix direction

Use the buy screen's orders-rail grammar (8c172866): `GWControlTrack` for the header, `TransactionRow` for rows. Needs Jakub's pick on sketch 169 first. Also fix the stale comment at `router.dart:84`, which names a "View all" button 8c172866 removed. Sketch numbers 067/068 were reused elsewhere; pick a new one.
