part of 'existing_wallet_bloc.dart';

abstract class ExistingWalletEvent {}

class ToggleLegal extends ExistingWalletEvent {}

class ImportWalletSelected extends ExistingWalletEvent {
  String walletName;
  int coinType;

  ImportWalletSelected({required this.walletName, required this.coinType});
}

class WalletSecurityEntered extends ExistingWalletEvent {
  ///TODO: Make these fields into a single object?
  final int coinType;
  final String walletName;
  final String walletType;
  final SecurityType securityType;
  final String pasteFieldText;

  /// Password provided for the KeyStore type
  final String? password;

  WalletSecurityEntered({
    required this.coinType,
    required this.walletName,
    required this.walletType,
    required this.securityType,
    required this.pasteFieldText,
    this.password,
  });
}

class PinCreated extends ExistingWalletEvent {
  String pin;

  PinCreated({required this.pin});
}

class PinConfirmPassed extends ExistingWalletEvent {}

class PinConfirmFailed extends ExistingWalletEvent {}

class LegalAccepted extends ExistingWalletEvent {
  final bool userExists;

  LegalAccepted({required this.userExists});
}
