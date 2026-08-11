import 'package:flutter/material.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/cards/gw_select_row.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/nav_chip_style.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

/// The three side effects a network switch has to perform, in one place.
///
/// This exists because `walletCubit.selectNetwork()` had exactly ONE call
/// site in the entire app - `_showNetworkDrawer` below - and the phone shell
/// no longer mounts [NetworkDropdownSelector] at all. Without this seam,
/// mobile would lose the ability to change network completely.
///
/// The side effects live in the entry, never at the call site. That is the
/// precedent `AccountDrawer.show` already set, and for the same reason: a
/// caller that performs the cubit write but forgets the Hive write ships a
/// selection that looks correct until the next launch, at which point the
/// app silently reads balances from an RPC the user did not choose. There is
/// no partial-write path here because there is only one implementation.
class NetworkSelection {
  const NetworkSelection._();

  /// Applies [network] as the selected network: cubit, toast, then both Hive
  /// keys, in the same order `_showNetworkDrawer` has always performed them.
  ///
  /// [context] must outlive the surface that triggered the switch. Callers
  /// that pop a sheet first should pass the ROOT navigator's context, the way
  /// `account_drawer.dart`'s confirm flows already do, because the popped
  /// surface's own context is deactivated by then.
  static Future<void> apply({
    required BuildContext context,
    required WalletDetailsCubit walletCubit,
    required Network network,
  }) async {
    walletCubit.selectNetwork(network);

    showToast(
      context,
      'Switched to ${network.name ?? network.symbol ?? "network"}.',
      title: 'Network Changed',
      type: ToastType.success,
    );

    final box = Hive.box(networkBoxName);
    await box.put(selectedNetworkKeyChainId, network.chainId);
    await box.put(selectedNetworkKeyRpcUrl, network.rpcUrl);
  }
}

/// One network as a horizontal chip, for the strip at the top of the combined
/// wallet-and-network sheet.
///
/// The name is TEXT, beside the icon rather than instead of it. The phone
/// header identifies the current chain with a 16px badge, which is a
/// change-detector and not an identifier; this chip is where the chain is
/// actually named on screen.
class NetworkSelectChip extends StatelessWidget {
  const NetworkSelectChip({
    super.key,
    required this.network,
    required this.selected,
    required this.onTap,
  });

  final Network network;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    // Selected is a brand TINT plus a brand edge, deliberately NOT the brand
    // CTA gradient that `GWTimeframeSegment`'s selected chip wears. This
    // sheet already carries one gradient fill - the `Add Wallet` footer - and
    // the house rule is one filled gradient per surface, fill meaning
    // commitment. Being already on a network is not a commitment. The edge
    // carries 1.4.11 at 9.86:1, so selection is never colour alone.
    final fill = selected
        ? gw.brandPrimary.withValues(alpha: 0.12)
        : gw.surfaceSunken;
    final edge = selected ? gw.brandPrimary : gw.borderSubtle;

