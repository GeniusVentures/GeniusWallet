import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/banxa/banxa_components/order_details_drawer.dart';
import 'package:genius_wallet/banxa/banxa_components/order_status_style.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_state.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_status.dart';
import 'package:genius_wallet/banxa/checkout/checkout_rules.dart';
import 'package:genius_wallet/banxa/checkout/checkout_webview.dart';
import 'package:genius_wallet/banxa/checkout/checkout_webview_windows.dart';
import 'package:genius_wallet/banxa/checkout_qr.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/components/overlays/gw_dialog.dart';
import 'package:genius_wallet/components/overlays/gw_menu_item.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

typedef CheckoutHostBuilder =
    Widget Function(
      BuildContext context,
      Uri uri,
      VoidCallback onReturn,
      VoidCallback onLoadError,
    );

Widget defaultCheckoutHost(
  BuildContext context,
  Uri uri,
  VoidCallback onReturn,
  VoidCallback onLoadError,
) {
  return switch (checkoutHostKind(Platform.operatingSystem)) {
    CheckoutHostKind.webview => CheckoutWebView(
      uri: uri,
      onReturn: onReturn,
      onLoadError: onLoadError,
    ),
    CheckoutHostKind.windows => CheckoutWebViewWindows(
      uri: uri,
      onReturn: onReturn,
      onLoadError: onLoadError,
    ),
    CheckoutHostKind.external => CheckoutExternal(uri: uri),
  };
}

Future<void> _openInBrowser(BuildContext context, Uri uri) async {
  var opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    opened = false;
  }
  if (!opened && context.mounted) {
    showToast(context, "Couldn't open your browser.", type: ToastType.error);
  }
}

