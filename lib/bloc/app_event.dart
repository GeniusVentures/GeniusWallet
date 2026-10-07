part of 'app_bloc.dart';

abstract class AppEvent {}

/// A delete that can remove a key wallet. All of them share one queue, so
/// each last-wallet guard sees the previous delete's result.
sealed class WalletRemoval extends AppEvent {}

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

class DeleteWallet extends WalletRemoval {
  final String address;

  /// A key wallet and a watch-only row can share [address]; this picks one.
  final bool watchOnly;

  DeleteWallet(this.address, {required this.watchOnly});
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

/// Re-reads the node's selected account while a switch is still landing.
class SDKSwitchPolled extends AppEvent {}

class DeleteSDKAccount extends WalletRemoval {
  final String publicAddress;

  DeleteSDKAccount(this.publicAddress);
}

class RefreshSDKAccounts extends AppEvent {}

/// Re-reads the receipt of every send the history still shows as pending --
/// the startup read finds nothing for a send that had not mined yet.
class SettlePendingSends extends AppEvent {}

class SetSDKPayoutAddress extends AppEvent {
  final String publicAddress;

  /// Completes with this request's own SDK result.
  final result = Completer<GeniusNodeReturnValue>();

  SetSDKPayoutAddress(this.publicAddress);
}
