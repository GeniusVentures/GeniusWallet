import 'package:flutter/material.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/cards/gw_kicker.dart';
import 'package:genius_wallet/components/cards/gw_select_row.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/components/inputs/gw_focus_ring.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
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

/// The phone sheet's network control: the current chain, named, in a field
/// that opens [NetworkPicker]. The name is text beside the icon because the
/// header's 16px badge only signals a change; this is where the chain is named.
class NetworkSelectField extends StatelessWidget {
  const NetworkSelectField({
    super.key,
    required this.network,
    required this.onTap,
  });

  final Network? network;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final name = network?.name ?? network?.symbol ?? 'Select a network';

    return Semantics(
      button: true,
      label: 'Network, $name',
      excludeSemantics: true,
      child: GWFocusRing(
        radius: GeniusWalletConsts.radiusLg,
        // surfaceWell, not surfaceSunken: on the white light-mode panel the
        // sunken grey read as a heavy block. The fill is only a step from the
        // panel, so the control edge carries WCAG 1.4.11 on its own.
        background: gw.surfaceWell,
        restingColor: gw.borderControl,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusLg),
            child: SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: GeniusWalletConsts.space6,
                ),
                child: Row(
                  spacing: GeniusWalletConsts.space4,
                  children: [
                    Image.asset(
                      network?.iconPath ?? "",
                      width: 20,
                      height: 20,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(width: 20, height: 20),
                    ),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GeniusWalletTypography.labelMd.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: gw.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: gw.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The one network picker: a name filter above the list, split into Mainnet
/// and Testnet by the `testnet` flag. Both the desktop selector and the phone
/// sheet open it; it only returns the pick, the caller applies it.
class NetworkPicker extends StatefulWidget {
  const NetworkPicker({super.key, required this.networks, this.current});

  final List<Network> networks;
  final Network? current;

  /// Opens the picker; resolves to the tapped network, or null if dismissed.
  static Future<Network?> show(
    BuildContext context, {
    required List<Network> networks,
    Network? current,
  }) {
    return ResponsiveDrawer.show<Network>(
      context: context,
      // Owns a scrolling viewport, so the inset lives on the field and the
      // list rather than on the shell (kDrawerBodyPadding).
      bodyPadding: EdgeInsets.zero,
      title: "Select Network",
      child: NetworkPicker(networks: networks, current: current),
    );
  }

  @override
  State<NetworkPicker> createState() => _NetworkPickerState();
}

class _NetworkPickerState extends State<NetworkPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final query = _query.trim().toLowerCase();
    final matches = widget.networks
        .where((n) => (n.name ?? '').toLowerCase().contains(query))
        .toList();
    final mainnets = matches.where((n) => !n.testnet).toList();
    final testnets = matches.where((n) => n.testnet).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            GeniusWalletConsts.space10,
            GeniusWalletConsts.space10,
            GeniusWalletConsts.space10,
            GeniusWalletConsts.space6,
          ),
          child: GWTextField(
            hint: 'Search networks',
            leadingIcon: Icon(Icons.search, size: 20, color: gw.textSecondary),
            focusRing: true,
            fill: gw.surfaceWell,
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        Expanded(
          child: matches.isEmpty
              ? GWEmptyState(
                  icon: Icons.search_off,
                  title: 'No networks match "${_query.trim()}"',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(
                    GeniusWalletConsts.space10,
                    0,
                    GeniusWalletConsts.space10,
                    GeniusWalletConsts.space10,
                  ),
                  children: [
                    if (mainnets.isNotEmpty)
                      _NetworkSection(
                        key: const ValueKey('mainnet-section'),
                        label: 'Mainnet',
                        networks: mainnets,
                        current: widget.current,
                      ),
                    if (testnets.isNotEmpty)
                      _NetworkSection(
                        key: const ValueKey('testnet-section'),
                        label: 'Testnet',
                        networks: testnets,
                        current: widget.current,
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// A labelled group of picker rows; tapping a row pops the picker with it.
class _NetworkSection extends StatelessWidget {
  const _NetworkSection({
    super.key,
    required this.label,
    required this.networks,
    required this.current,
  });

  final String label;
  final List<Network> networks;
  final Network? current;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            GeniusWalletConsts.space4,
            GeniusWalletConsts.space6,
            GeniusWalletConsts.space4,
            GeniusWalletConsts.space4,
          ),
          child: GWKicker(label),
        ),
        for (final network in networks)
          GWSelectRow(
            // chainId AND rpcUrl: networks.json ships pairs that share neither
            // reliably on their own.
            selected:
                network.chainId == current?.chainId &&
                network.rpcUrl == current?.rpcUrl,
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
          ),
      ],
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
    final selected = await NetworkPicker.show(
      context,
      networks: networks,
      current: selectedNetwork,
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
