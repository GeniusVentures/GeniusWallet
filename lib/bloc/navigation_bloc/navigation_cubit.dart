import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/screens/crypto_details/mobile/crypto_details_vertical.g.dart';
import 'package:geniuswallet/screens/settings/mobile/settings_vertical.g.dart';
import 'package:geniuswallet/screens/wallet_balance/mobile/wallet_balance_vertical.g.dart';
import 'package:geniuswallet/widgets/custom_page_route.dart';

import 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(InWallet());

  /// Method that goes to wallet and emits [InWallet] state
  void goToWallet(BuildContext context) {
    Navigator.of(context).pushReplacement(SlidingPageRoute(
      target: WalletBalanceVertical(),
      direction: AxisDirection.right,
    ));
    emit(InWallet());
  }

  /// Method that goes to dex and emits [InDex] state
  void gotToDex(BuildContext context) {
    /// Swap direction depending on the screen we came from
    var direction = AxisDirection.right;
    if (state is InWallet) {
      direction = AxisDirection.left;
    }
    Navigator.of(context).pushReplacement(SlidingPageRoute(
      target: CryptoDetailsVertical(),
      direction: direction,
    ));
    emit(InDex());
  }

  /// Method that goes to settings and emits [InSettings] state
  void goToSettings(BuildContext context) {
    Navigator.of(context).pushReplacement(SlidingPageRoute(
      target: SettingsVertical(),
      direction: AxisDirection.left,
    ));
    emit(InSettings());
  }
}
