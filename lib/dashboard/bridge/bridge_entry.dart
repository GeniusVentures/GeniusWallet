import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_gate.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_gate_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';

/// The gate as of this moment. A host with no [BridgeGateCubit] reads
/// disabled, never enabled.
BridgeGate liveBridgeGate(BuildContext context) =>
    context.read<BridgeGateCubit?>()?.resolveNow() ?? kBridgeGateUnknown;

/// Opens the bridge on the gate's GNUS coin. The gate is read again here, so
/// an earning switch that began after the last frame stops the tap.
Future<void> openGnusBridge(BuildContext context) async {
  final gate = liveBridgeGate(context);
  final coin = gate.coin;
  if (!gate.enabled || coin == null) {
    return;
  }
  final walletCubit = context.read<WalletDetailsCubit>();
  final router = GoRouter.of(context);
  walletCubit.selectCoin(coin);
  await router.push('/bridge');
  walletCubit.getCoins();
}

class BridgeButton extends StatelessWidget {
  const BridgeButton({super.key, required this.gate, required this.onPressed});

  final BridgeGate gate;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tap = gate.enabled ? onPressed : null;
    return Semantics(
      button: true,
      enabled: gate.enabled,
      label: 'Bridge',
      hint: gate.enabled ? null : gate.caption,
      excludeSemantics: true,
      onTap: tap,
      child: GWButton(
        variant: gate.enabled
            ? GWButtonVariant.gradientOutline
            : GWButtonVariant.tertiary,
        size: GWButtonSize.sm,
        label: 'Bridge',
        leading: const Icon(Icons.alt_route),
        onPressed: tap,
      ),
    );
  }
}

/// The reason Bridge is disabled, one line. Takes no space when enabled.
class BridgeReasonCaption extends StatelessWidget {
  const BridgeReasonCaption({super.key, required this.gate});

  final BridgeGate gate;

  @override
  Widget build(BuildContext context) {
    final caption = gate.caption;
    if (caption == null) {
      return const SizedBox.shrink();
    }
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Padding(
      padding: const EdgeInsets.only(top: GeniusWalletConsts.space4),
      child: Text(
        caption,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: GeniusWalletTypography.labelMd.copyWith(color: gw.textSecondary),
      ),
    );
  }
}
