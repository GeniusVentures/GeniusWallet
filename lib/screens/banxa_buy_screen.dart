import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/wallet.dart';
import 'package:genius_wallet/account/account_drawer.dart';
import 'package:genius_wallet/banxa/banxa_api_services.dart';
import 'package:genius_wallet/banxa/banxa_components/order_status_style.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/buy_gnus_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/buy_gnus_state.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/components/cards/gw_detail_grid.dart';
import 'package:genius_wallet/components/cards/gw_kicker.dart';
import 'package:genius_wallet/components/cards/gw_select_row.dart';
import 'package:genius_wallet/components/disclaimer_dialogue.dart';
import 'package:genius_wallet/components/effects/gw_hoverable.dart';
import 'package:genius_wallet/components/gw_control_track.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// `/buy`: one compact card that quotes GNUS live and buys it into the
/// Selected wallet.
class BanxaBuyScreen extends StatefulWidget {
  const BanxaBuyScreen({
    super.key,
    this.initialFiatCode,
    this.initialAmount,
    this.createCubit,
  });

  final String? initialFiatCode;
  final String? initialAmount;

  /// Lets a test hand in a cubit with its own clock and no device storage.
  @visibleForTesting
  final BuyGnusCubit Function(BanxaApiService api)? createCubit;

  @override
  State<BanxaBuyScreen> createState() => _BanxaBuyScreenState();
}

class _BanxaBuyScreenState extends State<BanxaBuyScreen> {
  late final BuyGnusCubit _cubit;
  late final StreamSubscription<BuyOrderStarted> _started;
  late final AppLifecycleListener _lifecycle;
  bool _inCheckout = false;

  @override
  void initState() {
    super.initState();
    final api = context.read<BanxaApiService>();
    final make = widget.createCubit ?? (BanxaApiService a) => BuyGnusCubit(a);
    _cubit = make(api);
    _started = _cubit.orderStarted.listen((e) => unawaited(_openCheckout(e)));
    // Quotes stop while the app is hidden, so they do not age in the dark.
    _lifecycle = AppLifecycleListener(
      onHide: _cubit.pause,
      onShow: () {
        if (!_inCheckout) {
          _cubit.resume();
        }
      },
    );
    unawaited(
      _cubit.load(
        initialFiat: widget.initialFiatCode,
        initialAmount: widget.initialAmount,
      ),
    );
  }

  Future<void> _openCheckout(BuyOrderStarted order) async {
    if (!mounted) {
      return;
    }
    unawaited(context.read<OrdersCubit>().track(order.orderId));
    _inCheckout = true;
    _cubit.pause();
    await context.push(
      '/checkout',
      extra: {'orderId': order.orderId, 'checkoutUrl': order.checkoutUrl},
    );
    _inCheckout = false;
    if (mounted) {
      _cubit.resume();
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    unawaited(_started.cancel());
    unawaited(_cubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<BuyGnusCubit, BuyGnusState>(
        listenWhen: (p, c) =>
            c.errorMessage.isNotEmpty && p.errorMessage != c.errorMessage,
        listener: (context, state) =>
            showToast(context, state.errorMessage, type: ToastType.error),
        child: const _BuyPage(),
      ),
    );
  }
}

class _BuyPage extends StatelessWidget {
  const _BuyPage();

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final coin = context.select((BuyGnusCubit c) => c.state.coin);
    return Scaffold(
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Align(
          alignment: Alignment.topCenter,
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
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GWPageHeader(
                        title: 'Buy $coin',
                        subtitle: 'Powered by Banxa',
                        centered: true,
                        trailing: IconButton(
                          icon: Icon(
                            Icons.receipt_long_outlined,
                            color: gw.textSecondary,
                            size: 24,
                          ),
                          tooltip: 'Buy orders',
                          onPressed: () =>
                              context.go('/transactions?filter=purchase'),
                        ),
                      ),
                      const _BuyCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BuyCard extends StatelessWidget {
  const _BuyCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuyGnusCubit, BuyGnusState>(
      builder: (context, state) {
        final Widget content;
        switch (state.availability) {
          case BuyAvailability.ready:
            content = _BuyForm(state: state);
          case BuyAvailability.loading:
            content = const _CardLoading();
          case BuyAvailability.notListed:
          case BuyAvailability.notConfigured:
          case BuyAvailability.loadFailed:
            content = _NotAvailable(
              availability: state.availability,
              coin: state.coin,
            );
        }
        return GWCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.isSandbox) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: _SandboxPill(),
                ),
                const SizedBox(height: GeniusWalletConsts.space6),
              ],
              content,
            ],
          ),
        );
      },
    );
  }
}

