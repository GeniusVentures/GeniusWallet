import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/banxa/banxa_components/order_details_drawer.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_state.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_status.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';
import 'package:go_router/go_router.dart';

/// Announces each Buy order that finishes, once, on the root navigator so it
/// outlives the screen that started it. Also pauses order polling while the
/// app is in the background.
class BuyOrderToasts extends StatefulWidget {
  const BuyOrderToasts({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  State<BuyOrderToasts> createState() => _BuyOrderToastsState();
}

class _BuyOrderToastsState extends State<BuyOrderToasts> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) => context.read<OrdersCubit>().setForeground(
        state == AppLifecycleState.resumed ||
            state == AppLifecycleState.inactive,
      ),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrdersCubit, OrdersState>(
      listenWhen: (previous, current) => current.justFinished.isNotEmpty,
      listener: (context, state) => _toastWhenAttached(state.justFinished),
      child: widget.child,
    );
  }

  /// Waits for the navigator to mount rather than dropping the announcement.
  void _toastWhenAttached(List<Order> orders) {
    final toastContext = widget.navigatorKey.currentContext;
    if (toastContext == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _toastWhenAttached(orders);
        }
      });
      return;
    }
    if (_onCheckout(toastContext)) {
      return;
    }
    for (final order in orders) {
      final copy = _copyFor(order);
      if (copy == null) {
        continue;
      }
      showToast(
        toastContext,
        copy.message,
        title: copy.title,
        type: copy.type,
        actionLabel: 'View order',
        onAction: () => showOrderDetails(toastContext, order),
      );
    }
  }

  /// Checkout shows its own outcome, so a toast on top of it would say it
  /// twice.
  bool _onCheckout(BuildContext context) {
    final config = GoRouter.maybeOf(
      context,
    )?.routerDelegate.currentConfiguration;
    if (config == null) {
      return false;
    }
    final path = config.isNotEmpty ? config.last.matchedLocation : '';
    return path.startsWith('/checkout');
  }
}

({String title, String message, ToastType type})? _copyFor(Order order) {
  switch (order.banxaStatus) {
    case BanxaOrderStatus.complete:
      return (
        title: 'GNUS is in your wallet',
        message:
            '${formatTxAmount(order.cryptoAmount)} GNUS from your Banxa '
            'order arrived.',
        type: ToastType.success,
      );
    case BanxaOrderStatus.declined:
      return (
        title: 'Payment declined',
        message: 'Your bank or card declined it. You were not charged.',
        type: ToastType.error,
      );
    case BanxaOrderStatus.expired:
      return (
        title: 'Order expired',
        message: 'Payment was not completed in time. You were not charged.',
        type: ToastType.warning,
      );
    case BanxaOrderStatus.cancelled:
      return (
        title: 'Order cancelled',
        message: 'You left checkout before paying. You were not charged.',
        type: ToastType.warning,
      );
    case BanxaOrderStatus.refunded:
      return (
        title: 'Order refunded',
        message:
            'Banxa refunded ${formatTxAmount(order.fiatAmount)} '
            '${order.fiat} to your card.',
        type: ToastType.warning,
      );
    default:
      return null;
  }
}
