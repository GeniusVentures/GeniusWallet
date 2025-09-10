// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/banaxa/banxa_components/ammount_input_field.dart';
import 'package:genius_wallet/banaxa/banxa_components/buy_action_button.dart';
import 'package:genius_wallet/banaxa/banxa_components/buy_dropdown.dart';
import 'package:genius_wallet/banaxa/banxa_components/create_order_button.dart';
import 'package:genius_wallet/banaxa/banxa_components/quote_card.dart';
import 'package:genius_wallet/banaxa/handle_banaxa_drawer.dart';
import 'package:genius_wallet/banxa_order/create_order_cubit.dart';
import 'package:genius_wallet/banxa_order/create_order_state.dart';

import 'package:genius_wallet/banaxa/banaxa_api_services.dart';
import 'package:genius_wallet/banaxa/banaxa_model.dart';
import 'package:genius_wallet/components/loading/loading.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';

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
                        BuyDropdownSection<FiatCurrency>(
                          label: 'Fiat',
                          items: state.fiats,
                          selected: state.selectedFiat,
                          display: (f) =>
                              compact ? f.code : '${f.name} (${f.code})',
                          onChanged:
                              state.step == MakeOrderStep.loadingCurrencies
                                  ? null
                                  : (val) => val == null
                                      ? null
                                      : context
                                          .read<MakeOrderCubit>()
                                          .selectFiat(val),
                          labelStyle: labelStyle,
                          compact: compact,
                        ),
                        const SizedBox(height: 12),

                        // Crypto Dropdown
                        BuyDropdownSection<CryptoCurrency>(
                          label: compact ? 'Crypto' : 'Crypto Currency',
                          items: state.cryptos,
                          selected: state.selectedCrypto,
                          display: (c) =>
                              compact ? c.code : '${c.name} (${c.code})',
                          onChanged:
                              state.step == MakeOrderStep.loadingCurrencies
                                  ? null
                                  : (val) => val == null
                                      ? null
                                      : context
                                          .read<MakeOrderCubit>()
                                          .selectCrypto(val),
                          labelStyle: labelStyle,
                          compact: compact,
                        ),
                        const SizedBox(height: 12),

                        // Payment Method Dropdown
                        BuyDropdownSection<PaymentMethod>(
                          label: compact ? 'Method' : 'Payment Method',
                          items: state.paymentMethods,
                          selected: state.selectedPaymentMethod,
                          display: (m) =>
                              compact ? _shortMethodName(m.name) : m.name,
                          onChanged:
                              state.step == MakeOrderStep.loadingCurrencies
                                  ? null
                                  : (val) => val == null
                                      ? null
                                      : context
                                          .read<MakeOrderCubit>()
                                          .selectPaymentMethod(val),
                          labelStyle: labelStyle,
                          compact: compact,
                        ),
                        const SizedBox(height: 12),

                        // Amount input
                        AmountInputField(
                          controller: _amountController,
                          labelText: _amountLabel(state, compact),
                          labelStyle: labelStyle,
                          compact: compact,
                          onChanged: (v) =>
                              context.read<MakeOrderCubit>().setAmountText(v),
                        ),
                        const SizedBox(height: 12),

                        // Get Quote & Retry Buttons
                        BuyActionButtons(
                          compact: compact,
                          canGetQuote: state.canGetQuote,
                          onGetQuote: () =>
                              context.read<MakeOrderCubit>().getQuote(),
                          showRetry: state.step == MakeOrderStep.error &&
                              state.fiats.isEmpty,
                          onRetry: () {
                            context.read<MakeOrderCubit>().loadCurrencies(
                                  initialFiatCode: widget.initialFiatCode,
                                  initialCryptoCode: widget.initialCryptoCode,
                                  initialPaymentMethodId:
                                      widget.initialPaymentMethodId,
                                  initialAmount: widget.initialAmount,
                                  initialWalletAddress:
                                      widget.initialWalletAddress,
                                );
                          },
                        ),

                        // QUOTE CARD
                        QuoteCard(state: state, compact: compact),
                        const SizedBox(height: 12),

                        // Wallet address input
                        WalletAddressField(
                          controller: _walletController,
                          labelText: compact ? 'Wallet' : 'Wallet Address',
                          labelStyle: labelStyle,
                          compact: compact,
                          onChanged: (v) =>
                              context.read<MakeOrderCubit>().setWalletText(v),
                        ),
                        const SizedBox(height: 18),

                        // Create Order Button
                        CreateOrderButton(
                          enabled: state.canCreateOrder,
                          onPressed: state.canCreateOrder
                              ? () async {
                                  if (state.checkoutUrl != null &&
                                      state.orderId != null) {
                                    await showCheckoutOptionsSheet(
                                      context,
                                      checkoutUrl: state.checkoutUrl!,
                                      orderId: state.orderId!,
                                      redirectUrl: state.redirectUrl ?? '',
                                    );
                                  } else {
                                    await context
                                        .read<MakeOrderCubit>()
                                        .createOrder();
                                  }
                                }
                              : null,
                          compact: compact,
                          label: compact ? 'Checkout' : 'Create Order',
                        ),

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
