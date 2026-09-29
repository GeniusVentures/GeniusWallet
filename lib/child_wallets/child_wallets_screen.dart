import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/account/account_drawer.dart' show AccountAvatar;
import 'package:genius_wallet/child_wallets/child_operation_dialogs.dart';
import 'package:genius_wallet/child_wallets/child_operation_status.dart';
import 'package:genius_wallet/child_wallets/child_operations_cubit.dart';
import 'package:genius_wallet/child_wallets/child_wallets_cubit.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/components/feedback/gw_error_state.dart';
import 'package:genius_wallet/components/gw_icon.dart';
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
    final cubit = context.watch<ChildWalletsCubit>();
    final operations = context.read<ChildOperationsCubit>();
    final state = cubit.state;
    final populatedOrConnectedEmpty = state.status == ChildWalletsStatus.loaded;

    void refresh() {
      cubit.refresh();
      operations.resolve();
    }

    return BlocListener<ChildOperationsCubit, ChildOperationsState>(
      // The registry's own resolve is the truth; this just makes the row's
      // displayed balance/list catch up to it immediately rather than
      // waiting for the next 10s poll.
      listenWhen: (previous, current) => current.justResolved.isNotEmpty,
      listener: (_, _) => cubit.refresh(),
      child: GWScreen(
        appBar: AppBar(title: const Text('Child wallets')),
        scroll: false,
        child: Column(
          children: [
            _ChildWalletsHeader(
              mainName: state.mainName,
              mainAddress: state.mainAddress,
              onRefresh: refresh,
            ),
            const SizedBox(height: GeniusWalletConsts.space8),
            Expanded(
              child: _ChildWalletsBody(state: state, onRetry: refresh),
            ),
            if (populatedOrConnectedEmpty) ...[
              const SizedBox(height: GeniusWalletConsts.space6),
              Text(
                "Balances come from the node's synced view and can lag.",
                style: GeniusWalletTypography.bodySm.copyWith(
                  color: context.gw.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The list for a populated or connected-empty read, or the empty/error
/// state that explains why there is nothing to list.
class _ChildWalletsBody extends StatelessWidget {
  const _ChildWalletsBody({required this.state, required this.onRetry});

  final ChildWalletsState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case ChildWalletsStatus.nodeNotRunning:
        return const GWEmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Node not running',
        );
      case ChildWalletsStatus.error:
        return GWErrorState(
          title: "Couldn't load child wallets",
          onRetry: onRetry,
        );
      case ChildWalletsStatus.loaded:
        if (state.children.isEmpty) {
          return const GWEmptyState(
            icon: Icons.account_tree_outlined,
            title: 'No child wallets registered under this account.',
          );
        }
        return ListView.separated(
          itemCount: state.children.length,
          separatorBuilder: (_, _) =>
              Divider(height: 1, color: context.gw.borderSubtle),
          itemBuilder: (_, index) => ChildWalletRow(
            wallet: state.children[index],
            mainAddress: state.mainAddress,
          ),
        );
    }
  }
}

/// Names the main account this screen is listing children for. Renders in
/// every state (populated, empty, disconnected, error) -- never hidden.
class _ChildWalletsHeader extends StatelessWidget {
  const _ChildWalletsHeader({
    required this.mainName,
    required this.mainAddress,
    required this.onRefresh,
  });

  final String mainName;
  final String mainAddress;
  final VoidCallback onRefresh;

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
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            color: gw.textSecondary,
            onPressed: onRefresh,
          ),
        ],
      ),
    );
  }
}

/// One child's identity, balance and actions: a "Child actions" menu (Fund,
/// more to follow) and its own pending/not-confirmed badge. Not a
/// `GWSelectRow`: the row itself is not tappable, only its trailing menu is.
class ChildWalletRow extends StatelessWidget {
  const ChildWalletRow({
    super.key,
    required this.wallet,
    required this.mainAddress,
  });

  final ChildWallet wallet;
  final String mainAddress;

  @override
  Widget build(BuildContext context) {
    final gw = context.gw;
    final registry = context.watch<ChildOperationsCubit>();
    final pendingOp = registry.latestFor(wallet.address);
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
          if (pendingOp != null) ...[
            const SizedBox(width: GeniusWalletConsts.space3),
            Flexible(
              child: ChildOperationBadge(
                op: pendingOp,
                labelFor: registry.labelFor,
              ),
            ),
          ],
          MenuAnchor(
            builder: (context, controller, child) => IconButton(
              icon: GWIcon.material(Icons.more_vert, color: gw.textSecondary),
              tooltip: 'Child actions',
              onPressed: () =>
                  controller.isOpen ? controller.close() : controller.open(),
            ),
            menuChildren: [
              MenuItemButton(
                leadingIcon: GWIcon.material(
                  Icons.arrow_upward,
                  color: gw.textPrimary,
                ),
                style: MenuItemButton.styleFrom(
                  foregroundColor: gw.textPrimary,
                ),
                onPressed: () =>
                    startFund(context, child: wallet, mainAddress: mainAddress),
                child: const Text('Fund'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
