import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/child_wallets/child_operations_cubit.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_select_row.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/components/overlays/gw_dialog.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';

/// True for an SGNUS public address: `0x` plus 128 hex characters, any case,
/// after trimming. A 42-character EVM address is not a main address.
bool isSdkAddress(String text) =>
    RegExp(r'^0x[0-9a-fA-F]{128}$').hasMatch(text.trim());

/// Lets the user pick one of [candidates] not in [excluded], or type an
/// address (also checked against [excluded]). Returns it, or null on Cancel.
Future<String?> showMainPicker(
  BuildContext context, {
  required String title,
  required List<String> candidates,
  required Set<String> excluded,
}) {
  // Read here: the dialog route sits beside `home`, so a provider scoped to
  // `home` would not reach it.
  final nameFor = context.read<ChildOperationsCubit>().nameFor;
  return showDialog<String>(
    context: context,
    barrierColor: context.gw.surfaceOverlay,
    builder: (_) => _MainPickerDialog(
      title: title,
      candidates: candidates,
      excluded: excluded,
      nameFor: nameFor,
    ),
  );
}

class _MainPickerDialog extends StatefulWidget {
  const _MainPickerDialog({
    required this.title,
    required this.candidates,
    required this.excluded,
    required this.nameFor,
  });

  final String title;
  final List<String> candidates;
  final Set<String> excluded;
  final String Function(String) nameFor;

  @override
  State<_MainPickerDialog> createState() => _MainPickerDialogState();
}

class _MainPickerDialogState extends State<_MainPickerDialog> {
  bool _manual = false;
  String? _picked;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isExcluded(String address) => widget.excluded.any(
    (excluded) => excluded.toLowerCase() == address.toLowerCase(),
  );

  List<String> get _visibleCandidates =>
      widget.candidates.where((candidate) => !_isExcluded(candidate)).toList();

  /// The picker's current answer: the picked row in list mode, or a typed
  /// address once it is both a valid SDK address and not excluded.
  String? get _target {
    if (!_manual) {
      return _picked;
    }
    final text = _controller.text.trim();
    return (isSdkAddress(text) && !_isExcluded(text)) ? text : null;
  }

  /// Why the typed address can't be used yet, or null while it is empty or
  /// fine.
  String? get _manualError {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !isSdkAddress(text)) {
      return 'Not an earning account address - 0x followed by 128 hex characters.';
    }
    if (text.isNotEmpty && _isExcluded(text)) {
      return "That account can't be chosen here.";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GWDialog(
      title: widget.title,
      content: _manual
          ? _MainPickerManualContent(
              controller: _controller,
              error: _manualError,
              onBack: () => setState(() => _manual = false),
              onChanged: () => setState(() {}),
            )
          : _MainPickerListContent(
              candidates: _visibleCandidates,
              nameFor: widget.nameFor,
              picked: _picked,
              onPick: (candidate) => setState(() => _picked = candidate),
              onManual: () => setState(() => _manual = true),
            ),
      actions: [
        GWDialogAction(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
        GWDialogAction(
          label: 'Continue',
          variant: GWButtonVariant.primary,
          onPressed: _target == null
              ? null
              : () => Navigator.of(context).pop(_target),
        ),
      ],
    );
  }
}

/// The picker's list mode: the user's other own accounts, or a line saying
/// there are none, then the "Enter an address" row.
class _MainPickerListContent extends StatelessWidget {
  const _MainPickerListContent({
    required this.candidates,
    required this.nameFor,
    required this.picked,
    required this.onPick,
    required this.onManual,
  });

  final List<String> candidates;
  final String Function(String) nameFor;
  final String? picked;
  final ValueChanged<String> onPick;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    final gw = context.gw;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (candidates.isEmpty)
          Text(
            'You have no other earning accounts. Enter an address instead.',
            style: GeniusWalletTypography.bodySm.copyWith(
              color: gw.textSecondary,
            ),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final candidate in candidates)
                    GWSelectRow(
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: gw.surfaceSunken,
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 16,
                          color: gw.textSecondary,
                        ),
                      ),
                      title: nameFor(candidate),
                      subtitle: WalletUtils.getAddressForDisplay(candidate),
                      subtitleStyle: GeniusWalletTypography.labelMd.copyWith(
                        fontFamily: GeniusWalletTypography.monoFamily,
                        color: gw.textSecondary,
                      ),
                      selected:
                          picked?.toLowerCase() == candidate.toLowerCase(),
                      onTap: () => onPick(candidate),
                    ),
                ],
              ),
            ),
          ),
        const SizedBox(height: GeniusWalletConsts.space8),
        GWSelectRow(
          leading: Icon(Icons.edit_outlined, color: gw.textSecondary),
          title: 'Enter an address',
          trailing: Icon(Icons.chevron_right, color: gw.textSecondary),
          onTap: onManual,
        ),
      ],
    );
  }
}

/// The picker's manual mode: a back link and the address field.
class _MainPickerManualContent extends StatelessWidget {
  const _MainPickerManualContent({
    required this.controller,
    required this.error,
    required this.onBack,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String? error;
  final VoidCallback onBack;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GWButton(
          label: '‹ Back',
          variant: GWButtonVariant.ghost,
          size: GWButtonSize.sm,
          onPressed: onBack,
        ),
        const SizedBox(height: GeniusWalletConsts.space6),
        GWTextField(
          controller: controller,
          label: 'Address',
          hint: '0x…',
          errorText: error,
          fill: context.gw.surfaceSunken,
          onChanged: (_) => onChanged(),
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.none,
        ),
      ],
    );
  }
}
