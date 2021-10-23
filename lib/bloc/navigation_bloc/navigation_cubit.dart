import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/screens/crypto_details/mobile/crypto_details_vertical.g.dart';
import 'package:geniuswallet/screens/new_wallet/mobile/new_wallet_vertical.g.dart';
import 'package:geniuswallet/screens/settings/mobile/settings_vertical.g.dart';

import 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationInitial());

  /// Method that goes to wallet and emits [InWallet] state
  void goToWallet(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => NewWalletVertical()));
    emit(InWallet());
  }

  /// Method that goes to dex and emits [InDex] state
  void gotToDex(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => CryptoDetailsVertical()));
    emit(InDex());
  }

  /// Method that goes to settings and emits [InSettings] state
  void goToSettings(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => SettingsVertical()));
    emit(InSettings());
  }
}
