import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/app/widgets/desktop_container.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/wallets/send/cubit/send_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/widgets/components/back_button_header.g.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_false.g.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_true.g.dart';
import 'package:genius_wallet/widgets/components/text_entry_field_widget.g.dart';
import 'package:genius_wallet/widgets/text_form_field_logic.g.dart';

class EnterWalletAddressScreen extends StatelessWidget {
  const EnterWalletAddressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (GeniusBreakpoints.useDesktopLayout(context)) {
      return const Desktop();
    }
    return const Mobile();
  }
}

class Desktop extends StatelessWidget {
  const Desktop({super.key});

  @override
  Widget build(BuildContext context) {
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
                  color: GeniusWalletColors.deepBlueTertiary,
                  borderRadius: BorderRadius.all(
                      Radius.circular(GeniusWalletConsts.borderRadiusCard))),
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Enter the Wallet address to send to',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextEntryFieldWidget(
                        logic: TextFormFieldLogic(
                          context,
                          hintText: 'Type the wallet address',
                          onChanged: context.read<SendCubit>().addressUpdated,
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Container(
                          padding: const EdgeInsets.only(
                              left: 30, right: 30, bottom: 30),
                          height: 75,
                          child: LayoutBuilder(builder: (context, constraints) {
                            return BlocBuilder<SendCubit, SendState>(
                              builder: (context, state) {
                                if (state
                                    .currentTransaction.recipients.isEmpty) {
                                  return IsactiveFalse(
                                    constraints,
                                    ovrContinue: 'Continue',
                                  );
                                }
                                return MaterialButton(
                                  onPressed: () {
                                    context
                                        .read<SendCubit>()
                                        .addressConfirmed();
                                  },
                                  child: IsactiveTrue(
                                    constraints,
                                    ovrContinue: 'Continue',
                                  ),
                                );
                              },
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
  const Mobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GeniusWalletColors.deepBlueSecondary,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
        height: 80,
        child: LayoutBuilder(builder: (context, constraints) {
          return BlocBuilder<SendCubit, SendState>(
            builder: (context, state) {
              if (state.currentTransaction.recipients.isEmpty) {
                return IsactiveFalse(
                  constraints,
                  ovrContinue: 'Continue',
                );
              }
              return MaterialButton(
                onPressed: () {
                  context.read<SendCubit>().addressConfirmed();
                },
                child: IsactiveTrue(
                  constraints,
                  ovrContinue: 'Continue',
                ),
              );
            },
          );
        }),
      ),
      body: AppScreenView(
        body: SizedBox(
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return BackButtonHeader(
                      constraints,
                      ovrTitle: 'Enter Wallet Address',
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const Text('Enter the Wallet address to send to'),
              const SizedBox(height: 100),
              Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                        width: MediaQuery.of(context).size.width,
                        child: const Text(
                          'Wallet address to send to',
                          textAlign: TextAlign.start,
                        ),
                      ),
                      TextEntryFieldWidget(
                        logic: TextFormFieldLogic(
                          context,
                          hintText: 'Type the wallet address',
                          onChanged: context.read<SendCubit>().addressUpdated,
                        ),
                      ),
                      // TODO: add qr support
                      // const SizedBox(height: 30),
                      // SizedBox(
                      //   height: 62,
                      //   width: MediaQuery.of(context).size.width,
                      //   child: Center(
                      //     child: LayoutBuilder(
                      //       builder: (BuildContext context,
                      //           BoxConstraints constraints) {
                      //         return WalletQRScan(constraints);
                      //       },
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(
                      //   height: 50,
                      // ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
