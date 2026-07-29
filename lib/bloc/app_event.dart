part of 'app_bloc.dart';

abstract class AppEvent {}

class InitializeSDK extends AppEvent {}

class LoadWallets extends AppEvent {}

class CheckIfUserExists extends AppEvent {}

/// Class whose purpose is to test FFI Bridge functionality
class RunFFITest extends AppEvent {}

class FetchAccount extends AppEvent {}

class StartSGNUSTransactionsStream extends AppEvent {}

class ProcessingStatusTicked extends AppEvent {}

/// Re-arms the polling timer an exception permanently cancelled
/// (`app_bloc.dart:192-195`'s catch) and clears the feed's unavailable flag
/// back to its pre-read value. See `AppBloc._onRetryProcessingStatus`.
class RetryProcessingStatus extends AppEvent {}

/// Dispatched by the initialization poll's `Timer.periodic`
/// (`AppBloc._startInitPolling`), mirroring `ProcessingStatusTicked`'s
/// existing shape.
class InitializationStatusTicked extends AppEvent {}

class DeleteWallet extends AppEvent {
  final String address;

  DeleteWallet(this.address);
}

class RenameWallet extends AppEvent {
  final String address;
  final String newName;

  RenameWallet(this.address, this.newName);
}

class SgnusConnectionChanged extends AppEvent {
  final SGNUSConnection connection;

  SgnusConnectionChanged(this.connection);
}

class SelectSDKAccount extends AppEvent {
  final String publicAddress;

  SelectSDKAccount(this.publicAddress);
}

class AddSDKAccountWithMnemonic extends AppEvent {
  final String mnemonic;

  AddSDKAccountWithMnemonic(this.mnemonic);
}

class AddSDKAccountWithPrivateKey extends AppEvent {
  final String privateKey;

  AddSDKAccountWithPrivateKey(this.privateKey);
}

class DeleteSDKAccount extends AppEvent {
  final String publicAddress;

  DeleteSDKAccount(this.publicAddress);
}

class RefreshSDKAccounts extends AppEvent {}

class SetSDKPayoutAddress extends AppEvent {
  final String publicAddress;

  SetSDKPayoutAddress(this.publicAddress);
}
