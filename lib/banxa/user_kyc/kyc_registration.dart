import 'dart:io';

import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/banxa_api_services.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/tokens/widgets/sketch_icons.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/web/web_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BanxaKycScreen extends StatefulWidget {
  const BanxaKycScreen({super.key});

  @override
  State<BanxaKycScreen> createState() => _BanxaKycScreenState();
}

class _BanxaKycScreenState extends State<BanxaKycScreen> {
  late WebViewController _controller;
  bool _isLoading = true; // Flag to show loading indicator
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

    debugPrint("Initializing WebView...");
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Enable JS
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
            });
            debugPrint("Page started loading: $url");
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
            debugPrint("Page finished loading: $url");
          },
          onNavigationRequest: (request) {
            debugPrint("Navigating to: ${request.url}");
            // Check if the current URL is the KYC redirect URL
            if (request.url.contains(BanxaApiService.banxaKycUrl)) {
              debugPrint("KYC URL detected, continuing...");
              return NavigationDecision.navigate;
            }

            // Handle redirect URL after KYC completion
            if (request.url.contains(BanxaApiService.redirectUrl)) {
              debugPrint("Redirect URL detected, popping the screen...");
              Navigator.pop(context, true);
              return NavigationDecision.prevent;
            }

            // Handle other URLs
            return NavigationDecision
                .navigate; // Allow navigation to other URLs
          },
        ),
      )
      ..loadRequest(
        Uri.parse(BanxaApiService.banxaKycUrl),
      ); // Use the banxaKycUrl
    debugPrint("WebView initialized and loading KYC URL...");
  }

  void _openInBrowser() {
    launchWebSite(context, BanxaApiService.banxaKycUrl);
  }

  // Task 2 · the same back-arrow AppBar recipe 09-06 Task 1 applied to
  // banxa_payment.dart (token_info_screen.dart:92-129 / 09-05's
  // checkout_qr.dart) — the two webview hosts are twins, so the recipe is
  // ported verbatim rather than re-derived.
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
              'Banxa KYC Flow',
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

    // On Linux, show a message that the KYC flow is open in the browser.
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
                // replacing the bare 64px Icon — ported verbatim from
                // banxa_payment.dart's twin fallback so the two hosts render
                // structurally identical.
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
                  'Banxa KYC opened in your browser',
                  style: GeniusWalletTypography.titleLg.copyWith(
                    color: gw.textPrimary,
                  ),
                ),
                const SizedBox(height: GeniusWalletConsts.space6),
                Text(
                  'Complete the identity verification in your browser, then return here.',
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
          if (_isLoading)
            const Center(child: Loading(text: "Loading Banxa KYC...")),
        ],
      ),
    );
  }
}