/// Shown whenever the client talks to Banxa's sandbox, so a test order is
/// never mistaken for a real purchase.
class _SandboxPill extends StatelessWidget {
  const _SandboxPill();

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final (:fg, :bg) = orderStatusPaint(OrderStatusTone.warning, gw);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space6,
        vertical: GeniusWalletConsts.space2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
      ),
      child: Text(
        'Sandbox · no real money',
        style: GeniusWalletTypography.labelMd.copyWith(color: fg),
      ),
    );
  }
}

/// Stands in for the whole form when Banxa cannot sell the coin right now.
class _NotAvailable extends StatelessWidget {
  const _NotAvailable({required this.availability, required this.coin});

  final BuyAvailability availability;
  final String coin;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final String title;
    final String body;
    String? retryLabel;
    switch (availability) {
      case BuyAvailability.notListed:
        title = "$coin isn't on Banxa yet";
        body =
            "Banxa doesn't sell $coin yet. Buying opens here as soon as it does.";
        retryLabel = 'Check again';
      case BuyAvailability.notConfigured:
        title = "Buying isn't set up in this build";
        body =
            'This build has no Banxa connection. Use an official release to buy $coin.';
      case BuyAvailability.loadFailed:
      case BuyAvailability.loading:
      case BuyAvailability.ready:
        title = "Couldn't reach Banxa";
        body = 'Check your connection and try again.';
        retryLabel = 'Try again';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: GeniusWalletConsts.space8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: GeniusWalletTypography.titleMd.copyWith(
              color: gw.textPrimary,
            ),
          ),
          const SizedBox(height: GeniusWalletConsts.space4),
          Text(
            body,
            textAlign: TextAlign.center,
            style: GeniusWalletTypography.bodyMd.copyWith(
              color: gw.textSecondary,
            ),
          ),
          if (retryLabel != null) ...[
            const SizedBox(height: GeniusWalletConsts.space8),
            GWButton(
              variant: GWButtonVariant.gradientOutline,
              size: GWButtonSize.sm,
              label: retryLabel,
              onPressed: () => unawaited(context.read<BuyGnusCubit>().load()),
            ),
          ],
        ],
      ),
    );
  }
}

class _CardLoading extends StatelessWidget {
  const _CardLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: GeniusWalletConsts.space24),
      child: Center(child: Loading(text: 'Loading from Banxa')),
    );
  }
}

class _BuyForm extends StatelessWidget {
  const _BuyForm({required this.state});

