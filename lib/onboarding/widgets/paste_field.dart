import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:clipboard/clipboard.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_font_size.dart';
import 'package:genius_wallet/theme/genius_wallet_text.dart';

class PasteField extends StatelessWidget {
  final String hintText;
  final Widget? additionalWidget;
  final String subtitle;
  final TextEditingController controller;
  final double height;
  const PasteField({
    Key? key,
    this.additionalWidget,
    this.subtitle = '',
    this.hintText = '',
    this.height = 200,
    required this.controller,
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
            color: GeniusWalletColors.grayPrimary,
            border: Border.all(color: GeniusWalletColors.borderGrey),
            borderRadius:
                BorderRadius.circular(GeniusWalletConsts.borderRadiusCard),
          ),
          width: MediaQuery.of(context).size.width * 0.9,
          height: height,
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
                bottom: 10,
                right: 10,
                child: TextButton.icon(
                  onPressed: () async {
                    final textValue = await FlutterClipboard.paste();
                    controller.text = textValue;
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    side: const BorderSide(width: 1.0, color: Colors.white),
                  ),
                  icon: const Icon(Icons.content_copy,
                      color: Colors.white, size: GeniusWalletFontSize.base),
                  label: const Text(
                    GeniusWalletText.btnPaste,
                    style: TextStyle(
                        fontSize: GeniusWalletFontSize.medium,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        ...addon,
        const SizedBox(height: 20),
        SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Text(
              subtitle,
              textAlign: TextAlign.left,
            )),
      ],
    );
  }
}
