import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart' show GeniusNodeReturnValue;
import 'package:genius_wallet/child_wallets/child_operations_cubit.dart';
import 'package:genius_wallet/child_wallets/child_wallets_cubit.dart'
    show ChildWallet, minionsToGnus;
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/components/overlays/gw_dialog.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';

/// Opens the Fund dialog for [child], paid from [mainAddress]. Every write
/// goes through the registry -- this file never calls the SDK directly.
Future<void> startFund(
  BuildContext context, {
  required ChildWallet child,
  required String mainAddress,
}) async {
  final registry = context.read<ChildOperationsCubit>();
  // Root navigator, not a route pop: the MenuAnchor this is called from
  // closes itself on selection -- there is no drawer route to close here.
  final navigator = Navigator.of(context, rootNavigator: true);
  final barrierColor = context.gw.surfaceOverlay;

  final amount = await showDialog<BigInt>(
    context: navigator.context,
    barrierColor: barrierColor,
    builder: (_) =>
        _FundDialog(registry: registry, child: child, mainAddress: mainAddress),
  );

  if (amount == null) {
    return;
  }

  final result = registry.submit(
    kind: ChildOperationKind.fund,
    target: child.address,
    main: mainAddress,
    amountMinions: amount,
  );

  if (!navigator.context.mounted) {
    return;
  }
  if (result == null) {
    showToast(
      // ignore: use_build_context_synchronously
      navigator.context,
      'Nothing was sent. Try again.',
      type: ToastType.error,
    );
    return;
  }
  if (result != GeniusNodeReturnValue.GENIUS_NODE_RET_OK) {
    showToast(
      // ignore: use_build_context_synchronously
      navigator.context,
      'The SDK refused to fund this child: ${result.name}',
      type: ToastType.error,
    );
  }
  // OK: no toast here -- the pending badge is the feedback, and the success
  // toast only fires once the registry's own resolve() sees the real signal.
}

/// The Fund confirmation, shaped like `sdk_account_manager.dart`'s
/// `_AddAccountDialog`: a private `StatefulWidget` building `GWDialog` itself
/// so the amount field's error text can update live.
class _FundDialog extends StatefulWidget {
  const _FundDialog({
    required this.registry,
    required this.child,
    required this.mainAddress,
  });

  final ChildOperationsCubit registry;
  final ChildWallet child;
  final String mainAddress;

  @override
  State<_FundDialog> createState() => _FundDialogState();
}

class _FundDialogState extends State<_FundDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registry = widget.registry;
    final mainName = registry.labelFor(widget.mainAddress);
    final childName = registry.labelFor(widget.child.address);
    final balance = registry.payingBalance(
      ChildOperationKind.fund,
      widget.child.address,
    );

    return GWDialog(
      title: 'Fund $childName',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('From $mainName to $childName.'),
          const SizedBox(height: GeniusWalletConsts.space6),
          GWTextField(
            controller: _controller,
            label: 'Amount',
            hint: '0.0',
            errorText: _error,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            suffix: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('GNUS'),
                const SizedBox(width: GeniusWalletConsts.space4),
                GWButton(
                  label: 'MAX',
                  variant: GWButtonVariant.ghost,
                  size: GWButtonSize.sm,
                  onPressed: () => setState(() {
                    _controller.text = minionsToGnus(balance);
                    _error = null;
                  }),
                ),
              ],
            ),
            onChanged: (_) => setState(() => _error = null),
          ),
        ],
      ),
      actions: [
        GWDialogAction(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
        GWDialogAction(
          label: 'Fund',
          variant: GWButtonVariant.primary,
          onPressed: () {
            final parsed = parseGnusAmount(
              _controller.text,
              balanceMinions: balance,
              payer: mainName,
            );
            if (parsed.minions == null) {
              setState(() => _error = parsed.error);
              return;
            }
            Navigator.of(context).pop(parsed.minions);
          },
        ),
      ],
    );
  }
}
