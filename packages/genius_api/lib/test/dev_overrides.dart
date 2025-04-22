import 'dart:math';

const walletPK = String.fromEnvironment('WALLET_PK', defaultValue: '');

final rand = Random();

bool isWalletPKBypass() {
  return walletPK.isNotEmpty;
}

String? getDevPrivateKey() {
  if (isWalletPKBypass()) {
    return walletPK;
  }
  return null;
}
