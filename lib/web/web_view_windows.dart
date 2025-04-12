import 'dart:async';
import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:webview_windows/webview_windows.dart';

class WebViewWindows extends StatefulWidget {
  final String url;
  final bool? includeBackButton;

  const WebViewWindows(
      {Key? key, required this.url, this.includeBackButton = false})
      : super(key: key);

  @override
  _WebViewWindowsState createState() => _WebViewWindowsState();
}

class _WebViewWindowsState extends State<WebViewWindows> {
  final WebviewController _controller = WebviewController();
  final TextEditingController _urlController = TextEditingController();
  StreamSubscription<String>? _urlSubscription;
  final List<String> history = [];
  int currentHistoryIndex = -1;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    await _controller.initialize();
    _controller.loadUrl(widget.url);
    _urlController.text = widget.url;

    // Listen for URL changes
    _urlSubscription = _controller.url.listen((url) {
      if (currentHistoryIndex == -1 ||
          history.isEmpty ||
          history[currentHistoryIndex] != url) {
        // If we navigated back, remove "forward" history
        if (currentHistoryIndex < history.length - 1) {
          history.removeRange(currentHistoryIndex + 1, history.length);
        }

        history.add(url);
        currentHistoryIndex = history.length - 1;
      }
      setState(() {
        _urlController.text = url;
      });
    });
  }

  bool canGoBack() => currentHistoryIndex > 0;
  bool canGoForward() => currentHistoryIndex < history.length - 1;

  void goBack() {
    if (canGoBack()) {
      currentHistoryIndex--;
      _controller.loadUrl(history[currentHistoryIndex]);
      setState(() {}); // Refresh UI
    }
  }

  void goForward() {
    if (canGoForward()) {
      currentHistoryIndex++;
      _controller.loadUrl(history[currentHistoryIndex]);
      setState(() {}); // Refresh UI
    }
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
    _urlSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final includeBackButton = widget.includeBackButton ?? false;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        toolbarHeight: 80,
        leadingWidth: 80,
        backgroundColor: GeniusWalletColors.deepBlueCardColor,
        titleSpacing: 0,
        title: _buildSearchBar(),
        leading: includeBackButton
            ? Builder(
                builder: (context) => IconButton(
                    icon: const Icon(
                      Icons.cancel,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              )
            : null,
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
              child: ClipRRect(child: Webview(_controller)),
            )
          : const Center(
              child: CircularProgressIndicator(
                color: GeniusWalletColors.lightGreenPrimary,
              ),
            ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 16),
      decoration: BoxDecoration(
        color: GeniusWalletColors.deepBlueCardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIconButton(Icons.arrow_back, canGoBack() ? goBack : null),
          // HIDE FORWARD BUTTON FOR SPACE
          // _buildIconButton(
          //   Icons.arrow_forward,
          //   canGoForward() ? goForward : null,
          // ),
          _buildIconButton(Icons.refresh, _controller.reload),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _urlController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter URL...",
                hintStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: GeniusWalletColors.deepBlueTertiary,
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

  Widget _buildIconButton(IconData icon, VoidCallback? onPressed) {
    return IconButton(
      icon: Icon(icon),
      color: GeniusWalletColors.lightGreenPrimary,
      iconSize: 24,
      onPressed: onPressed,
      hoverColor: GeniusWalletColors.deepBlueCardColor.withOpacity(0.3),
      splashColor: GeniusWalletColors.deepBlueCardColor.withOpacity(0.5),
    );
  }
}
