import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
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

/// The native coin's spendable quantity in raw base units, or null when the
/// holdings carry no native entry.
///
/// Read from the holding's own `balance`, never from `selectedWalletBalance`:
/// that field is a FIAT total across every coin, and spending it here would
/// offer a swap many times larger than the wallet can cover.
///
/// The native coin is the holding with no contract address — the same
/// discriminator the ERC-20 branch uses to decide what it may read.
///
/// ponytail: `Coin.balance` is a double, so a holding needing more than ~17
/// significant digits is already rounded before it reaches this line. Accepted
/// because it is the same figure the rest of the app displays; the upgrade path
/// is a string or BigInt balance on `Coin`. `toStringAsFixed` is what keeps a
/// dust balance out of exponent notation, which `toBaseUnits` rejects.
BigInt? nativeCoinBaseUnits(List<Coin> coins, int decimals) {
  if (decimals < 0) {
    return null;
  }
  for (final coin in coins) {
    if (coin.address == null && coin.balance != null) {
      return toBaseUnits(
        coin.balance!.toStringAsFixed(decimals.clamp(0, 20).toInt()),
        decimals,
      );
    }
  }
  return null;
}

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

  /// Bumped whenever the form changes. A quote answers the generation it was
  /// asked under, and the provider call cannot be cancelled, so a slow reply
  /// for an edited-away request has to be dropped on arrival instead.
  int _quoteGeneration = 0;
  double slippage = 0.5; // Default slippage

  // D-09 / criterion 2: the CTA ladder's own state (swap_cta_state.dart).
  bool isFetchingRoute = false;
  bool routeError = false;
  bool isSubmitting = false;

  /// Set when a SUBMIT failed, so the shared error notice names which way it
  /// failed instead of repeating the route-fetch copy. Null means the notice
  /// is speaking for a failed quote, which is what it shipped for.
  String? submitFailure;

  /// True when the typed amount has digits the pay token cannot hold.
  bool get _tooPrecise =>
      fromToken != null && exceedsPrecision(fromAmount, fromToken!.decimals);

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
      // The native coin has no contract to call, so its quantity comes from
      // the holdings list rather than an RPC read.
      if (isNativeToken(token.address)) {
        final raw = nativeCoinBaseUnits(wallet.coins, token.decimals);
        result.add(raw == null ? token : token.withBalance(raw));
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

    if (fromAmountUnits == null || _tooPrecise) {
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
      // The input, not the network, is now why no route is fetched, and the
      // last quote's figures belong to a form that no longer exists.
      setState(() {
        routeError = false;
        submitFailure = null;
        toAmount = '';
        toAmountController.clear();
      });
      return;
    }

    setState(() {
      isFetchingRoute = true;
      routeError = false;
      submitFailure = null;
    });

    final generation = ++_quoteGeneration;

    try {
      final quote = await widget.provider.quote(request);
      if (!mounted || generation != _quoteGeneration) {
        return;
      }
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
      if (!mounted || generation != _quoteGeneration) {
        return;
      }
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
    // Drop the old quote NOW, not when the new one lands. For the whole
    // debounce the figures on screen belong to the previous request, and a
    // quote left in place keeps the CTA submittable against them. Bumping the
    // generation also disowns any reply still in flight for the old form.
    _quoteGeneration++;
    if (fetchedQuote != null) {
      setState(() => fetchedQuote = null);
    }
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      _fetchRoute();
    });
  }

  /// The READY rung's submit action — a thin adapter over the orchestrator.
  /// It reads [sideEffectsFor] and never re-derives that decision: a screen
  /// judging its own swap successful is how a false receipt gets shown.
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
    final networkSymbol = network?.symbol ?? '';

    // Frozen here, before the first await. Approval and settling can run for a
    // minute with the pickers and the amount field still live, and every row
    // this swap writes has to describe the trade that was actually submitted.
    final submitted = _SubmittedSwap(
      fromAmount: fromAmount,
      toAmount: toAmount,
      fromSymbol: fromToken?.symbol,
      toSymbol: toToken?.symbol,
      fromIconUrl: fromToken?.logoUri,
      toIconUrl: toToken?.logoUri,
    );
    final payToken = fromToken!;

    setState(() => isSubmitting = true);
    try {
      final outcome = await widget.execute(
        tokenAddress: payToken.address,
        amount: request.fromAmount,
        // What the route card showed. A quote that never arrived showed no
        // fees, and a route that then charges some is stopped like any other.
        quotedFees: fetchedQuote?.feeLines ?? const [],
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
          if (response.isSuccess) {
            return response.data;
          }
          // A hash on a failure is a broadcast the node never answered.
          if (response.data != null) {
            throw const SwapBroadcastUnanswered();
          }
          return null;
        },
        readStatus: widget.provider.status,
        wait: Future<void>.delayed,
        onBroadcast: (hash) async {
          // Deliberately NOT guarded on mounted. Storage is an injected
          // dependency, not context, and the funds have already left: leaving
          // the screen between send and settle must not be what decides
          // whether the transfer is recorded at all.
          await widget.storage.addTransaction(
            address,
            _swapRow(
              hash: hash,
              status: TransactionStatus.pending,
              walletAddress: address,
              networkSymbol: networkSymbol,
              chainId: chainId,
              submitted: submitted,
            ),
          );
        },
      );

      // No mounted check here on purpose. The outcome's storage writes have
      // to land whether or not the user is still looking: nothing else ever
      // re-polls a stored swap, so a row left pending here stays pending for
      // good. _applyOutcome gates its own UI on mounted.
      await _applyOutcome(
        outcome,
        walletAddress: address,
        networkSymbol: networkSymbol,
        chainId: chainId,
        transactionsCubit: transactionsCubit,
        submitted: submitted,
      );
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  /// Does exactly what [sideEffectsFor] permits, and nothing on any outcome
  /// that carries no hash. What the user is TOLD is `swapFailureMessage`'s
  /// job; this method only decides what may happen.
  Future<void> _applyOutcome(
    SwapOutcome outcome, {
    required String walletAddress,
    required String networkSymbol,
    required int chainId,
    required TransactionsCubit transactionsCubit,
    required _SubmittedSwap submitted,
  }) async {
    final effects = sideEffectsFor(outcome);
    if (!effects.storeRow) {
      // Nothing to store, and reporting is a setState.
      if (mounted) {
        _reportFailure(outcome);
      }
      return;
    }

    // Only a hash-bearing outcome gets here, and only one shape carries one.
    final broadcast = outcome as SwapBroadcast;

    Transaction rowWith(TransactionStatus status) => _swapRow(
      hash: broadcast.hash,
      status: status,
      walletAddress: walletAddress,
      networkSymbol: networkSymbol,
      chainId: chainId,
      submitted: submitted,
      recoveryUrl: broadcast.recoveryUrl,
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

    // The funds have moved, so every number on screen now describes a swap
    // that is finished: the amounts are spent, the balance behind them has
    // changed, and the router has consumed this quote id. `_reportFailure`
    // clears the same fields after a FAILED swap because "a stale figure is a
    // number the user might still act on" — after a successful one that is
    // truer, since the CTA would otherwise sit on its ready rung and a second
    // tap would submit against a quote that cannot be filled again.
    //
    // The two tokens stay seated. Swapping the same pair again is the likely
    // next action, and re-picking them is the part that is tedious.
    setState(() {
      fromAmount = '';
      toAmount = '';
      fromAmountController.clear();
      toAmountController.clear();
      fetchedQuote = null;
      submitFailure = null;
      routeError = false;
    });
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
                      : 'The swap did not complete.',
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
      tooPrecise: _tooPrecise,
    );
    // The availability gate sits ABOVE the ladder, not inside it: a build that
    // cannot reach Squid has no rung to be on, and the ladder stays the single
    // source of truth for every state that can actually be reached.
    final unavailable = !widget.swapAvailable;
    final label = unavailable
        ? 'Swap unavailable'
        : swapCtaLabel(
            state,
            symbol: fromToken?.symbol,
            decimals: fromToken?.decimals,
          );
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
          // should not wait out the quote debounce.
          onPressed: !enabled
              ? null
              : state == SwapCtaState.routeError
              ? _fetchRoute
              : _submitSwap,
        ),
      );
    }

    final isRefused =
        !unavailable &&
        (state == SwapCtaState.insufficientBalance ||
            state == SwapCtaState.tooPrecise);
    final background = isRefused
        ? gw.statusError.withValues(alpha: 0.12)
        : gw.surfaceMenu;
    final foreground = isRefused ? gw.statusError : gw.textPrimary38;

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
                // Shrinks rather than truncates: a refusal must stay readable
                // whole in the fixed-height button at large text scales.
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: GeniusWalletTypography.titleLg.copyWith(
                        color: foreground,
                      ),
                    ),
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

