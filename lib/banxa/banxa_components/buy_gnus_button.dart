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
        // icon: const Icon(
        //   Icons.attach_money,
        //   color: GeniusWalletColors.lightGreenPrimary,
        // ),
        label: const Text(
          "Buy GNUS",
          style: TextStyle(fontSize: 14),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          overlayColor: Colors.transparent,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.transparent,
         
        ),
        onPressed: () async {
         

        
            context.push('/buy');
          
        });
  }
}
