import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/test/dev_overrides.dart';
import 'package:go_router/go_router.dart';
import 'package:local_secure_storage/local_secure_storage.dart';
import 'package:provider/provider.dart';

/// Runtime mock-mode entry point. Skips real wallet creation, FFI init and
/// secure-storage gating so a developer can navigate the authenticated UI
/// (dashboard, wallet detail, transactions, bridge) for design review.
///
/// Reuses the existing `byPass*` overrides from `dev_overrides.dart` but
/// forces them on at runtime instead of waiting for the `WALLET_PK` env var.
class MockMode {
  /// Inject a fake wallet + SGNUS connection + sample transactions, then
  /// route into the dashboard. Safe to call from a debug-only button.
  static Future<void> enableAndNavigate(BuildContext context) async {
    final api = context.read<GeniusApi>();
    final storage = context.read<LocalWalletStorage>();
    final appBloc = context.read<AppBloc>();

    byPassWalletCreation(storage, force: true);
    byPassSGNUSConnecton(api, force: true);
    addFakeSGNUSTransactions(
      api.getSGNUSTransactionsController(),
      force: true,
    );

    // Refire LoadWallets so AppBloc picks up the freshly-added wallet
    // and wires WalletDetailsCubit + TransactionsCubit through `loadInitial`.
    appBloc.add(LoadWallets());

    // Wait until the bloc has the wallet loaded — gives downstream cubits a
    // chance to settle before the dashboard tries to render against them.
    await appBloc.stream.firstWhere(
      (s) =>
          s.subscribeToWalletStatus == AppStatus.loaded &&
          s.wallets.isNotEmpty,
      orElse: () => appBloc.state,
    );

    if (context.mounted) {
      context.go('/dashboard');
    }
  }
}
