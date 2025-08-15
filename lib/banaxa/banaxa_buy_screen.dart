// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/banaxa/handle_banaxa_drawer.dart';
import 'package:genius_wallet/banxa_order/create_order_cubit.dart';
import 'package:genius_wallet/banxa_order/create_order_state.dart';

import 'package:genius_wallet/banaxa/banaxa_api_services.dart';
import 'package:genius_wallet/banaxa/banaxa_model.dart';

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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Colors.red),
            );
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

          return LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final compact = w < 400;
              final tight = w < 320;
              final pad = EdgeInsets.all(compact ? 12 : 16);
              final labelStyle = TextStyle(fontSize: compact ? 13 : 14);

              final isBootLoading =
                  state.step == MakeOrderStep.loadingCurrencies &&
                      state.fiats.isEmpty &&
                      state.cryptos.isEmpty;

              return Scaffold(
                appBar: AppBar(
                  title: Text(compact ? 'Buy' : 'Buy Crypto'),
                ),
                body: Stack(
                  children: [
                    if (isBootLoading)
                      const _FullCenterLoader(message: 'Loading currencies...')
                    else
                      Padding(
                        padding: pad,
                        child: ListView(
                          children: [
                            _Dropdown<FiatCurrency>(
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
                            _Dropdown<CryptoCurrency>(
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
                            _Dropdown<PaymentMethod>(
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
                            TextField(
                              controller: _amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              onChanged: (v) => context
                                  .read<MakeOrderCubit>()
                                  .setAmountText(v),
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
                            if (compact)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ElevatedButton(
                                    onPressed: state.canGetQuote
                                        ? () async => context
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
                                              initialAmount:
                                                  widget.initialAmount,
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
                                          ? () async => context
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
                                              initialAmount:
                                                  widget.initialAmount,
                                              initialWalletAddress:
                                                  widget.initialWalletAddress,
                                            );
                                      },
                                      icon: const Icon(Icons.refresh),
                                      tooltip: 'Retry',
                                    ),
                                ],
                              ),
                            if (state.hasQuote) ...[
                              const SizedBox(height: 12),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                            ],
                            const SizedBox(height: 12),
                            TextField(
                              controller: _walletController,
                              onChanged: (v) => context
                                  .read<MakeOrderCubit>()
                                  .setWalletText(v),
                              style: TextStyle(fontSize: compact ? 14 : 16),
                              decoration: InputDecoration(
                                labelText:
                                    compact ? 'Wallet' : 'Wallet Address',
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
                            ElevatedButton(
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
                              child:
                                  Text(compact ? 'Checkout' : 'Create Order'),
                            ),
                            if (tight) const SizedBox(height: 6),
                          ],
                        ),
                      ),
                    if (state.showOverlay)
                      Container(
                        color: Colors.black45,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                state.loadingMessage,
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final T? selected;
  final void Function(T?)? onChanged;
  final String Function(T) display;
  final TextStyle? labelStyle;
  final bool compact;

  const _Dropdown({
    required this.label,
    required this.items,
    required this.selected,
    required this.onChanged,
    required this.display,
    this.labelStyle,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: labelStyle,
        border: const OutlineInputBorder(),
        isDense: compact,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: compact ? 10 : 14,
        ),
      ),
      value: selected,
      items: items.map((item) {
        final text = display(item);
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class _FullCenterLoader extends StatelessWidget {
  final String message;
  const _FullCenterLoader({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(message),
      ]),
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
