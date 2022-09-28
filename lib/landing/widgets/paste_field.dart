import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:clipboard/clipboard.dart';

class PasteField extends StatelessWidget {
  final String hintText;
  final Widget? additionalWidget;
  final String subtitle;
  const PasteField({
    Key? key,
    this.additionalWidget,
    this.subtitle = '',
    this.hintText = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
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
            children: [
              TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                ),
                minLines: 10,
                maxLines: 10,
              ),
              Positioned(
                bottom: 25,
                right: 25,
                child: MaterialButton(
                  onPressed: () async {
                    final textValue = await FlutterClipboard.paste();
                    controller.text = textValue;
                  },
                  child: const Text(
                    'Paste',
                    style: TextStyle(
                      color: GeniusWalletColors.blue500,
                      fontSize: 18,
                    ),
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
        ),
      ],
    );
  }
}
