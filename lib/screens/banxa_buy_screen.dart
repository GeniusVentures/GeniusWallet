// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/banxa/banxa_order/create_order_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/create_order_state.dart';

import 'package:genius_wallet/banxa/banxa_api_services.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/banxa/handle_banxa_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/components/disclaimer_dialogue.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/tokens/widgets/sketch_icons.dart';
import 'package:genius_wallet/utils/breakpoints.dart';

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
            showAppSnackBar(
              context,
              state.errorMessage,
              backgroundColor: GeniusWalletColors.statusError,
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
          final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
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

          final isBootLoading =
              state.step == MakeOrderStep.loadingCurrencies &&
              state.fiats.isEmpty &&
              state.cryptos.isEmpty;

          final width = GeniusBreakpoints.small * 2 / 3;
          return Scaffold(
            // token_info_screen.dart:92-129's back-arrow AppBar recipe,
            // applied unconditionally: this screen is always pushed at
            // `/createOrder`, so it always has a back target.
            appBar: AppBar(
              toolbarHeight: 48,
              backgroundColor: gw.surfaceSunken,
              elevation: 0,
              titleSpacing: 0,
              automaticallyImplyLeading: false,
              centerTitle: false,
              title: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      MediaQuery.sizeOf(context).width > GeniusBreakpoints.medium
                      ? GeniusWalletConsts.space10
                      : GeniusWalletConsts.space8,
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).maybePop(),
                      borderRadius:
                          BorderRadius.circular(GeniusWalletConsts.radiusSm),
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: Center(
                          child: SketchIcon(
                            SketchIcons.back,
                            size: 18,
                            color: gw.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: GeniusWalletConsts.space6),
                    Text(
                      'Buy Crypto',
                      style: GeniusWalletTypography.titleMd.copyWith(
                        color: gw.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: Stack(
              children: [
                if (isBootLoading)
                  const Center()
                else
                  Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      padding: EdgeInsetsGeometry.all(20.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: width),
                        child: Column(
                          spacing: 20.0,
                          children: [
                            DropdownMenu<FiatCurrency>(
                              key: ValueKey(state.selectedFiat),
                              initialSelection: state.selectedFiat,
                              label: const Text('Fiat'),
                              width: width,
                              dropdownMenuEntries: state.fiats.map((f) {
                                return DropdownMenuEntry<FiatCurrency>(
                                  value: f,
                                  label: '${f.name} (${f.code})',
                                );
                              }).toList(),
                              onSelected:
                                  state.step == MakeOrderStep.loadingCurrencies
                                  ? null
                                  : (val) {
                                      if (val != null) {
                                        context
                                            .read<MakeOrderCubit>()
                                            .selectFiat(val);
                                      }
                                    },
                            ),
                            DropdownMenu<CryptoCurrency>(
                              key: ValueKey(state.selectedCrypto),
                              initialSelection: state.selectedCrypto,
                              label: const Text('Crypto Currency'),
                              width: width,
                              dropdownMenuEntries: state.cryptos.map((c) {
                                return DropdownMenuEntry<CryptoCurrency>(
                                  value: c,
                                  label: '${c.name} (${c.code})',
                                );
                              }).toList(),
                              onSelected:
                                  state.step == MakeOrderStep.loadingCurrencies
                                  ? null
                                  : (val) {
                                      if (val != null) {
                                        context
                                            .read<MakeOrderCubit>()
                                            .selectCrypto(val);
                                      }
                                    },
                            ),
                            DropdownMenu<PaymentMethod>(
                              key: ValueKey(state.selectedPaymentMethod),
                              initialSelection: state.selectedPaymentMethod,
                              label: const Text('Payment Method'),
                              width: width,
                              dropdownMenuEntries: state.paymentMethods.map((
                                m,
                              ) {
                                return DropdownMenuEntry<PaymentMethod>(
                                  value: m,
                                  label: m.name,
                                );
                              }).toList(),
                              onSelected:
                                  state.step == MakeOrderStep.loadingCurrencies
                                  ? null
                                  : (val) {
                                      if (val != null) {
                                        context
                                            .read<MakeOrderCubit>()
                                            .selectPaymentMethod(val);
                                      }
                                    },
                            ),
                            TextField(
                              controller: _amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              onChanged: (v) => context
                                  .read<MakeOrderCubit>()
                                  .setAmountText(v),
                              decoration: InputDecoration(
                                labelText: _amountLabel(state),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: GWButton(
                                    variant: GWButtonVariant.secondary,
                                    expand: true,
                                    label: 'Get Quote',
                                    onPressed: state.canGetQuote
                                        ? () => context
                                              .read<MakeOrderCubit>()
                                              .getQuote()
                                        : null,
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
                            if (state.hasQuote)
                              GWCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'You will receive: ${state.quote!.cryptoAmount} ${state.cryptoCode}',
                                      style: GeniusWalletTypography.bodyLg
                                          .copyWith(color: gw.textPrimary),
                                    ),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 4,
                                      children: [
                                        Text(
                                          'Gateway: ${state.quote!.processingFee} ${state.fiatCode}',
                                          style: GeniusWalletTypography.bodySm
                                              .copyWith(
                                                color: gw.textSecondary,
                                              ),
                                        ),
                                        Text(
                                          'Network: ${state.quote!.networkFee} ${state.fiatCode}',
                                          style: GeniusWalletTypography.bodySm
                                              .copyWith(
                                                color: gw.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            TextField(
                              controller: _walletController,
                              onChanged: (v) => context
                                  .read<MakeOrderCubit>()
                                  .setWalletText(v),
                              decoration: InputDecoration(
                                labelText: 'Wallet Address',
                              ),
                            ),
                            GWButton(
                              variant: GWButtonVariant.gradient,
                              size: GWButtonSize.lg,
                              expand: true,
                              label: 'Create Order',
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
                                        activeColor:
                                            GeniusWalletColors.brandPrimaryOnSurface,
                                      );

                                      if (!accepted) {
                                        showAppSnackBar(
                                          context,
                                          'You must agree to the disclaimer to proceed.',
                                        );
                                        return;
                                      }

                                      // Proceed if disclaimer is accepted
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
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (state.showOverlay || isBootLoading)
                  Container(
                    color: Colors.black45,
                    child: Center(child: Loading(text: state.loadingMessage)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

String _amountLabel(MakeOrderState state) {
  if (state.fiatCode.isEmpty) {
    return 'Amount';
  }
  if (state.selectedPaymentMethod == null) {
    return 'Amount (${state.fiatCode})';
  }
  return 'Amount (${state.fiatCode}) [Min: ${state.minAmount ?? '-'} - Max: ${state.maxAmount ?? '-'}]';
}
