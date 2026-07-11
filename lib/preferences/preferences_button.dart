import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/network/network_dropdown_selector.dart';
import 'package:genius_wallet/preferences/gw_currency.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:provider/provider.dart';

/// Top-bar entry point for app preferences.
///
/// Network selection moved here from the top bar. Appearance toggles the
/// dark (black) / light (white) canvas. The Currency row is a static
/// placeholder for now (see HANDOFF.md §6).
class PreferencesButton extends StatelessWidget {
  const PreferencesButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GeniusWalletColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: GeniusWalletColors.borderSubtle, width: 1),
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
          child: Tooltip(
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
        _PrefRow(
          leading: const Icon(
            Icons.payments_outlined,
            size: 20,
            color: GeniusWalletColors.textSecondary,
          ),
          title: 'Currency',
          value: GWCurrency.instance.value,
          showChevron: true,
          onTap: () async {
            final picked = await ResponsiveDrawer.show<String>(
              context: context,
              title: 'Currency',
              children: [
                for (final c in gwCurrencies) _CurrencyOption(option: c),
              ],
            );
            if (picked != null) {
              await GWCurrency.instance.setCode(picked);
              if (mounted) setState(() {});
            }
          },
        ),
        _PrefRow(
          leading: Icon(
            GWAppearance.isLight
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            size: 20,
            color: GeniusWalletColors.textSecondary,
          ),
          title: 'Appearance',
          value: GWAppearance.isLight ? 'Light' : 'Dark',
          showChevron: true,
          onTap: () async {
            final picked = await ResponsiveDrawer.show<GWAppearanceMode>(
              context: context,
              title: 'Appearance',
              children: const [
                _AppearanceOption(
                  mode: GWAppearanceMode.dark,
                  label: 'Dark',
                  hint: 'Black canvas',
                  icon: Icons.dark_mode_outlined,
                ),
                _AppearanceOption(
                  mode: GWAppearanceMode.light,
                  label: 'Light',
                  hint: 'White canvas',
                  icon: Icons.light_mode_outlined,
                ),
              ],
            );
            if (picked != null) {
              await GWAppearance.instance.setMode(picked);
              if (mounted) setState(() {});
            }
          },
        ),
        const SizedBox(height: GeniusWalletConsts.space4),
      ],
    );
  }
}

class _CurrencyOption extends StatelessWidget {
  const _CurrencyOption({required this.option});

  final GWCurrencyOption option;

  @override
  Widget build(BuildContext context) {
    final isSelected = GWCurrency.instance.value == option.code;
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
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GeniusWalletConsts.radius2xl),
          ),
          leading: SizedBox(
            width: 32,
            child: Text(
              option.symbol.trim(),
              textAlign: TextAlign.center,
              style: GeniusWalletTypography.titleMd
                  .copyWith(color: GeniusWalletColors.brandPrimary),
            ),
          ),
          minLeadingWidth: 0,
          title: Text(option.code, style: GeniusWalletTypography.titleMd),
          subtitle: Text(option.label, style: GeniusWalletTypography.bodySm),
          trailing: isSelected
              ? const Icon(
                  Icons.check_circle_rounded,
                  color: GeniusWalletColors.brandPrimary,
                  size: 20,
                )
              : null,
          onTap: () => Navigator.of(context).pop(option.code),
        ),
      ),
    );
  }
}

class _AppearanceOption extends StatelessWidget {
  const _AppearanceOption({
    required this.mode,
    required this.label,
    required this.hint,
    required this.icon,
  });

  final GWAppearanceMode mode;
  final String label;
  final String hint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isSelected = GWAppearance.instance.value == mode;
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
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GeniusWalletConsts.radius2xl),
          ),
          leading: Icon(icon, size: 22, color: GeniusWalletColors.textPrimary),
          minLeadingWidth: 0,
          title: Text(label, style: GeniusWalletTypography.titleMd),
          subtitle: Text(hint, style: GeniusWalletTypography.bodySm),
          trailing: isSelected
              ? const Icon(
                  Icons.check_circle_rounded,
                  color: GeniusWalletColors.brandPrimary,
                  size: 20,
                )
              : null,
          onTap: () => Navigator.of(context).pop(mode),
        ),
      ),
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
              // Bounded: long network names ("Binance Smart Chain") must
              // ellipsize instead of overflowing the ListTile trailing slot.
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GeniusWalletTypography.bodyMd
                      .copyWith(color: GeniusWalletColors.textSecondary),
                ),
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
