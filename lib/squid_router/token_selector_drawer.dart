import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/inputs/gw_focus_ring.dart';
import 'package:genius_wallet/squid_router/models/squid_balance.dart';
import 'package:genius_wallet/squid_router/models/squid_token_info.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// The token picker, brought onto sketch **032 A1 "Comfortable"** — the list
/// archetype that `drawers-final` already settled for every picker in the app
/// (network, account, bridge destination).
///
/// What A1 asks for and this drawer did not have:
///
/// * **Body padding.** The search field and every row ran edge to edge inside
///   the panel, because the drawer shell deliberately adds no blanket padding
///   and this caller never added its own.
/// * **A visible row.** Rows painted `surfaceMenu` on a panel whose background
///   is also `surfaceMenu` — a rounded card that could not be seen, and 4px of
///   margin between invisible cards.
/// * **Selection.** The drawer was never told which token is already chosen,
///   so re-opening it showed no trace of the current pick. A1's selection is a
///   rounded gradient tint plus a gradient check — no accent bar, no
///   full-bleed square fill.
class TokenSelectorDrawer extends StatefulWidget {
  final List<SquidTokenInfo> tokens;
  final ValueChanged<SquidTokenInfo> onTokenSelected;
  final String title;

  /// The token currently chosen for this side of the swap, if any. Optional so
  /// the existing call shape stays valid; without it the list simply renders
  /// with nothing selected, which is what it did before.
  final SquidTokenInfo? selectedToken;

  const TokenSelectorDrawer({
    super.key,
    required this.tokens,
    required this.onTokenSelected,
    this.title = 'Select Token',
    this.selectedToken,
  });

  static void show({
    required BuildContext context,
    required List<SquidTokenInfo> tokens,
    required ValueChanged<SquidTokenInfo> onTokenSelected,
    String title = 'Select Token',
    SquidTokenInfo? selectedToken,
  }) {
    ResponsiveDrawer.show<void>(
      context: context,
      title: title,
      // No outer ListView any more. The old shape was a ListView wrapping a
      // Column wrapping a shrink-wrapped ListView.builder with scrolling
      // disabled — three scroll-capable layers to produce one scrolling list.
      child: TokenSelectorDrawer(
        tokens: tokens,
        onTokenSelected: onTokenSelected,
        title: title,
        selectedToken: selectedToken,
      ),
    );
  }

  @override
  State<TokenSelectorDrawer> createState() => _TokenSelectorDrawerState();
}

class _TokenSelectorDrawerState extends State<TokenSelectorDrawer> {
  static const int _maxRows = 30;

  String _query = '';

  bool _isSelected(SquidTokenInfo token) {
    final selected = widget.selectedToken;
    if (selected == null) return false;
    // Address alone is not identity across chains — the same address can exist
    // on several, and this list is explicitly cross-chain.
    return token.address.toLowerCase() == selected.address.toLowerCase() &&
        token.chainId == selected.chainId;
  }

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this subtree to rebuild on a live appearance toggle (04-04 discipline).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final query = _query.trim().toLowerCase();

    final filtered = widget.tokens
        .where(
          (t) =>
              t.symbol.toLowerCase().contains(query) ||
              t.name.toLowerCase().contains(query),
        )
        .take(_maxRows)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          // Matches the title's own inset in the shell's header, so the search
          // field's left edge and the drawer title sit on one axis.
          padding: const EdgeInsets.fromLTRB(
            GeniusWalletConsts.space10,
            GeniusWalletConsts.space10,
            GeniusWalletConsts.space10,
            GeniusWalletConsts.space6,
          ),
          child: GWFocusRing(
            radius: GeniusWalletConsts.radiusMd,
            background: gw.surfaceElevated,
            child: TextField(
              onChanged: (val) => setState(() => _query = val),
              style: GeniusWalletTypography.bodySm.copyWith(
                color: gw.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search tokens',
                hintStyle: GeniusWalletTypography.bodySm.copyWith(
                  color: gw.textSecondary,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: gw.textSecondary,
                  size: 20,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: GeniusWalletConsts.space6,
                ),
                // The ring is the border. All four silenced so the theme's
                // app-wide focusedBorder cannot paint a flat one inside it.
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? _EmptyResult(query: _query, gw: gw)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    GeniusWalletConsts.space10,
                    0,
                    GeniusWalletConsts.space10,
                    GeniusWalletConsts.space10,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final token = filtered[index];
                    return _TokenRow(
                      token: token,
                      selected: _isSelected(token),
                      onTap: () {
                        Navigator.of(context).pop();
                        widget.onTokenSelected(token);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult({required this.query, required this.gw});

  final String query;
  final GWColors gw;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(GeniusWalletConsts.space16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, color: gw.textPrimary38, size: 28),
          const SizedBox(height: GeniusWalletConsts.space6),
          Text(
            'No tokens match "$query"',
            textAlign: TextAlign.center,
            style: GeniusWalletTypography.bodySm.copyWith(
              color: gw.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TokenRow extends StatefulWidget {
  const _TokenRow({
    required this.token,
    required this.selected,
    required this.onTap,
  });

  final SquidTokenInfo token;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_TokenRow> createState() => _TokenRowState();
}

class _TokenRowState extends State<_TokenRow> {
  /// A1's selection tint: the REAL `brandCta` stops at low alpha, so selection
  /// and the gradient check below it are the same brand statement. Built here
  /// rather than added to `GeniusWalletGradient` — one consumer does not earn
  /// a shared token, and a second one would be the moment to promote it.
  static const LinearGradient _selectionTint = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0x2E0AD89C), Color(0x2E0AAEE6)],
  );

  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final balance = widget.token.balance;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
        child: Container(
          margin: const EdgeInsets.only(bottom: GeniusWalletConsts.space2),
          padding: const EdgeInsets.symmetric(
            horizontal: GeniusWalletConsts.space6,
            vertical: GeniusWalletConsts.space6,
          ),
          decoration: BoxDecoration(
            // A1: selection is a rounded gradient TINT, not a full-bleed fill
            // and not an accent bar. Resting is transparent — a row painted
            // `surfaceMenu` on a `surfaceMenu` panel is decoration nobody sees.
            gradient: widget.selected ? _selectionTint : null,
            color: widget.selected
                ? null
                : (_hovered ? GWDecorations.hoverFill : Colors.transparent),
            borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
            border: Border.all(
              color: widget.selected || _hovered
                  ? GWDecorations.hoverEdge
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              ClipOval(
                child: Image.network(
                  widget.token.logoURI,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : Container(width: 36, height: 36, color: gw.surfaceMenu),
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 36,
                    height: 36,
                    color: gw.surfaceMenu,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.broken_image,
                      color: gw.textSecondary,
                      size: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: GeniusWalletConsts.space6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.token.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GeniusWalletTypography.bodySm.copyWith(
                        color: gw.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.token.symbol,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GeniusWalletTypography.labelMd.copyWith(
                        color: gw.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // A balance the wallet does not hold is ABSENT, not "0" — the
              // same rule the transaction rows follow for a missing fiat line.
              if (balance != null) ...[
                const SizedBox(width: GeniusWalletConsts.space4),
                Text(
                  balance.displayBalance,
                  style: GeniusWalletTypography.numericBody.copyWith(
                    color: gw.textPrimary,
                  ),
                ),
              ],
              if (widget.selected) ...[
                const SizedBox(width: GeniusWalletConsts.space4),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      GeniusWalletGradient.brandCta.createShader(bounds),
                  child: const Icon(
                    Icons.check_circle,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
