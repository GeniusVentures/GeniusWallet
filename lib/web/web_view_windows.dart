import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_wallet/components/loading/loading.dart';
import 'package:genius_wallet/reown/reown_walletkit_instance.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/web/windows_webview_shutdown.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';

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
  Timer? _clipboardPoller;
  bool _isClipboardPairing = false;
  String? _lastHandledWalletConnectUri;
  bool _resourcesDisposed = false;
  final List<String> history = [];
  int currentHistoryIndex = -1;
  List<String> openTabs = [];
  int currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WindowsWebViewShutdown.instance.register(_disposeWebViewResources);
    unawaited(windowManager.setPreventClose(true));
    _initializeWebView();

    // Start polling clipboard for WalletConnect URIs ( auto connect on desktop workaround)
    _clipboardPoller =
        Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!mounted) {
        return;
      }
      final clipboard = await Clipboard.getData('text/plain');
      final text = clipboard?.text ?? '';
      if (text.startsWith('wc:')) {
        await _pairWalletConnectFromClipboard(text);
      }
    });
  }

  Future<void> _pairWalletConnectFromClipboard(String text) async {
    if (_isClipboardPairing || _resourcesDisposed) {
      return;
    }
    if (_lastHandledWalletConnectUri == text) {
      return;
    }

    _isClipboardPairing = true;
    try {
      await WalletKitInstance().initOnce();
      debugPrint('📋 WalletConnect URI from clipboard: $text');
      await WalletKitInstance().walletKit.pair(uri: Uri.parse(text));
      _lastHandledWalletConnectUri = text;
      // Clear the clipboard after processing to avoid repeated connections.
      await Clipboard.setData(const ClipboardData(text: ''));
    } catch (e) {
      debugPrint('❌ Clipboard WalletConnect pair failed: $e');
    } finally {
      _isClipboardPairing = false;
    }
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
    WindowsWebViewShutdown.instance.unregister(_disposeWebViewResources);
    if (!WindowsWebViewShutdown.instance.hasActiveWebViews) {
      unawaited(windowManager.setPreventClose(false));
    }
    unawaited(_disposeWebViewResources());
    super.dispose();
  }

  Future<void> _disposeWebViewResources() async {
    if (_resourcesDisposed) {
      return;
    }

    _resourcesDisposed = true;
    _clipboardPoller?.cancel();
    _clipboardPoller = null;
    await _urlSubscription?.cancel();
    _urlSubscription = null;
    _urlController.dispose();
    await _controller.dispose();
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
                padding: const EdgeInsets.only(left: GeniusWalletConsts.space4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (includeBackButton)
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(Icons.cancel,
                            size: 20, color: GeniusWalletColors.textPrimary),
                      ),
                    Flexible(child: _buildSearchBar()),
                  ],
                ),
              ),

              const SizedBox(height: GeniusWalletConsts.space2),

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
                        child: Loading(),
                      ),
              ),
            ],
          ),
        ));
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.only(
        left: GeniusWalletConsts.space4,
        right: GeniusWalletConsts.space8,
      ),
      decoration: BoxDecoration(
        gradient: GWDecorations.surfaceSheen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GeniusWalletColors.borderSubtle, width: 1),
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
          const SizedBox(width: GeniusWalletConsts.space4),
          Expanded(
            child: TextField(
              controller: _urlController,
              style: const TextStyle(color: GeniusWalletColors.textPrimary),
              decoration: InputDecoration(
                hintText: "Enter URL...",
                hintStyle:
                    const TextStyle(color: GeniusWalletColors.textPrimary70),
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
                Padding(
                  padding: const EdgeInsets.all(GeniusWalletConsts.space8),
                  child: Text(
                    "History",
                    style: GeniusWalletTypography.titleLg
                        .copyWith(color: GeniusWalletColors.textPrimary),
                  ),
                ),
                const Divider(color: GeniusWalletColors.textPrimary54),
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
                                : GeniusWalletColors.textPrimary,
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
