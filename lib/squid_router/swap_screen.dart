import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/hive/services/transaction_storage_service.dart';
import 'package:genius_wallet/squid_router/held_tokens.dart';
import 'package:genius_wallet/squid_router/models/squid_balance.dart';
import 'package:genius_wallet/squid_router/models/squid_route_response.dart';
import 'package:genius_wallet/squid_router/models/squid_swap_params.dart';
import 'package:genius_wallet/squid_router/models/squid_token_info.dart';
import 'package:genius_wallet/squid_router/route_details_card.dart';
import 'package:genius_wallet/squid_router/squid_token_service.dart';
import 'package:genius_wallet/squid_router/squid_util.dart';
import 'package:genius_wallet/squid_router/swap_cta_state.dart';
import 'package:genius_wallet/squid_router/swap_field.dart';
import 'package:genius_wallet/squid_router/swap_preselection.dart';
import 'package:genius_wallet/squid_router/swap_seam.dart';
import 'package:genius_wallet/squid_router/swap_settings_drawer.dart';
import 'package:genius_wallet/squid_router/token_flip_button.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

/// The list one side of the swap may pick from: everything except the token the
/// OTHER side already holds.
///
/// Pure and top-level so the rule can be pinned by a test, the same shape
/// `sdkRowActions` took. It exists because the rule was previously written
/// inline, twice, and both copies also excluded THIS side's own token - so the
/// token you had just chosen vanished from its own picker and the `selectedToken`
/// the drawer is handed could never match a row.
List<SquidTokenInfo> tokensForSide(
  List<SquidTokenInfo> all,
  SquidTokenInfo? otherSide,
) => all.where((t) => !t.sameAs(otherSide)).toList();

class SwapScreen extends StatefulWidget {
  const SwapScreen({super.key, this.preselectSymbol, this.preselectChainId});

  /// Seat this token when the screen opens, if the catalogue has it.
  ///
  /// Set when arriving from a coin page's Swap button — landing on an empty
  /// form after tapping Swap ON a specific coin makes the user re-find the
  /// thing they were already looking at.
  ///
  /// **Which side it lands on depends on whether the wallet holds it**, which
  /// is forced by the pay-side holdings filter (`held_tokens.dart`): seating an
  /// unheld token on the pay side would put back exactly what that filter
  /// exists to remove. So a held coin seats as "You Pay" (you are spending it)
  /// and an unheld one as "You Receive" (you are acquiring it) — both readings
  /// of "swap this coin", chosen by what the wallet can actually do.
  ///
  /// Null-safe by design: an unmatched symbol seats nothing rather than
  /// guessing. The catalogue is `mockTokens` today (13 entries), so plenty of
  /// real coins — GNUS among them — have no match at all.
  final String? preselectSymbol;

  /// Narrows the match when the same symbol exists on several chains, which is
  /// the normal case (ETH is on 1, 137 and 80001). Ignored when null.
  final int? preselectChainId;

