// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/banxa/banaxa_model.dart';
import 'package:genius_wallet/banxa/banxa_components/order_card.dart';
import 'package:genius_wallet/banxa/banxa_components/order_filter.dart';
import 'package:genius_wallet/banxa/banxa_helpers/banxa_helpers.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_state.dart';
import 'package:genius_wallet/banxa/handle_banaxa_drawer.dart';
import 'package:genius_wallet/components/loading/loading.dart';
import 'package:go_router/go_router.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final statuses = BanxaHelpers.getOrderStatuses();

  String? selectedStatus = "";
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<OrdersCubit>(context).fetchOrders('your-cust-id');
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });

      context.read<OrdersCubit>().applyFilters(
            status: selectedStatus,
            startDate: startDate,
            endDate: endDate,
          );
    }
  }

  void _onStatusChanged(String? status) {
    setState(() => selectedStatus = status ?? "");
    context.read<OrdersCubit>().applyFilters(
          status: selectedStatus,
          startDate: startDate,
          endDate: endDate,
        );
  }

  void _onSeeDetails(Order order) {
    context.push('/orderDetails',
        extra: BanxaHelpers.buildOrderDetailsExtra(order));
  }

  void _onCompletePayment(Order order) {
    final orderStatusUrl = order.orderStatusUrl;
    final redirectUrl = Uri(
      scheme: 'geniuswallet',
      host: 'banxa',
      path: 'callback',
      queryParameters: {'extOrderId': order.externalId},
    ).toString();
    showCheckoutOptionsSheet(
      context,
      checkoutUrl: orderStatusUrl,
      orderId: order.id,
      redirectUrl: redirectUrl,
    );
  }

  void _onRetryOrder(Order order) {
    context.push(
      '/createOrder',
      extra: {
        'fiat': order.fiat,
        'crypto': order.crypto.id,
        'method': order.paymentMethodId,
        'amount': order.fiatAmount,
        'wallet': order.walletAddress,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final canGoBack = GoRouter.of(context).canPop();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: canGoBack,
        leading: canGoBack
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/dashboard'),
              ),
        title: const Text("My Orders"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<OrdersCubit>().fetchOrders('your-cust-id');
            },
          ),
          Semantics(
            label: 'Create new order',
            button: true,
            child: IconButton(
              onPressed: () => context.push('/createOrder'),
              icon: const Row(
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 4),
                  Text('New Order'),
                ],
              ),
              tooltip: 'Create new order',
            ),
          )
        ],
      ),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state.status == OrdersStatus.loading) {
            return const Center(child: Loading());
          }
          if (state.status == OrdersStatus.error) {
            return Center(
              child: Text("❌ ${state.error}",
                  style: const TextStyle(color: Colors.red)),
            );
          }
          final orders = state.filteredOrders ?? [];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrderFilterPanel(
                statuses: statuses,
                selectedStatus: selectedStatus,
                startDate: startDate,
                endDate: endDate,
                onStatusChanged: _onStatusChanged,
                onDateRangePressed: () => _pickDateRange(context),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Total Orders: ${orders.length}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: orders.isEmpty
                    ? const Center(child: Text("No orders found."))
                    : LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 900;
                            final crossAxisCount = isWide ? 2 : 1;
                            const spacing = 16.0;
                            final totalSpacing = spacing * (crossAxisCount - 1);
                            final cardWidth =
                                (constraints.maxWidth - totalSpacing) /
                                    crossAxisCount;

                            const targetHeight = 300.0;
                            double childAspectRatio = cardWidth / targetHeight;
                            childAspectRatio = childAspectRatio.clamp(1.2, 2.5);

                            return GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: spacing,
                                crossAxisSpacing: spacing,
                                childAspectRatio: childAspectRatio,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              itemCount: orders.length,
                              itemBuilder: (context, index) {
                                final order = orders[index];
                                return OrderCard(
                                  order: order,
                                  onSeeDetails: () => _onSeeDetails(order),
                                  onCompletePayment: () =>
                                      _onCompletePayment(order),
                                  onRetryOrder: () => _onRetryOrder(order),
                                );
                              },
                            );
                          },
                        )

              ),
            ],
          );
        },
      ),
    );
  }
}
