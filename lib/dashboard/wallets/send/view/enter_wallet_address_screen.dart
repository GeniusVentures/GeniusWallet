import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/dashboard/wallets/send/cubit/send_cubit.dart';
import 'package:genius_wallet/widgets/components/back_button_header.g.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_false.g.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_true.g.dart';
import 'package:genius_wallet/widgets/components/text_entry_field_widget.g.dart';
import 'package:genius_wallet/widgets/components/wallet_q_r_scan.g.dart';
import 'package:genius_wallet/widgets/text_form_field_logic.g.dart';

class EnterWalletAddressScreen extends StatelessWidget {
  const EnterWalletAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
        height: 75,
        child: LayoutBuilder(builder: (context, constraints) {
          return BlocBuilder<SendCubit, SendState>(
            builder: (context, state) {
              if (state.currentTransaction.toAddress.isEmpty) {
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
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 62,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: LayoutBuilder(
                            builder: (BuildContext context,
                                BoxConstraints constraints) {
                              return WalletQRScan(constraints);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
