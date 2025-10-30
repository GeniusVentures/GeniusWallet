// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/banxa/banxa_order/create_order_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/create_order_state.dart';

import 'package:genius_wallet/banxa/banaxa_api_services.dart';
import 'package:genius_wallet/banxa/banaxa_model.dart';
import 'package:genius_wallet/banxa/handle_banaxa_drawer.dart';
import 'package:genius_wallet/components/custom_drop_down.dart';
import 'package:genius_wallet/components/disclaimer_dialogue.dart';
import 'package:genius_wallet/components/loading/loading.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';

class BanxaBuyScreen extends StatefulWidget {
  final String? initialFiatCode;
  final String? initialCryptoCode;
  final String? initialPaymentMethodId;
  final String? initialAmount;
  final String? initialWalletAddress;

  const BanxaBuyScreen({
    super.key,
    this.initialFiatCode,
    this.initialCryptoCode,
    this.initialPaymentMethodId,
    this.initialAmount,
    this.initialWalletAddress,
  });

  @override
  State<BanxaBuyScreen> createState() => _BanxaBuyScreenState();
}

class _BanxaBuyScreenState extends State<BanxaBuyScreen> {
  final _amountController = TextEditingController();
  final _walletController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _walletController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MakeOrderCubit(BanxaApiService())
        ..loadCurrencies(
          initialFiatCode: widget.initialFiatCode,
          initialCryptoCode: widget.initialCryptoCode,
          initialPaymentMethodId: widget.initialPaymentMethodId,
          initialAmount: widget.initialAmount,
          initialWalletAddress: widget.initialWalletAddress,
        ),
      child: BlocConsumer<MakeOrderCubit, MakeOrderState>(
        listenWhen: (p, c) =>
            p.errorMessage != c.errorMessage || p.step != c.step,
        listener: (context, state) async {
          if (state.errorMessage.isNotEmpty) {
            showAppSnackBar(context, state.errorMessage,
                backgroundColor: Colors.red);

            context.read<MakeOrderCubit>().clearError();
          }
          if (state.step == MakeOrderStep.orderReady &&
              state.checkoutUrl != null) {
            await showCheckoutOptionsSheet(
              context,
              checkoutUrl: state.checkoutUrl!,
              orderId: state.orderId!,
              redirectUrl: state.redirectUrl ?? BanxaApiService.redirectUrl,
            );
          }
        },
        builder: (context, state) {
          if (_amountController.text != state.amountText) {
            _amountController.text = state.amountText;
            _amountController.selection = TextSelection.fromPosition(
              TextPosition(offset: _amountController.text.length),
            );
          }
          if (_walletController.text != state.walletText) {
            _walletController.text = state.walletText;
            _walletController.selection = TextSelection.fromPosition(
              TextPosition(offset: _walletController.text.length),
            );
          }

          final w = MediaQuery.of(context).size.width;
          final compact = w < 400;
          final tight = w < 320;
          final pad = EdgeInsets.all(compact ? 12 : 16);
          final labelStyle = TextStyle(fontSize: compact ? 13 : 14);

          final isBootLoading = state.step == MakeOrderStep.loadingCurrencies &&
              state.fiats.isEmpty &&
              state.cryptos.isEmpty;

          return Scaffold(
            appBar: AppBar(
              title: Text(compact ? 'Buy' : 'Buy Crypto'),
            ),
            body: Stack(
              children: [
                if (isBootLoading)
                  const Center()
                else
                  Padding(
                    padding: pad,
                    child: ListView(
                      children: [
                        // FIAT Dropdown
                       // FIAT Dropdown
                        AppDropdown<FiatCurrency>(
                          label: 'Fiat',
                          items: state.fiats,
                          selected: state.selectedFiat,
                          display: (f) =>
                              compact ? f.code : '${f.name} (${f.code})',
                          onChanged:
                              state.step == MakeOrderStep.loadingCurrencies
                                  ? null
                                  : (val) {
                                      if (val != null) {
                                        context
                                            .read<MakeOrderCubit>()
                                            .selectFiat(val);
                                      }
                                    },
                          labelStyle: labelStyle,
                          compact: compact,
                        ),
                        const SizedBox(height: 12),

// Crypto Dropdown
                        AppDropdown<CryptoCurrency>(
                          label: compact ? 'Crypto' : 'Crypto Currency',
                          items: state.cryptos,
                          selected: state.selectedCrypto,
                          display: (c) =>
                              compact ? c.code : '${c.name} (${c.code})',
                          onChanged:
                              state.step == MakeOrderStep.loadingCurrencies
                                  ? null
                                  : (val) {
                                      if (val != null) {
                                        context
                                            .read<MakeOrderCubit>()
                                            .selectCrypto(val);
                                      }
                                    },
                          labelStyle: labelStyle,
                          compact: compact,
                        ),
                        const SizedBox(height: 12),

// Payment Method Dropdown
                        AppDropdown<PaymentMethod>(
                          label: compact ? 'Method' : 'Payment Method',
                          items: state.paymentMethods,
                          selected: state.selectedPaymentMethod,
                          display: (m) =>
                              compact ? _shortMethodName(m.name) : m.name,
                          onChanged:
                              state.step == MakeOrderStep.loadingCurrencies
                                  ? null
                                  : (val) {
                                      if (val != null) {
                                        context
                                            .read<MakeOrderCubit>()
                                            .selectPaymentMethod(val);
                                      }
                                    },
                          labelStyle: labelStyle,
                          compact: compact,
                        ),
                        const SizedBox(height: 12),

                        // Payment Method Dropdown
                      
                        const SizedBox(height: 12),

                        // Amount input
                        TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          onChanged: (v) =>
                              context.read<MakeOrderCubit>().setAmountText(v),
                          style: TextStyle(fontSize: compact ? 14 : 16),
                          decoration: InputDecoration(
                            labelText: _amountLabel(state, compact),
                            labelStyle: labelStyle,
                            border: const OutlineInputBorder(),
                            isDense: compact,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: compact ? 10 : 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Get Quote & Retry Buttons
                        if (compact)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton(
                                onPressed: state.canGetQuote
                                    ? () => context
                                        .read<MakeOrderCubit>()
                                        .getQuote()
                                    : null,
                                child: const Text('Get Quote'),
                              ),
                              if (state.step == MakeOrderStep.error &&
                                  state.fiats.isEmpty)
                                TextButton.icon(
                                  onPressed: () {
                                    context
                                        .read<MakeOrderCubit>()
                                        .loadCurrencies(
                                          initialFiatCode:
                                              widget.initialFiatCode,
                                          initialCryptoCode:
                                              widget.initialCryptoCode,
                                          initialPaymentMethodId:
                                              widget.initialPaymentMethodId,
                                          initialAmount: widget.initialAmount,
                                          initialWalletAddress:
                                              widget.initialWalletAddress,
                                        );
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry'),
                                ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: state.canGetQuote
                                      ? () => context
                                          .read<MakeOrderCubit>()
                                          .getQuote()
                                      : null,
                                  child: const Text('Get Quote'),
                                ),
                              ),
                              if (state.step == MakeOrderStep.error &&
                                  state.fiats.isEmpty)
                                IconButton(
                                  onPressed: () {
                                    context
                                        .read<MakeOrderCubit>()
                                        .loadCurrencies(
                                          initialFiatCode:
                                              widget.initialFiatCode,
                                          initialCryptoCode:
                                              widget.initialCryptoCode,
                                          initialPaymentMethodId:
                                              widget.initialPaymentMethodId,
                                          initialAmount: widget.initialAmount,
                                          initialWalletAddress:
                                              widget.initialWalletAddress,
                                        );
                                  },
                                  icon: const Icon(Icons.refresh),
                                  tooltip: 'Retry',
                                ),
                            ],
                          ),

                        // QUOTE CARD
                     if (!state.hasQuote)
                          const SizedBox()
                        else
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    compact
                                        ? 'Receive: ${state.quote!.cryptoAmount} ${state.cryptoCode}'
                                        : 'You will receive: ${state.quote!.cryptoAmount} ${state.cryptoCode}',
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 4,
                                    children: [
                                      Text(
                                          'Gateway: ${state.quote!.processingFee} ${state.fiatCode}'),
                                      Text(
                                          'Network: ${state.quote!.networkFee} ${state.fiatCode}'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),

                        // Wallet address input
                        TextField(
                          controller: _walletController,
                          onChanged: (v) =>
                              context.read<MakeOrderCubit>().setWalletText(v),
                          style: TextStyle(fontSize: compact ? 14 : 16),
                          decoration: InputDecoration(
                            labelText: compact ? 'Wallet' : 'Wallet Address',
                            labelStyle: labelStyle,
                            border: const OutlineInputBorder(),
                            isDense: compact,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: compact ? 10 : 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Create Order Button
                       ElevatedButton(
  onPressed: state.canCreateOrder
      ? () async {
          final accepted = await showDisclaimerDialog(
            context,
            title: "Payment Disclaimer",
            message:
                "You are now leaving GeniusWallet to complete your order or payment through Banxa (https://banxa.com). "
                "Services related to card payments, crypto purchases, and transaction processing are provided by Banxa — "
                "a separate third-party platform. By proceeding, you acknowledge that you have read and agreed to "
                "Banxa's Terms of Use and Privacy & Cookies Policy.",
            confirmText: "Continue",
            activeColor: Colors.blue,
          );

          if (!accepted) {
            showAppSnackBar(
              context,
              'You must agree to the disclaimer to proceed.',
            );
            return;
          }

          // Proceed if disclaimer is accepted
          if (state.checkoutUrl != null && state.orderId != null) {
            await showCheckoutOptionsSheet(
              context,
              checkoutUrl: state.checkoutUrl!,
              orderId: state.orderId!,
              redirectUrl: state.redirectUrl ?? '',
            );
          } else {
            await context.read<MakeOrderCubit>().createOrder();
          }
        }
      : null,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    elevation: 0,
    padding: EdgeInsets.zero,
    minimumSize: const Size.fromHeight(48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  child: Ink(
    decoration: BoxDecoration(
      gradient: state.canCreateOrder
          ? GeniusWalletGradient.greenBlueGreenGradient
          : LinearGradient(
              colors: [Colors.grey.shade500, Colors.grey.shade600],
            ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Container(
      alignment: Alignment.center,
      height: 48,
      child: Text(
        compact ? 'Checkout' : 'Create Order',
        style: TextStyle(
          color: state.canCreateOrder
              ? GeniusWalletColors.deepBlue
              : Colors.black.withAlpha(102),
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
  ),
)
,
                        if (tight) const SizedBox(height: 6),
                      ],
                    ),
                  ),
                if (state.showOverlay || isBootLoading)
                  Container(
                    color: Colors.black45,
                    child: Center(
                      child: Loading(
                        text: state.loadingMessage,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

String _shortMethodName(String name) {
  final n = name.trim();
  if (n.length <= 10) return n;
  final parts = n.split(RegExp(r'\s+'));
  if (parts.isNotEmpty) {
    final first = parts.first;
    if (first.length <= 10) return first;
  }
  return '${n.substring(0, 10)}…';
}

String _amountLabel(MakeOrderState state, bool compact) {
  if (state.selectedPaymentMethod == null) {
    return compact
        ? 'Amount (${state.fiatCode})'
        : 'Amount (${state.fiatCode})';
  }
  if (compact) {
    return 'Amt (${state.fiatCode}) [${state.minAmount ?? '-'}–${state.maxAmount ?? '-'}]';
  }
  return 'Amount (${state.fiatCode}) [Min: ${state.minAmount ?? '-'} - Max: ${state.maxAmount ?? '-'}]';
}
