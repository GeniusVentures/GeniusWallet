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
