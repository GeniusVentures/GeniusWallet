import 'package:flutter/material.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_text.dart';
import 'package:go_router/go_router.dart';

class DesktopContainer extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool? isIncludeBackButton;
  const DesktopContainer(
      {Key? key,
      this.child = const SizedBox(),
      this.title,
      this.isIncludeBackButton = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double horizontalPadding = GeniusBreakpoints.useDesktopLayout(context)
        ? GeniusWalletConsts.horizontalPadding
        : 20;
    return Scaffold(
        backgroundColor: GeniusWalletColors.deepBlueTertiary,
        body: SingleChildScrollView(
            child: SafeArea(
                child: Padding(
                    padding: EdgeInsets.only(
                        left: horizontalPadding,
                        top: 40,
                        right: horizontalPadding,
                        bottom: 40),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 40,
                                children: [
                                  Wrap(
                                    direction: Axis.vertical,
                                    spacing: 16,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.start,
                                    children: [
                                      Text(title ?? "Title",
                                          style: const TextStyle(
                                              fontSize: 48,
                                              fontWeight: FontWeight.w500)),
                                      if (isIncludeBackButton!)
                                        TextButton.icon(
                                            onPressed: () => {
                                                  if (context.canPop())
                                                    {context.pop()}
                                                  else
                                                    {
                                                      context
                                                          .replace('/dashboard')
                                                    }
                                                },
                                            icon: const Icon(
                                                Icons.arrow_back_ios),
                                            label: const Text('Back'))
                                    ],
                                  ),
                                  SizedBox(
                                      height: 50,
                                      width: MediaQuery.of(context).size.width *
                                          .3,
                                      child: const SearchBar(
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
                                      color:
                                          GeniusWalletColors.deepBlueTertiary,
                                      text: GeniusWalletText.btnSupport,
                                      textColor:
                                          GeniusWalletColors.lightGreenPrimary,
                                      icon: Icons.question_mark_outlined,
                                      isAddBorder: true,
                                    ),
                                    HeaderButton(
                                        color: GeniusWalletColors
                                            .lightGreenPrimary,
                                        text: GeniusWalletText.btnAddWallet,
                                        route: '/landing_screen',
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
  final String? route;
  const HeaderButton(
      {Key? key,
      this.child = const SizedBox(),
      this.text,
      this.textColor,
      this.color,
      this.isAddBorder = false,
      this.route,
      this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
        onPressed: () => context.push(route ?? ''),
        style: ButtonStyle(
            padding: const WidgetStatePropertyAll(EdgeInsets.all(20)),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (!states.contains(WidgetState.selected)) {
                return color;
              }
              return color;
            }),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
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
