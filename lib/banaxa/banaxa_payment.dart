import 'package:flutter/material.dart';
import 'package:genius_wallet/components/loading/loading.dart';
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

  @override
  void initState() {
    super.initState();

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

  @override
  Widget build(BuildContext context) {
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
