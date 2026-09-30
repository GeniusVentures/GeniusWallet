import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/banxa_helpers/order_transaction_mapping.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';

/// Opens the shared transaction drawer for a Banxa [order], so a row in any
/// list shows the same details.
void showOrderDetails(BuildContext context, Order order) {
  showTransactionDetails(
    context,
    orderAsTransaction(order),
    contentOverride: orderRowContent(order),
    extraTransactionRows: orderTransactionRows(order),
    extraNetworkRows: orderNetworkRows(order),
  );
}
