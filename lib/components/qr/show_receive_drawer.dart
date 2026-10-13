import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/qr/crypto_address_qr.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

/// Opens the address-QR receive drawer for the selected wallet. There is no
/// `/receive` route; no-op while no wallet address is known.
void showReceiveDrawer(BuildContext context, WalletDetailsState state) {
  final address = state.selectedWallet?.address;
  if (address == null || address.isEmpty) {
    return;
  }
  ResponsiveDrawer.show<void>(
    context: context,
    title: 'Receive',
    child: CryptoAddressQR(
      address: address,
      network:
          state.selectedNetwork?.name ?? state.selectedNetwork?.symbol ?? '',
      iconPath: state.selectedNetwork?.iconPath,
    ),
  );
}
