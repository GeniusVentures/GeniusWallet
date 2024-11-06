import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

class AppScreenView extends StatelessWidget {
  final Widget body;
  final Widget footer;
  final RefreshCallback? handleRefresh;
  const AppScreenView({
    super.key,
    required this.body,
    this.handleRefresh,
    this.footer = const SizedBox(),
  });

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse, // Enable mouse drag for desktop
          },
        ),
        child: RefreshIndicator(
            onRefresh: handleRefresh ?? _handleRefresh,
            color: GeniusWalletColors.lightGreenPrimary,
            child: SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: body,
                      ),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.only(bottom: 50),
                          child: footer,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )));
  }

  Future<void> _handleRefresh() async {}
}
