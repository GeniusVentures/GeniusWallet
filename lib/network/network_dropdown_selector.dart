import 'package:flutter/material.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/widgets/components/bottom_drawer/responsive_drawer.dart';
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
    final color =
        isSelected ? GeniusWalletColors.deepBlueTertiary : Colors.white;
    final subColor =
        isSelected ? GeniusWalletColors.deepBlueTertiary : Colors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.greenAccent
              : GeniusWalletColors.deepBlueCardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: SizedBox(
            width: 40,
            height: 40,
            child: Image.asset(
              network.iconPath ?? "",
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox(width: 40, height: 40),
            ),
          ),
          minLeadingWidth: 0,
          title: Text(
            network.name ?? "Unnamed",
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            network.symbol ?? "",
            style: TextStyle(
              fontSize: 14,
              color: subColor,
            ),
          ),
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
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    selectedNetwork ??= networks.firstWhere(
      (n) => n.chainId == savedChainId && n.rpcUrl == savedRpcUrl,
      orElse: () => widget.initialSelected ?? networks.first,
    );

    return GestureDetector(
      onTap: () => _showNetworkDrawer(networks),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: GeniusWalletColors.deepBlueCardColor,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              selectedNetwork?.iconPath ?? "",
              width: 20,
              height: 20,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox(width: 20, height: 20),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
