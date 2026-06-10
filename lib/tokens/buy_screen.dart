import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/preferences/gw_currency.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/utils/image_utils.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';

/// Buy flow — purchase tokens with a credit / debit card: enter a fiat
/// amount, pick the token, review, confirm.
///
/// The confirm is a demo (toast + back to dashboard); wire it to the real
/// on-ramp (Banxa) for live quotes + checkout — see HANDOFF.md §6.
class BuyScreen extends StatefulWidget {
  const BuyScreen({super.key, this.initialCoin});

  /// Pre-selected token (e.g. when opened from a token detail).
  final Coin? initialCoin;

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  final TextEditingController _amount = TextEditingController();
  Coin? _coin;

  static const _quickAmounts = [50, 100, 250];

  @override
  void initState() {
    super.initState();
    _coin = widget.initialCoin;
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
      builder: (context, state) {
        final coins = state.coins;
        final coin = _coin ??
            state.selectedCoin ??
            (coins.isNotEmpty ? coins.first : null);
        final amount = double.tryParse(_amount.text.trim()) ?? 0;
        final valid = amount > 0 && coin != null;
        final symbol = GWCurrency.symbol.trim();

        return GWCanvasBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: const Text('Buy'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(GeniusWalletConsts.space6),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ----- you pay -----
                        Text('You pay',
                            style: GeniusWalletTypography.labelMd.copyWith(
                                color: GeniusWalletColors.textSecondary)),
                        const SizedBox(height: GeniusWalletConsts.space4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: GeniusWalletConsts.space8,
                            vertical: GeniusWalletConsts.space6,
                          ),
                          decoration: GWDecorations.surface(
                              radius: GeniusWalletConsts.radiusLg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(symbol,
                                      style: GeniusWalletTypography
                                          .numericHeadline
                                          .copyWith(
                                              fontSize: 28,
                                              color: GeniusWalletColors
                                                  .textSecondary)),
                                  const SizedBox(
                                      width: GeniusWalletConsts.space4),
                                  Expanded(
                                    child: TextField(
                                      controller: _amount,
                                      onChanged: (_) => setState(() {}),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      style: GeniusWalletTypography
                                          .numericHeadline
                                          .copyWith(fontSize: 28),
                                      cursorColor:
                                          GeniusWalletColors.brandPrimary,
                                      decoration: InputDecoration(
                                        isCollapsed: true,
                                        border: InputBorder.none,
                                        hintText: '0',
                                        hintStyle: GeniusWalletTypography
                                            .numericHeadline
                                            .copyWith(
                                                fontSize: 28,
                                                color: GeniusWalletColors
                                                    .textPrimary38),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: GeniusWalletConsts.space6),
                              Row(
                                children: [
                                  for (final q in _quickAmounts) ...[
                                    GWButton(
                                      label: '$symbol$q',
                                      variant: GWButtonVariant.tertiary,
                                      size: GWButtonSize.sm,
                                      onPressed: () {
                                        _amount.text = '$q';
                                        setState(() {});
                                      },
                                    ),
                                    const SizedBox(
                                        width: GeniusWalletConsts.space4),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: GeniusWalletConsts.space10),

                        // ----- you receive -----
                        Text('You receive',
                            style: GeniusWalletTypography.labelMd.copyWith(
                                color: GeniusWalletColors.textSecondary)),
                        const SizedBox(height: GeniusWalletConsts.space4),
                        _TokenSelector(
                          coin: coin,
                          onTap: coins.length > 1
                              ? () => _pickToken(context, coins)
                              : null,
                        ),
                        const SizedBox(height: GeniusWalletConsts.space10),

                        // ----- payment method -----
                        Text('Payment method',
                            style: GeniusWalletTypography.labelMd.copyWith(
                                color: GeniusWalletColors.textSecondary)),
                        const SizedBox(height: GeniusWalletConsts.space4),
                        Container(
                          padding:
                              const EdgeInsets.all(GeniusWalletConsts.space6),
                          decoration: GWDecorations.surface(
                              radius: GeniusWalletConsts.radiusLg),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: GeniusWalletColors.brandPrimary
                                      .withAlpha(31),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.credit_card_rounded,
                                    size: 20,
                                    color: GeniusWalletColors.brandPrimary),
                              ),
                              const SizedBox(width: GeniusWalletConsts.space6),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Credit / Debit Card',
                                        style: GeniusWalletTypography.titleMd),
                                    Text('Visa · Mastercard',
                                        style: GeniusWalletTypography.bodySm
                                            .copyWith(
                                                color: GeniusWalletColors
                                                    .textSecondary)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.check_circle_rounded,
                                  size: 20,
                                  color: GeniusWalletColors.brandPrimary),
                            ],
                          ),
                        ),
                        const SizedBox(height: GeniusWalletConsts.space6),
                        Text(
                          'Final quote and fees are shown at checkout.',
                          textAlign: TextAlign.center,
                          style: GeniusWalletTypography.bodySm.copyWith(
                              color: GeniusWalletColors.textSecondary),
                        ),
                        const SizedBox(height: GeniusWalletConsts.space16),

                        // ----- CTA -----
                        GWButton(
                          label: 'Buy now',
                          variant: GWButtonVariant.gradient,
                          size: GWButtonSize.lg,
                          expand: true,
                          onPressed: valid
                              ? () => _review(context, coin, amount)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _pickToken(BuildContext context, List<Coin> coins) {
    ResponsiveDrawer.show<void>(
      context: context,
      title: 'Select token',
      children: [
        for (final c in coins)
          ListTile(
            onTap: () {
              setState(() => _coin = c);
              Navigator.of(context).pop();
            },
            leading: SizedBox(
              width: 36,
              height: 36,
              child: buildTokenIcon(iconPath: c.iconPath ?? '', size: 36),
            ),
            title: Text(c.name ?? c.symbol ?? 'Token',
                style: GeniusWalletTypography.titleMd),
            subtitle: Text(c.symbol ?? '',
                style: GeniusWalletTypography.bodySm
                    .copyWith(color: GeniusWalletColors.textSecondary)),
          ),
      ],
    );
  }

  void _review(BuildContext context, Coin coin, double amount) {
    final symbol = GWCurrency.symbol.trim();
    ResponsiveDrawer.show<void>(
      context: context,
      title: 'Review purchase',
      children: [
        const SizedBox(height: GeniusWalletConsts.space4),
        _SummaryRow('Token', '${coin.name ?? coin.symbol}'),
        _SummaryRow('You pay', '$symbol${amount.toStringAsFixed(2)}'),
        const _SummaryRow('Payment method', 'Credit / Debit Card'),
        const _SummaryRow('Quote', 'Shown at checkout'),
        const SizedBox(height: GeniusWalletConsts.space8),
        GWButton(
          label: 'Confirm purchase',
          variant: GWButtonVariant.gradient,
          size: GWButtonSize.lg,
          expand: true,
          onPressed: () {
            Navigator.of(context).pop(); // close review sheet
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Purchase submitted (demo)'),
                backgroundColor: GeniusWalletColors.surfaceMenu,
              ),
            );
            if (context.mounted) context.go('/dashboard');
          },
        ),
        const SizedBox(height: GeniusWalletConsts.space4),
      ],
    );
  }
}

class _TokenSelector extends StatelessWidget {
  const _TokenSelector({required this.coin, this.onTap});
  final Coin? coin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusLg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(GeniusWalletConsts.space6),
          decoration:
              GWDecorations.surface(radius: GeniusWalletConsts.radiusLg),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: buildTokenIcon(iconPath: coin?.iconPath ?? '', size: 36),
              ),
              const SizedBox(width: GeniusWalletConsts.space6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(coin?.name ?? coin?.symbol ?? 'Select token',
                        style: GeniusWalletTypography.titleMd,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(coin?.symbol ?? '',
                        style: GeniusWalletTypography.bodySm
                            .copyWith(color: GeniusWalletColors.textSecondary)),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.keyboard_arrow_down_rounded,
                    color: GeniusWalletColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: GeniusWalletConsts.space4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GeniusWalletTypography.bodyMd
                  .copyWith(color: GeniusWalletColors.textSecondary)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: GeniusWalletTypography.numericBody,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
