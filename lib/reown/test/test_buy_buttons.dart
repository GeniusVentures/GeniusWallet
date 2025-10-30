import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/banxa_components/buy_cancelled_drawer.dart';
import 'package:genius_wallet/banxa/banxa_components/buy_success_drawer.dart';


class TestBuyButtons extends StatelessWidget {
  const TestBuyButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: "Test Buy Success Drawer",
          icon: const Icon(Icons.shopping_cart, color: Colors.green),
          onPressed: () {
            BuySuccessDrawer.show(
              context,
            );
          },
        ),
        IconButton(
          tooltip: "Test Buy Cancelled Drawer",
          icon: const Icon(Icons.remove_shopping_cart, color: Colors.redAccent),
          onPressed: () {
            BuyCancelledDrawer.show(context);
          },
        ),
      ],
    );
  }
}
