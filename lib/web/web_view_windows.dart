import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/reown/reown_walletkit_instance.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:genius_wallet/web/web_chrome_helpers.dart';
import 'package:genius_wallet/web/windows_webview_shutdown.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';

class WebViewWindows extends StatefulWidget {
  final String url;
  final bool? includeBackButton;

  const WebViewWindows({
    super.key,
    required this.url,
    this.includeBackButton = false,
  });

  @override
  State<WebViewWindows> createState() => _WebViewWindowsState();
}

class _WebViewWindowsState extends State<WebViewWindows> {
  final WebviewController _controller = WebviewController();
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _urlFocusNode = FocusNode();
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
    _urlFocusNode.addListener(_onUrlFocusChange);
    _initializeWebView();

    // Start polling clipboard for WalletConnect URIs ( auto connect on desktop workaround)
    _clipboardPoller = Timer.periodic(const Duration(seconds: 2), (
      timer,
    ) async {
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
    unawaited(_controller.loadUrl(widget.url));
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

    if (input.isEmpty) {
      return;
    }

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

  // The real current page URL (the last value the controller's url stream
  // pushed into openTabs), independent of the editable field text.
  String get _currentUrl =>
      openTabs.isNotEmpty ? openTabs[currentTabIndex] : widget.url;

  // Omnibox swaps between the static favicon+lock+host row and the editable
  // field. On focus, seed the field with the FULL url and select-all.
  void _onUrlFocusChange() {
    if (_urlFocusNode.hasFocus) {
      final full = _currentUrl;
      _urlController.text = full;
      _urlController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: full.length,
      );
    }
    setState(() {});
  }

  // Same favicon service as the mobile path (fenced by D-09). tryParse so a
  // half-typed / hostless URL degrades to an empty host rather than throwing.
  String _getFaviconUrl(String url) {
    final host = Uri.tryParse(url.trim())?.host ?? '';
    return "https://www.google.com/s2/favicons?domain=$host&sz=32";
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
    _urlFocusNode.removeListener(_onUrlFocusChange);
    _urlFocusNode.dispose();
    _urlController.dispose();
    await _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final includeBackButton = widget.includeBackButton ?? false;
    return Scaffold(
      backgroundColor: context.gw.deepBlueCardColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 70,
              color: context.gw.deepBlueCardColor,
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (includeBackButton)
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.cancel,
                        size: 20,
                        color: Colors.white,
                      ),
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
                  : const Center(child: Loading()),
            ),
          ],
        ),
      ),
    );
  }

  // ponytail: the Windows omnibox is deliberately NOT a shared widget with the
  // mobile one — the controllers diverge (WebviewController's canGoBack() is a
  // sync bool here vs the mobile WebViewController's async Future), so a shared
  // widget would need generic callbacks, more code than it saves. Reuse is
  // limited to the pure helpers (webDisplayHost/webIsSecure, web_chrome_helpers).
  // Mirrors 18-01's 035-B omnibox: one field, nested back/forward, favicon +
  // https lock + host, refresh, and an outside `⋯` that keeps opening the
  // existing history dialog (Windows' only tab affordance).
  Widget _buildSearchBar() {
    final editing = _urlFocusNode.hasFocus;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: _buildOmniboxField(editing)),
        const SizedBox(width: GeniusWalletConsts.space4),
        _buildIconButton(
          Icons.more_horiz,
          _showTabSwitcher,
          color: context.gw.textPrimary60,
          size: 20,
        ),
      ],
    );
  }

  Widget _buildOmniboxField(bool editing) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: context.gw.surfaceSunken,
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusBase),
        border: Border.all(
          color: editing ? context.gw.brandPrimary : context.gw.borderSubtle,
          width: editing ? 2 : 1,
        ),
        boxShadow: editing
            ? [
                BoxShadow(
                  color: context.gw.brandPrimarySubtle,
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // canGoBack()/canGoForward() are synchronous here (no FutureBuilder):
          // brand-tinted + tappable when true, muted + inert otherwise (D-02).
          _buildIconButton(
            Icons.arrow_back,
            canGoBack() ? goBack : null,
            color: canGoBack()
                ? context.gw.brandPrimaryOnSurface
                : context.gw.textPrimary38,
            size: 18,
          ),
          _buildIconButton(
            Icons.arrow_forward,
            canGoForward() ? goForward : null,
            color: canGoForward()
                ? context.gw.brandPrimaryOnSurface
                : context.gw.textPrimary38,
            size: 18,
          ),
          Expanded(child: _buildOmniboxCenter(editing)),
          _buildIconButton(
            Icons.refresh,
            _controller.reload,
            color: context.gw.textPrimary,
            size: 18,
          ),
          const SizedBox(width: GeniusWalletConsts.space2),
        ],
      ),
    );
  }

  // Always-mounted TextField (keeps _urlFocusNode attached so the rest tap can
  // requestFocus() it); at rest an opaque cover paints favicon + https lock +
  // host over it.
  Widget _buildOmniboxCenter(bool editing) {
    final currentUrl = _currentUrl;
    final secure = webIsSecure(currentUrl);
    final host = webDisplayHost(currentUrl);
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        TextField(
          controller: _urlController,
          focusNode: _urlFocusNode,
          style: TextStyle(color: context.gw.textPrimary, fontSize: 14),
          textAlignVertical: TextAlignVertical.center,
          decoration: const InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 4),
          ),
          onSubmitted: (_) {
            _loadUrl();
            _urlFocusNode.unfocus();
          },
        ),
        if (!editing)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _urlFocusNode.requestFocus(),
              child: Container(
                color: context.gw.surfaceSunken,
                padding: const EdgeInsets.symmetric(
                  horizontal: GeniusWalletConsts.space2,
                ),
                child: Row(
                  children: [
                    Image.network(
                      _getFaviconUrl(currentUrl),
                      width: 16,
                      height: 16,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.language,
                        color: context.gw.textPrimary60,
                        size: 16,
                      ),
                    ),
                    if (secure) ...[
                      const SizedBox(width: GeniusWalletConsts.space2),
                      const Icon(
                        Icons.lock,
                        color: GeniusWalletColors.statusSuccess,
                        size: 13,
                      ),
                    ],
                    const SizedBox(width: GeniusWalletConsts.space2),
                    Expanded(
                      child: Text(
                        host,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.gw.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIconButton(
    IconData icon,
    VoidCallback? onPressed, {
    Color? color,
    double size = 24,
  }) {
    return IconButton(
      icon: Icon(icon),
      color: color ?? context.gw.lightGreenPrimary,
      iconSize: size,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      hoverColor: context.gw.deepBlueCardColor.withValues(alpha: 0.3),
      splashColor: context.gw.deepBlueCardColor.withValues(alpha: 0.5),
    );
  }

  void _showTabSwitcher() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: context.gw.deepBlueCardColor,
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
                                ? context.gw.lightGreenPrimary
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
