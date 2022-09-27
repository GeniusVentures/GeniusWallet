import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/pin_cubit.dart';
import 'package:genius_wallet/app/screens/pin_screen.dart';

class NumberPad extends StatelessWidget {
  const NumberPad({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * .25,
      ),
      child: Column(
        children: [
          Row(
            children: const [
              StringButton(value: '1'),
              Spacer(),
              StringButton(value: '2'),
              Spacer(),
              StringButton(value: '3'),
            ],
          ),
          const Spacer(),
          Row(
            children: const [
              StringButton(value: '4'),
              Spacer(),
              StringButton(value: '5'),
              Spacer(),
              StringButton(value: '6'),
            ],
          ),
          const Spacer(),
          Row(
            children: const [
              StringButton(value: '7'),
              Spacer(),
              StringButton(value: '8'),
              Spacer(),
              StringButton(value: '9'),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              /// Clear all button
              MaterialButton(
                onPressed: () {
                  context.read<PinCubit>().clearAll();
                },
                child: const Icon(Icons.refresh),
              ),

              const Spacer(),
              const StringButton(value: '0'),
              const Spacer(),

              /// Backspace
              MaterialButton(
                onPressed: () {
                  context.read<PinCubit>().backspace();
                },
                child: const Icon(Icons.backspace),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Button that holds a string as value and appends value to provided controller
class StringButton extends StatelessWidget {
  final String value;
  const StringButton({
    Key? key,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        context.read<PinCubit>().add(value);
      },
      height: 60,
      child: Text(
        value,
        style: TextStyle(fontSize: 22 * MediaQuery.of(context).textScaleFactor),
      ),
    );
  }
}
