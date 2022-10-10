import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/wallet_preview.g.dart';

class HorizontalWalletsScrollview extends StatelessWidget {
  const HorizontalWalletsScrollview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return SizedBox(
            height: 100,
            width: 200,
            child: LayoutBuilder(builder: (context, constraints) {
              return WalletPreview(constraints);
            }),
          );
        },
      ),
    );
  }
}
