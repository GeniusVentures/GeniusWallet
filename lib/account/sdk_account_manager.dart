import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/bottom_drawer/bottom_drawer.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/components/gw_icon.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/components/overlays/gw_dialog.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// A widget that shows the currently selected SDK account and opens a drawer
/// for managing SDK accounts (select, add, delete).
///
/// This is separate from [AccountDropdownSelector] because it manages the
/// native SDK's account list rather than the app's wallet list. The SDK
/// account determines which identity the node uses for processing and
/// minting operations.
class SDKAccountManagerButton extends StatelessWidget {
  const SDKAccountManagerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final selected = state.selectedSDKAccount;
        final accounts = state.sdkAccounts;

        if (accounts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Tooltip(
          message: 'SDK Accounts',
          child: TextButton(
            onPressed: () => _showSDKAccountDrawer(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6.0,
              children: [
                const GWIcon.material(Icons.settings_applications),
                if (MediaQuery.sizeOf(context).width >= GeniusBreakpoints.small)
                  Text(
                    selected != null
                        ? WalletUtils.getAddressForDisplay(selected)
                        : 'No account',
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                const GWIcon.material(Icons.arrow_drop_down),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSDKAccountDrawer(BuildContext context) async {
    await ResponsiveDrawer.show(
      context: context,
      // title/actions deliberately omitted here -- BottomDrawer supplies its
      // own header, so _ResponsiveDrawerScaffold must not render a competing
      // AppBar (04-UI-SPEC §5.1, the load-bearing binding rule from Phase 3).
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          final accounts = state.sdkAccounts;
          final selected = state.selectedSDKAccount;
          // Fail-soft read: registers the InheritedWidget dependency that
          // forces this content to rebuild on a live appearance toggle
          // (04-02 D-02).
          final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

          if (accounts.isEmpty) {
            return BottomDrawer(
              title: 'SDK Accounts',
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: GeniusWalletConsts.space10,
                  ),
                  child: Text(
                    'No SDK accounts available.\nAdd one to get started.',
                    textAlign: TextAlign.center,
                    style: GeniusWalletTypography.bodyMd.copyWith(
                      color: gw.textSecondary,
                    ),
                  ),
                ),
              ],
            );
          }

          return BottomDrawer(
            title: 'SDK Accounts',
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: GeniusWalletConsts.space4,
                ),
                child: Text(
                  'Select the account the SDK uses for processing:',
                  style: GeniusWalletTypography.labelMd.copyWith(
                    color: gw.textSecondary,
                  ),
                ),
              ),
              for (var i = 0; i < accounts.length; i++) ...[
                if (i > 0) const SizedBox(height: GeniusWalletConsts.space2),
                _buildAccountRow(
                  context,
                  accounts[i],
                  isSelected: accounts[i] == selected,
                ),
              ],
            ],
          );
        },
      ),
      // These two footer actions had NO inline style: override, so they were
      // fully dependent on the now-dropped outlinedButtonTheme
      // (04-RESEARCH §1/§4.2) -- explicitly restyled as GWButton secondary
      // so they never fall back to stock Material 3 defaults.
      footer: Padding(
        padding: const EdgeInsets.all(GeniusWalletConsts.space6),
        child: Row(
          spacing: GeniusWalletConsts.space4,
          children: [
            Expanded(
              child: GWButton(
                label: 'Add with mnemonic',
                leading: const GWIcon.material(Icons.text_fields),
                variant: GWButtonVariant.secondary,
                onPressed: () => _showAddWithMnemonicDialog(context),
              ),
            ),
            Expanded(
              child: GWButton(
                label: 'Add with private key',
                leading: const GWIcon.material(Icons.key),
                variant: GWButtonVariant.secondary,
                onPressed: () => _showAddWithPrivateKeyDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountRow(
    BuildContext context,
    String address, {
    required bool isSelected,
  }) {
    // Fail-soft read: registers the InheritedWidget dependency (on the
    // per-row context passed in from the drawer's own itemBuilder, NOT the
    // widget-level this.context) that forces this row to rebuild on a live
    // appearance toggle while the drawer stays open (04-02 D-02).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    // Mode-invariant brand accent for the selected row (formerly the
    // deepBlueTertiary text color + greenAccent tile fill, collapsed into a
    // single brandPrimary border/icon accent -- the row's own surface stays
    // on the appearance-aware gw.surfaceElevated in BOTH states, per
    // 04-06-PLAN's routing table; brandPrimary text directly on a light
    // surfaceElevated fails WCAG AA, which is why the accent lives on the
    // border/icon, not on the body text).
    final accentColor =
        isSelected ? GeniusWalletColors.brandPrimary : gw.textPrimary;

    final mnemonic = context.read<AppBloc>().api.getSelectedAccountMnemonic();

    return GWCard(
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space6,
        vertical: GeniusWalletConsts.space4,
      ),
      background: gw.surfaceElevated,
      border: Border.all(
        color: isSelected ? GeniusWalletColors.brandPrimary : gw.borderSubtle,
        width: isSelected ? 2 : 1,
      ),
      onTap: () {
        if (!isSelected) {
          context.read<AppBloc>().add(SelectSDKAccount(address));
          showAppSnackBar(
            context,
            'SDK account selected',
            duration: const Duration(seconds: 1),
          );
        }
      },
      child: Row(
        children: [
          GWIcon.material(
            isSelected ? Icons.check_circle : Icons.account_balance_wallet,
            color: accentColor,
          ),
          const SizedBox(width: GeniusWalletConsts.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  WalletUtils.getAddressForDisplay(address),
                  style: GeniusWalletTypography.bodySm.copyWith(
                    fontFamily: 'JetBrainsMono',
                    color: gw.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isSelected)
                  Text(
                    'Active processing account',
                    style: GeniusWalletTypography.labelMd.copyWith(
                      color: gw.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          isSelected
              ? MenuAnchor(
                  // Explicit menuStyle: the reconciled theme no longer
                  // supplies menuTheme, so an un-styled MenuAnchor container
                  // reverts to stock Material 3 (04-RESEARCH Pitfall 5).
                  style: MenuStyle(
                    backgroundColor:
                        WidgetStatePropertyAll(gw.surfaceElevated),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          GeniusWalletConsts.radiusLg,
                        ),
                      ),
                    ),
                  ),
                  builder: (context, controller, child) => IconButton(
                    icon: GWIcon.material(
                      Icons.more_vert,
                      color: accentColor,
                    ),
                    onPressed: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                  ),
                  menuChildren: [
                    MenuItemButton(
                      leadingIcon: GWIcon.material(
                        Icons.edit_location_alt,
                        color: gw.textPrimary,
                      ),
                      style: MenuItemButton.styleFrom(
                        foregroundColor: gw.textPrimary,
                      ),
                      onPressed: () => _showSetPayoutAddressDialog(context),
                      child: const Text('Set payout address'),
                    ),
                    if (mnemonic != null) ...[
                      MenuItemButton(
                        leadingIcon: GWIcon.material(
                          Icons.numbers,
                          color: gw.textPrimary,
                        ),
                        style: MenuItemButton.styleFrom(
                          foregroundColor: gw.textPrimary,
                        ),
                        onPressed: () => {
                          Clipboard.setData(ClipboardData(text: mnemonic)),
                        },
                        child: const Text("Copy mnemonic"),
                      ),
                      MenuItemButton(
                        leadingIcon: GWIcon.material(
                          Icons.qr_code,
                          color: gw.textPrimary,
                        ),
                        style: MenuItemButton.styleFrom(
                          foregroundColor: gw.textPrimary,
                        ),
                        onPressed: () async => {
                          // Mnemonic QR display kept UNCHANGED (03-GAP-
                          // INVENTORY §6): develop's existing qr_flutter
                          // usage, incl. its intentional white backdrop
                          // (mode-invariant, required for scannability --
                          // not routed through GWColors).
                          await showDialog<void>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              contentPadding: EdgeInsetsGeometry.all(16),
                              content: SizedBox(
                                width: GeniusBreakpoints.small * 0.5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      GeniusWalletConsts.borderRadiusCard,
                                    ),
                                    color: Colors.white,
                                  ),
                                  padding: EdgeInsets.all(4),
                                  child: QrImageView(data: mnemonic),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text('Cancel'),
                                ),
                              ],
                            ),
                          ),
                        },
                      ),
                    ],
                  ],
                )
              : IconButton(
                  icon: const GWIcon.material(
                    Icons.delete_outline,
                    color: GeniusWalletColors.statusError,
                  ),
                  tooltip: 'Delete account',
                  onPressed: () =>
                      _confirmDeleteSDKAccount(context, address, isSelected),
                ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteSDKAccount(
    BuildContext context,
    String address,
    bool isSelected,
  ) async {
    // The native SDK blocks deleting the selected account, but we also
    // guard on the Dart side so the user gets a clear message.
    if (isSelected) {
      showAppSnackBar(
        context,
        'Cannot delete the currently selected SDK account. '
        'Select a different account first.',
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Pure re-skin of develop's existing confirmation dialog (04-UI-SPEC
    // §4.1 D-06 note applies to the sibling wallet-drawer; this dialog
    // already confirms, so the same "resolved, not conditional" logic
    // holds here too). Copy preserved verbatim.
    final confirmed = await GWDialog.show<bool>(
      context: context,
      title: 'Delete SDK account',
      message:
          'Are you sure you want to delete the account ${WalletUtils.getAddressForDisplay(address)}?\n'
          'This action cannot be undone.',
      actions: [
        GWDialogAction(
          label: 'Cancel',
          onPressed: () =>
              Navigator.of(context, rootNavigator: true).pop(false),
        ),
        GWDialogAction(
          label: 'Delete',
          // Mode-invariant statusError destructive fill -- never
          // Colors.red/redAccent, never routed through GWColors.
          variant: GWButtonVariant.destructive,
          onPressed: () =>
              Navigator.of(context, rootNavigator: true).pop(true),
        ),
      ],
    );

    if (confirmed == true && context.mounted) {
      context.read<AppBloc>().add(DeleteSDKAccount(address));
      showAppSnackBar(
        context,
        'SDK account deleted',
        duration: const Duration(seconds: 1),
      );
    }
  }

  Future<void> _showAddWithMnemonicDialog(BuildContext context) async {
    final controller = TextEditingController();
    // SECURITY (V6): this dialog handles mnemonic key material. GWTextField
    // is a pure presentation-layer wrapper around the SAME
    // TextEditingController -- it never reads/logs the controller's value;
    // the value flows straight from controller.text.trim() into the pop
    // result below, exactly as develop's raw TextField did.
    final mnemonic = await GWDialog.show<String>(
      context: context,
      title: 'Add Account with Mnemonic',
      content: GWTextField(
        controller: controller,
        maxLines: 4,
        hint: 'Enter your 12 or 24 word mnemonic phrase',
      ),
      actions: [
        GWDialogAction(
          label: 'Cancel',
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
        GWDialogAction(
          label: 'Add Account',
          variant: GWButtonVariant.primary,
          onPressed: () => Navigator.of(context, rootNavigator: true)
              .pop(controller.text.trim()),
        ),
      ],
    );

    if (mnemonic != null && mnemonic.isNotEmpty && context.mounted) {
      final bloc = context.read<AppBloc>();
      bloc.add(AddSDKAccountWithMnemonic(mnemonic));
      // Refresh after a short delay to let the SDK process the addition.
      await Future.delayed(const Duration(milliseconds: 500));
      if (context.mounted) {
        bloc.add(RefreshSDKAccounts());
        showAppSnackBar(
          context,
          'Account added successfully',
          duration: const Duration(seconds: 1),
        );
      }
    }
  }

  Future<void> _showAddWithPrivateKeyDialog(BuildContext context) async {
    final controller = TextEditingController();
    // SECURITY (V6): this dialog handles private-key material. GWTextField
    // is a pure presentation-layer wrapper around the SAME
    // TextEditingController -- it never reads/logs the controller's value;
    // the value flows straight from controller.text.trim() into the pop
    // result below, exactly as develop's raw TextField did.
    final privateKey = await GWDialog.show<String>(
      context: context,
      title: 'Add Account with Private Key',
      content: GWTextField(
        controller: controller,
        hint: 'Enter your Ethereum private key (hex)',
      ),
      actions: [
        GWDialogAction(
          label: 'Cancel',
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
        GWDialogAction(
          label: 'Add Account',
          variant: GWButtonVariant.primary,
          onPressed: () => Navigator.of(context, rootNavigator: true)
              .pop(controller.text.trim()),
        ),
      ],
    );

    if (privateKey != null && privateKey.isNotEmpty && context.mounted) {
      final bloc = context.read<AppBloc>();
      bloc.add(AddSDKAccountWithPrivateKey(privateKey));
      // Refresh after a short delay to let the SDK process the addition.
      await Future.delayed(const Duration(milliseconds: 500));
      if (context.mounted) {
        bloc.add(RefreshSDKAccounts());
        showAppSnackBar(
          context,
          'Account added successfully',
          duration: const Duration(seconds: 1),
        );
      }
    }
  }

  Future<void> _showSetPayoutAddressDialog(BuildContext context) async {
    final controller = TextEditingController();
    final payoutAddress = await GWDialog.show<String>(
      context: context,
      title: 'Set Payout Address',
      content: GWTextField(
        controller: controller,
        hint: 'Enter the payout address (hex)',
      ),
      actions: [
        GWDialogAction(
          label: 'Cancel',
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
        GWDialogAction(
          label: 'Set Address',
          variant: GWButtonVariant.primary,
          onPressed: () => Navigator.of(context, rootNavigator: true)
              .pop(controller.text.trim()),
        ),
      ],
    );

    if (payoutAddress != null && payoutAddress.isNotEmpty && context.mounted) {
      context.read<AppBloc>().add(SetSDKPayoutAddress(payoutAddress));
      final result = context.read<AppBloc>().state.setPayoutAddressResult;
      if (result == GeniusNodeReturnValue.GENIUS_NODE_RET_OK) {
        showAppSnackBar(
          context,
          'Payout address set successfully',
          duration: const Duration(seconds: 1),
        );
      } else {
        showAppSnackBar(
          context,
          'Failed to set payout address: ${result?.name}',
          duration: const Duration(seconds: 3),
        );
      }
    }
  }
}
