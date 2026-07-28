import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/banxa/banxa_components/order_card.dart';
import 'package:genius_wallet/banxa/banxa_helpers/banxa_helpers.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_state.dart';
import 'package:genius_wallet/banxa/handle_banxa_drawer.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/components/feedback/gw_error_state.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/tokens/widgets/sketch_icons.dart';
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
    context.push(
      '/orderDetails',
      extra: BanxaHelpers.buildOrderDetailsExtra(order),
    );
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

  // Task 2 · sketch 152 / token_info_screen.dart:92-129, applied verbatim —
  // the one shared back-arrow AppBar recipe, reused rather than reinvented.
  // Only reached when `canGoBack` (see build()); the three actions are the
  // SAME instances the plain-chrome branch uses (icons/tooltips/onPressed
  // unchanged, D-01).
  PreferredSizeWidget _buildBackArrowAppBar(
    BuildContext context,
    GWColors gw,
    List<Widget> actions,
  ) {
    return AppBar(
      toolbarHeight: 48,
      backgroundColor: gw.surfaceSunken,
      elevation: 0,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: Padding(
        padding: EdgeInsets.symmetric(
          horizontal:
              MediaQuery.sizeOf(context).width > GeniusBreakpoints.medium
              ? GeniusWalletConsts.space10
              : GeniusWalletConsts.space8,
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusSm),
              child: SizedBox(
                width: 30,
                height: 30,
                child: Center(
                  child: SketchIcon(
                    SketchIcons.back,
                    size: 18,
                    color: gw.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: GeniusWalletConsts.space6),
            Text(
              'My Orders',
              style: GeniusWalletTypography.titleMd.copyWith(
                color: gw.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      actions: actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    final canGoBack = GoRouter.of(context).canPop();
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final actions = <Widget>[
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
          children: [Icon(Icons.add), SizedBox(width: 4), Text('New Order')],
        ),
        tooltip: 'Create new order',
      ),
    ];
    return Scaffold(
      appBar: canGoBack
          ? _buildBackArrowAppBar(context, gw, actions)
          : AppBar(
              automaticallyImplyLeading: canGoBack,
              title: const Text("My Orders"),
              actions: actions,
            ),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state.status == OrdersStatus.loading) {
            return const Center(child: Loading());
          }
          if (state.status == OrdersStatus.error) {
            // Task 3 · crypto_news_screen.dart:149-152's GWErrorState usage.
            // `state.error` is preserved verbatim as the detail line; `onRetry`
            // re-dispatches the EXISTING fetchOrders('your-cust-id') call the
            // Refresh action and initState already make (D-01/D-02 — no new
            // call, no new argument).
            return GWErrorState(
              title: "Couldn't load your orders",
              message: state.error,
              onRetry: () =>
                  context.read<OrdersCubit>().fetchOrders('your-cust-id'),
            );
          }
          final orders = state.filteredOrders ?? [];
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: GeniusBreakpoints.xxl),
                child: Column(
                  spacing: 16.0,
                  children: [
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
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300.0),
                      child: OutlinedButton(
                        onPressed: () => _pickDateRange(context),
                        child: const Text("Pick Date Range"),
                      ),
                    ),
                    if (startDate != null && endDate != null)
                      Text(
                        "Selected: ${DateFormat('yyyy-MM-dd').format(startDate!)} → ${DateFormat('yyyy-MM-dd').format(endDate!)}",
                        style: GeniusWalletTypography.bodySm.copyWith(
                          color: gw.textSecondary,
                        ),
                      ),
                    Text(
                      "Total Orders: ${orders.length}",
                      style: GeniusWalletTypography.labelMd.copyWith(
                        color: gw.textSecondary,
                      ),
                    ),
                    orders.isEmpty
                        ? Expanded(
                            child:
                                selectedStatus.isEmpty &&
                                    startDate == null &&
                                    endDate == null
                                ? GWEmptyState(
                                    icon: Icons.receipt_long_outlined,
                                    title: "No orders yet",
                                    message:
                                        "Your Banxa purchases will show up here once you create one.",
                                    actionLabel: "New Order",
                                    onAction: () =>
                                        context.push('/createOrder'),
                                  )
                                : const GWEmptyState(
                                    icon: Icons.receipt_long_outlined,
                                    title: "No orders match this filter.",
                                    // Recorded deviation (09-02-SUMMARY.md):
                                    // the UI-SPEC's filter-reset action is
                                    // deliberately NOT added here — resetting
                                    // filter state is behaviour, which
                                    // D-01/D-02 fence out of this re-skin. The
                                    // status
                                    // dropdown and date-range button stay on
                                    // screen directly above this empty state,
                                    // so no dead end exists.
                                  ),
                          )
                        : Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final crossAxisCount = max(
                                  (constraints.maxWidth / (294.0)).floor(),
                                  1,
                                );
                                const spacing = 16.0;

                                return GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        mainAxisSpacing: spacing,
                                        crossAxisSpacing: spacing,
                                        mainAxisExtent: 300.0,
                                      ),
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
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
