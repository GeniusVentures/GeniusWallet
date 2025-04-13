import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/bloc/pin_cubit.dart';
import 'package:genius_wallet/bloc/pin_state.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/utils/formatters.dart';
import 'package:genius_wallet/components/app_screen_view.dart';
import 'package:genius_wallet/components/app_screen_with_header_desktop.dart';
import 'package:genius_wallet/components/desktop_body_container.dart';
import 'package:genius_wallet/components/number_pad.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/components/continue_button/isactive_false.g.dart';
import 'package:genius_wallet/components/continue_button/isactive_true.g.dart';
import 'package:genius_wallet/components/incorrect_pin.g.dart';
import 'package:go_router/go_router.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        if (GeniusBreakpoints.useDesktopLayout(context)) {
          return _PinViewDesktop(
            text: text,
            onCompleted: onCompleted,
          );
        }
        return _PinViewMobile(
          text: text,
          onCompleted: onCompleted,
        );
      },
    );
  }
}

class _PinViewDesktop extends StatelessWidget {
  const _PinViewDesktop({
    Key? key,
    required this.onCompleted,
    required this.text,
  }) : super(key: key);

  final String text;
  final Function(String p1) onCompleted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScreenWithHeaderDesktop(
        title: text,
        subtitle: '',
        body: Center(
          child: DesktopBodyContainer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(text),
                PinCodeTextField(
                  appContext: context,
                  length: GeniusWalletConsts.pinCount,
                  pinTheme: PinTheme(
                    activeColor: Colors.white,
                    selectedColor: Colors.white,
                    disabledColor: Colors.white,
                    inactiveColor: Colors.white,
                  ),
                  cursorColor: Colors.white,
                  obscureText: true,
                  onChanged: context.read<PinCubit>().desktopOnChanged,
                  controller: context.watch<PinCubit>().state.controller,
                  inputFormatters: [Formatters.allowIntegers],
                  autoDisposeControllers: false,
                ),
                BlocBuilder<PinCubit, PinState>(builder: (context, state) {
                  if (state.displayIncorrectPin) {
                    return const Text(
                      'Incorrect PIN',
                      style: TextStyle(
                        color: GeniusWalletColors.foundationError,
                      ),
                    );
                  }
                  return const SizedBox();
                }),
                const SizedBox(height: 50),
                SizedBox(
                  height: 50,
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return BlocBuilder<PinCubit, PinState>(
                        builder: (context, state) {
                          if (state.pinFullness == PinFullness.completed) {
                            return MaterialButton(
                              padding: const EdgeInsets.all(0),
                              onPressed: () {
                                onCompleted(state.controller.text);
                              },
                              child: IsactiveTrue(constraints),
                            );
                          }
                          return IsactiveFalse(constraints);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PinViewMobile extends StatelessWidget {
  const _PinViewMobile({
    Key? key,
    required this.text,
    required this.onCompleted,
  }) : super(key: key);

  final String text;
  final Function(String p1) onCompleted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GeniusWalletColors.deepBlueSecondary,
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
                padding: const EdgeInsets.only(top: 20, left: 20),
                child: IconButton(
                  alignment: Alignment.center,
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close, size: 32),
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
                height: MediaQuery.of(context).size.height * 0.2,
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
              const SizedBox(height: 28),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: PinCodeTextField(
                    appContext: context,
                    obscureText: true,
                    cursorColor: Colors.transparent,
                    enableActiveFill: true,
                    obscuringWidget: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: GeniusWalletColors.lightGreenPrimary,
                      ),
                    ),
                    pinTheme: PinTheme(
                        selectedColor: GeniusWalletColors.borderGrey,
                        selectedFillColor: GeniusWalletColors.borderGrey,
                        inactiveFillColor: GeniusWalletColors.borderGrey,
                        inactiveColor: GeniusWalletColors.borderGrey,
                        activeColor: GeniusWalletColors.lightGreenPrimary,
                        activeFillColor: GeniusWalletColors.lightGreenPrimary,
                        borderWidth: 0,
                        fieldWidth: 16,
                        shape: PinCodeFieldShape.circle),
                    length: GeniusWalletConsts.pinCount,
                    onChanged: (passcode) {},
                    readOnly: true,
                    controller: context.watch<PinCubit>().state.controller,
                    onCompleted: onCompleted,
                    autoDisposeControllers: false,
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
