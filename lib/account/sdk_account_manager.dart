import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';

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
                const Icon(Icons.settings_applications),
                if (MediaQuery.sizeOf(context).width >= GeniusBreakpoints.small)
                  Text(
                    selected != null
                        ? WalletUtils.getAddressForDisplay(selected)
                        : 'No account',
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                const Icon(Icons.arrow_drop_down),
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
      title: 'SDK Accounts',
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          final accounts = state.sdkAccounts;
          final selected = state.selectedSDKAccount;

          if (accounts.isEmpty) {
            return const Center(
              child: Text(
                'No SDK accounts available.\nAdd one to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'Select the account the SDK uses for processing:',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (context, i) => _buildAccountRow(
                    context,
                    accounts[i],
                    isSelected: accounts[i] == selected,
                  ),
                  itemCount: accounts.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 6),
                ),
              ),
            ],
          );
        },
      ),
      footer: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          spacing: 8,
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showAddWithMnemonicDialog(context),
                icon: const Icon(Icons.text_fields, size: 18),
                label: const AutoSizeText('Add with mnemonic', maxLines: 1),
              ),
            ),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showAddWithPrivateKeyDialog(context),
                icon: const Icon(Icons.key, size: 18),
                label: const AutoSizeText('Add with private key', maxLines: 1),
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
    final textColor = isSelected
        ? GeniusWalletColors.deepBlueTertiary
        : Colors.white;
    final subColor = isSelected
        ? GeniusWalletColors.deepBlueTertiary
        : Colors.grey;

    final mnemonic = context.read<AppBloc>().api.getSelectedAccountMnemonic();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        selected: isSelected,
        selectedTileColor: Colors.greenAccent,
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
        leading: Icon(
          isSelected ? Icons.check_circle : Icons.account_balance_wallet,
          color: textColor,
        ),
        title: Text(
          WalletUtils.getAddressForDisplay(address),
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'JetBrainsMono',
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: isSelected
            ? Text(
                'Active processing account',
                style: TextStyle(fontSize: 12, color: subColor),
              )
            : null,
        trailing: isSelected
            ? MenuAnchor(
                builder: (context, controller, child) => IconButton(
                  icon: Icon(Icons.more_vert, size: 20, color: textColor),
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
                    leadingIcon: const Icon(Icons.edit_location_alt),
                    child: Text('Set payout address'),
                    onPressed: () => _showSetPayoutAddressDialog(context),
                  ),
                  if (mnemonic != null) MenuItemButton(
                    leadingIcon: const Icon(Icons.numbers),
                    child: Text("Copy mnemonic"),
                    onPressed: () => {
                      Clipboard.setData(ClipboardData(text: mnemonic))
                    },
                  ),
                ],
              )
            : IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Colors.redAccent,
                ),
                tooltip: 'Delete account',
                onPressed: () =>
                    _confirmDeleteSDKAccount(context, address, isSelected),
              ),
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

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete SDK account'),
        content: Text(
          'Are you sure you want to delete the account ${WalletUtils.getAddressForDisplay(address)}?\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
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
    final mnemonic = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Account with Mnemonic'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Enter your 12 or 24 word mnemonic phrase',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Add Account'),
          ),
        ],
      ),
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
    final privateKey = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Account with Private Key'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter your Ethereum private key (hex)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Add Account'),
          ),
        ],
      ),
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
    final payoutAddress = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Payout Address'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter the payout address (hex)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Set Address'),
          ),
        ],
      ),
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
