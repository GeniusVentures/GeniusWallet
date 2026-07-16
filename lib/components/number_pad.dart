import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/bloc/pin_cubit.dart';
import 'package:genius_wallet/components/string_button.dart';

class NumberPad extends StatelessWidget {
  const NumberPad({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * .35,
      ),
      child: Column(
        children: [
          Row(
            children: [
              StringButton(
                value: '1',
                onPressed: context.read<PinCubit>().add,
              ),
              const Spacer(),
              StringButton(
                value: '2',
                onPressed: context.read<PinCubit>().add,
              ),
              const Spacer(),
              StringButton(
                value: '3',
                onPressed: context.read<PinCubit>().add,
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              StringButton(
                value: '4',
                onPressed: context.read<PinCubit>().add,
              ),
              const Spacer(),
              StringButton(
                value: '5',
                onPressed: context.read<PinCubit>().add,
              ),
              const Spacer(),
              StringButton(
                value: '6',
                onPressed: context.read<PinCubit>().add,
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              StringButton(
                value: '7',
                onPressed: context.read<PinCubit>().add,
              ),
              const Spacer(),
              StringButton(
                value: '8',
                onPressed: context.read<PinCubit>().add,
              ),
              const Spacer(),
              StringButton(
                value: '9',
                onPressed: context.read<PinCubit>().add,
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              /// Disabled spacer button
              const MaterialButton(
                onPressed: null,
              ),

              const Spacer(),
              StringButton(
                value: '0',
                onPressed: context.read<PinCubit>().add,
              ),
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
