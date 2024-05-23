import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_text.dart';

class DesktopContainer extends StatelessWidget {
  final Widget child;
  final String? title;
  const DesktopContainer({Key? key, this.child = const SizedBox(), this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: GeniusWalletColors.deepBlueTertiary,
        body: SingleChildScrollView(
            child: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Wrap(
                            spacing: 40,
                            children: [
                              Text(title ?? "Title",
                                  style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(
                                  width: 300,
                                  child: SearchBar(
                                    hintText: 'Search ...',
                                    trailing: [
                                      Icon(
                                        Icons.search,
                                        color: GeniusWalletColors.gray500,
                                      )
                                    ],
                                  )),
                            ],
                          ),
                          const Wrap(
                              spacing: GeniusWalletConsts.itemSpacing,
                              runSpacing: GeniusWalletConsts.itemSpacing,
                              children: [
                                HeaderButton(
                                  color: GeniusWalletColors.deepBlueTertiary,
                                  text: GeniusWalletText.btnSupport,
                                  textColor:
                                      GeniusWalletColors.lightGreenPrimary,
                                  icon: Icons.question_mark_outlined,
                                  isAddBorder: true,
                                ),
                                HeaderButton(
                                    color: GeniusWalletColors.lightGreenPrimary,
                                    text: GeniusWalletText.btnAddWallet,
                                    textColor:
                                        GeniusWalletColors.deepBlueTertiary,
                                    icon: Icons.add_circle_outlined),
                                HeaderButton(
                                    color: GeniusWalletColors.gray900,
                                    text: 'Genius 1',
                                    textColor: Colors.white,
                                    icon: Icons.person),
                              ]),
                        ],
                      ),
                      const SizedBox(height: 40),
                      child
                    ])))));
  }
}

class HeaderButton extends StatelessWidget {
  final Widget child;
  final String? text;
  final Color? textColor;
  final Color? color;
  final IconData? icon;
  final bool? isAddBorder;
  const HeaderButton(
      {Key? key,
      this.child = const SizedBox(),
      this.text,
      this.textColor,
      this.color,
      this.isAddBorder = false,
      this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
        onPressed: null,
        style: ButtonStyle(
            padding: const MaterialStatePropertyAll(EdgeInsets.all(20)),
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (!states.contains(MaterialState.selected)) {
                return color;
              }
              return color;
            }),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: isAddBorder!
                  ? BorderSide(width: 1, color: textColor ?? Colors.red)
                  : BorderSide.none,
            ))),
        label: Text(
          text ?? 'Button',
          style: TextStyle(color: textColor),
        ),
        icon: Icon(
          icon,
          color: textColor,
        ));
  }
}
