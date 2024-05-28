import 'package:flutter/material.dart';
import 'package:genius_wallet/app/widgets/string_button.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

class CalculatorNumpad extends StatelessWidget {
  final void Function(String) onNumPressed;
  final void Function() onClearPressed;
  static const double _buttonWidth = 180;
  const CalculatorNumpad({
    Key? key,
    required this.onNumPressed,
    required this.onClearPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 270),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              StringButton(
                value: '1',
                onPressed: onNumPressed,
                color: GeniusWalletColors.gray800,
                minWidth: _buttonWidth,
              ),
              const Spacer(),
              StringButton(
                value: '2',
                onPressed: onNumPressed,
                color: GeniusWalletColors.gray800,
                minWidth: _buttonWidth,
              ),
              const Spacer(),
              StringButton(
                value: '3',
                onPressed: onNumPressed,
                color: GeniusWalletColors.gray800,
                minWidth: _buttonWidth,
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              StringButton(
                value: '4',
                onPressed: onNumPressed,
                color: GeniusWalletColors.gray800,
                minWidth: _buttonWidth,
              ),
              const Spacer(),
              StringButton(
                value: '5',
                onPressed: onNumPressed,
                color: GeniusWalletColors.gray800,
                minWidth: _buttonWidth,
              ),
              const Spacer(),
              StringButton(
                value: '6',
                onPressed: onNumPressed,
                color: GeniusWalletColors.gray800,
                minWidth: _buttonWidth,
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              StringButton(
                value: '7',
                onPressed: onNumPressed,
                color: GeniusWalletColors.gray800,
                minWidth: _buttonWidth,
              ),
              const Spacer(),
              StringButton(
                value: '8',
                onPressed: onNumPressed,
                color: GeniusWalletColors.gray800,
                minWidth: _buttonWidth,
              ),
              const Spacer(),
              StringButton(
                value: '9',
                onPressed: onNumPressed,
                color: GeniusWalletColors.gray800,
                minWidth: _buttonWidth,
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              StringButton(
                value: '.',
                onPressed: onNumPressed,
                color: GeniusWalletColors.gray800,
                minWidth: _buttonWidth,
              ),
              const Spacer(),
              StringButton(
                value: '0',
                onPressed: onNumPressed,
                color: GeniusWalletColors.gray800,
                minWidth: _buttonWidth,
              ),
              const Spacer(),

              /// Clear all button
              StringButton(
                onPressed: (value) => onClearPressed(),
                value: 'C',
                minWidth: _buttonWidth,
                color: GeniusWalletColors.gray500,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
