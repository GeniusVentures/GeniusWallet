import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/models/transaction.dart' show TransactionStatus;
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/coins/view/coins_screen.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/components/feedback/gw_warning_note.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/hive/services/transaction_storage_service.dart';
import 'package:genius_wallet/reown/send_transaction_details.dart';
import 'package:genius_wallet/reown/utilities.dart';
import 'package:genius_wallet/send/recipient_field.dart';
import 'package:genius_wallet/send/send_cubit.dart';
import 'package:genius_wallet/squid_router/squid_util.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

/// The `/send` route target: a keyboard form, not a drawer -- typing
/// an address and an amount in a bottom sheet is cramped on a phone.
class SendScreen extends StatelessWidget {
  const SendScreen({
    super.key,
    this.preselectSymbol,
    this.preselectAddress,
    this.preselectChainId,
    this.storage = const TransactionStorageService(),
  });

  final String? preselectSymbol;

  /// The token contract to seat; null means the native coin.
  final String? preselectAddress;
  final int? preselectChainId;
  final TransactionStorageService storage;

  @override
  Widget build(BuildContext context) {
    final walletState = context.watch<WalletDetailsCubit>().state;
    final wallet = walletState.selectedWallet;
    final network = walletState.selectedNetwork;

    if (wallet == null || network == null || !canSendFrom(wallet, network)) {
      return const Scaffold(
        body: SafeArea(
          child: GWEmptyState(
            icon: Icons.send_outlined,
            title: "Send isn't available here",
            message: "This wallet can't sign a transaction on this network.",
          ),
        ),
      );
    }

    // A network switch lands before that network's coins do. Seating from
    // the list still on state would sign on this chain under a coin, or a
    // contract address, from the chain just left.
    if (walletState.coinsNetwork != network) {
      final failed = walletState.coinsStatus == WalletStatus.error;
      return Scaffold(
        body: SafeArea(
          child: GWEmptyState(
            icon: Icons.hourglass_empty,
            title: failed ? "Couldn't load your coins" : 'Loading your coins',
            message: failed
                ? "Your coins on ${network.name} didn't load."
                : 'Your coins on ${network.name} are still loading.',
          ),
        ),
      );
    }

    final walletCubit = context.read<WalletDetailsCubit>();
    final transactions = context.read<TransactionsCubit>();
    final coin = _seatedCoin(
      walletState.coins,
      preselectSymbol,
      preselectAddress,
      preselectChainId,
      network,
    );

    // Keyed on the wallet and chain: switching either must start a fresh
    // form rather than carrying a stale recipient or review onto a
    // different signer or network.
    return BlocProvider<SendCubit>(
      key: ValueKey('${wallet.address}-${network.chainId}'),
      create: (_) => SendCubit(
        api: walletCubit.geniusApi,
        walletAddress: wallet.address,
        network: network,
        transactions: transactions,
        storage: storage,
        coinsLoadedFor: () => walletCubit.state.coinsNetwork,
        initialCoin: coin,
      ),
      child: const _SendBody(),
    );
  }
}

/// The held coin at [preselectAddress], or the native coin named
/// [preselectSymbol] when there is no address. Tickers are not unique, so an
/// unmatched address or chain id seats nothing rather than a namesake.
Coin? _seatedCoin(
  List<Coin> coins,
  String? preselectSymbol,
  String? preselectAddress,
  int? preselectChainId,
  Network network,
) {
  if (preselectSymbol == null && preselectAddress == null) {
    return null;
  }
  if (preselectChainId != null && preselectChainId != network.chainId) {
    return null;
  }
  for (final candidate in coins) {
    if (preselectAddress != null) {
      if (candidate.address?.toLowerCase() == preselectAddress.toLowerCase()) {
        return candidate;
      }
    } else if (candidate.address == null &&
        (candidate.symbol ?? '').toLowerCase() ==
            preselectSymbol!.toLowerCase()) {
      return candidate;
    }
  }
  return null;
}

class _SendBody extends StatefulWidget {
  const _SendBody();

  @override
  State<_SendBody> createState() => _SendBodyState();
}

class _SendBodyState extends State<_SendBody> {
  // Kept in step with `state.amount`/`state.recipient` in build -- MAX and a
  // paste/scan change the cubit's value without the user typing into either
  // field directly.
  final _amountController = TextEditingController();
  final _recipientController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _recipientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<SendCubit>();
    final state = cubit.state;
    final coin = state.coin;

    if (coin == null) {
      // A bare `/send` (the dashboard entry point) carries no coin --
      // offer the picker rather than a dead end.
      return Scaffold(
        body: SafeArea(child: CoinsScreen(onCoinSelected: cubit.selectCoin)),
      );
    }

    if (_amountController.text != state.amount) {
      _amountController.value = _amountController.value.copyWith(
        text: state.amount,
        selection: TextSelection.collapsed(offset: state.amount.length),
      );
    }
    if (_recipientController.text != state.recipient) {
      _recipientController.value = _recipientController.value.copyWith(
        text: state.recipient,
        selection: TextSelection.collapsed(offset: state.recipient.length),
      );
    }

