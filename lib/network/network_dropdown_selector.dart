import 'package:flutter/material.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/cards/gw_select_row.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/nav_chip_style.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

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

    if (selected != null && selected != selectedNetwork) {
      setState(() => selectedNetwork = selected);

      if (widget.onNetworkSelected != null) {
        widget.onNetworkSelected!(selected);
      }

      walletCubit.selectNetwork(selected);

      if (context.mounted) {
        ToastManager.instance.showToast(
          context: context,
          title: 'Network Changed',
          message:
              'Switched to ${selected.name ?? selected.symbol ?? "network"}.',
          type: ToastType.success,
        );
      }

      final box = Hive.box(networkBoxName);
      await box.put(selectedNetworkKeyChainId, selected.chainId);
      await box.put(selectedNetworkKeyRpcUrl, selected.rpcUrl);
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
