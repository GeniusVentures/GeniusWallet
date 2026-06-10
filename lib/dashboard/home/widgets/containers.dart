import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';

double gridSpacing = 8;

class DashboardViewContainer extends StatelessWidget {
  final Widget child;
  const DashboardViewContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(gridSpacing),
        child: Container(
            decoration: BoxDecoration(
                gradient: GWDecorations.surfaceSheen,
                borderRadius: const BorderRadius.all(
                    Radius.circular(GeniusWalletConsts.borderRadiusCard)),
                border: Border.fromBorderSide(BorderSide(
                    color: GeniusWalletColors.borderSubtle, width: 1))),
            child: Padding(
                padding: const EdgeInsets.all(GeniusWalletConsts.space8),
                child: Column(children: [
                  Row(children: [child])
                ]))));
  }
}

class DashboardViewNoWrapperContainer extends StatelessWidget {
  final Widget child;
  const DashboardViewNoWrapperContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(gridSpacing),
        child: Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                    Radius.circular(GeniusWalletConsts.borderRadiusCard))),
            child: child));
  }
}

class DashboardScrollContainer extends StatelessWidget {
  final Widget child;
  const DashboardScrollContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(gridSpacing),
        child: Container(
            decoration: BoxDecoration(
                gradient: GWDecorations.surfaceSheen,
                borderRadius: const BorderRadius.all(
                    Radius.circular(GeniusWalletConsts.borderRadiusCard)),
                border: Border.fromBorderSide(BorderSide(
                    color: GeniusWalletColors.borderSubtle, width: 1))),
            child: Padding(
                padding: const EdgeInsets.all(GeniusWalletConsts.space8),
                child: child)));
  }
}
