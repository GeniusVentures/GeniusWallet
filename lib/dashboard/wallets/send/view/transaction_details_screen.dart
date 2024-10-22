import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/app/utils/formatters.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/app/widgets/desktop_container.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/dashboard/wallets/send/cubit/send_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/widgets/components/back_button_header.g.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_true.g.dart';
import 'package:genius_wallet/widgets/components/text_entry_field_widget.g.dart';
import 'package:genius_wallet/widgets/components/transaction_detail_tile.g.dart';
import 'package:genius_wallet/widgets/text_form_field_logic.g.dart';

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (GeniusBreakpoints.useDesktopLayout(context)) {
      return const Desktop();
    }
    return const Mobile();
  }
}

class Desktop extends StatelessWidget {
  const Desktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<WalletDetailsCubit>().getCurrentFees();
    final formKey = GlobalKey<FormState>();
    return DesktopContainer(
      title: context
          .read<WalletDetailsCubit>()
          .state
          .selectedWallet!
          .currencySymbol,
      isIncludeBackButton: true,
      child: Center(
          child: Container(
              margin: const EdgeInsets.only(top: 40),
              padding: const EdgeInsets.all(40),
              decoration: const BoxDecoration(
                  color: GeniusWalletColors.deepBlueCardColor,
                  borderRadius: BorderRadius.all(
                      Radius.circular(GeniusWalletConsts.borderRadiusCard))),
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      'Send ' +
                          context
                              .read<WalletDetailsCubit>()
                              .state
                              .selectedWallet!
                              .currencySymbol,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      GeniusWalletColors.lightGreenSecondary),
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(
                                      GeniusWalletConsts.borderRadiusCard))),
                          child: Column(children: [
                            SizedBox(
                              height: 40,
                              child: LayoutBuilder(
                                builder: (BuildContext context,
                                    BoxConstraints constraints) {
                                  return TransactionDetailTile(
                                    constraints,
                                    ovrLeftfield: 'Available Balance',
                                    ovrAmount: context
                                        .read<WalletDetailsCubit>()
                                        .state
                                        .selectedWallet!
                                        .balance
                                        .toString(),
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              height: 40,
                              child: LayoutBuilder(
                                builder: (BuildContext context,
                                    BoxConstraints constraints) {
                                  return BlocBuilder<WalletDetailsCubit,
                                      WalletDetailsState>(
                                    builder: (context, state) {
                                      if (state.gasFeesStatus ==
                                          WalletStatus.successful) {
                                        return TransactionDetailTile(
                                          constraints,
                                          ovrLeftfield: 'Gas Fee',
                                          ovrAmount: context
                                              .watch<WalletDetailsCubit>()
                                              .state
                                              .gasFees
                                              .toString(),
                                        );
                                      }
                                      return Container();
                                    },
                                  );
                                },
                              ),
                            ),
                          ])),
                      const SizedBox(height: 50),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: const Text('Enter Amount'),
                      ),
                      const SizedBox(height: 20),
                      TextEntryFieldWidget(
                        logic: TextFormFieldLogic(
                          context,
                          hintText: 'Enter Amount',
                          keyboardType: const TextInputType.numberWithOptions(),
                          inputFormatters: [
                            Formatters.allowDecimals,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount to send';
                            }

                            context.read<SendCubit>().amountConfirmed(
                                  value,
                                  context
                                      .read<WalletDetailsCubit>()
                                      .state
                                      .gasFees,
                                  context
                                      .read<WalletDetailsCubit>()
                                      .state
                                      .selectedWallet!
                                      .balance,
                                );

                            final state = context.read<SendCubit>().state;

                            switch (state.sendStatus) {
                              case SendStatus.notEnoughBalance:
                                return 'You have insufficient funds';
                              case SendStatus.invalidValue:
                                return 'Invalid value';
                              default:
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      SizedBox(
                          height: 50,
                          child: LayoutBuilder(builder: (context, constraints) {
                            return MaterialButton(
                              onPressed: () {
                                formKey.currentState!.validate();
                              },
                              child: IsactiveTrue(
                                constraints,
                                ovrContinue: 'Continue',
                              ),
                            );
                          }))
                    ],
                  ),
                ],
              ))),
    );
  }
}

class Mobile extends StatelessWidget {
  const Mobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<WalletDetailsCubit>().getCurrentFees();
    return const Scaffold(
        backgroundColor: GeniusWalletColors.deepBlueSecondary,
        body: AmountForm());
  }
}

class AmountForm extends StatefulWidget {
  const AmountForm({super.key});

  @override
  AmountFormState createState() {
    return AmountFormState();
  }
}

class AmountFormState extends State<AmountForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: AppScreenView(
            body: Column(children: [
          SizedBox(
            height: 50,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return BackButtonHeader(
                  constraints,
                  ovrTitle: 'Transaction details',
                );
              },
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: GeniusWalletColors.deepBlueSecondary,
                        border: Border.all(color: GeniusWalletColors.gray500),
                        borderRadius: const BorderRadius.all(Radius.circular(
                            GeniusWalletConsts.borderRadiusCard))),
                    child: Column(children: [
                      SizedBox(
                        height: 40,
                        child: LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            return TransactionDetailTile(
                              constraints,
                              ovrLeftfield: 'Available Balance',
                              ovrAmount: context
                                  .read<WalletDetailsCubit>()
                                  .state
                                  .balance
                                  .toString(),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        child: LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            return BlocBuilder<WalletDetailsCubit,
                                WalletDetailsState>(
                              builder: (context, state) {
                                if (state.gasFeesStatus ==
                                    WalletStatus.successful) {
                                  return TransactionDetailTile(
                                    constraints,
                                    ovrLeftfield: 'Gas Fee',
                                    ovrAmount: context
                                        .watch<WalletDetailsCubit>()
                                        .state
                                        .gasFees
                                        .toString(),
                                  );
                                }
                                return Container();
                              },
                            );
                          },
                        ),
                      ),
                    ])),
                const SizedBox(height: 50),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: const Text('Enter Amount'),
                ),
                const SizedBox(height: 20),
                TextEntryFieldWidget(
                  logic: TextFormFieldLogic(
                    context,
                    hintText: 'Enter Amount',
                    keyboardType: const TextInputType.numberWithOptions(),
                    inputFormatters: [
                      Formatters.allowDecimals,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount to send';
                      }

                      context.read<SendCubit>().amountConfirmed(
                            value,
                            context.read<WalletDetailsCubit>().state.gasFees,
                            context
                                .read<WalletDetailsCubit>()
                                .state
                                .selectedWallet!
                                .balance,
                          );

                      final state = context.read<SendCubit>().state;

                      switch (state.sendStatus) {
                        case SendStatus.notEnoughBalance:
                          return 'You have insufficient funds';
                        case SendStatus.invalidValue:
                          return 'Invalid value';
                        default:
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                    height: 50,
                    child: MaterialButton(
                      onPressed: () {
                        _formKey.currentState!.validate();
                      },
                      child: LayoutBuilder(builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return IsactiveTrue(constraints,
                            ovrContinue: 'Continue');
                      }),
                    ))
              ],
            ),
          )
        ])));
  }
}
