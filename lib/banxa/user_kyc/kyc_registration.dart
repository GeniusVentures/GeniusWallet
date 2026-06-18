import 'dart:io';

import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/banxa_api_services.dart';
import 'package:genius_wallet/components/loading.dart';
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

  @override
  Widget build(BuildContext context) {
    // On Linux, show a message that the KYC flow is open in the browser.
    if (_isLinux) {
      return Scaffold(
        appBar: AppBar(title: const Text('Banxa KYC Flow')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.open_in_browser, size: 64),
                const SizedBox(height: 24),
                Text(
                  'Banxa KYC opened in your browser',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Complete the identity verification in your browser, then return here.',
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _openInBrowser(),
                  child: const Text('Re-open in Browser'),
                ),
                const SizedBox(height: 12),
                FilledButton(
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
      appBar: AppBar(title: const Text('Banxa KYC Flow')),
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
