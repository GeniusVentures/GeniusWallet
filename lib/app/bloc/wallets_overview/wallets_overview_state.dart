import 'package:equatable/equatable.dart';
import 'package:genius_api/genius_api.dart';

class WalletsOverviewState extends Equatable {
  final WalletsOverviewStatus fetchWalletsStatus;
  final List<Wallet> wallets;

  const WalletsOverviewState({
    this.fetchWalletsStatus = WalletsOverviewStatus.initial,
    this.wallets = const [],
  });

  WalletsOverviewState copyWith({
    WalletsOverviewStatus? fetchWalletsStatus,
    List<Wallet>? wallets,
  }) {
    return WalletsOverviewState(
      fetchWalletsStatus: fetchWalletsStatus ?? this.fetchWalletsStatus,
      wallets: wallets ?? this.wallets,
    );
  }

  @override
  List<Object?> get props => [fetchWalletsStatus, wallets];
}

enum WalletsOverviewStatus {
  initial,
  loading,
  error,
  success,
}
