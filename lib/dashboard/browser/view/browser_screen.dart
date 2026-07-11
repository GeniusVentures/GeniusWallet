import 'package:flutter/material.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/dashboard/browser/services/browser_storage.dart';
import 'package:genius_wallet/navigation/web_view_extras.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Curated DApp launcher with favourites + recent history.
///
/// - URL bar at the top: tap to focus → shows last 5 visited URLs instead of
///   the Featured/Popular grid. Empty focus shows the grid.
/// - Favourites section: only rendered when the user has saved at least one
///   dApp. Tap the bookmark icon on a tile to add/remove.
/// - Popular section: hard-coded curated list. Each tile can also be
///   favourited.
class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  final TextEditingController _urlCtrl = TextEditingController();
  final FocusNode _urlFocus = FocusNode();
  bool _searchActive = false;

  @override
  void initState() {
    super.initState();
    _urlFocus.addListener(() {
      if (_urlFocus.hasFocus != _searchActive) {
        setState(() => _searchActive = _urlFocus.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _urlFocus.dispose();
    super.dispose();
  }

  void _open(String url, {String? recordName}) {
    final normalized = _normalizeUrl(url);
    context.read<BrowserStorage>().recordVisit(normalized);
    _urlFocus.unfocus();
    context.push(
      '/web',
      extra: WebViewExtras(url: normalized, includeBackButton: true),
    );
  }

  String _normalizeUrl(String raw) {
    var trimmed = raw.trim();
    if (trimmed.isEmpty) return trimmed;
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      trimmed = 'https://$trimmed';
    }
    return trimmed;
  }

  void _openTyped() {
    final raw = _urlCtrl.text.trim();
    if (raw.isEmpty) return;
    _open(raw);
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<BrowserStorage>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              // Bottom clearance so the floating Swap FAB doesn't cover the
              // last dApp tiles.
              padding: const EdgeInsets.fromLTRB(
                GeniusWalletConsts.space6,
                GeniusWalletConsts.space4,
                GeniusWalletConsts.space6,
                90,
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                Text('Discover', style: GeniusWalletTypography.headlineLg),
                const SizedBox(height: GeniusWalletConsts.space2),
                Text(
                  'Connect to any DeFi app from your wallet.',
                  style: GeniusWalletTypography.bodySm,
                ),
                const SizedBox(height: GeniusWalletConsts.space8),
                _UrlBar(
                  controller: _urlCtrl,
                  focusNode: _urlFocus,
                  onSubmit: _openTyped,
                ),
                const SizedBox(height: GeniusWalletConsts.space10),
                if (_searchActive)
                  _RecentList(
                    urls: storage.recent,
                    onTap: _open,
                    onClear: storage.recent.isEmpty
                        ? null
                        : () => storage.clearRecent(),
                  )
                else ...[
                  if (storage.favorites.isNotEmpty) ...[
                    _SectionHeader(title: 'Favorites'),
                    const SizedBox(height: GeniusWalletConsts.space4),
                    _FavoritesList(
                      favorites: storage.favorites,
                      onTap: (f) => _open(f.url),
                      onRemove: (f) => storage.removeFavorite(f.url),
                    ),
                    const SizedBox(height: GeniusWalletConsts.space12),
                  ],
                  _SectionHeader(title: 'Popular DeFi'),
                  const SizedBox(height: GeniusWalletConsts.space4),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: GeniusWalletConsts.space2,
                    crossAxisSpacing: GeniusWalletConsts.space2,
                    childAspectRatio: 2.4,
                    children: _popular
                        .map(
                          (a) => _DappTile(
                            app: a,
                            isFavorite: storage.isFavorite(a.url),
                            onTap: () => _open(a.url),
                            onToggleFavorite: () => storage.toggleFavorite(
                              name: a.name,
                              url: a.url,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _DApp {
  const _DApp({
    required this.name,
    required this.tagline,
    required this.url,
    required this.icon,
    required this.color,
  });
  final String name;
  final String tagline;
  final String url;
  final IconData icon;
  final Color color;
}

const _popular = <_DApp>[
  _DApp(
    name: 'Uniswap',
    tagline: 'Largest DEX',
    url: 'https://app.uniswap.org',
    icon: Icons.swap_horiz_rounded,
    color: Color(0xFFFF007A),
  ),
  _DApp(
    name: 'Aave',
    tagline: 'Lend & borrow',
    url: 'https://app.aave.com',
    icon: Icons.account_balance_rounded,
    color: Color(0xFFB6509E),
  ),
  _DApp(
    name: 'Curve',
    tagline: 'Stable swaps',
    url: 'https://curve.fi',
    icon: Icons.show_chart_rounded,
    color: Color(0xFFA663F4),
  ),
  _DApp(
    name: '1inch',
    tagline: 'DEX aggregator',
    url: 'https://app.1inch.io',
    icon: Icons.hub_rounded,
    color: Color(0xFF94A6C3),
  ),
  _DApp(
    name: 'Lido',
    tagline: 'Liquid staking',
    url: 'https://stake.lido.fi',
    icon: Icons.bolt_rounded,
    color: Color(0xFF00A3FF),
  ),
  _DApp(
    name: 'Compound',
    tagline: 'Lending protocol',
    url: 'https://app.compound.finance',
    icon: Icons.savings_rounded,
    color: Color(0xFF00D395),
  ),
  _DApp(
    name: 'OpenSea',
    tagline: 'NFT marketplace',
    url: 'https://opensea.io',
    icon: Icons.image_rounded,
    color: Color(0xFF2081E2),
  ),
  _DApp(
    name: 'PancakeSwap',
    tagline: 'BSC swaps',
    url: 'https://pancakeswap.finance',
    icon: Icons.cake_rounded,
    color: Color(0xFFD1884F),
  ),
  _DApp(
    name: 'GMX',
    tagline: 'Perpetual trading',
    url: 'https://app.gmx.io',
    icon: Icons.trending_up_rounded,
    color: Color(0xFF2D42FC),
  ),
];

// ---------------------------------------------------------------------------

class _UrlBar extends StatelessWidget {
  const _UrlBar({
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GeniusWalletColors.surfaceElevated,
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
        border: Border.all(
          color: focusNode.hasFocus
              ? GeniusWalletColors.brandPrimary
              : GeniusWalletColors.borderSubtle,
          width: focusNode.hasFocus ? 1.5 : 1,
        ),
      ),
      padding:
          const EdgeInsets.symmetric(horizontal: GeniusWalletConsts.space4),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            size: 20,
            color: GeniusWalletColors.textSecondary,
          ),
          const SizedBox(width: GeniusWalletConsts.space2),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onSubmitted: (_) => onSubmit(),
              keyboardType: TextInputType.url,
              autocorrect: false,
              cursorColor: GeniusWalletColors.brandPrimary,
              style: GeniusWalletTypography.bodyMd,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: InputBorder.none,
                hintText: 'Search or enter URL',
                hintStyle: GeniusWalletTypography.bodyMd.copyWith(
                  color: GeniusWalletColors.textSecondary,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Open',
            icon: const Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: GeniusWalletColors.brandPrimary,
            ),
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: GeniusWalletTypography.titleLg),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _RecentList extends StatelessWidget {
  const _RecentList({
    required this.urls,
    required this.onTap,
    this.onClear,
  });
  final List<String> urls;
  final void Function(String) onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) {
      return Padding(
        padding:
            const EdgeInsets.symmetric(vertical: GeniusWalletConsts.space16),
        child: Column(
          children: [
            const Icon(
              Icons.history_rounded,
              size: 32,
              color: GeniusWalletColors.textSecondary,
            ),
            const SizedBox(height: GeniusWalletConsts.space4),
            Text('No recent sites', style: GeniusWalletTypography.titleMd),
            const SizedBox(height: GeniusWalletConsts.space2),
            Text(
              'URLs you visit will appear here.',
              style: GeniusWalletTypography.bodySm,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          title: 'Recent',
          trailing: onClear == null
              ? null
              : TextButton(
                  onPressed: onClear,
                  child: Text(
                    'Clear',
                    style: GeniusWalletTypography.labelMd.copyWith(
                      color: GeniusWalletColors.textSecondary,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: GeniusWalletConsts.space2),
        ...urls.map(
          (u) => InkWell(
            borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusBase),
            onTap: () => onTap(u),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GeniusWalletConsts.space2,
                vertical: GeniusWalletConsts.space4,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.history_rounded,
                    size: 18,
                    color: GeniusWalletColors.textSecondary,
                  ),
                  const SizedBox(width: GeniusWalletConsts.space4),
                  Expanded(
                    child: Text(
                      _displayUrl(u),
                      style: GeniusWalletTypography.bodyMd,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.north_west_rounded,
                    size: 14,
                    color: GeniusWalletColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _displayUrl(String url) => url
      .replaceFirst(RegExp(r'^https?://'), '')
      .replaceFirst(RegExp(r'/$'), '');
}

// ---------------------------------------------------------------------------

class _FavoritesList extends StatelessWidget {
  const _FavoritesList({
    required this.favorites,
    required this.onTap,
    required this.onRemove,
  });
  final List<BrowserFavorite> favorites;
  final void Function(BrowserFavorite) onTap;
  final void Function(BrowserFavorite) onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: favorites.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: GeniusWalletConsts.space2),
        itemBuilder: (_, i) {
          final f = favorites[i];
          return SizedBox(
            width: 96,
            child: GWCard(
              onTap: () => onTap(f),
              elevated: false,
              radius: GeniusWalletConsts.radius2xl,
              padding: const EdgeInsets.symmetric(
                horizontal: GeniusWalletConsts.space2,
                vertical: GeniusWalletConsts.space4,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: GeniusWalletColors.brandPrimary.withAlpha(38),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.bookmark_rounded,
                      size: 16,
                      color: GeniusWalletColors.brandPrimary,
                    ),
                  ),
                  const SizedBox(height: GeniusWalletConsts.space2),
                  Text(
                    f.name.isNotEmpty ? f.name : _hostOf(f.url),
                    style: GeniusWalletTypography.labelMd.copyWith(
                      color: GeniusWalletColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _hostOf(String url) =>
      url.replaceFirst(RegExp(r'^https?://'), '').split('/').first;
}

// ---------------------------------------------------------------------------

class _DappTile extends StatelessWidget {
  const _DappTile({
    required this.app,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });
  final _DApp app;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return GWCard(
      onTap: onTap,
      elevated: false,
      radius: GeniusWalletConsts.radius2xl,
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space4,
        vertical: GeniusWalletConsts.space4,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: app.color.withAlpha(46),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(app.icon, color: app.color, size: 18),
          ),
          const SizedBox(width: GeniusWalletConsts.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  app.name,
                  style: GeniusWalletTypography.titleMd,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  app.tagline,
                  style: GeniusWalletTypography.bodySm,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onToggleFavorite,
            iconSize: 18,
            padding: EdgeInsets.zero,
            // 48x48 hit area for a11y; the glyph itself stays 18px.
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            tooltip: isFavorite ? 'Remove bookmark' : 'Add bookmark',
            icon: Icon(
              isFavorite
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: isFavorite
                  ? GeniusWalletColors.brandPrimary
                  : GeniusWalletColors.textSecondary,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
