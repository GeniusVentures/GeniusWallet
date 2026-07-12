import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/bloc/pin_cubit.dart';
import 'package:genius_wallet/bloc/pin_state.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/utils/formatters.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PinScreen extends StatelessWidget {
  final String title;
  final Function(String) onCompleted;
  const PinScreen({super.key, required this.title, required this.onCompleted});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: GeniusBreakpoints.small),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineLarge),
            MaterialPinField(
              length: GeniusWalletConsts.pinCount,
              obscureText: true,
              onChanged: context.read<PinCubit>().desktopOnChanged,
              pinController: context.watch<PinCubit>().state.pinController,
              inputFormatters: [Formatters.allowIntegers],
            ),
            BlocBuilder<PinCubit, PinState>(
              builder: (context, state) {
                if (state.displayIncorrectPin) {
                  return Text(
                    'Incorrect PIN',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.errorContainer,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 250),
              child: BlocBuilder<PinCubit, PinState>(
                builder: (context, state) {
                  return FilledButton(
                    onPressed: state.pinFullness == PinFullness.completed
                        ? () => onCompleted(state.pinController.text)
                        : null,
                    child: const Text("Continue"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
