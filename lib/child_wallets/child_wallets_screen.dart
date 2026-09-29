import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/account/account_drawer.dart' show AccountAvatar;
import 'package:genius_wallet/child_wallets/child_wallets_cubit.dart';
import 'package:genius_wallet/components/scaffold/gw_screen.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';

/// The children registered under the node's own SDK account, each with its
/// linked wallet name (or "Unlinked") and its GNUS balance.
class ChildWalletsScreen extends StatelessWidget {
  const ChildWalletsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ChildWalletsCubit>().state;

    return GWScreen(
      appBar: AppBar(title: const Text('Child wallets')),
      scroll: false,
      child: Column(
        children: [
          _ChildWalletsHeader(
            mainName: state.mainName,
            mainAddress: state.mainAddress,
          ),
          const SizedBox(height: GeniusWalletConsts.space8),
          Expanded(
            child: ListView.separated(
              itemCount: state.children.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: context.gw.borderSubtle),
              itemBuilder: (_, index) =>
                  _ChildWalletRow(wallet: state.children[index]),
            ),
          ),
        ],
      ),
    );
  }
}

/// Names the main account this screen is listing children for. Renders in
/// every state (populated, empty, disconnected, error) -- never hidden.
class _ChildWalletsHeader extends StatelessWidget {
  const _ChildWalletsHeader({
    required this.mainName,
    required this.mainAddress,
  });

  final String mainName;
  final String mainAddress;

  @override
  Widget build(BuildContext context) {
    final gw = context.gw;
    return Container(
      padding: const EdgeInsets.all(GeniusWalletConsts.space6),
      decoration: BoxDecoration(
        color: gw.surfaceWell,
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: gw.brandPrimaryStrong,
            child: Icon(
              Icons.account_balance_wallet,
              size: 18,
              color: gw.textOnBrand,
            ),
          ),
          const SizedBox(width: GeniusWalletConsts.space6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mainName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GeniusWalletTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: gw.textPrimary,
                  ),
                ),
                Text(
                  WalletUtils.getAddressForDisplay(mainAddress),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GeniusWalletTypography.labelMd.copyWith(
                    fontFamily: GeniusWalletTypography.monoFamily,
                    color: gw.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One child's identity and balance. Not a `GWSelectRow`: nothing here is
/// tappable yet, so this reuses only its content shape.
class _ChildWalletRow extends StatelessWidget {
  const _ChildWalletRow({required this.wallet});

  final ChildWallet wallet;

  @override
  Widget build(BuildContext context) {
    final gw = context.gw;
    final linkedWallet = wallet.linkedWallet;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space6,
        vertical: GeniusWalletConsts.space6,
      ),
      child: Row(
        children: [
          linkedWallet != null
              ? AccountAvatar(wallet: linkedWallet, isSelected: false, size: 36)
              : CircleAvatar(
                  radius: 16,
                  backgroundColor: gw.surfaceSunken,
                  child: Icon(
                    Icons.question_mark,
                    size: 16,
                    color: gw.textSecondary,
                  ),
                ),
          const SizedBox(width: GeniusWalletConsts.space6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  wallet.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GeniusWalletTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: gw.textPrimary,
                  ),
                ),
                Text(
                  WalletUtils.getAddressForDisplay(wallet.address),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GeniusWalletTypography.labelMd.copyWith(
                    fontFamily: GeniusWalletTypography.monoFamily,
                    color: gw.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: GeniusWalletConsts.space4),
          Text(
            formatTxAmount(wallet.balanceGnus),
            style: GeniusWalletTypography.numericBody.copyWith(
              color: gw.textPrimary,
            ),
          ),
          Text(
            ' GNUS',
            style: GeniusWalletTypography.labelMd.copyWith(
              color: gw.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
