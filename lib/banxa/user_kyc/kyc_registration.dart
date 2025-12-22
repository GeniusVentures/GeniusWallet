import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/banaxa_api_services.dart';
import 'package:genius_wallet/components/loading/loading.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BanxaKycScreen extends StatefulWidget {
  const BanxaKycScreen({super.key});

  @override
  State<BanxaKycScreen> createState() => _BanxaKycScreenState();
}

class _BanxaKycScreenState extends State<BanxaKycScreen> {
  late WebViewController _controller;
  bool _isLoading = true; // Flag to show loading indicator

  @override
  void initState() {
    super.initState();
    // Initialize WebView
    print("Initializing WebView...");
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Enable JS
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true; // Show loading indicator
            });
            print("Page started loading: $url");
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false; // Hide loading indicator
            });
            print("Page finished loading: $url");
          },
          onNavigationRequest: (request) {
            print("Navigating to: ${request.url}");
            // Check if the current URL is the KYC redirect URL
            if (request.url.contains(BanxaApiService.banxaKycUrl)) {
              print("KYC URL detected, continuing...");
              return NavigationDecision.navigate; // Allow WebView to continue
            }

            // Handle redirect URL after KYC completion
            if (request.url.contains('your.redirect.url')) {
              print("Redirect URL detected, popping the screen...");
              Navigator.pop(context,
                  true); // Pop if the redirect URL is detected (KYC completed)
              return NavigationDecision.prevent; // Prevent further navigation
            }

            // Handle other URLs
            return NavigationDecision
                .navigate; // Allow navigation to other URLs
          },
        ),
      )
      ..loadRequest(
          Uri.parse(BanxaApiService.banxaKycUrl)); // Use the banxaKycUrl
    print("WebView initialized and loading KYC URL...");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Banxa KYC Flow')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
       
         if (_isLoading)
            const Center(
              child: Loading(
                text: "Loading Banxa KYC...",
              ),
            ),
        ],
      ),
    );
  }
}
