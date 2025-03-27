part of 'app_bloc.dart';

abstract class AppEvent {}

class SubscribeToWallets extends AppEvent {}

class CheckIfUserExists extends AppEvent {}

/// Class whose purpose is to test FFI Bridge functionality
class FFITestEvent extends AppEvent {}

class FetchAccount extends AppEvent {}

class StreamSGNUSTransactions extends AppEvent {}
