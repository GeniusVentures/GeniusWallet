import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

double gridSpacing = 8;

class DashboardViewContainer extends StatelessWidget {
  final Widget child;
  const DashboardViewContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(gridSpacing),
        child: Container(
            decoration: const BoxDecoration(
                color: GeniusWalletColors.deepBlueCardColor,
                borderRadius: BorderRadius.all(
                    Radius.circular(GeniusWalletConsts.borderRadiusCard))),
            child: Padding(
                padding: const EdgeInsets.all(24),
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

class DashboardViewNoFlexContainer extends StatelessWidget {
  final Widget child;
  const DashboardViewNoFlexContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(gridSpacing),
        child: Container(
            decoration: const BoxDecoration(
                color: GeniusWalletColors.deepBlueCardColor,
                borderRadius: BorderRadius.all(
                    Radius.circular(GeniusWalletConsts.borderRadiusCard))),
            child: Padding(padding: const EdgeInsets.all(24), child: child)));
  }
}
