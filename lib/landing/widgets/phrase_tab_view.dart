import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

class PhraseTabView extends StatelessWidget {
  const PhraseTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GeniusWalletColors.blue500.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      width: MediaQuery.of(context).size.width * 0.8,
      height: 150,
      child: Stack(
        children: [
          const Positioned(
            bottom: 25,
            right: 25,
            child: Text(
              'Paste',
              style: TextStyle(
                color: GeniusWalletColors.blue500,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