  final BuyGnusState state;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final cubit = context.read<BuyGnusCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const GWKicker('You pay'),
            const SizedBox(width: GeniusWalletConsts.space6),
            Expanded(child: _QuoteMeta(state: state)),
          ],
        ),
        const SizedBox(height: GeniusWalletConsts.space4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _AmountField(
                amountText: state.amountText,
                symbol: state.fiat?.symbol ?? '',
                fiatCode: state.fiat?.code ?? '',
                onChanged: cubit.setAmountText,
              ),
            ),
            const SizedBox(width: GeniusWalletConsts.space6),
            _FiatPill(state: state),
          ],
        ),
        const SizedBox(height: GeniusWalletConsts.space2),
        _LimitsLine(state: state),
        const SizedBox(height: GeniusWalletConsts.space6),
        _PresetChips(state: state),
        const SizedBox(height: GeniusWalletConsts.space10),
        const GWKicker('You get'),
        const SizedBox(height: GeniusWalletConsts.space2),
        _YouGet(state: state),
        const SizedBox(height: GeniusWalletConsts.space6),
        _QuoteRows(state: state),
        const SizedBox(height: GeniusWalletConsts.space10),
        _ToRow(state: state),
        const SizedBox(height: GeniusWalletConsts.space10),
        _PaymentRow(state: state),
        const SizedBox(height: GeniusWalletConsts.space10),
        _BuyButton(state: state),
        const SizedBox(height: GeniusWalletConsts.space4),
        Center(
          child: Text(
            'Banxa may ask for ID at checkout.',
            textAlign: TextAlign.center,
            style: GeniusWalletTypography.bodySm.copyWith(
              color: gw.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

/// "New quote in Ns" on a draining ring, or the reason there is no live quote.
class _QuoteMeta extends StatelessWidget {
  const _QuoteMeta({required this.state});

  final BuyGnusState state;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final style = GeniusWalletTypography.bodySm.copyWith(
      color: gw.textSecondary,
    );
    final Widget meta;
    if (state.quoteStale) {
      meta = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              'Quote out of date',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style.copyWith(color: gw.statusWarningText),
            ),
          ),
          const SizedBox(width: GeniusWalletConsts.space4),
          _TextLink(
            label: 'Refresh',
            onTap: context.read<BuyGnusCubit>().refreshQuote,
          ),
        ],
      );
    } else if (state.quoting) {
      meta = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: gw.brandPrimaryOnSurface,
            ),
          ),
          const SizedBox(width: GeniusWalletConsts.space4),
          Flexible(
            child: Text(
              state.quote == null
                  ? 'Getting quote from Banxa'
                  : 'Refreshing quote',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
        ],
      );
    } else if (state.quote != null && state.quoteFetchedAt != null) {
      final interval = context.read<BuyGnusCubit>().quoteInterval;
      meta = TweenAnimationBuilder<double>(
        key: ValueKey(state.quoteFetchedAt),
        tween: Tween<double>(begin: 1, end: 0),
        duration: interval,
        builder: (context, remaining, _) {
          final seconds = (remaining * interval.inMilliseconds / 1000).ceil();
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  value: remaining,
                  strokeWidth: 2,
                  color: gw.brandPrimaryOnSurface,
                  backgroundColor: gw.borderSubtle,
                ),
              ),
              const SizedBox(width: GeniusWalletConsts.space4),
              Flexible(
                child: Text(
                  'New quote in ${seconds}s',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style,
                ),
              ),
            ],
          );
        },
      );
    } else {
      meta = const SizedBox.shrink();
    }
    return Align(alignment: Alignment.centerRight, child: meta);
  }
}

