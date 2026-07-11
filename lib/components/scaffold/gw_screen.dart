import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

/// Unified screen wrapper. Provides: SafeArea, optional AppBar, a max content
/// width for wide viewports, and consistent horizontal padding.
///
/// Use this as the top-level widget of any route content — it plays well with
/// both mobile and desktop layouts without screens having to special-case them.
class GWScreen extends StatelessWidget {
  const GWScreen({
    super.key,
    required this.child,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.padding = const EdgeInsets.symmetric(
      horizontal: GeniusWalletConsts.space10,
      vertical: GeniusWalletConsts.space8,
    ),
    this.maxContentWidth = 1200,
    this.background,
    this.scroll = true,
    this.centerContent = true,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final EdgeInsetsGeometry padding;
  final double? maxContentWidth;
  final Color? background;
  final bool scroll;
  final bool centerContent;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(padding: padding, child: child);
    if (maxContentWidth != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth!),
        child: content,
      );
      if (centerContent) {
        content = Center(child: content);
      }
    }
    if (scroll) {
      content = SingleChildScrollView(
        child: content,
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: background ?? GeniusWalletColors.surfaceBase,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(child: content),
    );
  }
}
