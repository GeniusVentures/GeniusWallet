import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/cards/gw_select_row.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/components/inputs/gw_focus_ring.dart';
import 'package:genius_wallet/squid_router/models/squid_balance.dart';
import 'package:genius_wallet/squid_router/models/squid_token_info.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
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

  /// Shown when [tokens] arrives EMPTY — i.e. the caller had nothing to offer,
  /// not the search that found nothing.
  ///
  /// The pay side is filtered to holdings (`held_tokens.dart`), so an empty
  /// list there is the ordinary state of a new or single-token wallet, and
  /// "No tokens match """ — what the search empty-state would have said with a
  /// blank query — describes it wrongly. Optional: a caller that passes the
  /// full catalogue (the receive side) can never be empty and needs neither.
  final String? emptyTitle;
  final String? emptyMessage;

  const TokenSelectorDrawer({
    super.key,
    required this.tokens,
    required this.onTokenSelected,
    this.title = 'Select Token',
    this.selectedToken,
    this.emptyTitle,
    this.emptyMessage,
  });

  static void show({
    required BuildContext context,
    required List<SquidTokenInfo> tokens,
    required ValueChanged<SquidTokenInfo> onTokenSelected,
    String title = 'Select Token',
    SquidTokenInfo? selectedToken,
    String? emptyTitle,
    String? emptyMessage,
  }) {
    ResponsiveDrawer.show<void>(
      context: context,
      // Owns a scrolling viewport: the inset lives on the list so it scrolls
      // with the content and rows still reach the panel edge (kDrawerBodyPadding).
      bodyPadding: EdgeInsets.zero,
      title: title,
      // No outer ListView any more. The old shape was a ListView wrapping a
      // Column wrapping a shrink-wrapped ListView.builder with scrolling
      // disabled — three scroll-capable layers to produce one scrolling list.
      child: TokenSelectorDrawer(
        tokens: tokens,
        onTokenSelected: onTokenSelected,
        title: title,
        selectedToken: selectedToken,
        emptyTitle: emptyTitle,
        emptyMessage: emptyMessage,
      ),
    );
  }

  @override
  State<TokenSelectorDrawer> createState() => _TokenSelectorDrawerState();
}

class _TokenSelectorDrawerState extends State<TokenSelectorDrawer> {
  static const int _maxRows = 30;

  String _query = '';

  bool _isSelected(SquidTokenInfo token) => token.sameAs(widget.selectedToken);

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this subtree to rebuild on a live appearance toggle (04-04 discipline).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final query = _query.trim().toLowerCase();

    // Nothing to offer at all — distinct from "the search found nothing".
    // The search field is suppressed with the list: a field that can only ever
    // return the same empty state is an invitation to a dead end.
    final nothingToOffer = widget.tokens.isEmpty;

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
        if (!nothingToOffer)
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
              // Recessed, not raised -- the same call Jakub made live on the
              // slippage field, kept here so the two drawer inputs stay one
              // control. `surfaceSunken` is the app's existing well fill.
              background: gw.surfaceSunken,
              // The fill is 1.11:1 from the panel, so the edge carries 1.4.11 on
              // its own. See GeniusWalletColors.borderControl.
              restingColor: gw.borderControl,
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
          child: nothingToOffer
              ? GWEmptyState(
                  icon: Icons.account_balance_wallet_outlined,
                  title: widget.emptyTitle ?? 'No tokens available',
                  message: widget.emptyMessage,
                )
              : filtered.isEmpty
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

/// The token row: `GWSelectRow` plus the two things only a token has - remote
/// logo art with its own loading/error states, and a balance that is ABSENT
/// rather than "0" when the wallet does not hold the token.
///
/// Everything that used to live here - the gradient selection tint, the
/// app-wide hover recipe, the always-present transparent border, the
/// `ShaderMask` check - moved into `GWSelectRow` (sketch 068-A) so Select
/// Network, SDK Accounts and Your Accounts could stop hand-rolling their own.
/// This file authored that row; it is now one of four consumers.
class _TokenRow extends StatelessWidget {
  const _TokenRow({
    required this.token,
    required this.selected,
    required this.onTap,
  });

  final SquidTokenInfo token;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final balance = token.balance;

    return GWSelectRow(
      selected: selected,
      onTap: onTap,
      leading: ClipOval(
        child: Image.network(
          token.logoURI,
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
            child: Icon(Icons.broken_image, color: gw.textSecondary, size: 16),
          ),
        ),
      ),
      title: token.name,
      subtitle: token.symbol,
      // A balance the wallet does not hold is ABSENT, not "0" - the same rule
      // the transaction rows follow for a missing fiat line.
      trailing: balance == null
          ? null
          : Text(
              balance.displayBalance,
              style: GeniusWalletTypography.numericBody.copyWith(
                color: gw.textPrimary,
              ),
            ),
    );
  }
}
