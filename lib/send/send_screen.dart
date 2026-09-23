import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/coins/view/coins_screen.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/hive/services/transaction_storage_service.dart';
import 'package:genius_wallet/reown/send_transaction_details.dart';
import 'package:genius_wallet/reown/utilities.dart';
import 'package:genius_wallet/send/send_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

/// The `/send` route target: a keyboard form, not a drawer -- typing
/// an address and an amount in a bottom sheet is cramped on a phone.
class SendScreen extends StatelessWidget {
  const SendScreen({
    super.key,
    this.preselectSymbol,
    this.preselectChainId,
    this.storage = const TransactionStorageService(),
  });

  final String? preselectSymbol;
  final int? preselectChainId;
  final TransactionStorageService storage;

  @override
  Widget build(BuildContext context) {
    final walletState = context.watch<WalletDetailsCubit>().state;
    final wallet = walletState.selectedWallet;
    final network = walletState.selectedNetwork;

    if (wallet == null || network == null || !canSignOn(network)) {
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

    final api = context.read<WalletDetailsCubit>().geniusApi;
    final transactions = context.read<TransactionsCubit>();
    final coin = _seatedCoin(
      walletState.coins,
      preselectSymbol,
      preselectChainId,
      network,
    );

    // Keyed on the wallet and chain: switching either must start a fresh
    // form rather than carrying a stale recipient or review onto a
    // different signer or network.
    return BlocProvider<SendCubit>(
      key: ValueKey('${wallet.address}-${network.chainId}'),
      create: (_) => SendCubit(
        api: api,
        walletAddress: wallet.address,
        network: network,
        transactions: transactions,
        storage: storage,
        initialCoin: coin,
      ),
      child: const _SendBody(),
    );
  }
}

/// The held coin [preselectSymbol] names, seated only when [preselectChainId]
/// is unset or matches [network] -- a mismatched chain id is never guessed
/// into the wrong coin.
Coin? _seatedCoin(
  List<Coin> coins,
  String? preselectSymbol,
  int? preselectChainId,
  Network network,
) {
  if (preselectSymbol == null) {
    return null;
  }
  if (preselectChainId != null && preselectChainId != network.chainId) {
    return null;
  }
  for (final candidate in coins) {
    if ((candidate.symbol ?? '').toLowerCase() ==
        preselectSymbol.toLowerCase()) {
      return candidate;
    }
  }
  return null;
}

class _SendBody extends StatelessWidget {
  const _SendBody();

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

    final coinSymbol = (coin.symbol ?? '').toUpperCase();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(GeniusWalletConsts.space10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const GWPageHeader(title: 'Send'),
              const SizedBox(height: GeniusWalletConsts.space6),
              GWTextField(
                label: 'Recipient',
                hint: '0x...',
                errorText: state.error,
                onChanged: cubit.setRecipient,
              ),
              const SizedBox(height: GeniusWalletConsts.space6),
              GWTextField(
                label: 'Amount',
                hint: '0.0',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                suffix: Text(coinSymbol),
                onChanged: cubit.setAmount,
              ),
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

  /// Reviews, opens the confirm drawer on success, and acts on the drawer's
  /// answer -- Cancel drops the built transaction, Send signs it. What the
  /// user is told and shown comes straight off [SendCubit.submit]'s own
  /// return, never off stale cubit state a later call could have replaced.
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

    final shouldSend = await ResponsiveDrawer.show<bool>(
      context: context,
      title: 'Review send',
      child: SendTransactionDetails(
        fromAddress: cubit.walletAddress,
        toAddress: review.recipient,
        amount: formatEth(review.rawAmount.toString()),
        amountSymbol: assetSymbol,
        feeSymbol: gasSymbol,
        totalGasFee: formatEth(review.fee.maxCost.toString()),
        maxFeePerGas: formatEth(review.fee.maxFeePerGas.toString()),
        priorityFee: formatEth(review.fee.maxPriorityFeePerGas.toString()),
      ),
      footer: Row(
        children: [
          Expanded(
            child: GWButton(
              label: 'Cancel',
              variant: GWButtonVariant.gradientOutline,
              expand: true,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ),
          const SizedBox(width: GeniusWalletConsts.space6),
          Expanded(
            child: GWButton(
              label: 'Send',
              variant: GWButtonVariant.gradient,
              expand: true,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ),
        ],
      ),
    );

    if (shouldSend != true) {
      cubit.cancelReview();
      return;
    }

    final recorded = await cubit.submit();
    if (!context.mounted) {
      return;
    }
    if (recorded != null) {
      showToast(
        context,
        'Sent to ${WalletUtils.getAddressForDisplay(review.recipient)}.',
        title: 'Send submitted',
      );
      showTransactionDetails(context, recorded);
    } else if (cubit.state.error != null) {
      showToast(context, cubit.state.error!, type: ToastType.error);
    }
  }
}