    return Semantics(
      selected: selected,
      child: Material(
        color: fill,
        shape: StadiumBorder(side: BorderSide(color: edge)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            // 44, the touch-target floor. Every target in this strip and in
            // the header clears it.
            height: 44,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GeniusWalletConsts.space4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    network.iconPath ?? "",
                    width: 20,
                    height: 20,
                    // Same fail-soft shape the drawer rows use: a missing or
                    // corrupt iconPath degrades to blank rather than throwing
                    // mid-build.
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(width: 20, height: 20),
                  ),
                  const SizedBox(width: GeniusWalletConsts.space4),
                  Text(
                    network.name ?? "Unnamed",
                    style: GeniusWalletTypography.labelMd.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: gw.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NetworkDropdownSelector extends StatefulWidget {
  final Function(Network selectedNetwork)? onNetworkSelected;
  final Network? initialSelected;

  const NetworkDropdownSelector({
    super.key,
    this.onNetworkSelected,
    this.initialSelected,
  });

  @override
  State<NetworkDropdownSelector> createState() =>
      _NetworkDropdownSelectorState();
}

class _NetworkDropdownSelectorState extends State<NetworkDropdownSelector> {
  Network? selectedNetwork;
  int? savedChainId;
  String? savedRpcUrl;

  @override
  void initState() {
    super.initState();
    _loadSavedNetwork();
  }

  void _loadSavedNetwork() async {
    final box = Hive.box(networkBoxName);
    final chainId = box.get(selectedNetworkKeyChainId) as int?;
    final rpcUrl = box.get(selectedNetworkKeyRpcUrl) as String?;

    if (!mounted) {
      return;
    }
    setState(() {
      savedChainId = chainId;
      savedRpcUrl = rpcUrl;
    });
  }

  void _showNetworkDrawer(List<Network> networks) async {
    final walletCubit = context.read<WalletDetailsCubit>();
    final selected = await ResponsiveDrawer.show<Network>(
      context: context,
      // Owns a scrolling viewport: the inset lives on the list so it scrolls
      // with the content and rows still reach the panel edge (kDrawerBodyPadding).
      bodyPadding: EdgeInsets.zero,
      title: "Select Network",
      child: ListView(
        // The inset the rows used to carry as `contentPadding` now lives on
        // the viewport, so it scrolls with the content (kDrawerBodyPadding).
        padding: const EdgeInsets.all(GeniusWalletConsts.space10),
        children: networks.map((network) {
          final isSelected = network.chainId == selectedNetwork?.chainId;
          return _buildDrawerRow(network, isSelected);
        }).toList(),
      ),
    );

    if (!mounted) {
      return;
    }

    if (selected != null && selected != selectedNetwork) {
      setState(() => selectedNetwork = selected);

      if (widget.onNetworkSelected != null) {
        widget.onNetworkSelected!(selected);
      }

      // Cubit, toast and both Hive keys now live in [NetworkSelection.apply]
      // so the phone's sheet performs the identical three writes. This body
      // is unchanged in behaviour and order; it just no longer owns the only
      // copy.
      await NetworkSelection.apply(
        context: context,
        walletCubit: walletCubit,
        network: selected,
      );
    }
  }

  /// Sketch 068-A. This was a bare `ListTile` with `selected: isSelected` and
  /// nothing else -- no `selectedTileColor`, no check, and the title's colour
  /// literally commented out (`// color: color`). With no `ListTileTheme`
  /// behind it, `selected: true` paints NOTHING: the drawer whose whole job is
  /// to show which network you are on did not show which network you are on.
  ///
  /// `GWSelectRow` brings the tint, the brand edge, the check glyph that
  /// carries 1.4.11 on its own, and the app-wide hover recipe.
  Widget _buildDrawerRow(Network network, bool isSelected) {
    return GWSelectRow(
      selected: isSelected,
      onTap: () => Navigator.of(context).pop(network),
      leading: SizedBox(
        width: 36,
        height: 36,
        child: Image.asset(
          network.iconPath ?? "",
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const SizedBox(width: 36, height: 36),
        ),
      ),
      title: network.name ?? "Unnamed",
      subtitle: network.symbol,
    );
  }

  @override
  Widget build(BuildContext context) {
    final networks = Provider.of<NetworkProvider>(context).networks;

    if (networks.isEmpty) {
      final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
      return Center(
        child: Text(
          "No networks available.",
          style: TextStyle(color: gw.textSecondary),
        ),
      );
    }

    selectedNetwork ??= networks.firstWhere(
      (n) => n.chainId == savedChainId && n.rpcUrl == savedRpcUrl,
      orElse: () => widget.initialSelected ?? networks.first,
    );

    return Tooltip(
      message: "Select network",
      child: TextButton(
        style: navContextChipStyle(context),
        onPressed: () => _showNetworkDrawer(networks),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: GeniusWalletConsts.space4,
          children: [
            Image.asset(
              selectedNetwork?.iconPath ?? "",
              width: 20,
              height: 20,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox(width: 20, height: 20),
            ),
            const Icon(Icons.arrow_drop_down, size: 16),
          ],
        ),
      ),
    );
  }
}
