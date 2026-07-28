import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_section_title.dart';
import 'package:genius_wallet/components/coins/assets_totals.dart';
import 'package:genius_wallet/components/coins/view/coin_card_row.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/components/qr/crypto_address_qr.dart';
import 'package:genius_wallet/dev/dev_mock_holdings.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CoinsScreen extends StatefulWidget {
  final Function(Coin)? onCoinSelected;
  final List<Coin?>? filterCoins;
  final bool? isUseDivider;
  final bool? isGnusWalletConnected;

  const CoinsScreen({
    super.key,
    this.onCoinSelected,
    this.filterCoins,
    this.isGnusWalletConnected,
    this.isUseDivider,
  });

  @override
  CoinsScreenState createState() => CoinsScreenState();
}

class CoinsScreenState extends State<CoinsScreen> {
  Map<String, CoinGeckoMarketData?> _marketData = {};
  bool _isFetchingMarketData = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    // periodically fetch market data to keep wallet balance up to date
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final state = context.read<WalletDetailsCubit>().state;
      if (state.coinsStatus == WalletStatus.successful &&
          state.coins.isNotEmpty) {
        _fetchMarketData(state.coins);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchMarketData(List<Coin> coins) async {
    // DEV-ONLY: while mock-mode is ON, skip the network entirely and feed
    // rows the seeded offline prices instead. This also no-ops the 1-min
    // refresh timer and the BlocListener's successful-branch fetch, and
    // skips _calculateTotalValue (the balance is already set by
    // injectMockCoins).
    if (kDebugMode && context.read<WalletDetailsCubit>().mockMode) {
      setState(() {
        _marketData = DevMockHoldings.instance.marketData;
        _isFetchingMarketData = false;
      });
      return;
    }

    if (_isFetchingMarketData || coins.isEmpty) {
      return;
    }
    setState(() => _isFetchingMarketData = true);

    final coinGeckoCoinsList = await fetchAllCoinGeckoCoins();

    List<String> coinGeckoIds = coins
        .map((walletCoin) {
          // if there is a coin gecko id set use that instead of trying to match ( trying to match can have issues as symbols are not unique and the names may not match )
          if (walletCoin.coinGeckoId != null) {
            return walletCoin.coinGeckoId!;
          }
          final matchingCoin = coinGeckoCoinsList.firstWhere(
            (coin) =>
                coin.symbol.toLowerCase() == walletCoin.symbol?.toLowerCase(),
            orElse: () =>
                CoinGeckoCoin(id: '', symbol: '', name: 'Unknown Token'),
          );
          return matchingCoin.id.isNotEmpty ? matchingCoin.id : null;
        })
        .whereType<String>()
        .toList();

    if (coinGeckoIds.isNotEmpty) {
      final marketData = await fetchCoinsMarketData(coinIds: coinGeckoIds);

      if (!mounted) {
        return;
      }

      setState(() {
        _marketData = marketData;
        _isFetchingMarketData = false;
      });

      _calculateTotalValue(coins);
    } else {
      setState(() => _isFetchingMarketData = false);
    }
  }

  void _calculateTotalValue(List<Coin> coins) {
    final totalValue = assetsTotal(_valueHoldings(coins));
    final formattedTotal = totalValue.toStringAsFixed(2);

    context.read<WalletDetailsCubit>().setSelectedWalletBalance(formattedTotal);
  }

  /// Builds the (balance, price) records the totals helper folds over, keyed
  /// by `coin.symbol?.toLowerCase()` — the same key `_fetchMarketData` writes.
  List<({double balance, double price})> _valueHoldings(List<Coin> coins) {
    final holdings = <({double balance, double price})>[];
    for (final coin in coins) {
      final marketData = _marketData[coin.symbol?.toLowerCase()];
      if (marketData != null) {
        holdings.add((
          balance: coin.balance ?? 0.0,
          price: marketData.currentPrice,
        ));
      }
    }
    return holdings;
  }

  /// The pct-carrying variant used by the header's 24h-change subline.
  List<({double balance, double price, double pct})> _changeHoldings(
    List<Coin> coins,
  ) {
    final holdings = <({double balance, double price, double pct})>[];
    for (final coin in coins) {
      final marketData = _marketData[coin.symbol?.toLowerCase()];
      if (marketData != null) {
        holdings.add((
          balance: coin.balance ?? 0.0,
          price: marketData.currentPrice,
          pct: marketData.priceChangePercentage24h,
        ));
      }
    }
    return holdings;
  }

  /// Opens the address-QR receive drawer for the empty-wallet footer.
  ///
  /// ponytail: there is no dedicated `/receive` route in router.dart — the
  /// receive UI is the reusable [CryptoAddressQR] shown in a [ResponsiveDrawer].
  /// Ceiling: no send-flow deep-link / amount request. Upgrade path: a proper
  /// `/receive` screen if receive grows beyond "show my address".
  void _showReceive(WalletDetailsState state) {
    final address = state.selectedWallet?.address;
    if (address == null || address.isEmpty) {
      return;
    }
    ResponsiveDrawer.show<void>(
      context: context,
      title: 'Receive',
      child: CryptoAddressQR(
        address: address,
        network:
            state.selectedNetwork?.name ?? state.selectedNetwork?.symbol ?? '',
        iconPath: state.selectedNetwork?.iconPath,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletDetailsCubit, WalletDetailsState>(
      listener: (context, state) {
        final walletCubit = context.read<WalletDetailsCubit>();

        if (state.coinsStatus == WalletStatus.initial &&
            state.selectedNetwork != null) {
          walletCubit.getCoins();
        }

        if (state.coinsStatus == WalletStatus.successful) {
          _fetchMarketData(state.coins);
        }
      },
      child: BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
        builder: (context, state) {
          final walletCubit = context.read<WalletDetailsCubit>();

          // Fail-soft read: registers the InheritedWidget dependency that
          // forces this subtree to rebuild on a live appearance toggle.
          final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

          if (state.coinsStatus == WalletStatus.loading) {
            return Container(
              decoration: GWDecorations.surface(border: gw.borderSubtle),
              child: const Center(child: Loading()),
            );
          }

          if (state.coins.isEmpty) {
            return const GWEmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No coins yet',
              message:
                  'Your holdings will appear here once you receive a token.',
            );
          }

          final filteredCoins = state.coins
              .where(
                (coin) =>
                    widget.filterCoins?.contains(coin) == false ||
                    widget.filterCoins == null,
              )
              .toList();

          // Display order: float the Genius token (GNUS) to the top, keep the
          // rest in their fetched order. Stable (partition, not List.sort which
          // Dart does not guarantee stable). Scoped to display — read_asset's
          // native-first fetch order is unchanged for every other consumer.
          final orderedCoins = [
            ...filteredCoins.where((c) => c.symbol?.toUpperCase() == 'GNUS'),
            ...filteredCoins.where((c) => c.symbol?.toUpperCase() != 'GNUS'),
          ];

          // Dashboard-only chrome (header + empty-wallet footer). A future
          // coin-picker reuse passes onCoinSelected and gets the bare list.
          final bool isDashboard = widget.onCoinSelected == null;
          final currencyFormatter = NumberFormat.currency(symbol: "\$");
          final double total = assetsTotal(_valueHoldings(state.coins));
          final double dayChange = assetsDayChange(
            _changeHoldings(state.coins),
          );
          final double pctOfTotal = total == 0 ? 0 : dayChange / total * 100;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Assets header — now the shared GWSectionTitle (18px, space4
                // inset, space8 gap). The component reserves the shared header
                // min-height for every panel, so this call site no longer sets
                // its own; the center-aligned end-column keeps the total
                // vertically centered and two-line-stable across empty ($0.00)
                // and funded states.
                if (isDashboard)
                  GWSectionTitle(
                    title: 'Assets',
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currencyFormatter.format(total),
                          style: GeniusWalletTypography.numericBody.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: gw.textPrimary,
                          ),
                        ),
                        if (total > 0)
                          Text(
                            '${dayChange >= 0 ? '+' : ''}${currencyFormatter.format(dayChange)} · ${dayChange >= 0 ? '+' : ''}${pctOfTotal.toStringAsFixed(2)}%',
                            style: GeniusWalletTypography.labelMd.copyWith(
                              color: dayChange >= 0
                                  ? gw.statusSuccess
                                  : gw.statusError,
                            ),
                          ),
                      ],
                    ),
                  ),
                for (int i = 0; i < orderedCoins.length; i++) ...[
                  CoinCardRow(
                    onTap: () {
                      final coin = orderedCoins[i];
                      if (widget.onCoinSelected != null) {
                        widget.onCoinSelected!(coin);
                      } else {
                        walletCubit.selectCoin(coin);
                        context.push(
                          '/token-info',
                          extra: {
                            "isGnusWalletConnected":
                                widget.isGnusWalletConnected,
                            "marketData":
                                _marketData[coin.symbol?.toLowerCase()],
                          },
                        );
                      }
                    },
                    iconPath: orderedCoins[i].iconPath ?? "",
                    balance: orderedCoins[i].balance ?? 0.0,
                    name: orderedCoins[i].name ?? "",
                    symbol: orderedCoins[i].symbol ?? "",
                    marketData:
                        _marketData[orderedCoins[i].symbol?.toLowerCase()],
                  ),
                  if ((isDashboard || (widget.isUseDivider ?? false)) &&
                      i < orderedCoins.length - 1)
                    Divider(height: 1, thickness: 1, color: gw.borderSubtle),
                ],
                // Value-empty footer: the truly-no-coins case is handled above
                // by the state.coins.isEmpty -> GWEmptyState branch; this strip
                // covers a wallet that HAS coins but holds no value (total==0).
                if (isDashboard && total == 0)
                  Padding(
                    // top space8 mirrors the header's bottom space8 so the gap
                    // above the CTAs matches the Assets→first-row gap.
                    padding: const EdgeInsets.only(
                      top: GeniusWalletConsts.space8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GWButton(
                            variant: GWButtonVariant.gradientOutline,
                            size: GWButtonSize.sm,
                            label: 'Receive',
                            expand: true,
                            onPressed: () => _showReceive(state),
                          ),
                        ),
                        const SizedBox(width: GeniusWalletConsts.space4),
                        Expanded(
                          child: GWButton(
                            // Full brand-CTA gradient (#0AD89C→#0AAEE6) — the
                            // GNUS-logo gradient the walk picked, replacing the
                            // flat neon #14C8FF primary fill.
                            variant: GWButtonVariant.gradient,
                            size: GWButtonSize.sm,
                            label: 'Buy GNUS',
                            expand: true,
                            onPressed: () => context.push('/buy'),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
