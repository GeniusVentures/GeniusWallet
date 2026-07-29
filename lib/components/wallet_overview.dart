import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/account.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/components/data/gw_animated_number.dart';
import 'package:genius_wallet/components/job/submit_job_dashboard_button.dart';
import 'package:genius_wallet/components/sgnus/sgnus_connection_widget.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
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
    // Appearance-aware reads (04-02/04-04 discipline): registering the Theme
    // dependency here is what makes this subtree re-skin on a live appearance
    // flip. Mode-invariant tokens (statusError, brandPrimary) stay on the
    // GeniusWalletColors statics and are deliberately NOT routed through gw.
    // Kept ABOVE the LayoutBuilder below, deliberately: moving it into the
    // builder closure would relocate this dependency onto the LayoutBuilder
    // element for no benefit — the same instruction 260721-e3r gave for
    // GWEmptyState, for the same reason.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    // WHY this exists (05-08, gap B1): this widget is mounted in a hard
    // 300px-capped slot at two call sites (dashboard_screen.dart:198-201,
    // :270-273); DashboardScrollContainer eats 24px of that, leaving 276px.
    // The SGNUS-wallet branch below — a 48px balance line, a toggle row, a
    // connection button, a status row that grows by ~30px while processing,
    // and a conditional 48px CTA — does not fit in what remains.
    //
    // WHY the minHeight feedback is what makes this safe: it hands the
    // Column the EXACT SAME bound it receives today, so with
    // `mainAxisAlignment`/`mainAxisSize` unchanged, `RenderFlex` computes
    // its centering leftover from the same size — the rendering where there
    // IS room is identical, not merely hopefully so. The only thing that
    // changed is `maxHeight` is now unbounded, so content that does not fit
    // gets scrolled instead of striped.
    //
    // WHY no threshold constant appears here, unlike `GWEmptyState`'s
    // compact tier: this widget's intrinsic height is not derivable from
    // constants — an FFI-polled `AutoSizeText`, three possible connection
    // animations, and a conditional CTA — and two agents auditing it
    // disagreed by ~29px on what that height even is. A structural fix does
    // not depend on which of them was right.
    //
    // Nested-scrollable interaction, checked and load-bearing — do not
    // "fix" this later: the outer `RefreshIndicator` in
    // `OneColumnDashBoardView` is unaffected while this content fits,
    // because a `Scrollable` whose min and max scroll extents are equal
    // installs no drag recognizer and never enters the gesture arena. When
    // the content does not fit, the inner view scrolls — which is the
    // intended behavior in the only state where the two differ.
    //
    // ponytail: in the overflowing state the user must scroll inside a
    // 300px card to reach the last child; this widget does not shrink its
    // content the way `GWEmptyState` does. Upgrade path: give the panel
    // more height at the dashboard call sites, or add a compact tier here
    // once this widget's height is derivable from constants.
    //
    // KNOWN RISK: `LayoutBuilder` throws if an ancestor queries intrinsic
    // dimensions of its subtree. Neither dashboard call site does — both
    // reach this widget through a flex row and a plain `Container`/
    // `Padding`, with no `IntrinsicHeight` anywhere in the chain.
    return LayoutBuilder(
      builder: (context, constraints) {
        final double minHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 0.0;
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: _buildColumn(gw),
          ),
        );
      },
    );
  }

  Widget _buildColumn(GWColors gw) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Current Balance',
          style: GeniusWalletTypography.headlineMd.copyWith(
            color: gw.textSecondary,
          ),
        ),
        BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
          builder: (context, state) {
            if (state.selectedWallet == null) {
              return Text(
                'No wallet selected',
                style: GeniusWalletTypography.bodyMd.copyWith(
                  color: gw.textSecondary,
                ),
              );
            }

            if (state.selectedWallet?.walletType == WalletType.sgnus) {
              return Column(
                children: [
                  GeniusBalanceDisplay(useMinions: useMinions),
                  _buildToggle(),
                ],
              );
            }

            final balance =
                double.tryParse(state.selectedWalletBalance ?? '0') ?? 0;

            if (balance == 0) {
              return Text(
                'No funds available',
                style: GeniusWalletTypography.bodyMd.copyWith(
                  color: context.gw.statusError,
                ),
              );
            }

            // Counts up on first paint and on value change. The formatting
            // GWAnimatedNumber does internally (grouped, 2 decimals + the
            // locale's currency symbol as prefix) reproduces develop's
            // NumberFormat.simpleCurrency() output — the symbol is read off
            // that same formatter rather than hardcoded so a non-USD locale
            // keeps rendering as it did before the re-skin.
            return GWAnimatedNumber(
              value: balance,
              prefix: NumberFormat.simpleCurrency().currencySymbol,
              style: GeniusWalletTypography.numericDisplay.copyWith(
                color: gw.textPrimary,
              ),
              textAlign: TextAlign.left,
            );
          },
        ),
        const SizedBox(height: 20),
        const SGNUSConnectionWidget(),
        const SGNUSConnectionStatusWidget(),
        BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
          builder: (context, state) {
            if (state.selectedWallet != null) {
              return StreamBuilder<SGNUSConnection>(
                stream: context.read<GeniusApi>().getSGNUSConnectionStream(),
                builder: (context, snapshot) {
                  final connection = snapshot.data;
                  return SubmitJobDashboardButton(
                    walletDetailsCubit: context.read<WalletDetailsCubit>(),
                    walletAddress: state.selectedWallet!.address,
                    gnusConnectedWalletAddress: connection?.walletAddress ?? "",
                  );
                },
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
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
      fillColor: context.gw.brandPrimaryStrong,
      // UI-SPEC §3.1's table specifies textPrimary here, but that is white in
      // dark mode and white-on-brandPrimary measures 1.96:1 — a hard WCAG AA
      // failure. textOnBrand measures 10.12:1 and is the token this project
      // already pairs with brand fills (theme.dart's onPrimary/onSecondary,
      // UI-SPEC §3.3's badge-icon swap, Phase 4 §1.3). See SUMMARY.
      selectedColor: context.gw.textOnBrand,
      borderColor: context.gw.borderSubtle,
      constraints: const BoxConstraints(minHeight: 36, minWidth: 100),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            Image.asset("assets/images/crypto/gnus.png", height: 20, width: 20),
            const Text("GNUS", style: TextStyle(fontSize: 13)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            Image.asset(
              "assets/images/crypto/minion.png",
              height: 20,
              width: 20,
            ),
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
