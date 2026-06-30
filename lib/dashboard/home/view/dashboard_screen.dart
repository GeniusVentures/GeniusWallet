import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/data/gw_animated_number.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/components/loading/gw_spinner.dart';
import 'package:genius_wallet/preferences/gw_currency.dart';
import 'package:genius_wallet/utils/image_utils.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_elevation.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Clean, mobile-first dashboard. Solid dark canvas, big centered hero
/// balance, pill-shaped action row, segmented Assets / NFTs tabs and flat
/// list rows separated by hairline dividers. Inspired by Phantom / Coinbase
/// Wallet's restrained chrome. (Activity lives in its own bottom-nav tab.)
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  _DashboardTab _tab = _DashboardTab.assets;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

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
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Coin> _filterCoins(List<Coin> coins) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return coins;
    return coins.where((c) {
      final name = (c.name ?? '').toLowerCase();
      final symbol = (c.symbol ?? '').toLowerCase();
      return name.contains(q) || symbol.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
                            walletAddress: walletState.selectedWallet?.address,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _Tabs(
                            value: _tab,
                            onChanged: (t) => setState(() => _tab = t),
                          ),
                        ),
                        if (_tab == _DashboardTab.assets) ...[
                          SliverToBoxAdapter(
                            child: _AssetSearch(
                              controller: _searchCtrl,
                              onChanged: (v) => setState(() => _query = v),
                            ),
                          ),
                          _AssetsSliver(
                            coins: _filterCoins(walletState.coins),
                            query: _query,
                          ),
                        ] else
                          const _NftsSliver(),
                        // Clearance so the global Swap FAB (bottom-right)
                        // doesn't cover the last list row.
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 96),
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

enum _DashboardTab { assets, nfts }

// ---------------------------------------------------------------------------

class _HeroBalance extends StatelessWidget {
  const _HeroBalance({required this.balance});
  final double balance;

