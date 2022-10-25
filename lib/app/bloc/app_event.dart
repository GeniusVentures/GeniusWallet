part of 'app_bloc.dart';

abstract class AppEvent {}

class CacheWallets extends AppEvent {
  final List<Wallet> wallets;

  CacheWallets({
    required this.wallets,
  });
}
