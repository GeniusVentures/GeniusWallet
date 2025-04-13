import 'package:flutter/material.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/models/wallet.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class SelectedWalletAndNetwork {
  final Wallet wallet;
  final Network network;

  SelectedWalletAndNetwork({required this.wallet, required this.network});
}

SelectedWalletAndNetwork getSelectedWalletAndNetwork(
  BuildContext context,
  List<Wallet> stateWallets,
) {
  final wallets = [...stateWallets];
  final walletBox = Hive.box(walletBoxName);
  final address = walletBox.get(selectedWalletKey) as String?;

  final networkBox = Hive.box(networkBoxName);
  final chainId = networkBox.get(selectedNetworkKeyChainId) as int?;
  final rpcUrl = networkBox.get(selectedNetworkKeyRpcUrl) as String?;

  final networks =
      Provider.of<NetworkProvider>(context, listen: false).networks;

  final selectedNetwork = networks.firstWhere(
    (n) => n.chainId == chainId && n.rpcUrl == rpcUrl,
    orElse: () => networks.first,
  );

  final selectedWallet = wallets.firstWhere(
    (w) => w.address == address,
    orElse: () => wallets.first,
  );

  return SelectedWalletAndNetwork(
    wallet: selectedWallet,
    network: selectedNetwork,
  );
}