/// What the user actually submitted, frozen at the tap.
///
/// The pickers and the amount field stay live through approval and settling,
/// so a row built from them afterwards can describe a different trade than the
/// one on chain.
class _SubmittedSwap {
  const _SubmittedSwap({
    required this.fromAmount,
    required this.toAmount,
    required this.fromSymbol,
    required this.toSymbol,
    required this.fromIconUrl,
    required this.toIconUrl,
  });

  final String fromAmount;
  final String toAmount;
  final String? fromSymbol;
  final String? toSymbol;
  final String? fromIconUrl;
  final String? toIconUrl;
}

/// One swap row: the submitted trade plus whatever the chain has said so far.
///
/// Top level on purpose — it takes a snapshot and holds no screen, so it
/// cannot read a field that has moved on since the swap was sent.
Transaction _swapRow({
  required String hash,
  required TransactionStatus status,
  required String walletAddress,
  required String networkSymbol,
  required int chainId,
  required _SubmittedSwap submitted,
  String? recoveryUrl,
}) => Transaction(
  hash: hash,
  fromAddress: walletAddress,
  recipients: [
    TransferRecipients(toAddr: walletAddress, amount: submitted.toAmount),
  ],
  timeStamp: DateTime.now(),
  transactionDirection: TransactionDirection.received,
  // Squid reports gas in USD and this field renders as a native-coin amount,
  // so a dollar figure here prints as "0.42 ETH". Blank until a native number
  // exists -- the receipt already skips a blank fee row.
  fees: '',
  coinSymbol: networkSymbol,
  transactionStatus: status,
  type: TransactionType.swap,
  chainId: chainId,
  toAmount: submitted.toAmount,
  toIconUrl: submitted.toIconUrl,
  fromSymbol: submitted.fromSymbol,
  toSymbol: submitted.toSymbol,
  fromAmount: submitted.fromAmount,
  fromIconUrl: submitted.fromIconUrl,
  // Persisted, because the session that makes a paused swap is the one session
  // the user is NOT in when they come back to resume it.
  recoveryUrl: recoveryUrl,
);
