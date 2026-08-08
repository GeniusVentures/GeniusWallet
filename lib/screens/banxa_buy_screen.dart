// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
// For `RenderProxyBox`, which `_RenderZeroIntrinsicHeight` extends -
// `material.dart` does not re-export the rendering layer.
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/banxa/banxa_api_services.dart';
import 'package:genius_wallet/banxa/banxa_components/order_status_style.dart';
import 'package:genius_wallet/banxa/banxa_helpers/order_transaction_mapping.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_state.dart';
import 'package:genius_wallet/banxa/banxa_order/create_order_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/create_order_state.dart';
import 'package:genius_wallet/banxa/handle_banxa_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/components/cards/gw_detail_grid.dart';
import 'package:genius_wallet/components/cards/gw_kicker.dart';
import 'package:genius_wallet/components/disclaimer_dialogue.dart';
import 'package:genius_wallet/components/effects/gw_hoverable.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/components/feedback/gw_error_state.dart';
import 'package:genius_wallet/components/gw_back_link.dart';
import 'package:genius_wallet/components/gw_control_track.dart';
import 'package:genius_wallet/components/inputs/gw_select.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// `/buy` (09-08): the buy FORM, on the app's shared page frame, with the
/// order history rendered beside it as a rail. Replaces the pre-09-08 shape,
/// where this screen only rendered when pushed from a small `+` on the
/// orders list at `/createOrder` — `/buy` itself mapped to [OrdersPage]
/// (`router.dart`), so tapping "Buy GNUS" anywhere in the app opened a list
/// of things already bought instead of a way to buy more.
///
/// Design: `.planning/sketches/167-banxa-buy-flow/final.html` (approved
/// 2026-07-30). Rationale: `.planning/sketches/167-banxa-buy-flow/DECISION.md`.
class BanxaBuyScreen extends StatefulWidget {
  final String? initialFiatCode;
  final String? initialCryptoCode;
  final String? initialPaymentMethodId;
  final String? initialAmount;
  final String? initialWalletAddress;

  /// The label the back link shows, naming where the caller pushed `/buy`
  /// from - `'HOME'` for the wallet dashboard (`wallet_information.dart`),
  /// `'MARKETS'` for the coins list (`coins_screen.dart`). Passed explicitly
  /// by the caller through `router.dart`'s `/buy` builder rather than sniffed
  /// from the navigation stack, so a deep link that never supplies it falls
  /// back to the honest, origin-neutral `'BACK'` (walk item 2, 2026-07-31)
  /// instead of guessing a tab it may not have come from.
  final String? originLabel;

  const BanxaBuyScreen({
    super.key,
    this.initialFiatCode,
    this.initialCryptoCode,
    this.initialPaymentMethodId,
    this.initialAmount,
    this.initialWalletAddress,
    this.originLabel,
  });

  @override
  State<BanxaBuyScreen> createState() => _BanxaBuyScreenState();
}

class _BanxaBuyScreenState extends State<BanxaBuyScreen> {
  /// Local UI state for the orders rail's count-chip filter (Task 3). Kept
  /// here rather than in `OrdersCubit` so tapping a chip on THIS screen
  /// cannot narrow what `OrdersPage` shows when the user next opens it — the
  /// two screens share one `OrdersCubit` instance (`main.dart`), and
  /// `OrdersCubit.applyFilters` filters by an exact status STRING, not a
  /// tone bucket, so it cannot express this filter anyway.
  OrderStatusTone? _selectedOrdersTone;