  @override
  Widget build(BuildContext context) {
    // WIRE-9 (see WIRING.md): mock 24h delta — replace `balance * 0.024` with a
    // real 24h price-change source (per-asset change, aggregated).
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
          Stack(
            alignment: Alignment.center,
            children: [
              // Soft cyan→mint aura behind the balance — a quiet hero moment.
              IgnorePointer(
                child: Container(
                  width: 220,
                  height: 48,
                  decoration: GWDecorations.heroGlow,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: GWAnimatedNumber(
                  value: balance,
                  // Display-only currency symbol — values stay USD-priced
                  // until FX conversion is wired (HANDOFF.md §6).
                  prefix: GWCurrency.symbol,
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
            ],
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
                '${positive ? '+' : '−'}${GWCurrency.symbol}${delta.abs().toStringAsFixed(2)}',
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
        onTap: () => context.push('/send'),
      ),
      _PillAction(
        icon: Icons.arrow_downward_rounded,
        label: 'Receive',
        onTap: () => _receive(context),
      ),
      // Swap deliberately absent here — the global Swap FAB covers it.
      _PillAction(
        icon: Icons.compare_arrows_rounded,
        label: 'Bridge',
        onTap: () => context.push('/bridge'),
      ),
      // Buy = the row's primary CTA, so it carries the brand gradient.
      // Opens the credit-card purchase flow (demo confirm — HANDOFF.md §6).
      _PillAction(
        icon: Icons.add_rounded,
        label: 'Buy',
        highlight: true,
        onTap: () => context.push('/buy-tokens'),
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
    this.highlight = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  /// Brand-gradient treatment for the row's primary CTA (Buy).
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: highlight
              ? BoxDecoration(
                  gradient: GeniusWalletGradient.brandCta,
                  shape: BoxShape.circle,
                  boxShadow: [
                    ...GeniusWalletElevation.card,
                    BoxShadow(
                      color: GeniusWalletColors.brandPrimary.withAlpha(64),
                      blurRadius: 18,
                    ),
                  ],
                )
              : GWDecorations.actionCircle(),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: Center(
                child: Icon(
                  icon,
                  size: 22,
                  color: highlight
                      ? GeniusWalletColors.textOnBrand
                      : GeniusWalletColors.brandPrimary,
                ),
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
        height: 48, // was 36 — Material touch target for the Assets/NFTs tabs
        // Recessed track — sits a layer below the canvas in both modes, so
        // the raised thumb reads as a physical slider.
        decoration: BoxDecoration(
          color: GeniusWalletColors.surfaceSunken,
          borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
          border: Border.all(color: GeniusWalletColors.borderSubtle, width: 1),
        ),
        child: Row(
          children: [
            Expanded(child: _tab(context, _DashboardTab.assets, 'Assets')),
            Expanded(child: _tab(context, _DashboardTab.nfts, 'NFTs')),
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
          // Raised thumb: top-lit sheen + hairline + soft shadow so the
          // active segment pops off the recessed track in both modes.
          gradient: selected ? GWDecorations.surfaceSheen : null,
          borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
          border: selected
              ? Border.all(color: GeniusWalletColors.borderSubtle, width: 1)
              : null,
          boxShadow: selected ? GeniusWalletElevation.card : null,
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
  const _AssetsSliver({required this.coins, this.query = ''});
  final List<Coin> coins;
  final String query;

  @override
  Widget build(BuildContext context) {
    if (coins.isEmpty) {
      // Distinguish "no results for a search" from "no assets at all".
      if (query.trim().isNotEmpty) {
        return SliverToBoxAdapter(
          child: _EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No tokens match "$query"',
            subtitle: 'Try a different name or symbol.',
          ),
        );
      }
      return const SliverToBoxAdapter(
        child: _EmptyState(
          icon: Icons.account_balance_wallet_outlined,
          title: 'No assets yet',
          subtitle: 'Buy or receive your first token to get started.',
        ),
      );
    }
    return SliverPadding(
      padding:
          const EdgeInsets.symmetric(horizontal: GeniusWalletConsts.space6),
      sliver: DecoratedSliver(
        decoration: GWDecorations.surface(radius: GeniusWalletConsts.radius2xl),
        sliver: SliverPadding(
          padding:
              const EdgeInsets.symmetric(vertical: GeniusWalletConsts.space4),
          sliver: SliverList.separated(
            itemCount: coins.length,
            separatorBuilder: (_, __) => const _RowDivider(),
            itemBuilder: (_, i) => _CoinRow(coin: coins[i]),
          ),
        ),
      ),
    );
  }
}

class _AssetSearch extends StatelessWidget {
  const _AssetSearch({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        GeniusWalletConsts.space6,
        GeniusWalletConsts.space2,
        GeniusWalletConsts.space6,
        GeniusWalletConsts.space4,
      ),
      // Card shadow behind the field so it separates from the open canvas
      // (matches the asset list's elevated surface).
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusLg),
          boxShadow: GeniusWalletElevation.card,
        ),
        child: GWTextField(
          controller: controller,
          hint: 'Filter your assets',
          onChanged: onChanged,
          prefix: const Icon(
            Icons.search_rounded,
            size: 20,
            color: GeniusWalletColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _NftsSliver extends StatelessWidget {
  const _NftsSliver();

  // Placeholder collectibles so the NFT grid is reviewable in the redesign.
  // WIRE-8 (see WIRING.md): replace `_items` with a real NFT source (cubit/
  // provider) and render the NFT image instead of the gradient placeholder.
  static const _items = <_Nft>[
    _Nft('Genius Mind #1024', 'Genius Originals'),
    _Nft('Aurora Key #07', 'Aurora Keys'),
    _Nft('Pixel Spirit #318', 'Pixel Spirits'),
    _Nft('Cosmic Drop #55', 'Cosmic Drops'),
    _Nft('Mecha Unit #09', 'Mecha Units'),
    _Nft('Ancient Glyph #220', 'Glyphs'),
  ];

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        GeniusWalletConsts.space6,
        GeniusWalletConsts.space2,
        GeniusWalletConsts.space6,
        0,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: GeniusWalletConsts.space6,
          crossAxisSpacing: GeniusWalletConsts.space6,
          childAspectRatio: 0.80,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) => _NftTile(nft: _items[i], seed: i),
          childCount: _items.length,
        ),
      ),
    );
  }
}

class _Nft {
  const _Nft(this.name, this.collection);
  final String name;
  final String collection;
}

class _NftTile extends StatelessWidget {
  const _NftTile({required this.nft, required this.seed});
  final _Nft nft;
  final int seed;

  static const _arts = <List<Color>>[
    [GeniusWalletColors.brandPrimary, GeniusWalletColors.brandSecondary],
    [GeniusWalletColors.brandTertiary, GeniusWalletColors.brandPrimary],
    [GeniusWalletColors.brandSecondary, GeniusWalletColors.brandTertiary],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = _arts[seed % _arts.length];
    return Container(
      decoration: GWDecorations.surface(radius: GeniusWalletConsts.radius2xl),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radius2xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Placeholder art — replace with the NFT image.
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.auto_awesome_outlined,
                    color: GeniusWalletColors.textPrimary70,
                    size: 30,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(GeniusWalletConsts.space6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nft.name,
                    style: GeniusWalletTypography.titleMd,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: GeniusWalletConsts.space2),
                  Text(
                    nft.collection,
                    style: GeniusWalletTypography.bodySm.copyWith(
                      color: GeniusWalletColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
      // Route to the canonical token detail (same screen the markets / coins
      // lists use) so a token opens consistently from anywhere.
      onTap: () {
        context.read<WalletDetailsCubit>().selectCoin(coin);
        context.push('/token-info', extra: {
          "isGnusWalletConnected": false,
          // WIRE-11 (see WIRING.md): placeholder — wire real security info + history.
          "securityInfo": "Coming Soon",
          "transactionHistory": ["Coming Soon"],
          "marketData": null,
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: GeniusWalletConsts.space6,
          vertical: GeniusWalletConsts.space4,
        ),
        child: Row(
          children: [
            // Real token icon when available; letter avatar as fallback.
            (coin.iconPath ?? '').isNotEmpty
                ? SizedBox(
                    width: 36,
                    height: 36,
                    child: buildTokenIcon(iconPath: coin.iconPath!, size: 36),
                  )
                : _RowIcon(letter: symbol.characters.first),
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
            // Right side: holding amount only. The ticker already appears under
            // the name on the left, so it isn't repeated here.
            Text(
              _formatNumber(balance),
              style: GeniusWalletTypography.numericBody,
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
