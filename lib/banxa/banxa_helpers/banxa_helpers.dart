import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/banaxa_api_services.dart';
import 'package:genius_wallet/banxa/banaxa_model.dart';
import 'package:intl/intl.dart';

class BannerInfo {
  final Color color;
  final String text;
  const BannerInfo(this.color, this.text);
}

class BanxaHelpers {
  BanxaHelpers._();

  static BannerInfo? getBannerInfo(String? status) {
    final s = status?.toLowerCase();
    if (s == 'cancel') {
      return BannerInfo(
          Colors.amber.shade100, 'Checkout cancelled. Verifying order status…');
    } else if (s == 'failure' || s == 'failed') {
      return BannerInfo(
          Colors.red.shade100, 'Payment failed. Verifying order status…');
    } else if (s == 'success' || s == 'completed') {
      return BannerInfo(
          Colors.green.shade100, 'Payment completed. Fetching final details…');
    }
    return null;
  }
    static List<String> getOrderStatuses() => [
        "",
        "pendingPayment",
        "completed",
        "declined",
        "inProgress",
        "expired",
      ];

  static String getOrderStatusLabel(String status) {
    switch (status) {
      case "pendingPayment":
        return "Pending Payment";
      case "completed":
        return "Completed";
      case "declined":
        return "Declined";
      case "inProgress":
        return "In Progress";
      case "expired":
        return "Expired";
      default:
        return status;
    }
  }

 static String formatDate(DateTime date) {
    final DateFormat dateFormat =
        DateFormat.yMMMd(); 
    return dateFormat.format(date);
  }

      static Map<String, dynamic> buildOrderDetailsExtra(Order order) => {
        'orderId': order.id,
        'checkoutUrl': order.orderStatusUrl,
        'redirectUrl': BanxaApiService.redirectUrl,
      };

}