  @override
  State<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> {
  List<SquidTokenInfo> tokens = [];
  SquidTokenInfo? fromToken;
  SquidTokenInfo? toToken;
  bool isLoading = true;
  String fromAmount = '';
  String toAmount = '';
  Timer? _debounce;
  final TextEditingController fromAmountController = TextEditingController();
  final TextEditingController toAmountController = TextEditingController();
  SquidRouteResponse? fetchedRoute;
  double slippage = 0.5; // Default slippage

  // D-09 / criterion 2: the CTA ladder's own state (swap_cta_state.dart).
  bool isFetchingRoute = false;
  bool routeError = false;
  bool isSubmitting = false;

  /// The selected pay token's balance as a number, or null when unknown.
  /// Never accuse the user of an insufficient balance on missing data.
  double? get fromBalanceAmount => fromToken?.balance?.amountAsDouble;

  @override
  void initState() {
    super.initState();
    _loadTokens();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    fromAmountController.dispose();
    toAmountController.dispose();
    super.dispose();
  }

  /// Seats [SwapScreen.preselectSymbol] once the catalogue and balances have
  /// merged — it must run AFTER the merge, or every candidate still has a null
  /// balance and the held/unheld decision below would always answer "unheld".
  ///
  /// Deliberately does nothing when the symbol does not match. Guessing a
  /// neighbouring token would be worse than an empty form: the user would have
  /// to notice the wrong one before correcting it.
  void _applyPreselection() {
    if (fromToken != null || toToken != null) {
      return;
    }

    final result = resolvePreselection(
      tokens: tokens,
      symbol: widget.preselectSymbol,
      chainId: widget.preselectChainId,
    );
    if (result == null) {
      return;
    }

    setState(() {
      switch (result.side) {
        case PreselectSide.pay:
          fromToken = result.token;
        case PreselectSide.receive:
          toToken = result.token;
      }
    });
  }

  Future<void> _loadTokens() async {
    try {
      final walletState = context.read<WalletDetailsCubit>().state;
      final walletAddress = walletState.selectedWallet?.address;
      final chainId = walletState.selectedNetwork?.chainId;

      final result = await SquidTokenService.fetchTokens();
      final balances = await SquidTokenService.fetchBalances(
        chainIds: ["$chainId"],
        walletAddress: walletAddress!,
      );

      // Merge balances into tokens
      for (final token in result) {
        final matchingBalance = balances.cast<SquidBalance?>().firstWhere(
          (b) =>
              b!.symbol.toLowerCase() == token.symbol.toLowerCase() &&
              b.chainId.toLowerCase() ==
                  token.chainId.toString().toLowerCase() &&
              b.address.toLowerCase() == token.address.toLowerCase(),
          orElse: () => null,
        );
        token.balance = matchingBalance;
      }

      setState(() {
        tokens = result;
        isLoading = false;
      });
      _applyPreselection();
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        showAppSnackBar(
          context,
          'Failed to load tokens. Check your connection and try again.',
        );
      }
    }
  }

  void _flipTokens() {
    setState(() {
      // Flip tokens
      final tempToken = fromToken;
      fromToken = toToken;
      toToken = tempToken;

      // Flip amounts
      final tempAmount = fromAmount;
      fromAmount = toAmount;
      toAmount = tempAmount;

      // Update controllers
      fromAmountController.text = fromAmount;
      toAmountController.text = toAmount;
    });

    _debouncedFetchRoute(); // Re-fetch route after flipping
  }

  bool get canSwap =>
      fromToken != null &&
      toToken != null &&
      fromAmount.isNotEmpty &&
      double.tryParse(fromAmount) != null;

  SquidSwapParams? get swapParams {
    if (!canSwap) {
      return null;
    }

    final walletState = context.read<WalletDetailsCubit>().state;
    final fromAddress = walletState.selectedWallet?.address;
    final toAddress = walletState.selectedWallet?.address;

    if (fromAddress == null || toAddress == null) {
      return null;
    }

    return SquidSwapParams(
      fromChain: fromToken!.chainId,
      fromToken: fromToken!.address,
      fromAmount: fromAmount,
      toChain: toToken!.chainId,
      toToken: toToken!.address,
      fromAddress: fromAddress,
      toAddress: toAddress,
      slippage: slippage,
    );
  }

  Future<void> _fetchRoute() async {
    if (!canSwap) {
      return;
    }

    final params = swapParams;
    if (params == null) {
      return;
    }

    setState(() {
      isFetchingRoute = true;
      routeError = false;
    });

    try {
      final route = await SquidTokenService.getRoute(params);
      final formatted = formatTokenAmount(
        BigInt.parse(route.toAmount),
        toToken!.decimals,
      );
      setState(() {
        toAmount = formatted;
        toAmountController.text = formatted;
        fetchedRoute = route;
        isFetchingRoute = false;
      });
    } catch (e) {
      // D-09 HARD CONTRACT: a failed fetch must never leave a stale quote on
      // screen. Null the route, clear the receive controller (the field then
      // shows the em-dash placeholder), hide the route card and surface a
      // red inline notice with an enabled Retry CTA. The snackbar stays as a
      // supplementary toast, not the mechanism.
      setState(() {
        routeError = true;
        fetchedRoute = null;
        toAmount = '';
        toAmountController.clear();
        isFetchingRoute = false;
      });
      if (mounted) {
        showAppSnackBar(
          context,
          'Failed to fetch route. Check your input and try again.',
        );
      }
    }
  }

