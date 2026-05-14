import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BuyGnusButton extends StatelessWidget {
  final String walletAddress;
  final String userEmail;

  const BuyGnusButton({
    super.key,
    required this.walletAddress,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        label: const Text(
          "Buy GNUS",
          style: TextStyle(fontSize: 14),
        ),
        onPressed: () async {
          context.push('/buy');
        });
  }
}
