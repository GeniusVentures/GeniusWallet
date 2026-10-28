import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_handler.dart';
import 'package:genius_wallet/navigation/router.dart';
import 'package:genius_wallet/reown/approve_dapp_connection_drawer.dart';
import 'package:genius_wallet/reown/gnus_wallet_connect.dart';
import 'package:genius_wallet/reown/handle_dapp_requests.dart';
import 'package:genius_wallet/reown/reown_walletkit_instance.dart';
import 'package:genius_wallet/reown/utilities.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:reown_walletkit/reown_walletkit.dart' hide Wallet;

/// Owns the WalletConnect listeners for the app's lifetime, so a proposal or
/// request is answered whatever is on screen.
class WalletConnectHost {
  /// [walletKit] and [init] default to the app's shared instance; tests pass
  /// a fake.
  WalletConnectHost({
    required this.geniusApi,
    required this.walletDetails,
    required this.transactions,
    required this.handler,
    required this.signableChainIds,
    required this.devBuild,
    ReownWalletKit? walletKit,
    Future<void> Function()? init,
  }) : _walletKit = walletKit,
       _init = init;

  final GeniusApi geniusApi;
  final WalletDetailsCubit walletDetails;
  final TransactionsCubit transactions;
  final GnusRpcHandler handler;

  /// The chains the wallet can sign on, read when a proposal arrives.
  final Iterable<int> Function() signableChainIds;

  /// Whether a loopback page may be trusted without Verify.
  final bool devBuild;
  final ReownWalletKit? _walletKit;
  final Future<void> Function()? _init;

  ReownWalletKit get walletKit => _walletKit ?? WalletKitInstance().walletKit;

  Future<bool>? _pending;
  bool _attached = false;
  bool _disposed = false;
  void Function()? _stopDappRequests;
  void Function()? _stopGnusRequests;

  /// Starts the SDK and attaches the listeners once. False when the SDK did
  /// not start; the next call tries again.
  Future<bool> start() {
    if (_attached) {
      return Future.value(true);
    }
    return _pending ??= _start().whenComplete(() => _pending = null);
  }

  Future<bool> _start() async {
    try {
      await (_init ?? WalletKitInstance().initOnce)();
    } catch (e) {
      debugPrint('WalletConnect start failed ${e.runtimeType}');
      return false;
    }
    if (_disposed) {
      return false;
    }
    walletKit.onSessionProposal.subscribe(_onProposal);
    _stopDappRequests = handleDappRequests(
      walletKit: walletKit,
      geniusApi: geniusApi,
      walletDetailsCubit: walletDetails,
      transactionsCubit: transactions,
    );
    _stopGnusRequests = handleGnusRequests(
      walletKit: walletKit,
      handler: handler,
      devBuild: devBuild,
    );
    _attached = true;
    return true;
  }

  void dispose() {
    _disposed = true;
    if (!_attached) {
      return;
    }
    walletKit.onSessionProposal.unsubscribe(_onProposal);
    _stopDappRequests?.call();
    _stopGnusRequests?.call();
    _attached = false;
  }

  Future<void> _reject(int id, ReownSignError reason) async {
    try {
      await walletKit.rejectSession(id: id, reason: reason);
    } catch (e) {
      debugPrint('WalletConnect reject failed ${e.runtimeType}');
    }
  }

  void _toast(String message, ToastType type) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      showToast(context, message, type: type);
    }
  }

  /// The selected wallet when it can sign. Otherwise the proposal is
  /// rejected, the user is told why, and the result is null.
  Future<Wallet?> _signerOrReject(int proposalId) async {
    final wallet = walletDetails.state.selectedWallet;
    if (wallet != null && walletCanSign(wallet)) {
      return wallet;
    }
    await _reject(
      proposalId,
      ReownSignError(
        code: Errors.getSdkError(Errors.UNSUPPORTED_ACCOUNTS).code,
        message: 'The selected wallet cannot sign',
      ),
    );
    _toast(
      'The selected wallet cannot sign. Switch to a wallet that can sign, '
      'then connect again.',
      ToastType.error,
    );
    return null;
  }

  Future<void> _onProposal(SessionProposalEvent? event) async {
    if (event == null) {
      return;
    }
    if (await _signerOrReject(event.id) == null) {
      return;
    }
    final metadata = event.params.proposer.metadata;
    final gnusMethods = requestedGnusMethods(event.params);
    var dappUrl = metadata.url;
    if (gnusMethods.isNotEmpty) {
      final check = gnusProposalOrigin(
        event.verifyContext,
        metadata.url,
        devBuild: devBuild,
      );
      final origin = check.origin;
      if (origin == null) {
        final flagged = check.refusal == GnusRefusal.flagged;
        await _reject(
          event.id,
          ReownSignError(
            code: 5000,
            message: flagged
                ? 'Site flagged by WalletConnect Verify'
                : 'Site could not be verified',
          ),
        );
        _toast(
          flagged
              ? 'WalletConnect flagged this site as unsafe, so it was not '
                    'connected.'
              : 'This site could not be verified, so it was not connected.',
          ToastType.error,
        );
        return;
      }
      dappUrl = origin.value;
    }

    final chainIds = signableChainIds().toList();

    final context = navigatorKey.currentContext;
    if (context == null) {
      await _reject(
        event.id,
        Errors.getSdkError(Errors.USER_REJECTED).toSignError(),
      );
      return;
    }

    try {
      final approved = await ApproveDappConnectionDrawer.show(
        context: context,
        dappName: metadata.name,
        dappUrl: dappUrl,
        dappDescription: metadata.description,
        iconUrl: metadata.icons.isNotEmpty ? metadata.icons.first : null,
      );
      if (approved != true) {
        _toast('DApp connection was rejected.', ToastType.error);
        await _reject(
          event.id,
          Errors.getSdkError(Errors.USER_REJECTED).toSignError(),
        );
        return;
      }
      // The user may have switched wallets while the drawer was open.
      final signer = await _signerOrReject(event.id);
      if (signer == null) {
        return;
      }
      final chains = <int>{
        ...(chainIds.isEmpty ? const [1] : chainIds),
        if (gnusMethods.isNotEmpty) kGnusWalletConnectChainId,
      };
      await walletKit.approveSession(
        id: event.id,
        namespaces: {
          'eip155': eip155Namespace(
            chainIds: chains,
            address: signer.address,
            methods: [...supportedMethods, ...gnusMethods],
            events: [...eip155Events, ...requestedGnusEvents(event.params)],
          ),
        },
      );
    } catch (e) {
      debugPrint('WalletConnect proposal failed ${e.runtimeType}');
      // The page must not wait on a proposal this wallet could not finish.
      await _reject(
        event.id,
        const ReownSignError(code: -32000, message: 'Could not connect'),
      );
    }
  }
}
