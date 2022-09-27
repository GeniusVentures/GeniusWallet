import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

class PasteField extends StatelessWidget {
  final Widget? additionalWidget;
  final String subtitle;
  const PasteField({
    Key? key,
    this.additionalWidget,
    this.subtitle = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var addon = const <Widget>[SizedBox()];
    if (additionalWidget != null) {
      addon = [
        const SizedBox(height: 20),
        additionalWidget!,
      ];
    }
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: GeniusWalletColors.blue500.withOpacity(0.1),
            borderRadius: BorderRadius.circular(5),
          ),
          width: MediaQuery.of(context).size.width * 0.8,
          height: 200,
          child: Stack(
            children: const [
              Positioned(
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
        ),
        ...addon,
        const SizedBox(height: 20),
        Text(
          subtitle,
          textAlign: TextAlign.left,
        )
      ],
    );
  }
}
