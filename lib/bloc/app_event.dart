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
