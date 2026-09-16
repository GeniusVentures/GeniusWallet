import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/hive/services/transaction_storage_service.dart';
import 'package:genius_wallet/squid_router/held_tokens.dart';
import 'package:genius_wallet/squid_router/route_details_card.dart';
import 'package:genius_wallet/squid_router/squid_client.dart';
import 'package:genius_wallet/squid_router/squid_swap_provider.dart';
import 'package:genius_wallet/squid_router/squid_util.dart';
import 'package:genius_wallet/squid_router/swap_allowance.dart';
import 'package:genius_wallet/squid_router/swap_cta_state.dart';
import 'package:genius_wallet/squid_router/swap_execution.dart';
import 'package:genius_wallet/squid_router/swap_field.dart';
import 'package:genius_wallet/squid_router/swap_messages.dart';
import 'package:genius_wallet/squid_router/swap_preselection.dart';
import 'package:genius_wallet/squid_router/swap_seam.dart';
import 'package:genius_wallet/squid_router/swap_settings_drawer.dart';
import 'package:genius_wallet/squid_router/token_flip_button.dart';
import 'package:genius_wallet/swap/swap_provider.dart';
import 'package:genius_wallet/swap/swap_quote.dart';
import 'package:genius_wallet/swap/swap_token.dart';
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
List<SwapToken> tokensForSide(List<SwapToken> all, SwapToken? otherSide) =>
    all.where((t) => !t.sameAs(otherSide)).toList();

class SwapScreen extends StatefulWidget {
  const SwapScreen({
    super.key,
    this.preselectSymbol,
    this.preselectChainId,
    this.swapAvailable = squidConfigured,
    this.provider = swapProvider,
    this.execute = executeSwap,
    this.storage = const TransactionStorageService(),
  });

  /// The swap orchestrator and the transaction store, injected so the cases
  /// can drive every outcome with no network, no key and no wallet.
  final SwapExecutor execute;
  final TransactionStorageService storage;

  /// Where the catalogue and the quote come from. A parameter so a test can
  /// drive the screen without a network or a credential.
  final SwapProvider provider;

  /// Whether this build can reach Squid at all. False means no integrator ID,
  /// so the screen refuses up front rather than rendering a 401 as a route
  /// error. A parameter so a test can drive both sides without a build define.
  final bool swapAvailable;

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
  /// guessing. The catalogue is the selected chain's only, so a coin held
  /// elsewhere has no match at all.
  final String? preselectSymbol;

  /// Narrows the match when the same symbol exists on several chains, which is
  /// the normal case (ETH is on 1, 137 and 80001). Ignored when null.
  final int? preselectChainId;

