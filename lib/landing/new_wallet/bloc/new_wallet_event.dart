part of 'new_wallet_bloc.dart';

abstract class NewWalletEvent {}

class LoadRecoveryPhrase extends NewWalletEvent {}

class CopyRecoveryPhrase extends NewWalletEvent {}
