import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/network/network_dropdown_selector.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:provider/provider.dart';

/// Top-bar entry point for app preferences.
///
/// Network selection moved here from the top bar; the Currency and Appearance
/// rows are static placeholders for now (see HANDOFF.md §6).
class PreferencesButton extends StatelessWidget {
  const PreferencesButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GeniusWalletColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        side:
            const BorderSide(color: GeniusWalletColors.borderSubtle, width: 1),
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
        onTap: () => ResponsiveDrawer.show<void>(
          context: context,
          title: 'Preferences',
          children: const [_PreferencesSheet()],
        ),
        child: Container(
          // >=48px tap target (a11y), matching the other top-bar pills.
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          alignment: Alignment.center,
          child: const Tooltip(
            message: 'Preferences',
            child: Icon(
              Icons.tune_rounded,
              size: 20,
              color: GeniusWalletColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _PreferencesSheet extends StatefulWidget {
  const _PreferencesSheet();

  @override
  State<_PreferencesSheet> createState() => _PreferencesSheetState();
}

class _PreferencesSheetState extends State<_PreferencesSheet> {
  @override
  Widget build(BuildContext context) {
    final networks = context.watch<NetworkProvider>().networks;
    final current = networks.isEmpty
        ? null
        : resolveSelectedNetwork(
            networks,
            fallback: context.read<WalletDetailsCubit>().state.selectedNetwork,
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PrefRow(
          leading: current?.iconPath != null && current!.iconPath!.isNotEmpty
              ? Image.asset(
                  current.iconPath!,
                  width: 22,
                  height: 22,
                  semanticLabel: current.name,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.hub_outlined,
                    size: 20,
                    color: GeniusWalletColors.textSecondary,
                  ),
                )
              : const Icon(
                  Icons.hub_outlined,
                  size: 20,
                  color: GeniusWalletColors.textSecondary,
                ),
          title: 'Network',
          value: current?.name ?? 'Unavailable',
          showChevron: networks.isNotEmpty,
          onTap: networks.isEmpty
              ? null
              : () async {
                  final picked = await showNetworkPicker(context);
                  if (picked != null && mounted) setState(() {});
                },
        ),
        const _PrefRow(
          leading: Icon(
            Icons.payments_outlined,
            size: 20,
            color: GeniusWalletColors.textSecondary,
          ),
          title: 'Currency',
          value: 'USD',
        ),
        const _PrefRow(
          leading: Icon(
            Icons.dark_mode_outlined,
            size: 20,
            color: GeniusWalletColors.textSecondary,
          ),
          title: 'Appearance',
          value: 'Dark',
        ),
        const SizedBox(height: GeniusWalletConsts.space4),
      ],
    );
  }
}

class _PrefRow extends StatelessWidget {
  const _PrefRow({
    required this.leading,
    required this.title,
    required this.value,
    this.onTap,
    this.showChevron = false,
  });

  final Widget leading;
  final String title;
  final String value;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: GeniusWalletConsts.space2),
      child: Container(
        decoration: GWDecorations.surface(radius: GeniusWalletConsts.radius2xl),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: GeniusWalletConsts.space6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GeniusWalletConsts.radius2xl),
          ),
          leading: SizedBox(
            width: 24,
            height: 24,
            child: Center(child: leading),
          ),
          minLeadingWidth: 0,
          title: Text(title, style: GeniusWalletTypography.titleMd),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: GeniusWalletTypography.bodyMd
                    .copyWith(color: GeniusWalletColors.textSecondary),
              ),
              if (showChevron) ...[
                const SizedBox(width: GeniusWalletConsts.space2),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: GeniusWalletColors.textSecondary,
                ),
              ],
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
