import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_wallet/reown/reown_walletkit_instance.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
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
  List<String> openTabs = [];
  int currentTabIndex = 0;
  void _injectDarkTheme() {
    const darkCSS = '''
    html, body { background: #181A20 !important; color: #f2f2f2 !important; }
    * { background-color: transparent !important; color: #f2f2f2 !important; border-color: #30343a !important; }
    a { color: #3ddc97 !important; }
    input, textarea, select { background: #23242b !important; color: #f2f2f2 !important; border: 1px solid #30343a !important; }
  ''';

    // Add more selectors if you want to hide other banners too!
    const hideBannerJS = '''
    // Hide Uniswap "Get the Wallet App" banner by attribute or class (expand as needed)
    var uniswapBanner = document.querySelector('[data-testid="uni-banner"], [data-testid="get-wallet-banner"], .uni-banner, .wallet-banner, [id*="banner"], [class*="banner"]');
    if (uniswapBanner) uniswapBanner.style.display = "none";
    // Hide other common banners/ads if desired
    var allBanners = document.querySelectorAll('.adsbygoogle, .sticky-footer, .sticky-header');
    allBanners.forEach(function(b) { b.style.display = "none"; });
  ''';

    _controller.executeScript('''
    (function() {
      // Inject dark CSS
      var darkStyle = document.getElementById("force-dark-css");
      if (!darkStyle) {
        darkStyle = document.createElement('style');
        darkStyle.id = "force-dark-css";
        darkStyle.innerHTML = `$darkCSS`;
        document.head.appendChild(darkStyle);
      }
      // Hide banners/ads
      $hideBannerJS
    })();
  ''');
  }

  @override
  void initState() {
    super.initState();
    _initializeWebView();

    // Start polling clipboard for WalletConnect URIs ( auto connect on desktop workaround)
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      final clipboard = await Clipboard.getData('text/plain');
      final text = clipboard?.text ?? '';
      if (text.startsWith('wc:')) {
        debugPrint('📋 WalletConnect URI from clipboard: $text');
        WalletKitInstance().walletKit.pair(uri: Uri.parse(text));
        // Clear the clipboard after processing to avoid repeated connections
        await Clipboard.setData(const ClipboardData(text: ''));
      }
    });
  }

  Future<void> _initializeWebView() async {
    await _controller.initialize();
    _controller.loadUrl(widget.url);
    _urlController.text = widget.url;

    // Add the initial tab
    openTabs.add(widget.url);
    currentTabIndex = 0;

    _urlSubscription = _controller.url.listen((url) {
      if (!history.contains(url)) {
        if (currentHistoryIndex < history.length - 1) {
          history.removeRange(currentHistoryIndex + 1, history.length);
        }

        history.add(url);
        currentHistoryIndex = history.length - 1;
      } else {
        currentHistoryIndex = history.indexOf(url);
      }

      setState(() {
        _urlController.text = url;
        if (openTabs.isNotEmpty) {
          openTabs[currentTabIndex] = url;
        }
      });
      _controller.loadingState.listen((event) {
        if (event == LoadingState.navigationCompleted) {
          _injectDarkTheme();
        }
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
    String input = _urlController.text.trim();

    // Basic check for whether it's likely a URL
    final isLikelyUrl = input.contains('.') && !input.contains(' ');

    if (input.isEmpty) return;

    if (!isLikelyUrl) {
      // Treat as search query
      final query = Uri.encodeComponent(input);
      input = "https://www.google.com/search?q=$query";
    } else if (!input.startsWith('http://') && !input.startsWith('https://')) {
      // Prepend https if it's a plain domain
      input = "https://$input";
    }

    _controller.loadUrl(input);
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
        backgroundColor: GeniusWalletColors.deepBlueCardColor,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                height: 70,
                color: GeniusWalletColors.deepBlueCardColor,
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (includeBackButton)
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(Icons.cancel,
                            size: 20, color: Colors.white),
                      ),
                    Flexible(child: _buildSearchBar()),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // Webview or loader
              Expanded(
                child: _controller.value.isInitialized
                    ? Container(
                        decoration: const BoxDecoration(
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
              ),
            ],
          ),
        ));
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.only(
        left: 8,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: GeniusWalletColors.deepBlueCardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIconButton(Icons.arrow_back, canGoBack() ? goBack : null),
          // HIDE FORWARD BUTTON FOR SPACE
          _buildIconButton(
            Icons.arrow_forward,
            canGoForward() ? goForward : null,
          ),
          _buildIconButton(Icons.refresh, _controller.reload),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _urlController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter URL...",
                hintStyle: const TextStyle(color: Colors.white70),
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
          _buildIconButton(Icons.tab, _showTabSwitcher),
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
      hoverColor: GeniusWalletColors.deepBlueCardColor.withAlpha(77),
      splashColor: GeniusWalletColors.deepBlueCardColor.withAlpha(128),
    );
  }

  void _showTabSwitcher() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: GeniusWalletColors.deepBlueCardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: SizedBox(
            width: 500,
            height: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "History",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                const Divider(color: Colors.white54),
                Expanded(
                  child: ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final url = history[index];
                      return ListTile(
                        title: Text(
                          url,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: index == currentTabIndex
                                ? GeniusWalletColors.lightGreenPrimary
                                : Colors.white,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          _switchToTab(index);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _switchToTab(int index) {
    if (index != currentTabIndex) {
      currentTabIndex = index;
      _controller.loadUrl(history[currentTabIndex]);
      _urlController.text = history[currentTabIndex];
      setState(() {});
    }
  }
}
