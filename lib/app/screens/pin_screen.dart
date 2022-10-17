import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/pin_cubit.dart';
import 'package:genius_wallet/app/bloc/pin_state.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/app/widgets/number_pad.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/widgets/components/incorrect_pin.g.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PinScreen extends StatelessWidget {
  final String text;
  final Function(String) onCompleted;
  const PinScreen({
    Key? key,
    required this.text,
    required this.onCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GeniusWalletColors.blue500,
      body: AppScreenView(
        body: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50, left: 40),
                child: IconButton(
                  alignment: Alignment.center,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 40),
                ),
              ),
              BlocBuilder<PinCubit, PinState>(
                builder: (context, state) {
                  if (state.displayIncorrectPin) {
                    return Center(
                      child: SizedBox(
                        width: 200,
                        height: 40,
                        child: LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            return IncorrectPin(constraints);
                          },
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              Center(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 80),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: PinCodeTextField(
                    appContext: context,
                    obscureText: true,
                    obscuringWidget: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.circle,
                      activeColor: Colors.white,
                      disabledColor: Colors.white,
                      inactiveColor: Colors.white,
                    ),
                    length: 6,
                    onChanged: (passcode) {},
                    readOnly: true,
                    controller: context.watch<PinCubit>().state.controller,
                    onCompleted: onCompleted,
                  ),
                ),
              ),
              const SizedBox(height: 80),
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                  ),
                  child: const NumberPad(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
