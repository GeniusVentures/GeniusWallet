import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/banxa_api_services.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/banxa/banxa_components/order_details_card.dart';
import 'package:genius_wallet/banxa/banxa_components/order_status_style.dart';
import 'package:genius_wallet/banxa/banxa_helpers/banxa_helpers.dart';
import 'package:genius_wallet/banxa/handle_banxa_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/custom_future_builder.dart';
import 'package:genius_wallet/components/feedback/gw_error_state.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:go_router/go_router.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;
  final String? checkoutUrl;
  final String? redirectUrl;
  final String? initialStatus;

  const OrderDetailsPage({
    required this.orderId,
    this.checkoutUrl,
    this.redirectUrl,
    this.initialStatus,
    super.key,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late Future<Order> _orderFuture;
  final _service = BanxaApiService();
  OrderStatusTone? _bannerTone;
  String? _bannerText;

  @override
  void initState() {
    super.initState();
    _orderFuture = _service.getOrderById(widget.orderId);

    final bannerInfo = BanxaHelpers.getBannerInfo(widget.initialStatus);

    if (bannerInfo != null) {
      _bannerTone = bannerTone(widget.initialStatus);
      _bannerText = bannerInfo.text;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAppSnackBar(context, _bannerText!);
      });
    }
  }

  String? _effectiveCheckoutUrl(Order o) {
    if ((widget.checkoutUrl ?? '').isNotEmpty) return widget.checkoutUrl;
    return o.orderStatusUrl.isNotEmpty ? o.orderStatusUrl : null;
  }

  Widget _buildActionButton(BuildContext context, Order o) {
    final status = o.status.toLowerCase();
    final checkout = _effectiveCheckoutUrl(o);
    final orderId = (o.id.isNotEmpty ? o.id : widget.orderId);
    final redirect = widget.redirectUrl ?? BanxaApiService.redirectUrl;

    if (status == 'pendingpayment' && checkout != null && orderId.isNotEmpty) {
      return GWButton(
        onPressed: () async {
          await showCheckoutOptionsSheet(
            context,
            checkoutUrl: checkout,
            orderId: orderId,
            redirectUrl: redirect,
          );
        },
        label: 'Complete Payment',
        variant: GWButtonVariant.gradient,
      );
    } else if (status == 'declined') {
      return GWButton(
        onPressed: () {
          context.push(
            '/createOrder',
            extra: {
              'fiat': o.fiat,
              'crypto': o.crypto.id,
              'method': o.paymentMethodId,
              'amount': o.fiatAmount,
              'wallet': o.walletAddress,
            },
          );
        },
        label: 'Retry Order',
        variant: GWButtonVariant.secondary,
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final canGoBack = GoRouter.of(context).canPop();
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        backgroundColor: gw.surfaceSunken,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Order Details',
          style: GeniusWalletTypography.titleMd.copyWith(
            color: gw.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        automaticallyImplyLeading: canGoBack,
        leading: canGoBack
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back, color: gw.textSecondary),
                onPressed: () {
                  context.go('/buy');
                },
              ),
      ),
      body: FutureStateWidget<Order>(
        future: _orderFuture,
        error: const GWErrorState(title: "Couldn't load this order"),
        onRetry: () {
          setState(() {
            _orderFuture = _service.getOrderById(widget.orderId);
          });
        },
        onData: (order) => OrderDetailCard(
          order: order,
          bannerTone: _bannerTone,
          bannerText: _bannerText,
          actionButton: _buildActionButton(context, order),
        ),
      ),
    );
  }
}
