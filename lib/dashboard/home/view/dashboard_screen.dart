import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/data/gw_animated_number.dart';
import 'package:genius_wallet/components/loading/gw_spinner.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Clean, mobile-first dashboard. Solid dark canvas, big centered hero
/// balance, pill-shaped action row, segmented Assets/Activity tabs and flat
/// list rows separated by hairline dividers. Inspired by Phantom / Coinbase
/// Wallet's restrained chrome.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  _DashboardTab _tab = _DashboardTab.assets;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        context.read<WalletDetailsCubit>().getCoins();
      } catch (_) {/* mock mode */}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GeniusWalletColors.surfaceBase,
      body: SafeArea(
        child: BlocBuilder<AppBloc, AppState>(
          builder: (context, appState) {
            if (appState.subscribeToWalletStatus != AppStatus.loaded) {
              return const Center(child: GWSpinner(size: 48));
            }
            return BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
              builder: (context, walletState) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: _HeroBalance(
                            balance: _resolveBalance(appState, walletState),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _ActionRow(
                            walletAddress:
                                walletState.selectedWallet?.address,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _Tabs(
                            value: _tab,
                            onChanged: (t) => setState(() => _tab = t),
                          ),
                        ),
                        if (_tab == _DashboardTab.assets)
                          _AssetsSliver(coins: walletState.coins)
                        else
                          const _ActivitySliver(),
                        const SliverToBoxAdapter(
                          child: SizedBox(
                            height: GeniusWalletConsts.space20,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  double _resolveBalance(AppState appState, WalletDetailsState walletState) {
    final accountBalance = appState.account?.balance;
    if (accountBalance != null && accountBalance > 0) return accountBalance;
    final str = walletState.selectedWalletBalance;
    if (str != null) {
      final parsed = double.tryParse(str);
      if (parsed != null) return parsed;
    }
    return walletState.selectedWallet?.balance ?? 0;
  }

}

enum _DashboardTab { assets, activity }

// ---------------------------------------------------------------------------

class _HeroBalance extends StatelessWidget {
  const _HeroBalance({required this.balance});
  final double balance;

  @override
  Widget build(BuildContext context) {
    // Mock 24h delta — wire to real data later.
    final delta = balance * 0.024;
    final positive = delta >= 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        GeniusWalletConsts.space6,
        GeniusWalletConsts.space12,
        GeniusWalletConsts.space6,
        GeniusWalletConsts.space10,
      ),
      child: Column(
        children: [
          Text(
            'Total balance',
            style: GeniusWalletTypography.labelMd.copyWith(
              color: GeniusWalletColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: GeniusWalletConsts.space2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: GWAnimatedNumber(
              value: balance,
              prefix: '\$',
              decimals: 2,
              textAlign: TextAlign.center,
              style: GeniusWalletTypography.numericDisplay.copyWith(
                fontSize: 56,
                fontWeight: FontWeight.w700,
                height: 1.0,
                letterSpacing: -1.5,
              ),
            ),
          ),
          const SizedBox(height: GeniusWalletConsts.space2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                positive
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 14,
                color: positive
                    ? GeniusWalletColors.brandSecondary
                    : GeniusWalletColors.statusError,
              ),
              const SizedBox(width: GeniusWalletConsts.space2),
              Text(
                '${positive ? '+' : '−'}\$${delta.abs().toStringAsFixed(2)}',
                style: GeniusWalletTypography.labelMd.copyWith(
                  color: positive
                      ? GeniusWalletColors.brandSecondary
                      : GeniusWalletColors.statusError,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: GeniusWalletConsts.space4),
              Text(
                '24h',
                style: GeniusWalletTypography.labelMd.copyWith(
                  color: GeniusWalletColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _ActionRow extends StatelessWidget {
  const _ActionRow({this.walletAddress});
  final String? walletAddress;

  @override
  Widget build(BuildContext context) {
    final actions = <_PillAction>[
      _PillAction(
        icon: Icons.arrow_upward_rounded,
        label: 'Send',
        onTap: () => _stub(context, 'Send'),
      ),
      _PillAction(
        icon: Icons.arrow_downward_rounded,
        label: 'Receive',
        onTap: () => _receive(context),
      ),
      _PillAction(
        icon: Icons.swap_horiz_rounded,
        label: 'Swap',
        onTap: () => context.push('/swap'),
      ),
      _PillAction(
        icon: Icons.compare_arrows_rounded,
        label: 'Bridge',
        onTap: () => context.push('/bridge'),
      ),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space6,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: actions,
      ),
    );
  }

  void _stub(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label flow — coming soon'),
        backgroundColor: GeniusWalletColors.surfaceMenu,
      ),
    );
  }

  void _receive(BuildContext context) {
    if (walletAddress != null && walletAddress!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: walletAddress!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Wallet address copied'),
          backgroundColor: GeniusWalletColors.surfaceMenu,
        ),
      );
    }
  }
}

class _PillAction extends StatelessWidget {
  const _PillAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: GeniusWalletColors.surfaceElevated,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 56,
              height: 56,
              child: Icon(
                icon,
                size: 22,
                color: GeniusWalletColors.brandPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: GeniusWalletConsts.space2),
        Text(
          label,
          style: GeniusWalletTypography.labelMd.copyWith(
            color: GeniusWalletColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _Tabs extends StatelessWidget {
  const _Tabs({required this.value, required this.onChanged});
  final _DashboardTab value;
  final ValueChanged<_DashboardTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        GeniusWalletConsts.space6,
        GeniusWalletConsts.space12,
        GeniusWalletConsts.space6,
        GeniusWalletConsts.space4,
      ),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: GeniusWalletColors.surfaceElevated,
          borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
        ),
        child: Row(
          children: [
            Expanded(child: _tab(context, _DashboardTab.assets, 'Assets')),
            Expanded(child: _tab(context, _DashboardTab.activity, 'Activity')),
          ],
        ),
      ),
    );
  }

  Widget _tab(BuildContext context, _DashboardTab t, String label) {
    final selected = value == t;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(t),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: selected
              ? GeniusWalletColors.surfaceMenu
              : Colors.transparent,
          borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GeniusWalletTypography.labelMd.copyWith(
            color: selected
                ? GeniusWalletColors.textPrimary
                : GeniusWalletColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _AssetsSliver extends StatelessWidget {
  const _AssetsSliver({required this.coins});
  final List<Coin> coins;

  @override
  Widget build(BuildContext context) {
    if (coins.isEmpty) {
      return const SliverToBoxAdapter(
        child: _EmptyState(
          icon: Icons.account_balance_wallet_outlined,
          title: 'No assets yet',
          subtitle: 'Buy or receive your first token to get started.',
        ),
      );
    }
    return SliverList.separated(
      itemCount: coins.length,
      separatorBuilder: (_, __) => const _RowDivider(),
      itemBuilder: (_, i) => _CoinRow(coin: coins[i]),
    );
  }
}

class _ActivitySliver extends StatelessWidget {
  const _ActivitySliver();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsCubit, List<Transaction>>(
      builder: (context, txs) {
        final list = txs.toList();
        if (list.isEmpty) {
          return const SliverToBoxAdapter(
            child: _EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No activity yet',
              subtitle: 'Your sends, receives and swaps will appear here.',
            ),
          );
        }
        return SliverList.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const _RowDivider(),
          itemBuilder: (_, i) => _TxRow(tx: list[i]),
        );
      },
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space6,
      ),
      child: Container(
        height: 1,
        color: GeniusWalletColors.borderSubtle,
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _CoinRow extends StatelessWidget {
  const _CoinRow({required this.coin});
  final Coin coin;

  @override
  Widget build(BuildContext context) {
    final balance = coin.balance ?? 0;
    final symbol = coin.symbol ?? '?';
    return InkWell(
      onTap: () {/* token info */},
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: GeniusWalletConsts.space6,
          vertical: GeniusWalletConsts.space4,
        ),
        child: Row(
          children: [
            _RowIcon(letter: symbol.characters.first),
            const SizedBox(width: GeniusWalletConsts.space6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coin.name ?? symbol,
                    style: GeniusWalletTypography.titleMd,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    symbol,
                    style: GeniusWalletTypography.bodySm,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatNumber(balance),
                  style: GeniusWalletTypography.numericBody.copyWith(
                    fontSize: 15,
                  ),
                ),
                Text(
                  symbol,
                  style: GeniusWalletTypography.bodySm,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(double v) =>
      NumberFormat.decimalPatternDigits(decimalDigits: v < 1 ? 6 : 4).format(v);
}

class _RowIcon extends StatelessWidget {
  const _RowIcon({required this.letter});
  final String letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: GeniusWalletColors.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: GeniusWalletTypography.labelMd.copyWith(
          color: GeniusWalletColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _TxRow extends StatelessWidget {
  const _TxRow({required this.tx});
  final Transaction tx;

  @override
  Widget build(BuildContext context) {
    final isReceived = tx.transactionDirection == TransactionDirection.received;
    final amount = tx.recipients.isNotEmpty ? tx.recipients.first.amount : '0';
    final counterparty = isReceived
        ? _short(tx.fromAddress)
        : _short(tx.recipients.isNotEmpty ? tx.recipients.first.toAddr : '');
    return InkWell(
      onTap: () {/* tx detail */},
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: GeniusWalletConsts.space6,
          vertical: GeniusWalletConsts.space4,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: GeniusWalletColors.surfaceElevated,
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Icon(
                isReceived
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                size: 16,
                color: isReceived
                    ? GeniusWalletColors.brandSecondary
                    : GeniusWalletColors.textPrimary,
              ),
            ),
            const SizedBox(width: GeniusWalletConsts.space6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isReceived ? 'Received' : 'Sent',
                    style: GeniusWalletTypography.titleMd,
                  ),
                  Text(
                    counterparty.isEmpty
                        ? _relative(tx.timeStamp)
                        : '$counterparty · ${_relative(tx.timeStamp)}',
                    style: GeniusWalletTypography.bodySm,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isReceived ? '+' : '−'}$amount',
                  style: GeniusWalletTypography.numericBody.copyWith(
                    fontSize: 15,
                    color: isReceived
                        ? GeniusWalletColors.brandSecondary
                        : GeniusWalletColors.textPrimary,
                  ),
                ),
                Text(tx.coinSymbol, style: GeniusWalletTypography.bodySm),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _short(String addr) => addr.length > 10
      ? '${addr.substring(0, 6)}…${addr.substring(addr.length - 4)}'
      : addr;

  String _relative(DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat.MMMd().format(ts);
  }
}

// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space8,
        vertical: GeniusWalletConsts.space16,
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: GeniusWalletColors.textSecondary),
          const SizedBox(height: GeniusWalletConsts.space4),
          Text(title, style: GeniusWalletTypography.titleMd),
          const SizedBox(height: GeniusWalletConsts.space2),
          Text(
            subtitle,
            style: GeniusWalletTypography.bodySm,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
