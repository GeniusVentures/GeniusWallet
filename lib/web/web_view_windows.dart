import 'dart:async';
import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:webview_windows/webview_windows.dart';

class WebViewWindows extends StatefulWidget {
  final String url;

  const WebViewWindows({Key? key, required this.url}) : super(key: key);

  @override
  _WebViewWindowsState createState() => _WebViewWindowsState();
}

class _WebViewWindowsState extends State<WebViewWindows> {
  final WebviewController _controller = WebviewController();
  final TextEditingController _urlController = TextEditingController();
  StreamSubscription<String>? _urlSubscription;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    await _controller.initialize();
    _controller.loadUrl(widget.url);
    _urlController.text = widget.url; // Set initial URL in text field

    // Listen for URL changes and update the search bar
    _urlSubscription = _controller.url.listen((url) {
      setState(() {
        _urlController.text = url;
      });
    });
  }

  void _loadUrl() {
    String url = _urlController.text.trim();
    if (url.isNotEmpty && !url.startsWith("http")) {
      url = "https://$url";
    }
    _controller.loadUrl(url);
  }

  @override
  void dispose() {
    _urlSubscription?.cancel(); // Stop listening to URL changes
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Soft background
      appBar: AppBar(
        backgroundColor:
            GeniusWalletColors.deepBlueCardColor, // Search bar background color
        elevation: 2,
        titleSpacing: 0,
        title: _buildSearchBar(),
      ),
      body: _controller.value.isInitialized
          ? Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                child: Webview(_controller),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(
                  color: GeniusWalletColors.lightGreenPrimary)),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: GeniusWalletColors.deepBlueCardColor, // Search bar background
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIconButton(Icons.arrow_back, _controller.goBack),
          _buildIconButton(Icons.arrow_forward, _controller.goForward),
          _buildIconButton(Icons.refresh, _controller.reload),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _urlController,
              style:
                  const TextStyle(color: Colors.white), // White text in input
              decoration: InputDecoration(
                hintText: "Enter URL...",
                hintStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: GeniusWalletColors
                    .deepBlueTertiary, // Darker blue input background
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _loadUrl(),
            ),
          ),
        ],
      ),
    );
  }

  /// **Reusable Icon Button with Hover & Press Effects**
  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon),
      color: GeniusWalletColors.lightGreenPrimary, // Default color
      iconSize: 24, // Standard icon size
      onPressed: onPressed,
      hoverColor:
          GeniusWalletColors.deepBlueCardColor.withOpacity(0.3), // Hover effect
      splashColor:
          GeniusWalletColors.deepBlueCardColor.withOpacity(0.5), // Press effect
    );
  }
}
