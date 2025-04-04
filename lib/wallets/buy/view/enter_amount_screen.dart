import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/utils/formatters.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/wallets/buy/bloc/buy_bloc.dart';
import 'package:genius_wallet/wallets/buy/bloc/buy_event.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/widgets/components/back_button_header.g.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_false.g.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_true.g.dart';
import 'package:genius_wallet/widgets/components/text_entry_field_widget.g.dart';
import 'package:genius_wallet/widgets/text_form_field_logic.g.dart';
import 'package:url_launcher/url_launcher.dart';

class EnterAmountScreen extends StatefulWidget {
  const EnterAmountScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _EnterAmountScreenState();
  }
}

class _EnterAmountScreenState extends State<EnterAmountScreen> {
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: AppScreenView(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 50,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return BackButtonHeader(
                      constraints,
                      ovrTitle: 'Enter amount',
                    );
                  },
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: const Text('Minimum of 50'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return TextEntryFieldWidget(
                      logic: TextFormFieldLogic(
                        context,
                        hintText: '\$ 0.00',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        controller: controller,
                        onChanged: (amount) => context
                            .read<BuyBloc>()
                            .add(ConvertCurrency(amount: amount)),
                        inputFormatters: [Formatters.allowDecimals],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              BlocBuilder<BuyBloc, BuyState>(builder: (context, state) {
                if (state.conversionStatus == ConversionStatus.error) {
                  return const Text(
                    'An unexpected error occurred.',
                    style: TextStyle(color: Colors.red),
                  );
                }
                return Text(
                  '~ ${state.approxCryptoConversion} ${state.cryptoCurrency}',
                  style: const TextStyle(
                    color: GeniusWalletColors.gray500,
                  ),
                );
              }),
              const SizedBox(height: 80),
              SizedBox(
                height: 50,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    if (controller.text.isNotEmpty) {
                      return MaterialButton(
                        onPressed: () async {
                          ///TODO: Open MoonPay with desired settings here
                          await launchUrl(Uri.parse('https://moonpay.com/buy'));
                        },
                        child: IsactiveTrue(
                          constraints,
                          ovrContinue: 'Proceed',
                        ),
                      );
                    }
                    return IsactiveFalse(
                      constraints,
                      ovrContinue: 'Proceed',
                    );
                  },
                ),
              ),
            ],
          ),
          footer: const Text(
            ///TODO: This should be a gradient
            'Purchase is powered by MoonPay, a 3rd party platform.',
            style: TextStyle(color: GeniusWalletColors.blue500),
          ),
        ),
      ),
    );
  }
}
