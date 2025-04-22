import 'package:reown_walletkit/reown_walletkit.dart';

class WalletKitInstance {
  static final WalletKitInstance _instance = WalletKitInstance._internal();
  late final ReownWalletKit walletKit;

  factory WalletKitInstance() => _instance;

  WalletKitInstance._internal() {
    walletKit = ReownWalletKit(
      core: ReownCore(projectId: '999123e54f32a21dbd087339746231b1'),
      metadata: const PairingMetadata(
        name: 'Gnus.ai Wallet',
        description: 'Gnus.ai wallet',
        url: 'https://gnus.ai/',
        icons: ['https://example.com/logo.png'],
      ),
    );
  }
}