    final coinSymbol = (coin.symbol ?? '').toUpperCase();

    return Scaffold(
      body: SafeArea(
        // A short phone with the keyboard up or large text has no room for
        // every warning; scrolling keeps each input and Review reachable.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(GeniusWalletConsts.space10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const GWPageHeader(title: 'Send'),
              const SizedBox(height: GeniusWalletConsts.space6),
              RecipientField(
                controller: _recipientController,
                errorText: state.recipientError,
              ),
              const SizedBox(height: GeniusWalletConsts.space6),
              GWTextField(
                controller: _amountController,
                label: 'Amount',
                hint: '0.0',
                errorText: state.amountError,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                suffix: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(coinSymbol),
                    const SizedBox(width: GeniusWalletConsts.space4),
                    GWButton(
                      label: 'MAX',
                      variant: GWButtonVariant.ghost,
                      size: GWButtonSize.sm,
                      onPressed: state.busy ? null : cubit.useMax,
                    ),
                  ],
                ),
                onChanged: cubit.setAmount,
              ),
              if (state.error != null) ...[
                const SizedBox(height: GeniusWalletConsts.space6),
                Semantics(liveRegion: true, child: GWWarningNote(state.error!)),
              ],
              const SizedBox(height: GeniusWalletConsts.space8),
              GWButton(
                label: 'Review',
                variant: GWButtonVariant.gradient,
                expand: true,
                isLoading: state.busy,
                onPressed: state.busy ? null : () => _review(context, cubit),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Reviews, then acts on the confirm drawer: Cancel drops the built
  /// transaction, Send signs it. The outcome shown comes from
  /// [SendCubit.submit]'s return, never cubit state a later call replaced.
  Future<void> _review(BuildContext context, SendCubit cubit) async {
    await cubit.review();
    if (!context.mounted) {
      return;
    }
    final review = cubit.state.review;
    if (review == null) {
      return;
    }

    final gasSymbol = (cubit.network.nativeSymbol ?? cubit.network.symbol ?? '')
        .toUpperCase();
    final assetSymbol = (cubit.state.coin?.symbol ?? gasSymbol).toUpperCase();
    // The drawer opens on the root navigator, but this page sits inside the
    // shell's nested one -- a plain `Navigator.of(context)` would pop /send
    // and leave the drawer open.
    final rootNav = Navigator.of(context, rootNavigator: true);

    final shouldSend = await ResponsiveDrawer.show<bool>(
      context: context,
      title: 'Review send',
      // Large text on a short phone outgrows the sheet; the footer's Send
      // stays pinned while the details scroll.
      child: SingleChildScrollView(
        child: SendTransactionDetails(
          fromAddress: cubit.walletAddress,
          toAddress: review.recipient,
          amount: formatTokenAmount(review.rawAmount, review.decimals),
          amountSymbol: assetSymbol,
          feeSymbol: gasSymbol,
          networkName: cubit.network.name,
          tokenContract: cubit.state.coin?.address,
          totalGasFee: formatTokenAmount(review.fee.maxCost, 18),
          maxFeePerGas: formatTokenAmount(review.fee.maxFeePerGas, 18),
          priorityFee: formatTokenAmount(review.fee.maxPriorityFeePerGas, 18),
        ),
      ),
      footer: Row(
        children: [
          Expanded(
            child: GWButton(
              label: 'Cancel',
              variant: GWButtonVariant.gradientOutline,
              expand: true,
              onPressed: () => rootNav.pop(false),
            ),
          ),
          const SizedBox(width: GeniusWalletConsts.space6),
          Expanded(
            child: GWButton(
              label: 'Send',
              variant: GWButtonVariant.gradient,
              expand: true,
              onPressed: () => rootNav.pop(true),
            ),
          ),
        ],
      ),
    );

    // Leaving /send while the drawer was open closed the cubit with it, and
    // either answer would then emit on a closed cubit.
    if (!context.mounted || cubit.isClosed) {
      return;
    }
    if (shouldSend != true) {
      cubit.cancelReview();
      return;
    }

    final recorded = await cubit.submit();
    if (!context.mounted) {
      return;
    }
    if (recorded == null) {
      if (cubit.state.error != null) {
        showToast(context, cubit.state.error!, type: ToastType.error);
      }
      return;
    }
    final to = WalletUtils.getAddressForDisplay(review.recipient);
    switch (recorded.transactionStatus) {
      case TransactionStatus.failed:
        showToast(
          context,
          'The network rejected the send to $to. Only the fee was spent.',
          title: 'Send failed',
          type: ToastType.error,
        );
      case TransactionStatus.pending:
        showToast(
          context,
          cubit.state.error ??
              'Sent to $to. Still confirming -- your history will update.',
          title: 'Send submitted',
          type: ToastType.warning,
        );
      default:
        showToast(context, 'Sent to $to.', title: 'Send complete');
    }
    showTransactionDetails(context, recorded);
  }
}
