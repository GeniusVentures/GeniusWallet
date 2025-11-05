import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/banaxa_api_services.dart';
import 'package:genius_wallet/banxa/banaxa_model.dart';
import 'package:genius_wallet/banxa/banxa_components/order_details_card.dart';
import 'package:genius_wallet/banxa/banxa_helpers/banxa_helpers.dart';
import 'package:genius_wallet/banxa/handle_banaxa_drawer.dart';
import 'package:genius_wallet/components/custom_future_builder.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';
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
  Color? _bannerColor;
  String? _bannerText;

  @override
  void initState() {
    super.initState();
    _orderFuture = _service.getOrderById(widget.orderId);

    final bannerInfo = BanxaHelpers.getBannerInfo(widget.initialStatus);

    if (bannerInfo != null) {
      _bannerColor = bannerInfo.color;
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
      return ElevatedButton(
        onPressed: () async {
          await showCheckoutOptionsSheet(
            context,
            checkoutUrl: checkout,
            orderId: orderId,
            redirectUrl: redirect,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Complete Payment'),
      );
    } else if (status == 'declined') {
      return OutlinedButton(
        onPressed: () {
          context.push('/createOrder', extra: {
            'fiat': o.fiat,
            'crypto': o.crypto.id,
            'method': o.paymentMethodId,
            'amount': o.fiatAmount,
            'wallet': o.walletAddress,
          });
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Retry Order'),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final canGoBack = GoRouter.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        automaticallyImplyLeading: canGoBack,
        leading: canGoBack
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.go('/buy');
                },
              ),
      ),
      body: FutureStateWidget<Order>(
        future: _orderFuture,
        onData: (order) => OrderDetailCard(
          order: order,
          bannerColor: _bannerColor,
          bannerText: _bannerText,
          actionButton: _buildActionButton(context, order),
        ),
      ),
    );
  }
}
