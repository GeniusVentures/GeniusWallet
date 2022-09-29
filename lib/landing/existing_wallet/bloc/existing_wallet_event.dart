part of 'existing_wallet_bloc.dart';

abstract class ExistingWalletEvent {}

class ToggleLegal extends ExistingWalletEvent {}

class ChangeStep extends ExistingWalletEvent {
  FlowStep step;

  ChangeStep({required this.step});
}

class ImportWalletSelected extends ExistingWalletEvent {
  String walletName;

  ImportWalletSelected({required this.walletName});
}

class WalletSecurityEntered extends ExistingWalletEvent {
  ///TODO: Make these fields into a single object?
  final String walletName;

  final String walletType;

  final String securityType;

  final String pasteFieldText;

  /// Password provided for the KeyStore type
  final String? password;

  WalletSecurityEntered({
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

class PinCheckSuccessful extends ExistingWalletEvent {}

class PinCheckFailed extends ExistingWalletEvent {}