  @override
  State<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> {
  List<SwapToken> tokens = [];
  SwapToken? fromToken;
  SwapToken? toToken;
  bool isLoading = true;
  String fromAmount = '';
  String toAmount = '';
  Timer? _debounce;
  final TextEditingController fromAmountController = TextEditingController();
  final TextEditingController toAmountController = TextEditingController();
  SwapQuote? fetchedQuote;
  double slippage = 0.5; // Default slippage

  // D-09 / criterion 2: the CTA ladder's own state (swap_cta_state.dart).
  bool isFetchingRoute = false;
  bool routeError = false;
  bool isSubmitting = false;

  /// Set when a SUBMIT failed, so the shared error notice names which way it
  /// failed instead of repeating the route-fetch copy. Null means the notice
  /// is speaking for a failed quote, which is what it shipped for.
  String? submitFailure;

  /// The selected pay token's balance as a number, or null when unknown.
  /// Never accuse the user of an insufficient balance on missing data.
  double? get fromBalanceAmount => fromToken?.amountAsDouble;

  @override
  void initState() {
    super.initState();
    if (widget.swapAvailable) {
      _loadTokens();
    } else {
      // Nothing will clear this gate otherwise, and an unreachable swap would
      // sit on a spinner forever instead of saying so.
      isLoading = false;
    }
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
      chainId: widget.preselectChainId?.toString(),
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
    final cubit = context.read<WalletDetailsCubit>();
    final walletState = cubit.state;
    final chainId = walletState.selectedNetwork?.chainId;

    if (chainId == null) {
      setState(() {
        tokens = [];
        isLoading = false;
      });
      return;
    }

    try {
      final catalogue = await widget.provider.tokens('$chainId');
      final withBalances = await _withBalances(
        catalogue,
        walletState,
        cubit.geniusApi,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        tokens = withBalances;
        isLoading = false;
      });
      _applyPreselection();
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => isLoading = false);
      showToast(
        context,
        'Failed to load tokens. Check your connection and try again.',
        type: ToastType.error,
      );
    }
  }

  /// Reads a balance only for the tokens this wallet already holds, decided
  /// from `coins`. A busy chain lists hundreds of tokens, and one RPC call per
  /// catalogue entry would be that many round trips on every page load.
  Future<List<SwapToken>> _withBalances(
    List<SwapToken> catalogue,
    WalletDetailsState wallet,
    GeniusApi api,
  ) async {
    final address = wallet.selectedWallet?.address;
    final rpcUrl = wallet.selectedNetwork?.rpcUrl;
    final held = <String>{
      for (final coin in wallet.coins)
        if (coin.address != null) coin.address!.toLowerCase(),
    };

    final result = <SwapToken>[];
    for (final token in catalogue) {
      // The native coin has no contract to call. Its figure is the one the
      // rest of the app already displays, so this adds no RPC path for it.
      if (isNativeToken(token.address)) {
        result.add(
          token.withBalance(
            toBaseUnits(wallet.selectedWalletBalance ?? '', token.decimals),
          ),
        );
        continue;
      }
      if (address == null ||
          rpcUrl == null ||
          !held.contains(token.address.toLowerCase())) {
        result.add(token);
        continue;
      }
      result.add(
        token.withBalance(
          await api.rawBalanceOf(
            address: address,
            contractAddress: token.address,
            rpcUrl: rpcUrl,
          ),
        ),
      );
    }
    return result;
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

  /// The quote request, in the aggregator-neutral shape. Null whenever the
  /// form cannot describe a swap yet.
  SwapQuoteRequest? get quoteRequest {
    if (!canSwap) {
      return null;
    }

    final address = context
        .read<WalletDetailsCubit>()
        .state
        .selectedWallet
        ?.address;

    if (address == null) {
      return null;
    }

    // Base units, not the typed string: '1.5' sent as-is is 1.5 wei.
    final fromAmountUnits = toBaseUnits(fromAmount, fromToken!.decimals);

    if (fromAmountUnits == null) {
      return null;
    }

    return SwapQuoteRequest(
      fromChainId: fromToken!.chainId,
      fromToken: fromToken!.address,
      fromAmount: fromAmountUnits,
      toChainId: toToken!.chainId,
      toToken: toToken!.address,
      fromAddress: address,
      toAddress: address,
      slippage: slippage,
    );
  }

  Future<void> _fetchRoute() async {
    if (!canSwap) {
      return;
    }

    final request = quoteRequest;
    if (request == null) {
      return;
    }

    setState(() {
      isFetchingRoute = true;
      routeError = false;
      submitFailure = null;
    });

    try {
      final quote = await widget.provider.quote(request);
      setState(() {
        toAmount = quote.toAmountDisplay;
        toAmountController.text = quote.toAmountDisplay;
        fetchedQuote = quote;
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
        fetchedQuote = null;
        toAmount = '';
        toAmountController.clear();
        isFetchingRoute = false;
      });
      if (mounted) {
        showToast(
          context,
          'Failed to fetch route. Check your input and try again.',
          type: ToastType.error,
        );
      }
    }
  }

  /// One second, because the quote endpoint is rate limited to one request a
  /// second and answers an overrun with an error the user would read as a
  /// broken swap. Shorten this only alongside a higher tier.
  void _debouncedFetchRoute() {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      _fetchRoute();
    });
  }

  /// The READY rung's submit action — a thin adapter over the orchestrator.
  ///
  /// It reads [sideEffectsFor] and acts on it. It must never re-derive that
  /// decision: a screen that decides for itself whether a swap succeeded is
  /// the bug this phase exists to remove.
  Future<void> _submitSwap() async {
    final request = quoteRequest;
    final walletState = context.read<WalletDetailsCubit>().state;
    final address = walletState.selectedWallet?.address;
    final network = walletState.selectedNetwork;
    final rpcUrl = network?.rpcUrl;
    final chainId = network?.chainId;

    if (request == null ||
        address == null ||
        rpcUrl == null ||
        chainId == null) {
      return;
    }

    final api = context.read<WalletDetailsCubit>().geniusApi;
    final transactionsCubit = context.read<TransactionsCubit>();
    final payToken = fromToken!;

    setState(() => isSubmitting = true);
    try {
      final outcome = await widget.execute(
        tokenAddress: payToken.address,
        amount: request.fromAmount,
        fetchRoute: () => widget.provider.buildTransaction(request),
        readAllowance: (spender) => api.allowance(
          owner: address,
          spender: spender,
          contractAddress: payToken.address,
          rpcUrl: rpcUrl,
        ),
        approve: (spender, amount) async {
          final response = await api.approve(
            contractAddress: payToken.address,
            rpcUrl: rpcUrl,
            address: address,
            spender: spender,
            amount: amount,
            chainId: chainId,
          );
          return response.isSuccess;
        },
        send: (tx) async {
          final response = await api.signAndSendTransaction(
            tx: tx,
            rpcUrl: rpcUrl,
            address: address,
            sourceChainId: chainId,
          );
          return response.data;
        },
        readStatus: widget.provider.status,
        wait: Future<void>.delayed,
      );

      if (!mounted) {
        return;
      }
      await _applyOutcome(
        outcome,
        walletAddress: address,
        networkSymbol: network?.symbol ?? '',
        transactionsCubit: transactionsCubit,
      );
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  /// Does exactly what [sideEffectsFor] permits, and nothing on any outcome
  /// that carries no hash. 26-07 owns what the user is told instead; until
  /// then the shipped route-error path is what speaks.
  Future<void> _applyOutcome(
    SwapOutcome outcome, {
    required String walletAddress,
    required String networkSymbol,
    required TransactionsCubit transactionsCubit,
  }) async {
    final effects = sideEffectsFor(outcome);
    if (!effects.storeRow) {
      _reportFailure(outcome);
      return;
    }

    // Only a hash-bearing outcome gets here, and only one shape carries one.
    final broadcast = outcome as SwapBroadcast;

    Transaction rowWith(TransactionStatus status) => Transaction(
      hash: broadcast.hash,
      fromAddress: walletAddress,
      recipients: [TransferRecipients(toAddr: walletAddress, amount: toAmount)],
      timeStamp: DateTime.now(),
      transactionDirection: TransactionDirection.received,
      // Something executed now, so a real network fee exists to report.
      fees: fetchedQuote?.gasUsd.toStringAsFixed(2) ?? '',
      coinSymbol: networkSymbol,
      transactionStatus: status,
      type: TransactionType.swap,
      toAmount: toAmount,
      toIconUrl: toToken?.logoUri,
      fromSymbol: fromToken?.symbol,
      toSymbol: toToken?.symbol,
      fromAmount: fromAmount,
      fromIconUrl: fromToken?.logoUri,
    );

    // Written BEFORE the resolved status, keyed by the real hash: a crash
    // between broadcast and resolution must leave an accurate pending row
    // rather than no record of funds that already moved.
    await widget.storage.addTransaction(
      walletAddress,
      rowWith(TransactionStatus.pending),
    );
    final resolved = rowWith(broadcast.status);
    await widget.storage.addTransaction(walletAddress, resolved);

    if (!mounted) {
      return;
    }
    if (effects.showToast) {
      // The row is stored and the receipt opens either way — the funds moved.
      // What is SAID depends on how it settled; claiming success for a
      // partial or paused swap is the lie this phase removes.
      final unresolved = swapFailureMessage(outcome);
      showToast(
        context,
        unresolved ??
            'Swapped $fromAmount ${fromToken?.symbol ?? ""} for '
                '${toToken?.symbol ?? ""}.',
        title: unresolved == null ? 'Swap Submitted' : 'Swap Sent',
        type: unresolved == null ? ToastType.success : ToastType.warning,
      );
    }
    if (effects.showReceipt) {
      showTransactionDetails(context, resolved);
    }
    transactionsCubit.addTransaction(resolved);
  }

  /// Says which way the swap failed, reusing the two error affordances this
  /// screen already has: the toast and the inline notice.
  ///
  /// The quote is cleared with it — a stale figure beside a failure message
  /// is a number the user might still act on.
  void _reportFailure(SwapOutcome outcome) {
    final message = swapFailureMessage(outcome);
    if (message == null) {
      return;
    }

    setState(() {
      submitFailure = message;
      routeError = true;
      fetchedQuote = null;
      toAmount = '';
      toAmountController.clear();
    });
    showToast(context, message, type: ToastType.error);
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
                  submitFailure == null
                      ? "Couldn't fetch a route."
                      : 'The swap did not go through.',
                  style: GeniusWalletTypography.labelMd.copyWith(
                    color: gw.statusError,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: GeniusWalletConsts.space2),
                Text(
                  submitFailure ??
                      'Check your connection and try again — the quote above '
                          'is not current.',
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
      hasRoute: fetchedQuote != null,
      routeError: routeError,
      isSubmitting: isSubmitting,
    );
    // The availability gate sits ABOVE the ladder, not inside it: a build that
    // cannot reach Squid has no rung to be on, and the ladder stays the single
    // source of truth for every state that can actually be reached.
    final unavailable = !widget.swapAvailable;
    final label = unavailable
        ? 'Swap unavailable'
        : swapCtaLabel(state, symbol: fromToken?.symbol);
    final enabled = swapCtaEnabled(state);

    if (!unavailable &&
        (state == SwapCtaState.ready || state == SwapCtaState.routeError)) {
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

    final isInsufficient =
        !unavailable && state == SwapCtaState.insufficientBalance;
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
                if (!unavailable && state == SwapCtaState.submitting) ...[
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
            fetchedQuote = null;
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
                                // Header lives INSIDE the focused column and
                                // centres over it (Jakub's call, 26-07): a
                                // left-gutter title with the form parked in
                                // the middle of a 1536 frame left the two
                                // agreeing on nothing. Settings icon stays on
                                // the column's right edge, where it was before
                                // the GWPageHeader migration (905a2a91).
                                GWPageHeader(
                                  title: "Swap",
                                  subtitle: "Trade any token across chains",
                                  centered: true,
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.tune,
                                      color: gw.textSecondary,
                                      size: 24,
                                    ),
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
                                if (fetchedQuote != null && !routeError)
                                  RouteDetailsCard(
                                    quote: fetchedQuote!,
                                    fromAmount: fromAmountController.text,
                                    toAmount: toAmountController.text,
                                    fromSymbol: fromToken?.symbol,
                                    toSymbol: toToken?.symbol,
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