/// Full-screen checkout. Done comes from the polled order, so it shows even
/// when no return link ever arrives; the return link only speeds up the read.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.orderId,
    required this.checkoutUrl,
    this.isSandbox = false,
    this.hostBuilder = defaultCheckoutHost,
  });

  final String orderId;
  final String checkoutUrl;
  final bool isSandbox;
  final CheckoutHostBuilder hostBuilder;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _returned = false;
  bool _readDone = false;
  bool _loadFailed = false;
  int _hostKey = 0;

  @override
  void initState() {
    super.initState();
    // Keeps the order in the polled set even if the caller did not add it.
    unawaited(context.read<OrdersCubit>().track(widget.orderId));
  }

  Future<void> _onReturn() async {
    if (_returned) {
      return;
    }
    final cubit = context.read<OrdersCubit>();
    setState(() {
      _returned = true;
      _readDone = false;
    });
    await cubit.refreshOrder(widget.orderId);
    if (!mounted) {
      return;
    }
    setState(() => _readDone = true);
  }

  void _onLoadError() {
    if (!mounted) {
      return;
    }
    setState(() => _loadFailed = true);
  }

  void _restartHost() {
    setState(() {
      _returned = false;
      _readDone = false;
      _loadFailed = false;
      _hostKey++;
    });
  }

  void _payOnAnotherDevice() {
    unawaited(
      ResponsiveDrawer.show<void>(
        context: context,
        title: 'Pay on another device',
        child: CheckoutQrBody(checkoutUrl: widget.checkoutUrl),
      ),
    );
  }

  void _openInBrowserNow() {
    final uri = Uri.tryParse(widget.checkoutUrl);
    if (uri != null) {
      unawaited(_openInBrowser(context, uri));
    }
  }

  Future<void> _confirmLeave() async {
    final leave = await GWDialog.show<bool>(
      context: context,
      title: 'Leave checkout?',
      message:
          'Your order stays open for a while. You can finish it from Buy '
          'orders in Transactions.',
      actions: [
        GWDialogAction(
          label: 'Leave',
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
        ),
        GWDialogAction(
          label: 'Keep paying',
          variant: GWButtonVariant.gradient,
          onPressed: () =>
              Navigator.of(context, rootNavigator: true).pop(false),
        ),
      ],
    );
    if (leave == true && mounted) {
      _close();
    }
  }

  void _close() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      context.go('/buy');
    }
  }

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final uri = Uri.tryParse(widget.checkoutUrl);
    final trusted = uri != null && isTrustedCheckoutUrl(uri);
    final wide = MediaQuery.sizeOf(context).width > GeniusBreakpoints.medium;

    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        final order = state.orders?.orders
            .where((o) => o.id == widget.orderId)
            .firstOrNull;
        final status = order?.banxaStatus;

        final Widget body;
        var showingResult = false;
        if (!trusted) {
          body = _CheckoutNotice(
            title: "This checkout link isn't from Banxa",
            message: 'Nothing was loaded. Close this screen and start again.',
            actions: [
              GWButton(
                variant: GWButtonVariant.secondary,
                expand: true,
                label: 'Close',
                onPressed: _close,
              ),
            ],
          );
        } else if (order != null &&
            status != null &&
            (status.isPaid || status.isFinal || (_returned && _readDone))) {
          showingResult = true;
          body = CheckoutResult(order: order, onCompletePayment: _restartHost);
        } else if (_returned && !_readDone) {
          body = const _CheckoutNotice(
            busy: true,
            title: 'Checking your order',
            message: 'Banxa sent you back. Asking for the latest status.',
          );
        } else if (_loadFailed) {
          body = _CheckoutNotice(
            title: "Checkout didn't load",
            message:
                'Your order is created. Check your connection and try again.',
            actions: [
              GWButton(
                variant: GWButtonVariant.gradient,
                expand: true,
                label: 'Try again',
                onPressed: _restartHost,
              ),
              GWButton(
                variant: GWButtonVariant.secondary,
                expand: true,
                label: 'Open in browser',
                onPressed: _openInBrowserNow,
              ),
              GWButton(
                variant: GWButtonVariant.ghost,
                label: 'Pay on another device',
                onPressed: _payOnAnotherDevice,
              ),
            ],
          );
        } else {
          body = KeyedSubtree(
            key: ValueKey(_hostKey),
            child: widget.hostBuilder(context, uri, _onReturn, _onLoadError),
          );
        }

        final progress = CheckoutProgress(
          pay: _payStep(status),
          done: status?.isPaid ?? false,
        );

        final paying = trusted && !showingResult;

        return PopScope(
          canPop: !paying,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              unawaited(_confirmLeave());
            }
          },
          child: Scaffold(
            backgroundColor: gw.surfaceBase,
            body: SafeArea(
              child: Column(
                children: [
                  _CheckoutHeader(
                    isSandbox: widget.isSandbox,
                    onClose: paying ? _confirmLeave : _close,
                    onPayOnAnotherDevice: paying ? _payOnAnotherDevice : null,
                    onOpenInBrowser: paying ? _openInBrowserNow : null,
                    progress: wide ? progress : null,
                  ),
                  if (!wide)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: GeniusWalletConsts.space4,
                      ),
                      child: progress,
                    ),
                  Expanded(child: body),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

CheckoutStepState _payStep(BanxaOrderStatus? status) {
  if (status == null) {
    return CheckoutStepState.active;
  }
  return switch (status) {
    BanxaOrderStatus.declined ||
    BanxaOrderStatus.expired ||
    BanxaOrderStatus.cancelled => CheckoutStepState.failed,
    BanxaOrderStatus.refunded => CheckoutStepState.done,
    _ => status.isPaid ? CheckoutStepState.done : CheckoutStepState.active,
  };
}

class _CheckoutHeader extends StatelessWidget {
  const _CheckoutHeader({
    required this.isSandbox,
    required this.onClose,
    required this.onPayOnAnotherDevice,
    required this.onOpenInBrowser,
    required this.progress,
  });

  final bool isSandbox;
  final VoidCallback onClose;
  final VoidCallback? onPayOnAnotherDevice;
  final VoidCallback? onOpenInBrowser;
  final Widget? progress;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final sandbox = orderStatusPaint(OrderStatusTone.warning, gw);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space4,
        vertical: GeniusWalletConsts.space2,
      ),
      child: Row(
        children: [
          GWButton.icon(
            icon: Icon(Icons.close, color: gw.textPrimary),
            tooltip: 'Close',
            semanticLabel: 'Close',
            onPressed: onClose,
          ),
          const SizedBox(width: GeniusWalletConsts.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: GeniusWalletConsts.space4,
                  runSpacing: GeniusWalletConsts.space2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Buy GNUS',
                      style: GeniusWalletTypography.titleMd.copyWith(
                        color: gw.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isSandbox)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: GeniusWalletConsts.space4,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: sandbox.bg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Sandbox · no real money',
                          style: GeniusWalletTypography.labelMd.copyWith(
                            color: sandbox.fg,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.lock_outline, size: 14, color: gw.textSecondary),
                    const SizedBox(width: GeniusWalletConsts.space2),
                    Text(
                      'Secured by Banxa',
                      style: GeniusWalletTypography.labelMd.copyWith(
                        color: gw.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ?progress,
          if (onPayOnAnotherDevice != null && onOpenInBrowser != null)
            _CheckoutMenu(
              onPayOnAnotherDevice: onPayOnAnotherDevice!,
              onOpenInBrowser: onOpenInBrowser!,
            ),
          const SizedBox(width: GeniusWalletConsts.space4),
        ],
      ),
    );
  }
}

class _CheckoutMenu extends StatelessWidget {
  const _CheckoutMenu({
    required this.onPayOnAnotherDevice,
    required this.onOpenInBrowser,
  });

  final VoidCallback onPayOnAnotherDevice;
  final VoidCallback onOpenInBrowser;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return MenuAnchor(
      builder: (context, controller, child) => IconButton(
        icon: Icon(Icons.more_vert, color: gw.textPrimary),
        tooltip: 'More',
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
      menuChildren: [
        GWMenuItem(
          icon: Icons.qr_code_2,
          label: 'Pay on another device',
          subtitle: 'Scan a code or copy the link',
          onPressed: onPayOnAnotherDevice,
        ),
        GWMenuItem(
          icon: Icons.open_in_new,
          label: 'Open in browser',
          subtitle: 'For Apple Pay or iDEAL',
          onPressed: onOpenInBrowser,
        ),
      ],
    );
  }
}

enum CheckoutStepState { pending, active, done, failed }

/// Order > Pay > Done. Order is always behind the user once checkout opens.
class CheckoutProgress extends StatelessWidget {
  const CheckoutProgress({super.key, required this.pay, required this.done});

  final CheckoutStepState pay;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _ProgressStep(
          number: 1,
          label: 'Order',
          state: CheckoutStepState.done,
        ),
        _ProgressGap(color: gw.textSecondary),
        _ProgressStep(number: 2, label: 'Pay', state: pay),
        _ProgressGap(color: gw.textSecondary),
        _ProgressStep(
          number: 3,
          label: 'Done',
          state: done ? CheckoutStepState.done : CheckoutStepState.pending,
        ),
      ],
    );
  }
}

