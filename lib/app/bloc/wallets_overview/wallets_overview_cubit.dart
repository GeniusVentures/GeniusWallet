import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/wallets_overview/wallets_overview_state.dart';

class WalletsOverviewCubit extends Cubit<WalletsOverviewState> {
  final GeniusApi geniusApi;
  WalletsOverviewCubit({
    required this.geniusApi,
  }) : super(const WalletsOverviewState());

  Future<void> fetchWallets(String userId) async {
    emit(state.copyWith(
      fetchWalletsStatus: WalletsOverviewStatus.loading,
    ));
    try {
      final userWallets = await geniusApi.getUserWallets('userId');
      emit(state.copyWith(
        wallets: userWallets,
        fetchWalletsStatus: WalletsOverviewStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(fetchWalletsStatus: WalletsOverviewStatus.error));
    }
  }

  /// Gathers transactions and emits a new [WalletsOverviewState] with all aggregated transactions.
  ///
  /// !Note: Assumes that wallets have already been fetched
  Future<void> fetchTransactions() async {
    emit(
      state.copyWith(fetchTransactionsStatus: WalletsOverviewStatus.loading),
    );

    final transactions = <Transaction>[];
    for (var wallet in state.wallets) {
      transactions.addAll(wallet.transactions);
    }

    emit(
      state.copyWith(
        transactions: transactions,
        fetchTransactionsStatus: WalletsOverviewStatus.success,
      ),
    );
  }
}
