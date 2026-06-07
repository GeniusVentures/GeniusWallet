import 'package:flutter/material.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:genius_wallet/hive/constants/cache.dart';

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

    //print("Saved chainId: $chainId, rpcUrl: $rpcUrl");

    if (!mounted) return;
    setState(() {
      savedChainId = chainId;
      savedRpcUrl = rpcUrl;
    });
  }

  void _showNetworkDrawer(List<Network> networks) async {
    final walletCubit = context.read<WalletDetailsCubit>();
    final selected = await ResponsiveDrawer.show<Network>(
      context: context,
      title: "Select Network",
      children: networks.map((network) {
        final isSelected = network.chainId == selectedNetwork?.chainId;
        return _buildDrawerRow(network, isSelected);
      }).toList(),
    );

    if (selected != null && selected != selectedNetwork) {
      setState(() => selectedNetwork = selected);

      if (widget.onNetworkSelected != null) {
        widget.onNetworkSelected!(selected);
      }

      walletCubit.selectNetwork(selected);

      final box = Hive.box(networkBoxName);
      await box.put(selectedNetworkKeyChainId, selected.chainId);
      await box.put(selectedNetworkKeyRpcUrl, selected.rpcUrl);
    }
  }

  Widget _buildDrawerRow(Network network, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: GeniusWalletConsts.space2),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? GeniusWalletColors.brandPrimary.withAlpha(38)
              : GeniusWalletColors.surfaceElevated,
          borderRadius: BorderRadius.circular(GeniusWalletConsts.radius2xl),
          border: Border.all(
            color: isSelected
                ? GeniusWalletColors.brandPrimary
                : GeniusWalletColors.borderSubtle,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: GeniusWalletConsts.space6,
            vertical: 0,
          ),
          leading: SizedBox(
            width: 32,
            height: 32,
            child: Image.asset(
              network.iconPath ?? "",
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox(width: 32, height: 32),
            ),
          ),
          minLeadingWidth: 0,
          title: Text(
            network.name ?? "Unnamed",
            style: GeniusWalletTypography.titleMd,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            network.symbol ?? "",
            style: GeniusWalletTypography.bodySm,
          ),
          trailing: isSelected
              ? const Icon(
                  Icons.check_circle_rounded,
                  color: GeniusWalletColors.brandPrimary,
                  size: 20,
                )
              : null,
          onTap: () => Navigator.of(context).pop(network),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final networks = Provider.of<NetworkProvider>(context).networks;

    if (networks.isEmpty) {
      return const Center(
        child: Text(
          "No networks available.",
          style: TextStyle(color: GeniusWalletColors.textPrimary70),
        ),
      );
    }

    selectedNetwork ??= networks.firstWhere(
      (n) => n.chainId == savedChainId && n.rpcUrl == savedRpcUrl,
      orElse: () => widget.initialSelected ?? networks.first,
    );

    return Material(
      color: GeniusWalletColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
        onTap: () => _showNetworkDrawer(networks),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: GeniusWalletConsts.space4,
            vertical: 6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                selectedNetwork?.iconPath ?? "",
                width: 18,
                height: 18,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox(width: 18, height: 18),
              ),
              const SizedBox(width: GeniusWalletConsts.space2),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: GeniusWalletColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