class _ProgressGap extends StatelessWidget {
  const _ProgressGap({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space2,
      ),
      child: ExcludeSemantics(
        child: Icon(Icons.chevron_right, size: 16, color: color),
      ),
    );
  }
}

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({
    required this.number,
    required this.label,
    required this.state,
  });

  final int number;
  final String label;
  final CheckoutStepState state;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final success = orderStatusPaint(OrderStatusTone.success, gw);
    final error = orderStatusPaint(OrderStatusTone.error, gw);
    final (fg, bg, mark, word) = switch (state) {
      CheckoutStepState.done => (success.fg, success.bg, '✓', 'done'),
      CheckoutStepState.failed => (error.fg, error.bg, '!', 'failed'),
      CheckoutStepState.active => (
        gw.brandPrimaryOnSurface,
        gw.surfaceElevated,
        '$number',
        'in progress',
      ),
      CheckoutStepState.pending => (
        gw.textSecondary,
        gw.surfaceElevated,
        '$number',
        'waiting',
      ),
    };

    return Semantics(
      label: '$label, $word',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: state == CheckoutStepState.active
                  ? Border.all(color: fg, width: 1.5)
                  : null,
            ),
            child: Text(
              mark,
              style: GeniusWalletTypography.labelMd.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: GeniusWalletConsts.space2),
          Text(
            label,
            style: GeniusWalletTypography.labelMd.copyWith(
              color: state == CheckoutStepState.pending
                  ? gw.textSecondary
                  : gw.textPrimary,
              fontWeight: state == CheckoutStepState.active
                  ? FontWeight.w600
                  : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutNotice extends StatelessWidget {
  const _CheckoutNotice({
    required this.title,
    required this.message,
    this.busy = false,
    this.actions = const [],
  });

  final String title;
  final String message;
  final bool busy;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(GeniusWalletConsts.space12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (busy) ...[
                const Loading(),
                const SizedBox(height: GeniusWalletConsts.space8),
              ],
              Text(
                title,
                textAlign: TextAlign.center,
                style: GeniusWalletTypography.titleLg.copyWith(
                  color: gw.textPrimary,
                ),
              ),
              const SizedBox(height: GeniusWalletConsts.space4),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GeniusWalletTypography.bodyMd.copyWith(
                  color: gw.textSecondary,
                ),
              ),
              for (final action in actions) ...[
                const SizedBox(height: GeniusWalletConsts.space6),
                action,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Waits in the system browser where an in-app page is not available; the
/// screen moves on by itself once the polled order shows payment.
class CheckoutExternal extends StatefulWidget {
  const CheckoutExternal({super.key, required this.uri});

  final Uri uri;

  @override
  State<CheckoutExternal> createState() => _CheckoutExternalState();
}

class _CheckoutExternalState extends State<CheckoutExternal> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_openInBrowser(context, widget.uri));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _CheckoutNotice(
      title: 'Finish paying in your browser',
      message: 'This screen updates when Banxa has your payment.',
      actions: [
        GWButton(
          variant: GWButtonVariant.secondary,
          expand: true,
          label: 'Reopen checkout',
          onPressed: () => unawaited(_openInBrowser(context, widget.uri)),
        ),
      ],
    );
  }
}

/// What the order came to once checkout ended, read from Banxa's status.
class CheckoutResult extends StatelessWidget {
  const CheckoutResult({
    super.key,
    required this.order,
    required this.onCompletePayment,
  });

  final Order order;
  final VoidCallback onCompletePayment;

  static final _support = Uri.parse('https://support.banxa.com');

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final status = order.banxaStatus;
    final notCharged =
        status == BanxaOrderStatus.declined ||
        status == BanxaOrderStatus.expired ||
        status == BanxaOrderStatus.cancelled;
    final unpaid =
        status == BanxaOrderStatus.pendingPayment ||
        status == BanxaOrderStatus.extraVerification;
    final offersSupport =
        notCharged ||
        status == BanxaOrderStatus.extraVerification ||
        status == BanxaOrderStatus.refunded;
    final approx = status == BanxaOrderStatus.complete ? '' : '≈';

    final List<Widget> actions;
    if (notCharged) {
      actions = [
        GWButton(
          variant: GWButtonVariant.gradient,
          expand: true,
          label: 'Try again',
          onPressed: () => context.go('/buy'),
        ),
      ];
    } else if (unpaid) {
      actions = [
        GWButton(
          variant: GWButtonVariant.gradient,
          expand: true,
          label: 'Complete payment',
          onPressed: onCompletePayment,
        ),
      ];
    } else {
      actions = [
        GWButton(
          variant: GWButtonVariant.tertiary,
          expand: true,
          label: 'Back to Buy',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        GWButton(
          variant: GWButtonVariant.secondary,
          expand: true,
          label: 'View order',
          onPressed: () => showOrderDetails(context, order),
        ),
      ];
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(GeniusWalletConsts.space12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '+ $approx${order.cryptoAmount} ${order.crypto.id}',
                textAlign: TextAlign.center,
                style: GeniusWalletTypography.headlineLg.copyWith(
                  color: gw.textPrimary,
                ),
              ),
              const SizedBox(height: GeniusWalletConsts.space2),
              Text(
                notCharged
                    ? 'Not charged'
                    : '${order.fiatAmount} ${order.fiat}',
                style: GeniusWalletTypography.bodyMd.copyWith(
                  color: gw.textSecondary,
                ),
              ),
              const SizedBox(height: GeniusWalletConsts.space6),
              OrderStatusPill(status: order.status),
              const SizedBox(height: GeniusWalletConsts.space6),
              Text(
                status.description,
                textAlign: TextAlign.center,
                style: GeniusWalletTypography.bodyMd.copyWith(
                  color: gw.textSecondary,
                ),
              ),
              const SizedBox(height: GeniusWalletConsts.space6),
              _OrderIdRow(orderId: order.id),
              if (offersSupport)
                GWButton(
                  variant: GWButtonVariant.ghost,
                  size: GWButtonSize.sm,
                  label: 'Contact Banxa support',
                  onPressed: () => unawaited(_openInBrowser(context, _support)),
                ),
              for (final action in actions) ...[
                const SizedBox(height: GeniusWalletConsts.space6),
                action,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderIdRow extends StatefulWidget {
  const _OrderIdRow({required this.orderId});

  final String orderId;

  @override
  State<_OrderIdRow> createState() => _OrderIdRowState();
}

class _OrderIdRowState extends State<_OrderIdRow> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.orderId));
    if (mounted) {
      setState(() => _copied = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Banxa order',
          style: GeniusWalletTypography.labelMd.copyWith(
            color: gw.textSecondary,
          ),
        ),
        GWButton(
          variant: GWButtonVariant.ghost,
          size: GWButtonSize.sm,
          label: widget.orderId,
          trailing: Icon(
            _copied ? Icons.check : Icons.copy_outlined,
            size: 16,
            color: gw.textPrimary,
          ),
          tooltip: _copied ? 'Copied' : 'Copy order ID',
          onPressed: () => unawaited(_copy()),
        ),
      ],
    );
  }
}
