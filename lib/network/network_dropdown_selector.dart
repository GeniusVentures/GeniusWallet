import 'package:flutter/material.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:provider/provider.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:genius_wallet/hive/constants/cache.dart';

/// Resolve the active network: the Hive-persisted selection when it matches an
/// available network, else [fallback], else the first available network.
Network? resolveSelectedNetwork(List<Network> networks, {Network? fallback}) {
  if (networks.isEmpty) return fallback;
  final box = Hive.box(networkBoxName);
  final chainId = box.get(selectedNetworkKeyChainId) as int?;
  final rpcUrl = box.get(selectedNetworkKeyRpcUrl) as String?;
  return networks.firstWhere(
    (n) => n.chainId == chainId && n.rpcUrl == rpcUrl,
    orElse: () => fallback ?? networks.first,
  );
}

/// Show the network picker drawer. Persists the choice and pushes it into
/// [WalletDetailsCubit]. Returns the picked network (null when dismissed).
/// Lives here so the Preferences sheet and any contextual selector share one
/// implementation.
Future<Network?> showNetworkPicker(BuildContext context) async {
  final networks = context.read<NetworkProvider>().networks;
  if (networks.isEmpty) return null;
  final walletCubit = context.read<WalletDetailsCubit>();
  final current = resolveSelectedNetwork(
    networks,
    fallback: walletCubit.state.selectedNetwork,
  );

  final selected = await ResponsiveDrawer.show<Network>(
    context: context,
    title: "Select Network",
    children: networks
        .map((network) => _NetworkPickerRow(
              network: network,
              isSelected: network.chainId == current?.chainId,
            ))
        .toList(),
  );

  if (selected != null && selected.chainId != current?.chainId) {
    walletCubit.selectNetwork(selected);
    final box = Hive.box(networkBoxName);
    await box.put(selectedNetworkKeyChainId, selected.chainId);
    await box.put(selectedNetworkKeyRpcUrl, selected.rpcUrl);
  }
  return selected;
}

class _NetworkPickerRow extends StatelessWidget {
  const _NetworkPickerRow({required this.network, required this.isSelected});

  final Network network;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: GeniusWalletConsts.space2),
      child: Container(
        decoration: BoxDecoration(
          color:
              isSelected ? GeniusWalletColors.brandPrimary.withAlpha(38) : null,
          gradient: isSelected ? null : GWDecorations.surfaceSheen,
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
              semanticLabel: network.name,
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
}

/// Compact pill showing the active network; tap opens the shared picker.
/// No longer mounted in the top bar — network selection moved into the
/// Preferences sheet — but kept for contextual placements.
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
  @override
  Widget build(BuildContext context) {
    final networks = Provider.of<NetworkProvider>(context).networks;

    if (networks.isEmpty) {
      return Center(
        child: Text(
          "No networks available.",
          style: TextStyle(color: GeniusWalletColors.textPrimary70),
        ),
      );
    }

    final selectedNetwork =
        resolveSelectedNetwork(networks, fallback: widget.initialSelected);

    return Material(
      color: GeniusWalletColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: GeniusWalletColors.borderSubtle, width: 1),
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
        onTap: () async {
          final picked = await showNetworkPicker(context);
          if (picked != null) {
            widget.onNetworkSelected?.call(picked);
            if (mounted) setState(() {});
          }
        },
        child: Container(
          // >=48px tap target (a11y); content stays vertically centered.
          constraints: const BoxConstraints(minHeight: 48),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: GeniusWalletConsts.space4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                selectedNetwork?.iconPath ?? "",
                width: 18,
                height: 18,
                semanticLabel: selectedNetwork?.name,
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
