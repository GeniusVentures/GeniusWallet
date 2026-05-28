import 'dart:io';

import 'package:flutter/material.dart';
import 'package:genius_wallet/components/loading.dart';
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

  @override
  Widget build(BuildContext context) {
    // On Linux, show a message that the payment flow is open in the browser.
    if (_isLinux) {
      return Scaffold(
        appBar: AppBar(title: const Text('Complete Payment')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.open_in_browser, size: 64),
                const SizedBox(height: 24),
                Text(
                  'Payment opened in your browser',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                const Text(
                    'Complete your payment in the browser, then return here.'),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => _openInBrowser(),
                  child: const Text('Re-open in Browser'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Complete Payment")),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: Loading()),
        ],
      ),
    );
  }
}