class _TextLink extends StatelessWidget {
  const _TextLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusXs),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: GeniusWalletConsts.space2,
            vertical: GeniusWalletConsts.space2,
          ),
          child: Text(
            label,
            style: GeniusWalletTypography.bodySm.copyWith(
              color: gw.brandPrimaryOnSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _AmountField extends StatefulWidget {
  const _AmountField({
    required this.amountText,
    required this.symbol,
    required this.fiatCode,
    required this.onChanged,
  });

  final String amountText;
  final String symbol;
  final String fiatCode;
  final ValueChanged<String> onChanged;

  @override
  State<_AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<_AmountField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.amountText,
  );

  @override
  void didUpdateWidget(_AmountField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A chip or a currency change writes the cubit, and the field follows it.
    if (_controller.text != widget.amountText) {
      _controller.value = TextEditingValue(
        text: widget.amountText,
        selection: TextSelection.collapsed(offset: widget.amountText.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Amount in ${widget.fiatCode}',
      child: GWTextField(
        controller: _controller,
        hint: '0',
        textStyle: GeniusWalletTypography.numericHeadline,
        prefix: widget.symbol.isEmpty ? null : Text(widget.symbol),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        onChanged: widget.onChanged,
      ),
    );
  }
}

/// The currency code with a caret: the change link for the fiat.
class _FiatPill extends StatelessWidget {
  const _FiatPill({required this.state});

  final BuyGnusState state;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final cubit = context.read<BuyGnusCubit>();
    return Semantics(
      button: true,
      label: 'Change currency',
      excludeSemantics: true,
      child: Material(
        color: gw.surfaceMenu,
        shape: StadiumBorder(side: BorderSide(color: gw.borderControl)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () => _showCurrencyDrawer(context, cubit, state),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: GeniusWalletConsts.space6,
              vertical: GeniusWalletConsts.space6,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.fiat?.code ?? '',
                  style: GeniusWalletTypography.bodyMd.copyWith(
                    color: gw.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(Icons.expand_more, size: 20, color: gw.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showCurrencyDrawer(
  BuildContext context,
  BuyGnusCubit cubit,
  BuyGnusState state,
) {
  return ResponsiveDrawer.show<void>(
    context: context,
    bodyPadding: EdgeInsets.zero,
    title: 'Select currency',
    child: _CurrencyList(
      fiats: state.fiats,
      selectedCode: state.fiat?.code,
      onPick: cubit.selectFiat,
    ),
  );
}

class _CurrencyList extends StatefulWidget {
  const _CurrencyList({
    required this.fiats,
    required this.selectedCode,
    required this.onPick,
  });

  final List<FiatCurrency> fiats;
  final String? selectedCode;
  final ValueChanged<FiatCurrency> onPick;

  @override
  State<_CurrencyList> createState() => _CurrencyListState();
}

class _CurrencyListState extends State<_CurrencyList> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final q = _query.trim().toLowerCase();
    final shown = widget.fiats
        .where(
          (f) =>
              q.isEmpty ||
              f.name.toLowerCase().contains(q) ||
              f.code.toLowerCase().contains(q),
        )
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            GeniusWalletConsts.space10,
            GeniusWalletConsts.space10,
            GeniusWalletConsts.space10,
            GeniusWalletConsts.space6,
          ),
          child: GWSearchField(
            hint: 'Search currencies',
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: shown.isEmpty
              ? Center(
                  child: Text(
                    'No currency matches your search',
                    style: GeniusWalletTypography.bodyMd.copyWith(
                      color: gw.textSecondary,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(
                    GeniusWalletConsts.space10,
                    0,
                    GeniusWalletConsts.space10,
                    GeniusWalletConsts.space10,
                  ),
                  children: [
                    for (final fiat in shown)
                      GWSelectRow(
                        selected: fiat.code == widget.selectedCode,
                        onTap: () {
                          // Popped from the drawer's own context: the drawer
                          // sits on the root navigator, not the page's.
                          Navigator.of(context).pop();
                          widget.onPick(fiat);
                        },
                        leading: _CurrencyBadge(fiat: fiat),
                        title: '${fiat.name} (${fiat.code})',
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _CurrencyBadge extends StatelessWidget {
  const _CurrencyBadge({required this.fiat});

  final FiatCurrency fiat;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: gw.surfaceMenu, shape: BoxShape.circle),
      child: Text(
        fiat.symbol.isEmpty ? fiat.code : fiat.symbol,
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: GeniusWalletTypography.labelMd.copyWith(color: gw.textPrimary),
      ),
    );
  }
}

class _LimitsLine extends StatelessWidget {
  const _LimitsLine({required this.state});

  final BuyGnusState state;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final amount = state.amount;
    var text = 'Min ${state.money(state.min)}';
    if (state.max > 0) {
      text = '$text · Max ${state.money(state.max)}';
    }
    var isError = false;
    if (amount != null && amount > 0) {
      if (amount < state.min) {
        text = 'Minimum is ${state.money(state.min)}';
        isError = true;
      } else if (state.max > 0 && amount > state.max) {
        text = 'Maximum is ${state.money(state.max)}';
        isError = true;
      }
    }
    return Text(
      text,
      style: GeniusWalletTypography.bodySm.copyWith(
        color: isError ? gw.statusErrorText : gw.textSecondary,
      ),
    );
  }
}

class _PresetChips extends StatelessWidget {
  const _PresetChips({required this.state});

  final BuyGnusState state;

  @override
  Widget build(BuildContext context) {
    final presets = state.presets;
    if (presets.isEmpty) {
      return const SizedBox.shrink();
    }
    final cubit = context.read<BuyGnusCubit>();
    final current = state.amount;
    return GWControlTrack(
      children: [
        for (final amount in presets)
          Expanded(
            child: _TrackChip(
              label: state.money(amount),
              selected: current == amount,
              onTap: () => cubit.setAmountText(amount.toString()),
            ),
          ),
      ],
    );
  }
}

class _YouGet extends StatelessWidget {
  const _YouGet({required this.state});

  final BuyGnusState state;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final quote = state.quote;
    return AnimatedOpacity(
      opacity: state.quoting && quote != null ? 0.5 : 1,
      duration: const Duration(milliseconds: 150),
      child: Text(
        quote == null ? '-' : '~${quote.cryptoAmount} ${state.coin}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GeniusWalletTypography.numericHeadline.copyWith(
          color: quote == null ? gw.textPrimary38 : gw.textPrimary,
        ),
      ),
    );
  }
}

class _QuoteRows extends StatelessWidget {
  const _QuoteRows({required this.state});

  final BuyGnusState state;

  @override
  Widget build(BuildContext context) {
    final quote = state.quote;
    return AnimatedOpacity(
      opacity: state.quoting && quote != null ? 0.5 : 1,
      duration: const Duration(milliseconds: 150),
      child: GWDetailGrid(
        rows: [
          _QuoteGridRow(
            label: 'Rate',
            value: quote == null ? '-' : _rateText(state, quote),
            isPlaceholder: quote == null,
          ),
          _QuoteGridRow(
            label: 'Banxa processing fee',
            value: quote == null ? '-' : _feeText(state, quote.processingFee),
            isPlaceholder: quote == null,
          ),
          _QuoteGridRow(
            label: 'Network fee',
            value: quote == null ? '-' : _feeText(state, quote.networkFee),
            isPlaceholder: quote == null,
          ),
        ],
      ),
    );
  }
}

/// Derived from the quote's own two amounts, so it cannot disagree with them.
String _rateText(BuyGnusState state, Quote quote) {
  final fiat = double.tryParse(quote.fiatAmount);
  final crypto = double.tryParse(quote.cryptoAmount);
  if (fiat == null || crypto == null || crypto == 0) {
    return '-';
  }
  final rate = fiat / crypto;
  return '1 ${state.coin} = ${rate.toStringAsFixed(rate < 1 ? 4 : 2)} ${state.fiat?.code ?? ''}'
      .trimRight();
}

String _feeText(BuyGnusState state, String raw) {
  final v = double.tryParse(raw);
  if (v == null) {
    return '-';
  }
  final symbol = state.fiat?.symbol ?? '';
  if (symbol.isEmpty) {
    return '${v.toStringAsFixed(2)} ${state.fiat?.code ?? ''}'.trimRight();
  }
  return NumberFormat.currency(symbol: symbol, decimalDigits: 2).format(v);
}

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
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GeniusWalletTypography.bodyMd.copyWith(
                color: gw.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: GeniusWalletConsts.space6),
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

/// Where the coin goes: the Selected wallet, read here for display only.
class _ToRow extends StatelessWidget {
  const _ToRow({required this.state});

  final BuyGnusState state;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return BlocSelector<WalletDetailsCubit, WalletDetailsState, Wallet?>(
      selector: (s) => s.selectedWallet,
      builder: (context, wallet) {
        final change = _TextLink(
          label: 'Change',
          onTap: () => unawaited(AccountDrawer.show(context)),
        );
        if (wallet == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'No wallet to receive ${state.coin}',
                style: GeniusWalletTypography.bodyMd.copyWith(
                  color: gw.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: GeniusWalletConsts.space2),
              Text(
                'Add or import a wallet first. ${state.coin} is delivered straight to it.',
                style: GeniusWalletTypography.bodySm.copyWith(
                  color: gw.textSecondary,
                ),
              ),
              const SizedBox(height: GeniusWalletConsts.space2),
              change,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const GWKicker('To'),
                const SizedBox(width: GeniusWalletConsts.space6),
                AccountAvatar(wallet: wallet, isSelected: false, size: 24),
                const SizedBox(width: GeniusWalletConsts.space4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wallet.walletName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GeniusWalletTypography.bodyMd.copyWith(
                          color: gw.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        WalletUtils.getAddressForDisplay(wallet.address),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GeniusWalletTypography.bodySm.copyWith(
                          color: gw.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                change,
              ],
            ),
            if (state.blockedReason(wallet) case final reason?) ...[
              const SizedBox(height: GeniusWalletConsts.space2),
              Text(
                reason,
                style: GeniusWalletTypography.bodySm.copyWith(
                  color: gw.statusWarningText,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// A choice only when the currency has more than one way to pay.
class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.state});

  final BuyGnusState state;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    if (!state.hasManyMethods) {
      final name = state.method?.name.trim() ?? '';
      if (name.isEmpty) {
        return const SizedBox.shrink();
      }
      return Row(
        children: [
          Icon(
            name.toLowerCase().contains('card')
                ? Icons.credit_card_outlined
                : Icons.account_balance_outlined,
            size: 18,
            color: gw.textSecondary,
          ),
          const SizedBox(width: GeniusWalletConsts.space4),
          Text(
            'Paid by $name',
            style: GeniusWalletTypography.bodyMd.copyWith(
              color: gw.textSecondary,
            ),
          ),
        ],
      );
    }
    final cubit = context.read<BuyGnusCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GWKicker('Pay with'),
        const SizedBox(height: GeniusWalletConsts.space4),
        GWControlTrack(
          children: [
            for (final method in state.fiat!.supportedPaymentMethods)
              Expanded(
                child: _TrackChip(
                  label: method.name,
                  selected: method.id == state.method?.id,
                  onTap: () => cubit.selectMethod(method),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _BuyButton extends StatelessWidget {
  const _BuyButton({required this.state});

  final BuyGnusState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BuyGnusCubit>();
    return BlocSelector<WalletDetailsCubit, WalletDetailsState, Wallet?>(
      selector: (s) => s.selectedWallet,
      builder: (context, wallet) {
        final cta = state.ctaFor(wallet);
        VoidCallback? onPressed;
        if (cta.action == BuyCtaAction.refresh) {
          onPressed = cubit.refreshQuote;
        } else if (cta.action == BuyCtaAction.buy) {
          onPressed = () => unawaited(_startBuy(context));
        }
        return GWButton(
          variant: GWButtonVariant.gradient,
          size: GWButtonSize.md,
          expand: true,
          label: cta.label,
          isLoading: state.creating,
          onPressed: onPressed,
        );
      },
    );
  }
}

/// The first buy on a device asks for the disclaimer; every buy then reads the
/// Selected wallet at this moment, so a switch after the quote is honoured.
Future<void> _startBuy(BuildContext context) async {
  final cubit = context.read<BuyGnusCubit>();
  final wallets = context.read<WalletDetailsCubit>();
  if (!cubit.state.disclaimerAccepted) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final accepted = await showDisclaimerDialog(
      context,
      title: 'Before your first buy',
      message:
          "Checkout opens inside GeniusWallet but is run by Banxa (banxa.com), a separate company. Your ID check and card details go to Banxa, not to GeniusWallet. By continuing you agree to Banxa's Terms of Use and Privacy & Cookies Policy.",
      confirmText: 'Continue',
      activeColor: gw.brandPrimaryOnSurface,
      textColor: gw.textPrimary,
    );
    if (!accepted || !context.mounted) {
      return;
    }
    await cubit.acceptDisclaimer();
  }
  await cubit.createOrder(wallets.state.selectedWallet);
}

/// One chip in a [GWControlTrack]. Selected is a flat fill, never the
/// gradient, which belongs to the card's one commitment button.
class _TrackChip extends StatelessWidget {
  const _TrackChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const double chipHeight = 32;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final isLight = Theme.of(context).brightness == Brightness.light;
    return GWHoverable(
      builder: (hovered) {
        final lifted = hovered && !selected;
        final textColor = selected || lifted
            ? gw.textPrimary
            : gw.textMutedOnSunken;
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
                      ? (isLight ? gw.surfaceElevated : gw.surfaceMenu)
                      : lifted
                      ? (isLight ? gw.textPrimary10 : gw.surfaceElevated)
                      : Colors.transparent,
                  // Light selects a white chip on a grey track, so the edge
                  // is always drawn there and the label never shifts by 1px.
                  border: isLight
                      ? Border.all(
                          color: selected
                              ? gw.borderSubtle
                              : Colors.transparent,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(
                    GeniusWalletConsts.radiusPill,
                  ),
                ),
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
    );
  }
}
