import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/banxa/banxa_components/order_card.dart';
import 'package:genius_wallet/banxa/banxa_helpers/banxa_helpers.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_state.dart';
import 'package:genius_wallet/banxa/handle_banxa_drawer.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final statuses = BanxaHelpers.getOrderStatuses();

  String selectedStatus = "";
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
        title: const Text("My Orders"),
        actions: [
          IconButton(
            tooltip: "KYC",
            icon: const Icon(Icons.assignment_ind),
            onPressed: () => context.push('/kyc'),
          ),
          IconButton(
            tooltip: "Refresh",
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<OrdersCubit>().fetchOrders('your-cust-id');
            },
          ),
          IconButton(
            onPressed: () => context.push('/createOrder'),
            icon: const Row(
              children: [
                Icon(Icons.add),
                SizedBox(width: 4),
                Text('New Order'),
              ],
            ),
            tooltip: 'Create new order',
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
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: GeniusBreakpoints.xxl),
                child: Column(spacing: 16.0, children: [
                  DropdownMenu<String>(
                    label: const Text("Status"),
                    width: 300.0,
                    onSelected: _onStatusChanged,
                    initialSelection: selectedStatus,
                    dropdownMenuEntries: statuses.map((status) {
                      return DropdownMenuEntry(
                        value: status,
                        label: status.isEmpty
                            ? "All"
                            : BanxaHelpers.getOrderStatusLabel(status),
                      );
                    }).toList(),
                    requestFocusOnTap: false,
                  ),
                  SizedBox(
                    width: 300.0,
                    child: OutlinedButton(
                        onPressed: () => _pickDateRange(context),
                        child: const Text("Pick Date Range")),
                  ),
                  if (startDate != null && endDate != null)
                    Text(
                      "Selected: ${DateFormat('yyyy-MM-dd').format(startDate!)} → ${DateFormat('yyyy-MM-dd').format(endDate!)}",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  Text(
                    "Total Orders: ${orders.length}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  orders.isEmpty
                      ? Text("No orders found.")
                      : Expanded(
                          child: LayoutBuilder(builder: (context, constraints) {
                          final crossAxisCount =
                              max((constraints.maxWidth / (294.0)).floor(), 1);
                          const spacing = 16.0;

                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    mainAxisSpacing: spacing,
                                    crossAxisSpacing: spacing,
                                    mainAxisExtent: 300.0),
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
                        }))
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}
