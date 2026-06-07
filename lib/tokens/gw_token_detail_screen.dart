import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/components/qr/crypto_address_qr.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/utils/image_utils.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Trust-Wallet-style per-token detail page: token header, balance, and a
/// per-token action row (Receive / Send / Swap / Buy). Lightweight on
/// purpose — takes just a [Coin]; the heavier market-data view
/// (`TokenInfoScreen`) stays on the markets flow.
class GWTokenDetailScreen extends StatelessWidget {
  const GWTokenDetailScreen({super.key, required this.coin});

  final Coin coin;

  String get _symbol => coin.symbol ?? '?';
  String get _name => coin.name ?? _symbol;

  @override
  Widget build(BuildContext context) {
    final balance = coin.balance ?? 0;
    return Scaffold(
      backgroundColor: GeniusWalletColors.surfaceBase,
      appBar: AppBar(
        backgroundColor: GeniusWalletColors.surfaceBase,
        elevation: 0,
        title: Text(_name, style: GeniusWalletTypography.headlineMd),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.symmetric(
                  vertical: GeniusWalletConsts.space8),
              children: [
                _Header(coin: coin, symbol: _symbol, name: _name),
                const SizedBox(height: GeniusWalletConsts.space6),
                _Balance(balance: balance, symbol: _symbol),
                const SizedBox(height: GeniusWalletConsts.space12),
                _ActionRow(coin: coin),
                const SizedBox(height: GeniusWalletConsts.space16),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: GeniusWalletConsts.space6),
                  child: Text('Activity',
                      style: GeniusWalletTypography.titleLg),
                ),
                const SizedBox(height: GeniusWalletConsts.space6),
                // Per-token activity filtering lands in Phase C2; the global
                // Activity tab already lists all transactions for now.
                GWEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No $_symbol activity yet',
                  message:
                      'Sends, receives and swaps for $_symbol will show here.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.coin, required this.symbol, required this.name});
  final Coin coin;
  final String symbol;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: (coin.iconPath ?? '').isNotEmpty
              ? buildTokenIcon(iconPath: coin.iconPath!, size: 64)
              : _LetterAvatar(letter: symbol.characters.first),
        ),
        const SizedBox(height: GeniusWalletConsts.space4),
        Text(symbol,
            style: GeniusWalletTypography.bodyMd
                .copyWith(color: GeniusWalletColors.textSecondary)),
      ],
    );
  }
}

class _LetterAvatar extends StatelessWidget {
  const _LetterAvatar({required this.letter});
  final String letter;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: GeniusWalletColors.surfaceElevated,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(letter,
          style: GeniusWalletTypography.headlineMd
              .copyWith(color: GeniusWalletColors.textPrimary)),
    );
  }
}

class _Balance extends StatelessWidget {
  const _Balance({required this.balance, required this.symbol});
  final double balance;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat.decimalPatternDigits(
            decimalDigits: balance < 1 ? 6 : 4)
        .format(balance);
    return Column(
      children: [
        Text(formatted, style: GeniusWalletTypography.numericDisplay),
        Text(symbol,
            style: GeniusWalletTypography.bodyMd
                .copyWith(color: GeniusWalletColors.textSecondary)),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.coin});
  final Coin coin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: GeniusWalletConsts.space6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TokenAction(
            icon: Icons.arrow_downward_rounded,
            label: 'Receive',
            onTap: () => _receive(context),
          ),
          _TokenAction(
            icon: Icons.arrow_upward_rounded,
            label: 'Send',
            onTap: () => _stub(context, 'Send'),
          ),
          _TokenAction(
            icon: Icons.swap_vert_rounded,
            label: 'Swap',
            onTap: () => context.push('/swap'),
          ),
          _TokenAction(
            icon: Icons.add_card_rounded,
            label: 'Buy',
            onTap: () => context.push('/createOrder'),
          ),
        ],
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
    final state = context.read<WalletDetailsCubit>().state;
    ResponsiveDrawer.show<void>(
      context: context,
      title: 'Receive ${coin.name ?? coin.symbol ?? ''}',
      children: [
        Padding(
          padding: const EdgeInsets.all(GeniusWalletConsts.space10),
          child: Center(
            child: CryptoAddressQR(
              iconPath: coin.iconPath,
              address: state.selectedWallet?.address ?? '',
              network: state.selectedNetwork?.name ?? '',
            ),
          ),
        ),
      ],
    );
  }
}

class _TokenAction extends StatelessWidget {
  const _TokenAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radius2xl),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: GeniusWalletConsts.space2,
              vertical: GeniusWalletConsts.space2),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: GeniusWalletColors.surfaceElevated,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon,
                    size: 22, color: GeniusWalletColors.brandPrimary),
              ),
              const SizedBox(height: GeniusWalletConsts.space2),
              Text(label,
                  style: GeniusWalletTypography.labelMd
                      .copyWith(color: GeniusWalletColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
