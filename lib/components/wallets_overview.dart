import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/account.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/wallets/view/genius_balance_display.dart';
import 'package:intl/intl.dart';

class WalletsOverview extends StatefulWidget {
  final Account? account;
  final GeniusApi geniusApi;
  const WalletsOverview({
    super.key,
    required this.geniusApi,
    required this.account,
  });
  @override
  WalletsOverviewState createState() => WalletsOverviewState();
}

class WalletsOverviewState extends State<WalletsOverview> {
  WalletsOverviewState();
  late Future<String?> futurePrices;
  bool useMinions = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: AutoSizeText(
                      'Current Balance',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.gw.textPrimary,
                        fontSize: 32,
                      ),
                    ),
                  ),
                  BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
                    builder: (context, state) {
                      if (state.selectedWallet == null) {
                        return const Center(child: Text('No wallet selected'));
                      }

                      if (state.selectedWallet?.walletType ==
                          WalletType.sgnus) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GeniusBalanceDisplay(useMinions: useMinions),
                            const SizedBox(height: 8),
                            _buildToggle(),
                          ],
                        );
                      }

                      final balance =
                          double.tryParse(state.selectedWalletBalance ?? '0') ??
                          0;
                      final displayBalance = balance == 0
                          ? "\$0.00"
                          : NumberFormat.simpleCurrency().format(balance);

                      if (balance == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'No funds available',
                            style: TextStyle(
                              color: context.gw.statusError,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }

                      return Flexible(
                        child: AutoSizeText(
                          displayBalance,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 36.0,
                            fontWeight: FontWeight.w500,
                            color: context.gw.textPrimary,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        // 14-08: the two SGNUS connection status widgets and the dashboard
        // job button that used to sit here (formerly
        // lib/components/sgnus/sgnus_connection_widget.dart and
        // lib/components/job/submit_job_dashboard_button.dart) were deleted -
        // three of the five shipped bugs 14-08 closes lived in those files;
        // the compute panel that replaces all three lives in
        // lib/dashboard/compute/ and lib/components/wallet_overview.dart.
        // This shadow file (GAP-06, `03-SHADOW-NAMES.md`) is dead code
        // reachable only from lib/dev/generated_closure_canary.dart's `Type`
        // literal - never mounted in the running app - so this is a
        // compile-only stub, not a UI regression.
        const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildToggle() {
    return ToggleButtons(
      isSelected: [!useMinions, useMinions],
      onPressed: (index) {
        setState(() {
          useMinions = index == 1;
        });
      },
      borderRadius: BorderRadius.circular(12),
      borderColor: context.gw.textPrimary24,
      selectedBorderColor: context.gw.textPrimary,
      fillColor: context.gw.textPrimary10,
      selectedColor: context.gw.textPrimary,
      constraints: const BoxConstraints(minHeight: 36, minWidth: 100),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/crypto/gnus.png", height: 20, width: 20),
            const SizedBox(width: 6),
            const Text("GNUS", style: TextStyle(fontSize: 13)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/crypto/minion.png",
              height: 20,
              width: 20,
            ),
            const SizedBox(width: 6),
            const Text("Minions", style: TextStyle(fontSize: 13)),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
