import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/account/account_drawer.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/nav_chip_style.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class AccountDropdownSelector extends StatefulWidget {
  final ValueChanged<Wallet>? onAccountSelected;
  final Wallet? initialSelected;

  const AccountDropdownSelector({
    super.key,
    this.onAccountSelected,
    this.initialSelected,
  });

  @override
  State<AccountDropdownSelector> createState() =>
      _AccountDropdownSelectorState();
}

class _AccountDropdownSelectorState extends State<AccountDropdownSelector> {
  Wallet? selectedWallet;
  String? savedWalletAddress;

  @override
  void initState() {
    super.initState();
    _loadSavedWallet();
  }

  Future<void> _loadSavedWallet() async {
    final address = Hive.box(walletBoxName).get(selectedWalletKey);
    if (!mounted) {
      return;
    }
    setState(() => savedWalletAddress = address);
  }

  Future<void> _showAccountDrawer() async {
    // The entry owns the real side effects (the WalletDetailsCubit update
    // and the Hive persistence write) - see AccountDrawer.show. This method
    // only does the widget-local work: skip if nothing changed, mirror the
    // selection locally, and fire the caller's own callback.
    final selected = await AccountDrawer.show(context);

    if (selected == null || selected == selectedWallet) {
      return;
    }

    setState(() => selectedWallet = selected);
    widget.onAccountSelected?.call(selected);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final wallets = state.wallets;
        if (wallets.isEmpty) {
          final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
          return Center(
            child: Text(
              "You have no wallets!",
              style: TextStyle(fontSize: 16, color: gw.textPrimary70),
            ),
          );
        }
        selectedWallet ??= wallets.firstWhere(
          (w) => w.address == savedWalletAddress,
          orElse: () => widget.initialSelected ?? wallets.first,
        );
        return Tooltip(
          message: "Select wallet",
          child: TextButton(
            style: navContextChipStyle(context),
            onPressed: () => _showAccountDrawer(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: GeniusWalletConsts.space4,
              children: [
                AccountAvatar(
                  wallet: selectedWallet!,
                  isSelected: false,
                  size: 25,
                ),
                if (MediaQuery.sizeOf(context).width >= GeniusBreakpoints.small)
                  Text(
                    selectedWallet!.walletType == WalletType.sgnus
                        ? 'Super Genius'
                        : WalletUtils.getAddressForDisplay(
                            selectedWallet!.address,
                          ),
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
}