  void _debouncedFetchRoute() {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchRoute();
    });
  }

  /// The READY rung's submit action — byte-identical to develop's inline
  /// closure (D-01/D-02: the TODO markers stay, nothing here invokes Squid
  /// or upgrades the copy's claims), only now wrapped with the `isSubmitting`
  /// flag around the real await so the CTA can show its "Submitting swap…"
  /// rung for exactly as long as this genuinely takes.
  Future<void> _submitSwap() async {
    final params = swapParams;
    if (params == null) {
      return;
    }

    setState(() => isSubmitting = true);
    try {
      debugPrint('Swapping with params: ${params.toJson()}');
      // TODO: invoke Squid API
      //
      // WHOEVER WIRES THIS: move the `_clearForm()` call at the bottom of this
      // method behind the real success. Today nothing executes here (D-01), so
      // there is no genuine success to hang the reset on and clearing after
      // the local record is written is the best available. Once a live call
      // lands, a rejected, reverted or timed-out swap would reach the same
      // line and wipe amounts the user typed and still needs.

      final walletState = context.read<WalletDetailsCubit>().state;
      final walletAddress = walletState.selectedWallet?.address;
      final walletNetwork = walletState.selectedNetwork?.symbol;
      final transactionsCubit = context.read<TransactionsCubit>();

      // TODO: record transaction...
      // IF SUCCESSS ...
      final transaction = Transaction(
        hash: "",
        fromAddress: walletAddress!,
        recipients: [
          TransferRecipients(toAddr: walletAddress, amount: toAmount),
        ],
        timeStamp: DateTime.now(),
        transactionDirection: TransactionDirection.received,
        // Blank, not fromAmount: nothing executed (D-01), so no network fee
        // exists to report. The receipt's blank-fee guard (D-20) omits the
        // row rather than printing what the user pays under "Network Fee".
        fees: '',
        coinSymbol: walletNetwork!,
        transactionStatus: TransactionStatus.completed,
        type: TransactionType.swap,
        toAmount: toAmount,
        toIconUrl: toToken?.logoURI,
        fromSymbol: fromToken?.symbol,
        toSymbol: toToken?.symbol,
        fromAmount: fromAmount,
        fromIconUrl: fromToken?.logoURI,
      );

      ToastManager.instance.showToast(
        context: context,
        title: 'Swap Submitted',
        message:
            'Swapping ${params.fromAmount} ${fromToken?.symbol ?? ""} for ${toToken?.symbol ?? ""}.',
        type: ToastType.success,
      );

      // D-03/D-04: the shared 031-B receipt replaces the superseded
      // SwapSuccessDrawer, alongside the toast above — never instead of it.
      if (mounted) {
        showTransactionDetails(context, transaction);
      }
      transactionsCubit.addTransaction(transaction);

      // save to hive
      await TransactionStorageService().addTransaction(
        walletAddress,
        transaction,
      );

      // The receipt opens ON TOP of this screen, so whatever the form still
      // holds is what the user comes back to when they close it: a fully
      // populated swap, one stray tap on the CTA away from running the whole
      // thing again. Read the TODO above before moving this line.
      if (mounted) {
        _clearForm();
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  /// Returns the form to its empty state after a submit, KEEPING the token
  /// pair seated.
  ///
  /// The wallet/network listener in `build` runs the same reset and also nulls
  /// `fromToken`/`toToken`. That difference is deliberate: there the chain
  /// changed underneath the form, so the seated tokens are about to stop being
  /// members of the catalogue `_loadTokens` is reloading. Nothing changed
  /// here. The pair the user just traded is the likeliest pair they want
  /// again, and re-picking both out of a drawer is the expensive half of this
  /// form.
  void _clearForm() {
    // A quote debounced from the last keystroke would otherwise land on an
    // empty form. It already refuses (`_fetchRoute` returns on `!canSwap`), so
    // this is about not leaving a timer alive with nothing left to do.
    _debounce?.cancel();
    setState(() {
      fromAmount = '';
      toAmount = '';
      fromAmountController.clear();
      toAmountController.clear();
      fetchedRoute = null;
      // Unreachable from the READY rung that got us here - the route-error
      // rung retries rather than submits - but a "clean state" that left a red
      // notice standing would not be one. `isFetchingRoute` is deliberately
      // NOT touched: `ready` already implies no fetch is in flight, and
      // forcing the flag would desync a real one if that ever changes.
      routeError = false;
    });
  }

  /// D-09 / finding 22's inline notice — background `statusError` @ ~12%
  /// alpha, `radiusMd`, space6/space8 padding, icon + copy both in
  /// `statusError`. Kept inline in this file per the UI-SPEC (no shared
  /// `GWInlineNotice` primitive exists and this phase does not add one).
  Widget _buildRouteErrorNotice(GWColors gw) {
    return Container(
      // Vertical only — same reason as RouteDetailsCard: this notice replaces
      // that card in the layout, so it has to sit on the same edge as it and
      // as the amount cards above.
      margin: const EdgeInsets.symmetric(vertical: GeniusWalletConsts.space4),
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space8,
        vertical: GeniusWalletConsts.space6,
      ),
      decoration: BoxDecoration(
        color: gw.statusError.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: gw.statusError, size: 18),
          const SizedBox(width: GeniusWalletConsts.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Couldn't fetch a route.",
                  style: GeniusWalletTypography.labelMd.copyWith(
                    color: gw.statusError,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: GeniusWalletConsts.space2),
                Text(
                  'Check your connection and try again — the quote above is '
                  'not current.',
                  style: GeniusWalletTypography.labelMd.copyWith(
                    color: gw.statusError,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The CTA ladder (criterion 2 / D-09). `resolveSwapCtaState` +
  /// `swapCtaLabel` + `swapCtaEnabled` (swap_cta_state.dart) are the single
  /// source of truth — this method only maps a resolved state to paint. The
  /// two rungs that share the brand gradient (`ready`, `routeError`) render
  /// through the real `GWButton(variant: GWButtonVariant.gradient)`; the
  /// three disabled rungs plus `insufficientBalance` reuse the shipped
  /// `textPrimary38`-on-`surfaceMenu` disabled treatment (D-15) — the
  /// insufficient rung swaps in the `statusError` pair per the UI-SPEC's CTA
  /// state → colour table. The CTA always renders — the old canSwap-gated
  /// visibility check is gone; a ladder whose disabled rungs never appear is
  /// not a ladder.
  Widget _buildSwapCta(GWColors gw) {
    final state = resolveSwapCtaState(
      hasBothTokens: fromToken != null && toToken != null,
      fromAmount: fromAmount,
      fromBalance: fromBalanceAmount,
      isFetchingRoute: isFetchingRoute,
      hasRoute: fetchedRoute != null,
      routeError: routeError,
      isSubmitting: isSubmitting,
    );
    final label = swapCtaLabel(state, symbol: fromToken?.symbol);
    final enabled = swapCtaEnabled(state);

    if (state == SwapCtaState.ready || state == SwapCtaState.routeError) {
      return Padding(
        // Vertical only: EdgeInsets.all inset the CTA 16px inside the amount
        // cards, so the button's edge disagreed with every card above it.
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: GWButton(
          variant: GWButtonVariant.gradient,
          size: GWButtonSize.lg,
          expand: true,
          label: label,
          // ROUTE-ERROR RUNG: retry fetches directly — a user tapping Retry
          // should not wait out the 500ms debounce.
          onPressed: !enabled
              ? null
              : state == SwapCtaState.routeError
              ? _fetchRoute
              : _submitSwap,
        ),
      );
    }

    final isInsufficient = state == SwapCtaState.insufficientBalance;
    final background = isInsufficient
        ? gw.statusError.withValues(alpha: 0.12)
        : gw.surfaceMenu;
    final foreground = isInsufficient ? gw.statusError : gw.textPrimary38;

    return Padding(
      // Same edge as the gradient rung above — the two must not disagree, or
      // the CTA would shift sideways as the ladder changes rung.
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusLg),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state == SwapCtaState.submitting) ...[
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(foreground),
                    ),
                  ),
                  const SizedBox(width: GeniusWalletConsts.space4),
                ],
                Text(
                  label,
                  style: GeniusWalletTypography.titleLg.copyWith(
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<WalletDetailsCubit, WalletDetailsState>(
        // If wallet or network changes
        listenWhen: (previous, current) =>
            previous.selectedWallet?.address !=
                current.selectedWallet?.address ||
            previous.selectedNetwork?.chainId !=
                current.selectedNetwork?.chainId,
        listener: (context, state) {
          // reset UI
          setState(() {
            fromToken = null;
            toToken = null;
            fromAmount = '';
            toAmount = '';
            fromAmountController.clear();
            toAmountController.clear();
            fetchedRoute = null;
            isLoading = true;
          });

          // Refetch tokens and balances
          _loadTokens();
        },
        child: _buildSwapContent(context),
      ),
    );
  }

  /// D-07 · sketch 105 A1's soft brand-sheen wash: two overlapping low-alpha
  /// radial glows behind the focused column. `IgnorePointer`-wrapped so it
  /// can never intercept taps; alpha is scaled down in light mode so the
  /// wash never competes with card contrast. Colours come from the brand
  /// tokens (never a literal sketch hex).
  Widget _buildSheen() {
    final isLight = GWAppearance.isLight;
    final cyanAlpha = isLight ? 0.05 : 0.10;
    final mintAlpha = isLight ? 0.04 : 0.08;
    return IgnorePointer(
      child: Stack(
        children: [
          Align(
            alignment: const Alignment(-0.3, -0.7),
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    context.gw.brandPrimaryStrong.withValues(alpha: cyanAlpha),
                    context.gw.brandPrimaryStrong.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.4, -0.3),
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    context.gw.brandSecondaryStrong.withValues(
                      alpha: mintAlpha,
                    ),
                    context.gw.brandSecondaryStrong.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwapContent(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: Loading()));
    }

    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this subtree to rebuild on a live appearance toggle (04-04 discipline).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _buildSheen()),
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: Padding(
                // Shared gap and gutter (`GeniusBreakpoints`), so the title
                // lands at the same X as the other tabs.
                padding: EdgeInsets.fromLTRB(
                  GeniusBreakpoints.pageGutter(context),
                  GeniusBreakpoints.pageTitleGap(context),
                  GeniusBreakpoints.pageGutter(context),
                  8,
                ),
                child: ConstrainedBox(
                  // xxl: this is the PAGE frame, not the card frame — unified
                  // with Transactions/Markets/News so the title lands at the
                  // same X.
                  constraints: const BoxConstraints(
                    maxWidth: GeniusBreakpoints.xxl,
                  ),
                  child: Column(
                    // stretch: the header takes the full capped width
                    // instead of shrink-wrapping and getting centred
                    // (transactions_screen.dart does the same).
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: ConstrainedBox(
                          // D-07 · sketch 105 A1: focused column, 500px -> 560px.
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: Padding(
                            // Page horizontal padding applied once at the
                            // column level so the header and the two cards
                            // share one left edge.
                            padding: const EdgeInsets.symmetric(
                              horizontal: GeniusWalletConsts.space10,
                            ),
                            child: Column(
                              children: [
                                // The header lives INSIDE the focused column,
                                // so it and the two cards share one left
                                // edge, and it is CENTRED at every width -
                                // the only one of the nine page headers that
                                // is. Two decisions, and the second one is a
                                // road already walked:
                                //
                                // **Jakub, 2026-07-26 - centred.** A
                                // left-gutter title with the form parked in
                                // the middle of a 1536 frame left the two
                                // agreeing on nothing. The settings glyph
                                // sits on the column's right edge, where it
                                // was before the GWPageHeader migration
                                // (905a2a91).
                                //
                                // **2026-08-10 - left on the phone: TRIED,
                                // REJECTED ON DEVICE.** The argument was that
                                // at 390 the column IS the page, so there is
                                // no wide frame left to disagree with, and
                                // every other tab reads left. It shipped as a
                                // `useDesktopLayout` split, Jakub looked at
                                // it on his iPhone the same hour and asked
                                // for the centre back, subtitle included. Do
                                // not re-run this experiment: it is not that
                                // nobody thought of it.
                                //
                                // What DID survive from that pass is the
                                // vertical fix, which was always a separate
                                // request: the glyph rides the TITLE's line,
                                // the relationship `/transactions` already
                                // has between its filter trigger and its
                                // title. Before it, the glyph's centre sat
                                // 22px below the title's, because a plain
                                // `trailing` centres on the whole identity
                                // block - title + `space2` + subtitle.
                                GWPageHeader(
                                  title: "Swap",
                                  subtitle: "Trade any token across chains",
                                  centered: true,
                                  trailingOnTitleLine: true,
                                  trailing: _SwapSettingsTrigger(
                                    onPressed: () {
                                      SwapSettingsDrawer.show(
                                        context,
                                        initialSlippage: slippage,
                                        onSlippageChanged: (value) {
                                          setState(() {
                                            slippage = value;
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                                // The two amount cards, with the flip control in
                                // the seam between them (D-07). SwapSeam
                                // computes that seam as the pay card's
                                // laid-out height plus half the gap, so the
                                // control cannot drift as the two cards
                                // diverge in height - which they do the moment
                                // a pay token is selected and its pill gains a
                                // logo.
                                //
                                // Two approaches were rejected, both for
                                // reasons worth not rediscovering. The control
                                // is NOT put inside the Column behind an
                                // overflowing wrapper: a RenderBox refuses
                                // hits outside its own size, so most of the
                                // 44px target would have been dead to taps
                                // while looking perfectly correct. And it is
                                // NOT positioned from a measured height fed
                                // back through setState: that costs a frame of
                                // lag on every height change and puts a
                                // derived number back into the layout.
                                //
                                // No hardcoded pixel offset exists here. The
                                // only numbers are the space8 token below and
                                // the children's own measured sizes.
                                SwapSeam(
                                  gap: GeniusWalletConsts.space8,
                                  payCard: SwapField(
                                    label: "You Pay",
                                    controller: fromAmountController,
                                    onChanged: (val) {
                                      setState(() => fromAmount = val);
                                      _debouncedFetchRoute();
                                    },
                                    selectedToken: fromToken,
                                    isSelectingFrom: true,
                                    // The pay side offers ONLY what the wallet
                                    // can spend (`heldTokens`) - you cannot
                                    // swap a BNB you do not have, and the old
                                    // full-catalogue list only revealed that at
                                    // the CTA. The receive side below is
                                    // deliberately NOT filtered.
                                    pickerEmptyTitle: 'No tokens to swap',
                                    pickerEmptyMessage:
                                        'This wallet holds no tokens with '
                                        'a balance on the selected '
                                        'network. Receive or buy a token '
                                        'to start swapping.',
                                    // Hide only the OTHER side's token. The
                                    // hand-written filter this replaces dropped
                                    // `fromToken` too, so the token you had
                                    // just picked was missing from its own
                                    // picker and `selectedToken` above could
                                    // never render - the row it marks was
                                    // filtered out first.
                                    tokens: tokensForSide(
                                      heldTokens(tokens),
                                      toToken,
                                    ),
                                    onTokenSelected: (token) {
                                      setState(() => fromToken = token);
                                      _debouncedFetchRoute();
                                    },
                                  ),
                                  receiveCard: SwapField(
                                    label: "You Receive",
                                    controller: toAmountController,
                                    onChanged: (val) =>
                                        setState(() => toAmount = val),
                                    selectedToken: toToken,
                                    isSelectingFrom: false,
                                    // D-09: on a failed route fetch the field
                                    // shows an em dash, never a stale amount.
                                    emptyPlaceholder: routeError ? '—' : null,
                                    // Mirror of the You Pay list: hide the
                                    // other side only, keep this side's own
                                    // token so it can show selected.
                                    tokens: tokensForSide(tokens, fromToken),
                                    onTokenSelected: (token) {
                                      setState(() => toToken = token);
                                      _debouncedFetchRoute();
                                    },
                                  ),
                                  control: TokenFlipButton(onFlip: _flipTokens),
                                ),
                                // D-09: the route card never shows figures derived
                                // from a route that just failed.
                                if (fetchedRoute != null && !routeError)
                                  RouteDetailsCard(
                                    route: fetchedRoute!,
                                    fromAmount: fromAmountController.text,
                                    toAmount: toAmountController.text,
                                    fromToken: fromToken,
                                    toToken: toToken,
                                    slippage: slippage.toString(),
                                  ),
                                if (routeError) _buildRouteErrorNotice(gw),
                                // The gap the eye reads here is NOT this box
                                // alone: RouteDetailsCard (and the error notice
                                // that replaces it) each carry their own
                                // `vertical: space4` margin, so the space
                                // between the fees table and the CTA was
                                // 8 + 24 = 32px. Halved to 16 at the walk
                                // (Braian, 2026-07-27) by taking this box to
                                // space4 — 8 + 8. Changing this to space6 would
                                // have given 20px, not the half that was asked
                                // for.
                                const SizedBox(
                                  height: GeniusWalletConsts.space4,
                                ),
                                _buildSwapCta(gw),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The Swap header's settings trigger - `Icons.tune`, opening
/// [SwapSettingsDrawer].
///
/// A widget rather than a bare `IconButton` at the call site because of the
/// BOX around the glyph, which is load-bearing and needs the paragraph below
/// next to it rather than four levels deep in an already deep tree.
///
/// This is the SECOND copy of the 48x32 trigger box `TransactionsFilterTrigger`
/// documents at length (`transactions_slim_view.dart`), and it is a copy on
/// purpose: two occurrences do not earn a shared component, and the two
/// triggers agree on nothing except this one measurement. What holds it up
/// here is `GWPageHeader`'s `trailingOnTitleLine` `Stack`, which is as tall as
/// its tallest child: a 48-tall control over a 32px title line makes the line
/// 48 and pushes "Swap" 8px down its own header. Measured on the phone at
/// 390x844 - a plain 48x48 `IconButton` gives a 108px header with its title at
/// y=32, this box gives 92 and y=24, and 24 is where "Assets" and
/// "Transactions" put their titles. The price is the same one that page paid:
/// 48x32 clears WCAG 2.2 SC 2.5.8's 24x24 floor and Android's 48dp on the
/// horizontal axis, and is under Apple's 44pt on the vertical one.
class _SwapSettingsTrigger extends StatelessWidget {
  const _SwapSettingsTrigger({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this subtree to rebuild on a live appearance toggle (04-04 discipline).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    return IconButton(
      icon: Icon(Icons.tune, color: gw.textSecondary, size: 24),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      // Tight, not `min*`: a minimum leaves `IconButton` free to grow, and
      // the default `MaterialTapTargetSize.padded` does exactly that - back
      // out to 48 on both axes, which is the 48 that was setting the header
      // row height. `shrinkWrap` and an explicit STANDARD density are what
      // make the constraint the final word: `VisualDensity` shrinks the
      // MINIMUM of a constraint by 4px per unit, and `ThemeData` defaults to
      // compact on every desktop platform, this repo's test harness included.
      constraints: const BoxConstraints.tightFor(width: 48, height: 32),
      visualDensity: VisualDensity.standard,
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