  @override
  void initState() {
    super.initState();
    // Same existing call `OrdersPage.initState` makes (D-01/D-02: no new
    // call, no new argument) — populates the rail with the same data the
    // orders history itself uses.
    context.read<OrdersCubit>().fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MakeOrderCubit(BanxaApiService())
        ..loadCurrencies(
          initialFiatCode: widget.initialFiatCode,
          initialCryptoCode: widget.initialCryptoCode,
          initialPaymentMethodId: widget.initialPaymentMethodId,
          initialAmount: widget.initialAmount,
          initialWalletAddress: widget.initialWalletAddress,
        ),
      child: BlocConsumer<MakeOrderCubit, MakeOrderState>(
        listenWhen: (p, c) =>
            p.errorMessage != c.errorMessage || p.step != c.step,
        listener: (context, state) async {
          if (state.errorMessage.isNotEmpty) {
            showToast(context, state.errorMessage, type: ToastType.error);

            context.read<MakeOrderCubit>().clearError();
          }
          if (state.step == MakeOrderStep.orderReady &&
              state.checkoutUrl != null) {
            await showCheckoutOptionsSheet(
              context,
              checkoutUrl: state.checkoutUrl!,
              orderId: state.orderId!,
              redirectUrl: state.redirectUrl ?? BanxaApiService.redirectUrl,
            );
          }
        },
        builder: (context, state) {
          final isBootLoading =
              state.step == MakeOrderStep.loadingCurrencies &&
              state.fiats.isEmpty &&
              state.cryptos.isEmpty;

          // The CTA's ACTIONS stay on the screen, because they open dialogs
          // and sheets, read `MakeOrderCubit` and touch navigation. Its LABEL
          // and its ENABLED rung are pure functions of `state` and moved into
          // [BanxaBuyForm] with the button itself.
          Future<void> onBuy() async {
            final accepted = await showDisclaimerDialog(
              context,
              title: "Payment Disclaimer",
              message:
                  "You are now leaving GeniusWallet to complete your order or payment through Banxa (https://banxa.com). "
                  "Services related to card payments, crypto purchases, and transaction processing are provided by Banxa — "
                  "a separate third-party platform. By proceeding, you acknowledge that you have read and agreed to "
                  "Banxa's Terms of Use and Privacy & Cookies Policy.",
              confirmText: "Continue",
              activeColor: context.gw.brandPrimaryOnSurface,
            );

            if (!accepted) {
              showToast(
                context,
                'You must agree to the disclaimer to proceed.',
              );
              return;
            }

            // A previously-created order re-opens the same checkout
            // sheet instead of creating a second order (D-01: unchanged
            // from the pre-09-08 "Create Order" button's own guard).
            if (state.checkoutUrl != null && state.orderId != null) {
              await showCheckoutOptionsSheet(
                context,
                checkoutUrl: state.checkoutUrl!,
                orderId: state.orderId!,
                redirectUrl: state.redirectUrl ?? '',
              );
            } else {
              await context.read<MakeOrderCubit>().createOrder();
            }
          }

          // A callback rather than something the form rebuilds itself: the
          // retry replays the SAME four `widget.initial*` arguments the boot
          // call used, and those live on the screen.
          void onRetryCurrencies() {
            context.read<MakeOrderCubit>().loadCurrencies(
              initialFiatCode: widget.initialFiatCode,
              initialCryptoCode: widget.initialCryptoCode,
              initialPaymentMethodId: widget.initialPaymentMethodId,
              initialAmount: widget.initialAmount,
              initialWalletAddress: widget.initialWalletAddress,
            );
          }

          return Scaffold(
            body: Stack(
              children: [
                if (isBootLoading)
                  const Center()
                else
                  SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Align(
                      alignment: Alignment.topCenter,
                      // Padding OUTSIDE the ConstrainedBox — same frame as
                      // Transactions/Markets/News (`transactions_screen.dart:
                      // 49-90`), so `/buy`'s title lands at the same X.
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          GeniusBreakpoints.pageGutter(context),
                          GeniusBreakpoints.pageTitleGap(context),
                          GeniusBreakpoints.pageGutter(context),
                          GeniusWalletConsts.space8,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: GeniusBreakpoints.xxl,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // `/buy` now lives INSIDE the app's shell
                              // (`router.dart`, moved 2026-07-31), so its way
                              // back is the same breadcrumb-style link the
                              // coin page uses, not a header-embedded
                              // chevron — the `GWPageHeader.leading` chevron
                              // this file carried before that move is gone;
                              // no back affordance sat here before either
                              // (this screen had no `GWPageHeader` at all
                              // pre-move, only its own AppBar's chevron,
                              // which the shell frame replaces entirely).
                              //
                              // Unlike the coin page (always reached from
                              // Markets), this page is pushed from more than
                              // one place - the wallet dashboard and the
                              // coins list - so the label is not hardcoded.
                              // Each caller passes its own `origin` through
                              // `/buy`'s `state.extra` (`router.dart`), which
                              // becomes `widget.originLabel` here. A deep
                              // link that never supplies one falls back to
                              // the origin-neutral 'BACK' (walk item 2,
                              // 2026-07-31).
                              GWBackLink(
                                label: widget.originLabel ?? 'BACK',
                                onTap: () => context.pop(),
                              ),
                              GWPageHeader(
                                title: 'Buy GNUS',
                                subtitle: 'Powered by Banxa',
                                trailing: GWButton(
                                  // `gradientOutline`, not `secondary` (Jakub,
                                  // 2026-07-31). `secondary` paints a flat
                                  // blue, and a census that day found it was
                                  // the app's one outlier - every other
                                  // outline CTA carries the brand gradient.
                                  // Outline is still right for the weight:
                                  // verifying commits nothing, so it must not
                                  // take a fill.
                                  variant: GWButtonVariant.gradientOutline,
                                  size: GWButtonSize.sm,
                                  label: 'Verify with Banxa',
                                  onPressed: () => context.push('/kyc'),
                                ),
                              ),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  // ONE condition, read once, feeding both the
                                  // layout choice and the rail's `bounded`
                                  // flag - so the two can never disagree about
                                  // which layout is rendering (260731-ti5).
                                  final wide =
                                      constraints.maxWidth >=
                                      GeniusBreakpoints.large;

                                  // The form card's own inner CONTENT width,
                                  // computed HERE and handed down as a number
                                  // rather than measured inside the card.
                                  // A `LayoutBuilder` inside the card would be
                                  // asked for an intrinsic height by the
                                  // `IntrinsicHeight` below and throw
                                  // (`_ZeroIntrinsicHeight`'s doc records the
                                  // same trap for the rail, which is shielded;
                                  // the form card is not, and must not be,
                                  // because it is the widget whose intrinsic
                                  // height defines the row).
                                  //
                                  // Read from the SAME `wide` flag that picks
                                  // the layout, so the number and the layout
                                  // can never disagree - the one-condition-
                                  // read-once idiom 260731-ti5 established two
                                  // comments below.
                                  //
                                  // A `GWCard`'s inner content width is its
                                  // outer width MINUS 34: `space8` (16) of
                                  // padding each side PLUS one pixel each side
                                  // for the hairline, because `Container` adds
                                  // `decoration.padding` on top of its own
                                  // `padding`. Measured and reasoned at
                                  // `_OrdersRail._inlineTrackMinWidth`, which
                                  // turns on the same two pixels.
                                  final cardOuterWidth = wide
                                      ? (constraints.maxWidth -
                                                GeniusWalletConsts.space8) /
                                            2
                                      : constraints.maxWidth;
                                  final formCard = BanxaBuyForm(
                                    state: state,
                                    cardInnerWidth: cardOuterWidth - 34,
                                    onRetryCurrencies: onRetryCurrencies,
                                    onGetQuote: () => context
                                        .read<MakeOrderCubit>()
                                        .getQuote(),
                                    onBuy: onBuy,
                                  );

                                  final ordersRail =
                                      BlocBuilder<OrdersCubit, OrdersState>(
                                        builder: (context, ordersState) =>
                                            _OrdersRail(
                                              state: ordersState,
                                              bounded: wide,
                                              selectedTone: _selectedOrdersTone,
                                              onSelectTone: (tone) => setState(
                                                () =>
                                                    _selectedOrdersTone = tone,
                                              ),
                                            ),
                                      );

                                  if (wide) {
                                    // D-02: the rail is exactly as tall as the
                                    // form card, and the form card decides.
                                    // `IntrinsicHeight` takes the MAX of its
                                    // children's intrinsic heights and forces
                                    // that on both; `_ZeroIntrinsicHeight`
                                    // makes the rail answer 0 to that query,
                                    // so the max is unconditionally the form
                                    // card's own height however many orders
                                    // the rail holds. `stretch` (not `start`)
                                    // is what spends the result: it hands both
                                    // children a TIGHT height instead of
                                    // letting each size itself.
                                    //
                                    // This makes the form card's "this card
                                    // never changes height when a quote
                                    // arrives" invariant load-bearing a SECOND
                                    // way. It is stated twice above: on the
                                    // `GWDetailGrid` that renders placeholder
                                    // rows before a quote exists, and on the
                                    // unconditional trailing `Text` under the
                                    // CTA. Both were written so the rail
                                    // beside this card would not SLIDE when a
                                    // quote landed. Now the rail's height is
                                    // derived from that card, so breaking
                                    // either would make the rail JUMP - resize
                                    // its own scroll viewport mid-interaction
                                    // - not merely shift position.
                                    return IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(child: formCard),
                                          const SizedBox(
                                            width: GeniusWalletConsts.space8,
                                          ),
                                          Expanded(
                                            child: _ZeroIntrinsicHeight(
                                              child: ordersRail,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  // D-04: stacked, so there is no card beside
                                  // the rail to derive a height from and
                                  // nothing to bound it to. The page's own
                                  // scroll carries the rows.
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      formCard,
                                      const SizedBox(
                                        height: GeniusWalletConsts.space8,
                                      ),
                                      ordersRail,
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (state.showOverlay || isBootLoading)
                  ColoredBox(
                    color: Colors.black45,
                    child: Center(child: Loading(text: state.loadingMessage)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The Buy GNUS form card - the `GWCard` itself, not its contents.
///
/// PUBLIC on purpose, and that is the whole point of the extraction
/// (260731-uhe). [BanxaBuyScreen] builds its own `MakeOrderCubit` with no
/// injection seam and the Banxa sandbox is unreachable under `flutter_test`,
/// so the real screen can only ever be pumped into its offline, no-quote step.
/// Every claim that needs a QUOTE, a non-USD fiat or a min/max-bounded payment
/// method was therefore pinned against a hand-copied RECONSTRUCTION of this
/// card (`buy_page_layout_test.dart`, since deleted), which its own doc
/// admitted was a design-contract proxy rather than a regression guard. Taking
/// a [MakeOrderState] as a parameter makes all three reachable against the
/// real production widget. Dart privacy is per-file, which is why this is
/// `public` rather than `_BanxaBuyForm`.
///
/// It renders the card, so a test can measure the card by
/// `tester.getSize(find.byType(BanxaBuyForm))`.
class BanxaBuyForm extends StatefulWidget {
  const BanxaBuyForm({
    super.key,
    required this.state,
    required this.cardInnerWidth,
    required this.onRetryCurrencies,
    required this.onGetQuote,
    required this.onBuy,
  });

  final MakeOrderState state;

  /// The card's own available CONTENT width, computed by the caller from the
  /// page's existing `LayoutBuilder` (outer width minus 34). Passed as a
  /// number because a `LayoutBuilder` in here would throw the moment
  /// `IntrinsicHeight` asked this card for an intrinsic height, which is
  /// exactly what the two-column layout does to it.
  final double cardInnerWidth;

  final VoidCallback onRetryCurrencies;
  final VoidCallback onGetQuote;
  final VoidCallback onBuy;

  @override
  State<BanxaBuyForm> createState() => _BanxaBuyFormState();
}

class _BanxaBuyFormState extends State<BanxaBuyForm> {
  final _amountController = TextEditingController();
  final _walletController = TextEditingController();

  // MEASURED 2026-07-31 (260731-uhe Task 1c), printed by the two
  // "MEASUREMENT" tests in `buy_form_layout_test.dart`, which pump every
  // number below rather than deriving it.
  //
  // Real intrinsic widths of a `GWSelect` at its own label:
  //   worst case  `United States Dollar (USD)` 476.0px, `Credit / Debit Card`
  //               364.0px -> budget 476 + 16 (space8 gap) + 364 = 856px
  //   typical     `Euro (EUR)` 220.0px, `Credit Card` 236.0px
  //               -> budget 220 + 16 + 236 = 472px
  //   chrome only `USD` 108.0px
  //
  // The threshold is set from the TYPICAL pair, not the worst case, and that
  // is the load-bearing judgement here rather than a rounding choice. A
  // `GWSelect` ELLIPSIZES; it does not overflow. Demanding that the longest
  // label Banxa can return render untruncated would put the floor at 856px,
  // and the form card's inner width tops out at 726px in the two-column
  // layout - so the side-by-side branch would be dead exactly where the
  // design asks for it. Above 480 the worst-case label truncates and stays
  // readable; below it, a column is closer to chrome (108) than to content.
  //
  // 480 = 472 + 8 of headroom.
  //
  // A `GWCard`'s inner content width is its outer width MINUS 34, not minus
  // 32: `space8` (16) of padding each side PLUS one pixel each side for the
  // hairline, because `Container` adds `decoration.padding` on top of its own
  // `padding`. Same two pixels `_OrdersRail._inlineTrackMinWidth` turns on.
  //
  // Measured crossovers, every one pumped rather than derived:
  //   - single column (window < 1048, since the two-column check is
  //     `window - 24 >= 1024`): card inner = window - 58. Measured 317 at
  //     window 375 and 442 at window 500 (both STACKED); the crossover is
  //     window 538 (inner 480), so SIDE BY SIDE from 538 to 1047.
  //   - two column (window >= 1048): card inner =
  //     (min(window - 24, 1536) - 16) / 2 - 34. Measured 470 at the 1048
  //     minimum (STACKED), 610 at window 1328 and 726 from window 1560 up,
  //     where the page hits its `GeniusBreakpoints.xxl` cap and stops
  //     growing. The crossover is window 1068 (inner 480).
  //
  // BOTH branches are live in BOTH layouts, so both are kept. The stacked
  // branch's two-column band is narrow - windows 1048 to 1067 - but it is
  // real, and it is the band where the card is at its narrowest with a rail
  // beside it.
  static const double _sideBySideMinWidth = 480;

  /// The fiat amounts the shortcut chips offer, before the payment method's
  /// own range filters them.
  static const List<int> _ladder = <int>[100, 500, 1000, 5000];

  // The track's own fixed slot: the chip height (32, pinned to
  // `_OrderToneChip._chipHeight`) plus 8 - `EdgeInsets.all(3)` of
  // `GWControlTrack` padding top and bottom, plus 1px of hairline top and
  // bottom. Fixed rather than shrink-wrapped so a payment method whose range
  // excludes every ladder amount cannot collapse the row and resize the rail.
  static const double _trackSlotHeight = _AmountChip.chipHeight + 8;

  @override
  void dispose() {
    _amountController.dispose();
    _walletController.dispose();
    super.dispose();
  }

  /// The chip's LABEL - formatted, with a symbol and thousands separators.
  /// Never what gets written to the field: `state.amountValue` is a
  /// `double.tryParse`, so a formatted string there parses to null and
  /// silently disables the CTA with no error.
  String _chipLabel(int amount, String symbol, String code) {
    if (symbol.isNotEmpty) {
      return NumberFormat.currency(
        symbol: symbol,
        decimalDigits: 0,
      ).format(amount);
    }
    // Banxa can return an empty symbol. Fall back to the code rather than
    // printing a bare number nobody can denominate.
    final plain = NumberFormat.decimalPattern().format(amount);
    return code.isEmpty ? plain : '$plain $code';
  }

  /// `Min: 20 / Max: 15000`, or `Min: - / Max: -` when no payment method is
  /// selected. ALWAYS non-null, which is the point: a helper that appeared
  /// only once a payment method was chosen would change the card's height at
  /// that moment, the same failure mode as a quote reflow. The `-` placeholder
  /// is the idiom the quote grid above already uses.
  String _limitsHelper(MakeOrderState state) {
    final format = NumberFormat.decimalPattern();
    final min = state.minAmount;
    final max = state.maxAmount;
    return 'Min: ${min == null ? '-' : format.format(min)} / '
        'Max: ${max == null ? '-' : format.format(max)}';
  }

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final state = widget.state;

    // The controllers follow the CUBIT, never the other way round - so a
    // shortcut chip that writes through `setAmountText` reaches the field.
    // Moved here with the controllers themselves; leaving this sync behind on
    // the screen would have silently broken the chips.
    if (_amountController.text != state.amountText) {
      _amountController.text = state.amountText;
      _amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: _amountController.text.length),
      );
    }
    if (_walletController.text != state.walletText) {
      _walletController.text = state.walletText;
      _walletController.selection = TextSelection.fromPosition(
        TextPosition(offset: _walletController.text.length),
      );
    }

    // One CTA, two rungs (DECISION.md): `getQuote()`/`canGetQuote` until a
    // quote exists, then `createOrder()`/`canCreateOrder`. Both guards read
    // straight from state — never re-derived locally.
    final ctaLabel = state.hasQuote ? 'Buy GNUS' : 'Get quote';
    final ctaEnabled = state.hasQuote
        ? state.canCreateOrder
        : state.canGetQuote;
    VoidCallback? ctaOnPressed;
    if (ctaEnabled) {
      ctaOnPressed = state.hasQuote ? widget.onBuy : widget.onGetQuote;
    }

    // A2: the chips are denominated in the SELECTED fiat. The design drew
    // dollars because the design drew USD; with EUR selected, `$100` is simply
    // false.
    final symbol = state.selectedFiat?.symbol ?? '';

    // The ladder, filtered to the payment method's legal range.
    //
    // Said plainly rather than implied: `minAmount`/`maxAmount` are null ONLY
    // while no payment method is selected, and in THAT state NOTHING here is
    // validated - the ladder is offered whole. That is safe, not lucky:
    // `canGetQuote` requires `hasSelections`, which requires a payment method,
    // so the CTA is disabled and an out-of-range chip cannot reach Banxa.
    final min = state.minAmount;
    final max = state.maxAmount;
    final amounts = _ladder
        .where((v) => (min == null || v >= min) && (max == null || v <= max))
        .toList();

    // ONE condition, read once, so the two branches below cannot disagree.
    final sideBySide = widget.cardInnerWidth >= _sideBySideMinWidth;

    // Built once and placed by whichever branch wins, so the two branches
    // cannot drift in what they render - only in how they arrange it.
    final fiatSelect = GWSelect<FiatCurrency>(
      key: ValueKey(state.selectedFiat),
      value: state.selectedFiat,
      enabled: state.step != MakeOrderStep.loadingCurrencies,
      items: state.fiats
          .map((f) => GWSelectItem(value: f, label: '${f.name} (${f.code})'))
          .toList(),
      onChanged: (val) {
        if (val != null) {
          context.read<MakeOrderCubit>().selectFiat(val);
        }
      },
    );
    final paymentSelect = GWSelect<PaymentMethod>(
      key: ValueKey(state.selectedPaymentMethod),
      value: state.selectedPaymentMethod,
      enabled: state.step != MakeOrderStep.loadingCurrencies,
      items: state.paymentMethods
          .map((m) => GWSelectItem(value: m, label: m.name))
          .toList(),
      onChanged: (val) {
        if (val != null) {
          context.read<MakeOrderCubit>().selectPaymentMethod(val);
        }
      },
    );

    return GWCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // The currency-load retry affordance (pre-existing: the
          // separate "Get Quote" row this replaces carried the same
          // icon/tooltip beside it). Kept — this plan changes chrome,
          // inputs and layout, not the error surfaces (Rule 2).
          if (state.step == MakeOrderStep.error && state.fiats.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: GeniusWalletConsts.space8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Couldn't load currencies.",
                      style: GeniusWalletTypography.bodySm.copyWith(
                        color: gw.statusError,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onRetryCurrencies,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Retry',
                  ),
                ],
              ),
            ),
          // THE HERO. The one number the user actually types, at the top of
          // the card and in a bigger type step than every other field on it
          // (`numericHeadline`'s 24 against `bodyLg`'s 16). Not
          // `numericDisplay` (32): this card is 470px wide at the narrowest
          // two-column window and the field shares that width with a symbol
          // prefix. Tabular figures so a live-typed number does not jitter
          // column to column.
          _LabelledField(
            'You spend',
            GWTextField(
              controller: _amountController,
              textStyle: GeniusWalletTypography.numericHeadline,
              // An INLINE prefix, on the digits' own baseline and sized to
              // the glyph - not the 48px centred icon gutter it used to
              // land in. Bare `Text` on purpose: the field supplies the
              // type step and the secondary ink through `prefixStyle`, and
              // restating them here would silently defeat it.
              prefix: symbol.isEmpty ? null : Text(symbol),
              helper: _limitsHelper(state),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (v) => context.read<MakeOrderCubit>().setAmountText(v),
            ),
          ),
          const SizedBox(height: GeniusWalletConsts.space8),
          // The shortcut track, in a FIXED slot - see `_trackSlotHeight`.
          // `GWControlTrack` is the shared recessed well, so this is the
          // app's fifth track rather than a fifth chip language.
          SizedBox(
            height: _trackSlotHeight,
            child: amounts.isEmpty
                ? null
                : GWControlTrack(
                    children: [
                      for (final amount in amounts)
                        // `Expanded`, so the track fills the card width and
                        // the chips share it evenly - which is what the
                        // design draws AND what makes the row overflow-proof
                        // at every width without a scroll viewport. A
                        // viewport here would throw the moment
                        // `IntrinsicHeight` queried this card.
                        Expanded(
                          child: _AmountChip(
                            label: _chipLabel(amount, symbol, state.fiatCode),
                            // Selection is DERIVED, never stored: typing 500
                            // by hand lights the same chip a tap would.
                            selected: state.amountValue == amount,
                            // A bare parseable number, never the formatted
                            // label - see `_chipLabel`.
                            onTap: () => context
                                .read<MakeOrderCubit>()
                                .setAmountText(amount.toString()),
                          ),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: GeniusWalletConsts.space8),
          if (sideBySide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _LabelledField('Currency', fiatSelect)),
                const SizedBox(width: GeniusWalletConsts.space8),
                Expanded(
                  child: _LabelledField('Payment method', paymentSelect),
                ),
              ],
            )
          else ...[
            _LabelledField('Currency', fiatSelect),
            const SizedBox(height: GeniusWalletConsts.space8),
            _LabelledField('Payment method', paymentSelect),
          ],
          // A1: the crypto picker is absent from the design and the screen is
          // called Buy GNUS, but deleting a live control that reads from
          // `state.cryptos` is a behaviour change, not a layout change. Gated
          // on there being a choice to make: on a GNUS-only Banxa response the
          // form matches the design exactly, and if Banxa ever offers more,
          // nobody is locked out.
          //
          // Placed HERE - full width, under the currency/payment row and above
          // the wallet field - for two reasons. It belongs with the other
          // "what am I trading" selects rather than after the wallet address.
          // And it must not join that row as a third column: the row's
          // collapse threshold is measured for exactly TWO selects, and a
          // third would invalidate the measurement and cramp the card at every
          // width.
          if (state.cryptos.length > 1) ...[
            const SizedBox(height: GeniusWalletConsts.space8),
            _LabelledField(
              'Crypto currency',
              GWSelect<CryptoCurrency>(
                key: ValueKey(state.selectedCrypto),
                value: state.selectedCrypto,
                enabled: state.step != MakeOrderStep.loadingCurrencies,
                items: state.cryptos
                    .map(
                      (c) => GWSelectItem(
                        value: c,
                        label: '${c.name} (${c.code})',
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    context.read<MakeOrderCubit>().selectCrypto(val);
                  }
                },
              ),
            ),
          ],
          const SizedBox(height: GeniusWalletConsts.space8),
          // Not in the design, kept at Jakub's explicit instruction.
          _LabelledField(
            'Wallet address',
            GWTextField(
              controller: _walletController,
              onChanged: (v) => context.read<MakeOrderCubit>().setWalletText(v),
            ),
          ),
          const SizedBox(height: GeniusWalletConsts.space10),
          // Rendered in BOTH states — placeholders before a quote,
          // values after — so this card never changes height and the
          // rail beside it never shifts when a quote lands.
          //
          // The reflow risk is no longer only this grid and the trailing line
          // below it. It is now ALSO the chip row's fixed slot (which stays
          // reserved when the ladder filters down to nothing) and the limits
          // helper on the hero field (which is always present, `-` and all).
          // Four things now have to stay height-constant, not two.
          GWDetailGrid(
            rows: [
              _QuoteGridRow(
                label: 'You get',
                value: state.hasQuote
                    ? '${state.quote!.cryptoAmount} ${state.cryptoCode}'
                    : '-',
                isPlaceholder: !state.hasQuote,
              ),
              _QuoteGridRow(
                label: 'Rate',
                value: _quoteRateText(state),
                isPlaceholder: !state.hasQuote,
              ),
              _QuoteGridRow(
                label: 'Banxa fee',
                value: _quoteFeeText(state),
                isPlaceholder: !state.hasQuote,
              ),
            ],
          ),
          const SizedBox(height: GeniusWalletConsts.space10),
          GWButton(
            variant: GWButtonVariant.gradient,
            size: GWButtonSize.lg,
            expand: true,
            label: ctaLabel,
            onPressed: ctaOnPressed,
          ),
          // Rendered UNCONDITIONALLY (an empty string in the no-quote
          // state) rather than only `if (state.hasQuote)` — the latter
          // would add a line only once a quote lands, growing the
          // card's height at the exact moment Task 2's own invariant
          // says it must not: "the form card's height does not change
          // when a quote arrives". An empty `Text` still reserves its
          // line-height, so the row's own space is constant across
          // both states.
          const SizedBox(height: GeniusWalletConsts.space4),
          Center(
            child: Text(
              state.hasQuote ? 'You will finish payment on Banxa.' : '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GeniusWalletTypography.bodySm.copyWith(
                color: gw.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A4: one labelled control on this card - a [GWKicker] over a field, with
/// the field's own built-in `label:` left null.
///
/// The design draws uppercase kickers (`YOU SPEND`, `CURRENCY`, `PAYMENT
/// METHOD`). `GWSelect` and `GWTextField` each render their own `label` in
/// sentence case at `labelMd`, and using kickers for some fields and the
/// built-in label for others is the "partial adoption reads as a different
/// design language on the same screen" failure `CONVENTIONS.md` names. So
/// every label on this card comes through here.
///
/// The kicker also owns the accessible casing - call sites pass sentence case
/// and the widget upper-cases for display - which pre-uppercasing a `label:`
/// string would have thrown away.
///
/// It owns NO gap of its own, so both branches of the CURRENCY / PAYMENT
/// METHOD split keep an identical vertical rhythm.
class _LabelledField extends StatelessWidget {
  const _LabelledField(this.kicker, this.field);

  final String kicker;
  final Widget field;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GWKicker(kicker),
        const SizedBox(height: GeniusWalletConsts.space4),
        field,
      ],
    );
  }
}

/// One amount shortcut chip under the hero field - a label at the track's own
/// rhythm, a child of [GWControlTrack]. Private: one consumer.
///
/// Modelled directly on [_OrderToneChip] below (same 32px height, same 120ms
/// settle, same `radiusPill`, same `GWHoverable` lift onto `surfaceElevated`,
/// same `Semantics(button:, selected:)`), differing only in carrying a label
/// with no count.
///
/// **No gradient in any state.** `GWTimeframeSegment`'s selected tab does wear
/// the brand gradient, and copying it here would be the exact mistake
/// `_OrderToneChip`'s own doc records replacing: this card already carries the
/// gradient CTA, and a shortcut chip must not be handed the visual weight of
/// the screen's one commitment action. Selected is a FLAT `gw.surfaceMenu`
/// fill with `gw.textPrimary`.
class _AmountChip extends StatelessWidget {
  const _AmountChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Pinned to `_OrderToneChip._chipHeight` and, through it, to the
  /// transactions filter bar's own 32px chip - so every track in the app sits
  /// at the same rhythm. Not private, because `_BanxaBuyFormState` computes
  /// the track's fixed slot from it.
  static const double chipHeight = 32;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Semantics(
      button: true,
      selected: selected,
      child: GWHoverable(
        builder: (hovered) {
          // Design-system hover = "lift chip" (sketch 008 variant D), the same
          // as every other interactive chip in the app.
          final bool lifted = hovered && !selected;
          final Color textColor = selected
              ? gw.textPrimary
              : (lifted ? gw.textPrimary : gw.textMutedOnSunken);
          // InkWell for focus + Enter/Space (WCAG 2.1.1 Level A).
          return Semantics(
            button: true,
            selected: selected,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                hoverColor: Colors.transparent,
                borderRadius: BorderRadius.circular(
                  GeniusWalletConsts.radiusPill,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  height: chipHeight,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: GeniusWalletConsts.space3,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? gw.surfaceMenu
                        : (lifted ? gw.surfaceElevated : Colors.transparent),
                    borderRadius: BorderRadius.circular(
                      GeniusWalletConsts.radiusPill,
                    ),
                  ),
                  // Ellipsised rather than allowed to overflow: at the
                  // phone-width card the four chips share 309px, and a long
                  // fallback label (`5,000 XYZ`, when Banxa returns no symbol)
                  // would not fit.
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GeniusWalletTypography.labelMd.copyWith(
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A rate DERIVED from the quote's own fields (fiatAmount / cryptoAmount) —
/// never a fabricated number. `-` (a plain hyphen, never an em dash) when no
/// quote exists or the arithmetic is not defined.
String _quoteRateText(MakeOrderState state) {
  final quote = state.quote;
  if (quote == null) {
    return '-';
  }
  final fiatAmount = double.tryParse(quote.fiatAmount);
  final cryptoAmount = double.tryParse(quote.cryptoAmount);
  if (fiatAmount == null || cryptoAmount == null || cryptoAmount == 0) {
    return '-';
  }
  final rate = fiatAmount / cryptoAmount;
  return '1 ${state.cryptoCode} = ${rate.toStringAsFixed(4)} ${state.fiatCode}';
}

/// "Banxa fee" is the sum of the quote's two real fee fields (processing +
/// network) — both given by the quote, never fabricated.
String _quoteFeeText(MakeOrderState state) {
  final quote = state.quote;
  if (quote == null) {
    return '-';
  }
  final processing = double.tryParse(quote.processingFee) ?? 0;
  final network = double.tryParse(quote.networkFee) ?? 0;
  final total = processing + network;
  return '${total.toStringAsFixed(2)} ${state.fiatCode}';
}

/// One row of the quote grid (Task 2). Private — the grid has exactly one
/// consumer (this screen).
class _QuoteGridRow extends StatelessWidget {
  const _QuoteGridRow({
    required this.label,
    required this.value,
    required this.isPlaceholder,
  });

  final String label;
  final String value;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Padding(
      padding: kGWDetailRowPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GeniusWalletTypography.bodyMd.copyWith(
              color: gw.textSecondary,
            ),
          ),
          // Pinned to one line: an unbounded value Text could wrap onto a
          // second line for a long real value where the `-` placeholder
          // never would, which is exactly the height difference Task 2's
          // own invariant forbids ("the form card's height does not change
          // when a quote arrives").
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: GeniusWalletTypography.bodyMd.copyWith(
                color: isPlaceholder ? gw.textPrimary38 : gw.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Task 3: the orders rail beside the form. A `StatelessWidget` private to
/// this file — one consumer, under the Rule of Three (`AGENTS.md:53`); not
/// promoted to `lib/components/`.
class _OrdersRail extends StatelessWidget {
  const _OrdersRail({
    required this.state,
    required this.bounded,
    required this.selectedTone,
    required this.onSelectTone,
  });

  final OrdersState state;

  /// True in the two-column layout, where the caller has already handed this
  /// card a TIGHT height derived from the form card beside it (D-02). The
  /// rows then live in an `Expanded` and scroll inside the leftover space.
  ///
  /// False in the stacked layout, where there is no card beside the rail and
  /// so no referent for "as tall as the box on the left" (D-04) - the rows
  /// shrink-wrap and the page's own scroll carries them.
  ///
  /// Set from the SAME condition that picks `Row` versus `Column` in
  /// `_BanxaBuyScreenState.build`, so the flag and the layout cannot disagree.
  final bool bounded;

  final OrderStatusTone? selectedTone;
  final ValueChanged<OrderStatusTone?> onSelectTone;

  // The STACKED layout's answer to "how tall is a rail with nothing in it",
  // for the loading and empty branches. `09-OUTSTANDING.md` records that
  // `GWEmptyState` auto-switches to a compact tier below a 192px slot, and
  // which tier renders in a card like this one had never been observed at a
  // real window size; bounding it removes that unknown.
  //
  // In the two-column layout the DERIVED bound supersedes it, and does so
  // without a conditional: `RenderConstrainedBox` clamps its own constraint
  // into the parent's (`BoxConstraints.enforce`), so under the tight height
  // the form card handed down, this 220 silently becomes that height. It is
  // therefore not a fixed pixel height on the two-column path, only on the
  // stacked one where it is the only answer available.
  static const double _boundedSlotHeight = 220;

  // RE-MEASURED 2026-07-31 (260731-ti5 Task 1), after `View all` was deleted
  // from both header branches - the link was a term in this budget, so its
  // removal moves the threshold AND flips the reachability finding this
  // comment used to record.
  //
  // Real intrinsic widths at 4 seeded orders, one per tone, printed by the
  // "MEASUREMENT" test in `test/banxa/orders_header_track_test.dart`:
  // `Your orders` kicker 148.5px, track 444.0px. Budget for the inline row is
  // now kicker (148.5) + a minimum gap (16) + track (444.0) = 608.5px. 610
  // below adds a couple of px of headroom. The old value was 736, carrying
  // the `VIEW ALL` link (113.8) and its space6 gap (12) as well.
  //
  // THE FINDING IS NOW THE OPPOSITE OF WHAT IT WAS. With the link in the row
  // the inline branch was unreachable in the two-column layout, because the
  // rail card's inner content width tops out at 726px and 726 was under 736.
  // 726 is comfortably OVER 610, so the inline branch is now genuinely live
  // in the two-column layout at wide windows.
  //
  // A `GWCard`'s inner width is its outer width MINUS 34, not minus 32:
  // `space8` (16) of padding on each side PLUS one pixel each side for the
  // hairline, because `Container` adds `decoration.padding` -
  // `Border.all(width: 1).dimensions` - on top of its own `padding`. Two
  // pixels, and they decide the branch within 1px of the crossover, so they
  // are not a rounding detail here.
  //
  // Measured crossovers, every one of them pumped rather than derived:
  //   - single column (window < 1048, since the two-column check is
  //     `window - 24 >= 1024`): card inner = window - 24 page padding - 34.
  //     Own row at window 667 (inner 609), INLINE from window 668 (inner 610).
  //   - two column (window >= 1048): card inner =
  //     (min(window - 24, 1536) - 16) / 2 - 34. That is 470px at the 1048px
  //     minimum (OWN ROW), 609.5px at window 1327 (still own row), 610px at
  //     window 1328 (INLINE), and 726px from window 1560 up, where the page
  //     hits its `GeniusBreakpoints.xxl` cap and stops growing.
  // Both branches are therefore reachable at real window sizes, which is why
  // both are kept.
  static const double _inlineTrackMinWidth = 610;

  @override
  Widget build(BuildContext context) {
    if (state.status == OrdersStatus.loading ||
        state.status == OrdersStatus.initial) {
      // The 220 needs no `bounded` conditional: `RenderConstrainedBox` folds
      // its own constraint into the incoming one (`BoxConstraints.enforce`),
      // so under the two-column layout's tight height this becomes the
      // derived height and in the stacked layout it stays 220. Already
      // correct in both.
      return const GWCard(
        child: SizedBox(
          height: _boundedSlotHeight,
          child: Center(child: Loading()),
        ),
      );
    }

    if (state.status == OrdersStatus.error) {
      // No fixed height here (unlike the loading/empty branches below):
      // `GWErrorState` has no compact tier, and `state.error` is an
      // unbounded string — a fixed slot would overflow on a long message.
      // Sized naturally, the same way `banxa_orders_history.dart` and
      // `order_details_page.dart` already render it.
      return GWCard(
        child: GWErrorState(
          title: "Couldn't load your orders",
          message: state.error,
          onRetry: () => context.read<OrdersCubit>().fetchOrders(),
        ),
      );
    }

    final counts = state.statusCounts;
    final total = state.totalOrderCount;
    final all = List<Order>.of(state.orders?.orders ?? const <Order>[])
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final visible = selectedTone == null
        ? all
        : all.where((o) => orderStatusTone(o.status) == selectedTone).toList();

    // Fixed order: All, Pending, Done, Issues. `OrderStatusTone.neutral`
    // deliberately has no chip: with today's five Banxa statuses it is always
    // 0, because `orderStatusTone`'s `default` arm (`order_status_style.dart`)
    // is only reached by an unrecognised status string — an unknown future
    // status lands under All only, and the four counts plus neutral always
    // sum to `total` (`banxa_order_state.dart`'s `statusCounts`/
    // `totalOrderCount`).
    //
    // Issues is the new chip and the point of this change: `orderStatusTone`
    // maps `declined`, `cancelled`, `expired` and `failed` to `error`, and
    // until now nothing rendered that count — a declined order was invisible
    // under every filter except All.
    // Measured (Task 3), the labelled track renders at ~444px — well over
    // the sketch's own ~332px estimate (`index.html:361`) — and does not fit
    // even the phone-width card's 344px inner content on its own row. Rather
    // than clip a status or silently drop a chip (both forbidden by this
    // plan's success criteria: "every status stays visible ... nothing is
    // hidden, deferred or stubbed"), the track is wrapped in a horizontal
    // `SingleChildScrollView`. `SingleChildScrollView`'s own render object
    // sizes itself to `constraints.constrain(child.size)` — under the loose
    // width constraints this `Align` gives it, that means it HUGS the
    // track's own width (so `Align` can still push it to the right) when
    // the track fits, and clamps to the available width (scrollable, not
    // overflowing, not hiding a chip) on the one width where it does not.
    // This wrapping is local to THIS call site, not `GWControlTrack` itself,
    // which stays geometry-only per its own doc comment.
    final track = Align(
      alignment: Alignment.centerRight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: GWControlTrack(
          children: [
            _OrderToneChip(
              label: 'All',
              count: total,
              selected: selectedTone == null,
              // All always sends null; a chip that is already active sends
              // null too, matching the transactions filter bar's "tap the
              // active chip to clear back to All" behaviour
              // (`transactions_slim_view.dart`'s
              // `_TransactionFilterBar._chip`).
              onTap: () => onSelectTone(null),
            ),
            _OrderToneChip(
              label: 'Pending',
              count: counts[OrderStatusTone.warning] ?? 0,
              selected: selectedTone == OrderStatusTone.warning,
              onTap: () => onSelectTone(
                selectedTone == OrderStatusTone.warning
                    ? null
                    : OrderStatusTone.warning,
              ),
            ),
            _OrderToneChip(
              label: 'Done',
              count: counts[OrderStatusTone.success] ?? 0,
              selected: selectedTone == OrderStatusTone.success,
              onTap: () => onSelectTone(
                selectedTone == OrderStatusTone.success
                    ? null
                    : OrderStatusTone.success,
              ),
            ),
            _OrderToneChip(
              label: 'Issues',
              count: counts[OrderStatusTone.error] ?? 0,
              selected: selectedTone == OrderStatusTone.error,
              onTap: () => onSelectTone(
                selectedTone == OrderStatusTone.error
                    ? null
                    : OrderStatusTone.error,
              ),
            ),
          ],
        ),
      ),
    );

    // The card's body slot under the header: the empty state, or the rows.
    // Wrapped in `Expanded` below when [bounded], so it consumes exactly the
    // height left over inside the height the form card handed down; left to
    // size itself when not.
    final Widget body = visible.isEmpty
        ? SizedBox(
            // Kept in BOTH layouts on purpose - see `_boundedSlotHeight`'s
            // own comment. Under the two-column layout's tight incoming
            // height this 220 is clamped away by `BoxConstraints.enforce` and
            // the derived height wins; in the stacked layout it is the only
            // bound there is.
            height: _boundedSlotHeight,
            child: GWEmptyState(
              icon: Icons.receipt_long_outlined,
              title: total == 0
                  ? 'No orders yet'
                  : 'No orders match this filter.',
              message: total == 0
                  ? 'Your Banxa purchases will show up here once you create one.'
                  : null,
            ),
          )
        : _OrderRows(orders: visible, scrollable: bounded);

    // No `View all` link here, in EITHER header branch (260731-ti5 D-01,
    // Jakub 2026-07-31). It existed only because the rail capped itself at
    // four rows and needed an escape hatch to the rest; the rail is now
    // bounded by the form card beside it and scrolls its whole in-memory
    // list, so there is nothing left for the link to escape to.
    // `GWViewAllLink` itself stays - `dashboard_markets.dart:68` is its other
    // live call site. The `/buy/orders` route this used to push is now
    // without an in-app entry point; recorded, not resolved, in
    // `.planning/todos/pending/2026-07-31-banxa-orders-never-enter-the-transaction-store.md`.
    return GWCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= _inlineTrackMinWidth) {
                return GWKicker('Your orders', trailing: track);
              }
              // `stretch`, not the `end` this carried while the kicker had a
              // `View all` trailing. `GWKicker` with no trailing is a bare
              // `Text`, and under `end` a bare Text shrink-wraps and gets
              // shoved to the RIGHT edge. Stretched, it fills the row and
              // renders left as it always did, while `track`'s own
              // `Align(centerRight)` still pushes the chips right - which is
              // exactly what the old `GWKicker` Row's `spaceBetween` did.
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const GWKicker('Your orders'),
                  const SizedBox(height: GeniusWalletConsts.space8),
                  track,
                ],
              );
            },
          ),
          const SizedBox(height: GeniusWalletConsts.space8),
          // NO `ClipRRect` around the scroll viewport, and none is needed.
          // `GWCard` insets its content by `space8` (16px) on every side, plus
          // 1px for the hairline, against a corner radius of `radiusLg`
          // (15px). 17 > 15, so the viewport's rect is inset FURTHER than the
          // corner arc reaches: no row and no overscroll glow can ever paint
          // over the rounded edge. A clip here would be dead code that costs
          // a save layer on every frame of the scroll. Asserted in
          // `orders_rail_bounds_test.dart`.
          if (bounded) Expanded(child: body) else body,
        ],
      ),
    );
  }
}

/// The rail's rows: the SAME `TransactionRow` the Transactions tab renders,
/// divider-separated exactly the way `transactions_slim_view.dart:512` draws
/// them, with no divider after the last (260731-ope). `ListView.separated`
/// gives that no-trailing-divider behaviour for free, which is all the manual
/// index check this replaced was doing.
///
/// The row is handed a pre-built `TxRowContent` rather than deriving one:
/// for a card purchase the fiat actually PAID is the value line, which is a
/// different FACT from the price map's estimate (D-03). That also means the
/// row makes no `livePricesBySymbol()` call and touches no Hive box here.
///
/// Day HEADERS are deliberately absent. The reason USED to be "the rail
/// renders at most four rows", which stopped being true when 260731-ti5
/// deleted the cap - so here is the reason that survives it: the day already
/// rides in each row's own subtitle (`orderRowContent`), so a header above
/// each row would be pure duplication, in a card half the page wide. The tab
/// groups by day because its rows carry no date of their own.
///
/// Accepted cost, stated so nobody "fixes" it: inside `GWCard` the hairline
/// is inset by the card's padding instead of running full-bleed like the
/// tab's. Do not negative-margin it out.
class _OrderRows extends StatelessWidget {
  const _OrderRows({required this.orders, required this.scrollable});

  final List<Order> orders;

  /// True when the rail has been given a bounded height and this list is what
  /// scrolls inside it (D-03: the BOX scrolls, it does not fetch - nothing
  /// here listens to scroll position and nothing calls `OrdersCubit`).
  /// False when the page's own scroll carries the rows, in which case this
  /// shrink-wraps and refuses to scroll on its own.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: !scrollable,
      physics: scrollable ? null : const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, thickness: 1, color: context.gw.borderSubtle),
      itemBuilder: (context, index) {
        final order = orders[index];
        // Built ONCE and shared by the row and the drawer it opens, so the two
        // presentations cannot disagree about a single order.
        final content = orderRowContent(order);
        final tx = orderAsTransaction(order);
        return TransactionRow(
          tx: tx,
          contentOverride: content,
          onTap: () => showTransactionDetails(
            context,
            tx,
            contentOverride: content,
            extraTransactionRows: orderTransactionRows(order),
            extraNetworkRows: orderNetworkRows(order),
            footer: _orderFooter(context, order),
          ),
        );
      },
    );
  }

  /// The drawer's footer for one order, or NULL to keep the shared drawer's
  /// own explorer-button behaviour (D-02).
  ///
  /// Gating is on the RAW status string lowercased - the same two literals
  /// `order_details_page.dart:65-99` compares - and NOT on the mapped
  /// `TransactionStatus`, which folds `inProgress` into `pending` and would
  /// offer Complete Payment on an order that cannot be paid.
  ///
  /// `/orderDetails` keeps its own buttons and stays routed; only the rail's
  /// tap target moved.
  Widget? _orderFooter(BuildContext context, Order order) {
    final status = order.status.toLowerCase();

    if (status == 'pendingpayment' &&
        order.orderStatusUrl.isNotEmpty &&
        order.id.isNotEmpty) {
      // A `Builder` INSIDE the footer, so `Navigator.of(ctx)` resolves to the
      // navigator hosting the DRAWER route. The outer `context` would resolve
      // to the shell navigator under GoRouter and pop the screen instead.
      //
      // Popping first is not cosmetic: `showCheckoutOptionsSheet` opens a
      // modal sheet, which would otherwise land underneath the open drawer.
      return Builder(
        builder: (ctx) => GWButton(
          onPressed: () async {
            Navigator.of(ctx).pop();
            await showCheckoutOptionsSheet(
              context,
              checkoutUrl: order.orderStatusUrl,
              orderId: order.id,
              redirectUrl: BanxaApiService.redirectUrl,
            );
          },
          label: 'Complete Payment',
          // A commitment - it takes you to pay.
          variant: GWButtonVariant.gradient,
          size: GWButtonSize.lg,
          expand: true,
        ),
      );
    }

    if (status == 'declined') {
      return Builder(
        builder: (ctx) => GWButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            context.push(
              '/createOrder',
              // The same prefilled map `order_details_page.dart:86-95` builds.
              extra: {
                'fiat': order.fiat,
                'crypto': order.crypto.id,
                'method': order.paymentMethodId,
                'amount': order.fiatAmount,
                'wallet': order.walletAddress,
              },
            );
          },
          label: 'Retry Order',
          // Hollow: it opens a form and commits to nothing - the same
          // reasoning that made the explorer button hollow. Deliberately
          // unlike `order_details_page.dart`'s `secondary` Retry, which that
          // page keeps.
          variant: GWButtonVariant.gradientOutline,
          size: GWButtonSize.lg,
          expand: true,
        ),
      );
    }

    return null;
  }
}

/// Reports **zero** intrinsic height, then fills whatever height it is given.
///
/// This is the whole mechanism behind D-02, and it exists for two separate
/// reasons - both non-obvious, and both the reason the naive version of this
/// layout fails:
///
///   1. `IntrinsicHeight` asks EVERY child for an intrinsic height, and a
///      scrollable has no answer - `RenderViewport` throws outright rather
///      than guess. Returning 0 WITHOUT forwarding the query is what makes
///      the rail's `ListView` legal underneath it at all. (The rail's own
///      `LayoutBuilder` would throw for the same reason, and is shielded by
///      the same 0.)
///   2. `IntrinsicHeight` takes the MAX of its children's intrinsic heights.
///      Left to answer honestly, a rail holding 40 orders would grow the FORM
///      card to match it - the exact opposite of what was asked. Answering 0
///      makes that max unconditionally the form card's own intrinsic height,
///      which is what makes the relationship ONE-DIRECTIONAL: the form card
///      decides, the rail follows.
///
/// `_FillHeight`/`_RenderFillHeight` at `token_info_screen.dart:1568` is the
/// same idea, doing the same job for the coin page's chart. It stays
/// duplicated rather than shared: two occurrences do not justify a shared
/// component (`AGENTS.md`, Rule of Three), and the two differ in intent
/// enough - one keeps a chart from driving a row, this one keeps a list from
/// driving a card - that a shared name would have to serve both badly.
///
/// ponytail: a `RenderProxyBox` intrinsic override rather than a layout
/// algorithm. Ceiling: a box that claims zero intrinsic height COLLAPSES
/// inside any parent that does not supply a tight height of its own, so this
/// is only ever correct under the stretch `Row` above - which the single call
/// site guarantees. Upgrade path: none needed; a second caller should assert
/// its parent instead of relaxing this.
class _ZeroIntrinsicHeight extends SingleChildRenderObjectWidget {
  const _ZeroIntrinsicHeight({required Widget child}) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderZeroIntrinsicHeight();
}

class _RenderZeroIntrinsicHeight extends RenderProxyBox {
  @override
  double computeMinIntrinsicHeight(double width) => 0;

  @override
  double computeMaxIntrinsicHeight(double width) => 0;
}

/// One "Your orders" filter chip (sketch 169 scheme B) — `label + count` at
/// intrinsic width, a child of [GWControlTrack]. Private — the rail's own
/// filter control, one consumer.
///
/// Replaces `_CountChip`, which broke two conventions at once: a raised
/// `surfaceMenu` pill with no track container (`.planning/codebase/
/// CONVENTIONS.md`'s "Control track" is a sunken well, not a raised chip),
/// and a `brandCta` GRADIENT for the selected state — the same gradient
/// fill as this screen's `Get quote` CTA (`:345-351`), giving a filter chip
/// the same visual weight as the screen's one commitment action. **No
/// gradient in any state** here: selected is a flat `gw.surfaceMenu` fill
/// with `gw.textPrimary`, matching the two conforming tracks
/// (`GWTimeframeSegment`, `_TransactionFilterBar`), neither of which uses a
/// gradient for selection either.
class _OrderToneChip extends StatelessWidget {
  const _OrderToneChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  // Pinned to the transactions filter bar's 32px chip height
  // (`_TransactionFilterBar._chipSize`, `transactions_slim_view.dart`) so
  // the two tracks sit at the same rhythm.
  static const double _chipHeight = 32;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Semantics(
      button: true,
      selected: selected,
      child: GWHoverable(
        builder: (hovered) {
          // Design-system hover = "lift chip" (sketch 008 variant D): an
          // unselected chip rises onto `surfaceElevated`, exactly the way
          // `_TimeframeTab` and `_FilterChip` do — the standard for ALL
          // interactive chrome, so this track behaves identically to the
          // other two under the same cursor.
          final bool lifted = hovered && !selected;
          final Color textColor = selected
              ? gw.textPrimary
              : (lifted ? gw.textPrimary : gw.textMutedOnSunken);
          // InkWell for focus + Enter/Space (WCAG 2.1.1 Level A).
          return Semantics(
            button: true,
            selected: selected,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                hoverColor: Colors.transparent,
                borderRadius: BorderRadius.circular(
                  GeniusWalletConsts.radiusPill,
                ),
                child: AnimatedContainer(
                  // 120ms matches `_TimeframeTab`/`_FilterChip`; all three
                  // control tracks must settle at the same speed.
                  duration: const Duration(milliseconds: 120),
                  height: _chipHeight,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: GeniusWalletConsts.space6,
                    vertical: GeniusWalletConsts.space3,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? gw.surfaceMenu
                        : (lifted ? gw.surfaceElevated : Colors.transparent),
                    borderRadius: BorderRadius.circular(
                      GeniusWalletConsts.radiusPill,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: GeniusWalletTypography.labelMd.copyWith(
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: GeniusWalletConsts.space2),
                      Text(
                        '$count',
                        // Tabular figures so the count does not jitter as it
                        // changes, matching `_TransactionFilterBar`'s menu-item
                        // counts.
                        style: GeniusWalletTypography.numericBody.copyWith(
                          fontSize: 13,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
