import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/banxa/banxa_order/polling_order_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/polling_order_state.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/tokens/widgets/sketch_icons.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CheckoutQrPage extends StatelessWidget {
  final String checkoutUrl;
  final String orderId;

  const CheckoutQrPage({
    super.key,
    required this.checkoutUrl,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final qrSize = math.max(
      160.0,
      math.min(320.0, MediaQuery.sizeOf(context).width - 64),
    );

    return BlocBuilder<PollingCubit, PollingState>(
      builder: (context, state) {
        final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
        final cubit = context.read<PollingCubit>();
        if (state.order != null &&
            (state.order!.status.toLowerCase() == 'completed' ||
                state.order!.status.toLowerCase() == 'inprogress') &&
            !cubit.hasNavigated) {
          cubit.hasNavigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.push(
              '/orderDetails',
              extra: {
                'orderId': state.order!.orderId,
                'checkoutUrl': state.order!.orderStatusUrl,
              },
            );
          });
        }

        if (state.order != null &&
            (state.order!.status.toLowerCase() == 'failed' ||
                state.order!.status.toLowerCase() == 'cancelled') &&
            !cubit.hasNavigated) {
          cubit.hasNavigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showToast(context, 'Order ${state.order!.status}');
          });
        }

        return Scaffold(
          // Task 1 · sketch 152 / token_info_screen.dart:92-129, the shared
          // back-arrow AppBar recipe already ported verbatim by 09-02's
          // banxa_orders_history.dart — reused rather than reinvented. This
          // screen is always reached via a push (from the checkout options
          // sheet), so it always has a back target; no canGoBack branch
          // needed the way order_details_page.dart/banxa_orders_history.dart
          // require one.
          appBar: AppBar(
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
                    borderRadius: BorderRadius.circular(
                      GeniusWalletConsts.radiusSm,
                    ),
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
                    'Scan to Continue',
                    style: GeniusWalletTypography.titleMd.copyWith(
                      color: gw.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(GeniusWalletConsts.space12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Scan this QR on another device to complete checkout.',
                  textAlign: TextAlign.center,
                  style: GeniusWalletTypography.bodyMd.copyWith(
                    color: gw.textSecondary,
                  ),
                ),
                const SizedBox(height: GeniusWalletConsts.space8),
                Center(
                  child: Container(
                    // The QR's white backing is the ONE literal that must
                    // NOT change — a scannable QR needs a light quiet zone
                    // regardless of theme (drawers-final/README.md's shipped
                    // convention). Do not make this appearance-aware.
                    color: Colors.white,
                    padding: const EdgeInsets.all(GeniusWalletConsts.space4),
                    child: QrImageView(
                      data: checkoutUrl,
                      version: QrVersions.auto,
                      size: qrSize,
                    ),
                  ),
                ),
                const SizedBox(height: GeniusWalletConsts.space8),
                SelectableText(
                  checkoutUrl.length > 50
                      ? '${checkoutUrl.substring(0, 50)}...'
                      : checkoutUrl,
                  textAlign: TextAlign.center,
                  style: GeniusWalletTypography.bodySm.copyWith(
                    color: gw.textSecondary,
                  ),
                ),
                const SizedBox(height: GeniusWalletConsts.space6),
                GWButton(
                  variant: GWButtonVariant.gradient,
                  leading: const Icon(Icons.content_copy),
                  label: 'Copy Link',
                  expand: true,
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: checkoutUrl));
                    if (context.mounted) {
                      showToast(context, 'Link copied');
                    }
                  },
                ),
                const SizedBox(height: GeniusWalletConsts.space12),
                Center(
                  child: Column(
                    children: [
                      if (state.status == PollingStatus.loading)
                        const Loading(),
                      const SizedBox(height: GeniusWalletConsts.space6),
                      Text(
                        state.message.isNotEmpty
                            ? state.message
                            : 'Waiting for payment...',
                        textAlign: TextAlign.center,
                        style: GeniusWalletTypography.bodyLg.copyWith(
                          color: gw.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
