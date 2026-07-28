import 'dart:io';

import 'package:flutter/material.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/tokens/widgets/sketch_icons.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BanxaPaymentWebView extends StatefulWidget {
  final String checkoutUrl;
  final String redirectUrl;

  const BanxaPaymentWebView({
    super.key,
    required this.checkoutUrl,
    required this.redirectUrl,
  });

  @override
  State<BanxaPaymentWebView> createState() => _BanxaPaymentWebViewState();
}

class _BanxaPaymentWebViewState extends State<BanxaPaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isLinux = false;

  @override
  void initState() {
    super.initState();

    // webview_flutter has no Linux implementation, so fall back to
    // opening the URL in the system browser on Linux.
    if (Platform.isLinux) {
      _isLinux = true;
      _isLoading = false;
      _openInBrowser();
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) {
            if (request.url.contains(widget.redirectUrl)) {
              Navigator.pop(context, true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(widget.checkoutUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // Task 1 · sketch 152 / token_info_screen.dart:92-129, the shared
  // back-arrow AppBar recipe already ported by 09-05's checkout_qr.dart —
  // reused rather than reinvented. Both webview hosts are always reached via
  // a push, so a back target always exists.
  PreferredSizeWidget _buildAppBar(BuildContext context, GWColors gw) {
    return AppBar(
      toolbarHeight: 48,
      backgroundColor: gw.surfaceSunken,
      elevation: 0,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width > GeniusBreakpoints.medium
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
              'Complete Payment',
              style: GeniusWalletTypography.titleMd.copyWith(
                color: gw.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    // On Linux, show a message that the payment flow is open in the browser.
    if (_isLinux) {
      return Scaffold(
        appBar: _buildAppBar(context, gw),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(GeniusWalletConsts.space12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 09-UI-SPEC's icon-in-circle empty-state recipe
                // (gw_empty_state.dart metrics: 72px circle / 32px glyph),
                // replacing the bare 64px Icon.
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: gw.surfaceElevated,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.open_in_browser,
                    size: 32,
                    color: gw.textSecondary,
                  ),
                ),
                const SizedBox(height: GeniusWalletConsts.space12),
                Text(
                  'Payment opened in your browser',
                  style: GeniusWalletTypography.titleLg.copyWith(
                    color: gw.textPrimary,
                  ),
                ),
                const SizedBox(height: GeniusWalletConsts.space6),
                Text(
                  'Complete your payment in the browser, then return here.',
                  style: GeniusWalletTypography.bodyMd.copyWith(
                    color: gw.textSecondary,
                  ),
                ),
                const SizedBox(height: GeniusWalletConsts.space16),
                GWButton(
                  variant: GWButtonVariant.secondary,
                  expand: true,
                  onPressed: () => _openInBrowser(),
                  label: 'Re-open in Browser',
                ),
                const SizedBox(height: GeniusWalletConsts.space6),
                GWButton(
                  variant: GWButtonVariant.gradient,
                  expand: true,
                  onPressed: () => Navigator.pop(context, true),
                  label: 'Done',
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context, gw),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: Loading()),
        ],
      ),
    );
  }
}
