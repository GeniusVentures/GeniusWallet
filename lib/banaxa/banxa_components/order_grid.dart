import 'package:flutter/material.dart';
import 'package:genius_wallet/banaxa/banaxa_model.dart';
import 'package:genius_wallet/banaxa/banxa_components/order_card.dart';
class OrderGrid extends StatelessWidget {
  final List<Order> orders;
  final Function(Order) onSeeDetails;
  final Function(Order) onCompletePayment;
  final Function(Order) onRetryOrder;
  const OrderGrid({
    required this.orders,
    required this.onSeeDetails,
    required this.onCompletePayment,
    required this.onRetryOrder,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 900;
      final crossAxisCount = isWide ? 2 : 1;
      const spacing = 16.0;
      final totalSpacing = spacing * (crossAxisCount - 1);
      final cardWidth = (constraints.maxWidth - totalSpacing) / crossAxisCount;

      const targetHeight = 300.0;
      double childAspectRatio = cardWidth / targetHeight;
      childAspectRatio = childAspectRatio.clamp(1.2, 2.5);

      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return OrderCard(
            order: order,
            onSeeDetails: () => onSeeDetails(order),
            onCompletePayment: () => onCompletePayment(order),
            onRetryOrder: () => onRetryOrder(order),
          );
        },
      );
    });
  }
}
