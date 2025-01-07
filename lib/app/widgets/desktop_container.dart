import 'package:auto_size_text/auto_size_text.dart';
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

  const DesktopContainer({
    Key? key,
    this.child = const SizedBox(),
    this.title,
    this.isIncludeBackButton = false,
  }) : super(key: key);

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
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title, Search Bar, and Buttons
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Back Button
                        if (isIncludeBackButton!)
                          IconButton(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.replace('/dashboard');
                              }
                            },
                            icon: const Icon(Icons.arrow_back_ios),
                          ),
                        // Title
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: AutoSizeText(
                            title ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Search Bar
                        const Flexible(
                          child: SizedBox(
                            child: SearchBar(
                              hintText: 'Search ...',
                              trailing: [
                                Icon(
                                  Icons.search,
                                  color: GeniusWalletColors.gray500,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Buttons
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HeaderButton(
                              color: GeniusWalletColors.deepBlueTertiary,
                              text: GeniusWalletText.btnSupport,
                              textColor: GeniusWalletColors.lightGreenPrimary,
                              icon: Icons.question_mark_outlined,
                              isAddBorder: true,
                            ),
                            SizedBox(width: 12),
                            HeaderButton(
                              color: GeniusWalletColors.lightGreenPrimary,
                              text: GeniusWalletText.btnAddWallet,
                              route: '/landing_screen',
                              textColor: GeniusWalletColors.deepBlueTertiary,
                              icon: Icons.add_circle_outlined,
                            ),
                            SizedBox(width: 12),
                            HeaderButton(
                              color: GeniusWalletColors.gray900,
                              text: 'Genius 1',
                              textColor: Colors.white,
                              icon: Icons.person,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 40),
                child,
              ],
            ),
          ),
        ),
      ),
    );
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

  const HeaderButton({
    Key? key,
    this.child = const SizedBox(),
    this.text,
    this.textColor,
    this.color,
    this.isAddBorder = false,
    this.route,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: TextButton.icon(
      onPressed: () => context.push(route ?? ''),
      style: ButtonStyle(
        padding: const MaterialStatePropertyAll(EdgeInsets.all(20)),
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          return color;
        }),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: isAddBorder!
                ? BorderSide(width: 1, color: textColor ?? Colors.red)
                : BorderSide.none,
          ),
        ),
      ),
      label: AutoSizeText(
        text ?? 'Button',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: textColor),
      ),
      icon: Icon(
        icon,
        color: textColor,
      ),
    ));
  }
}
