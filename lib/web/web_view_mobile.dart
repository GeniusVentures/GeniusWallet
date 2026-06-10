import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_wallet/dashboard/browser/services/browser_storage.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:webview_flutter/webview_flutter.dart';

void _debug(String message) {
  if (kDebugMode) debugPrint(message);
}

class WebViewMobile extends StatefulWidget {
  final String url;
  final bool? includeBackButton;

  const WebViewMobile({
    Key? key,
    required this.url,
    this.includeBackButton = false,
  }) : super(key: key);

  @override
  WebViewMobileState createState() => WebViewMobileState();
}

class WebViewMobileState extends State<WebViewMobile> {
  final List<WebViewController> _controllers = [];
  final List<String> _tabUrls = [];
  final List<Uint8List?> _tabImages = [];
  ScreenshotController screenshotController = ScreenshotController();

  int _currentTabIndex = 0;
  bool _showTabManager = false;

  final TextEditingController _urlController = TextEditingController();

  Future<bool> _safeRunJavaScript(
    WebViewController controller,
    String script, {
    required String context,
  }) async {
    try {
      await controller.runJavaScript(script);
      return true;
    } on PlatformException catch (e) {
      // WKWebView may reject JS evaluation during in-flight navigation.
      debugPrint('[DEBUG] JS eval failed ($context): ${e.message ?? e.code}');
      return false;
    } catch (e) {
      debugPrint('[DEBUG] JS eval failed ($context): $e');
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _addNewTab(widget.url);
  }

  Future<void> forceDarkModeAndRemoveBanner(int tabIndex) async {
    const js = '''
      (() => {
        try {
          const origMM = window.matchMedia;
          window.matchMedia = function(q) {
            if (q === '(prefers-color-scheme: dark)') {
              return {
                matches: true,
                media: q,
                onchange: null,
                addListener: function() {},
                removeListener: function() {},
                addEventListener: function() {},
                removeEventListener: function() {},
                dispatchEvent: function() { return false; }
              };
            }
            return origMM(q);
          };
          const evt = document.createEvent('Event');
          evt.initEvent('change', true, true);
          window.dispatchEvent(evt);
        } catch (e) {}

        try {
          document.documentElement.setAttribute('data-theme', 'dark');
          document.body.classList.add('dark');
        } catch (e) {}

        function hideBanner() {
          try {
            var banners = Array.from(document.querySelectorAll(
              '[data-testid*="banner"], .uni-banner, .wallet-banner, [id*="banner"], [class*="banner"]'
            ));
            banners = banners.filter(b =>
              b.textContent && b.textContent.match(/Get the Uniswap Wallet App/i)
            );
            banners.forEach(b => b.style.display = "none");
          } catch (e) {}
        }
        hideBanner();
        setTimeout(hideBanner, 600);
        setTimeout(hideBanner, 1800);
        try {
          const observer = new MutationObserver(hideBanner);
          observer.observe(document.body, { childList: true, subtree: true });
        } catch (e) {}
      })();
    ''';
    if (tabIndex < 0 || tabIndex >= _controllers.length) {
      return;
    }
    await _safeRunJavaScript(
      _controllers[tabIndex],
      js,
      context: 'forceDarkModeAndRemoveBanner',
    );
  }

  void _addNewTab(String url) {
    WebViewController? controller;
    bool retried = false;

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String loadedUrl) {
            _debug('[DEBUG] onPageStarted: $loadedUrl');
          },
          onPageFinished: (String loadedUrl) async {
            _debug('[DEBUG] onPageFinished: $loadedUrl');
            if (!Platform.isMacOS &&
                url.contains('uniswap.org') &&
                loadedUrl == 'about:blank') {
              _debug(
                  '[DEBUG] Injecting localStorage for Uniswap (about:blank)');
              await _safeRunJavaScript(
                  controller!,
                  '''
              localStorage.setItem("interface_color_theme", "\\"Dark\\"");
              localStorage.setItem("uni-theme", "\\"dark\\"");
              document.title = "DARK MODE SET";
            ''',
                  context: 'uniswap-about-blank-theme');
              await Future.delayed(const Duration(milliseconds: 80));
              controller.loadRequest(Uri.parse(url));
              return;
            }

            // Only retry ONCE if still not dark
            if (!Platform.isMacOS && loadedUrl.contains('uniswap.org')) {
              if (!retried) {
                _debug(
                    '[DEBUG] Uniswap loaded, attempting one retry for dark mode.');
                retried = true;
                await Future.delayed(const Duration(milliseconds: 350));
                await _safeRunJavaScript(
                    controller!,
                    '''
                if (!document.body.classList.contains('dark')) {
                  localStorage.setItem("interface_color_theme", "\\"Dark\\"");
                  localStorage.setItem("uni-theme", "\\"dark\\"");
                  window.dispatchEvent(new Event('storage'));
                  setTimeout(() => { window.location.reload(); }, 100);
                }
              ''',
                    context: 'uniswap-retry-theme');
              } else {
                _debug(
                    '[DEBUG] Already retried dark mode once. Not repeating.');
              }
            } else {
              _debug(
                  '[DEBUG] Non-Uniswap or macOS, injecting generic dark mode.');
              await forceDarkModeAndRemoveBanner(_currentTabIndex);
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _debug('[DEBUG] Capturing screenshot');
              captureScreenshot();
            });
          },
        ),
      );

    if (!Platform.isMacOS && url.contains('uniswap.org')) {
      _debug(
          '[DEBUG] Loading about:blank before Uniswap for reliable dark theme');
      controller.loadRequest(Uri.parse('about:blank'));
    } else {
      controller.loadRequest(Uri.parse(url));
    }
    setState(() {
      _debug('[DEBUG] Add controller, set tab index');
      _controllers.add(controller!);
      _tabUrls.add(url);
      _tabImages.add(null);
      _currentTabIndex = _controllers.length - 1;
    });
  }

  void captureScreenshot() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      final screenshot = await screenshotController.capture();
      if (screenshot != null && mounted) {
        setState(() {
          _tabImages[_currentTabIndex] = screenshot;
        });
      }
    });
  }

  void _goBack() async {
    if (await _controllers[_currentTabIndex].canGoBack()) {
      await _controllers[_currentTabIndex].goBack();
    }
  }

  void _goForward() async {
    if (await _controllers[_currentTabIndex].canGoForward()) {
      await _controllers[_currentTabIndex].goForward();
    }
  }

  void _loadUrl() {
    String input = _urlController.text.trim();
    if (input.isEmpty) return;
    final isLikelyUrl = input.contains('.') && !input.contains(' ');
    if (!isLikelyUrl) {
      final query = Uri.encodeComponent(input);
      input = "https://www.google.com/search?q=$query";
    } else if (!input.startsWith('http://') && !input.startsWith('https://')) {
      input = "https://$input";
    }
    _controllers[_currentTabIndex].loadRequest(Uri.parse(input));
    setState(() {
      _tabUrls[_currentTabIndex] = input;
    });
  }

  void _closeTab(int index) {
    if (_controllers.length == 1) return;
    setState(() {
      _controllers.removeAt(index);
      _tabUrls.removeAt(index);
      _tabImages.removeAt(index);
      _currentTabIndex = _currentTabIndex > 0 ? _currentTabIndex - 1 : 0;
      _urlController.text = _tabUrls[_currentTabIndex];
    });
  }

  void _switchTab(int index) {
    setState(() {
      _currentTabIndex = index;
      _urlController.text = _tabUrls[index];
      _showTabManager = false;
    });
  }

  Widget _buildWebView(int index) {
    return Screenshot(
      controller: screenshotController,
      child: WebViewWidget(controller: _controllers[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GeniusWalletColors.deepBlueTertiary,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildSearchBar(),
                Expanded(child: _buildWebView(_currentTabIndex)),
              ],
            ),
            if (_showTabManager)
              Positioned.fill(
                child: Container(
                  color: GeniusWalletColors.deepBlueTertiary,
                  child: Column(
                    children: [Expanded(child: _buildTabManager())],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final includeBackButton = widget.includeBackButton ?? false;
    return Container(
      color: GeniusWalletColors.deepBlueCardColor,
      padding: const EdgeInsets.symmetric(
          horizontal: GeniusWalletConsts.space6, vertical: 10),
      child: Row(
        children: [
          if (includeBackButton)
            Builder(
              builder: (context) {
                return InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Icon(Icons.cancel, size: 20),
                );
              },
            ),
          if (!includeBackButton) ...[
            IconButton(
              icon: FutureBuilder<bool>(
                future: _controllers[_currentTabIndex].canGoBack(),
                builder: (context, snapshot) {
                  final canGoBack = snapshot.data ?? false;
                  return Icon(
                    Icons.arrow_back,
                    color: canGoBack
                        ? GeniusWalletColors.lightGreenPrimary
                        : GeniusWalletColors.textSecondary,
                    size: 20,
                  );
                },
              ),
              onPressed: _goBack,
            ),
            const SizedBox(width: GeniusWalletConsts.space4),
          ],
          Expanded(
            child: TextField(
              controller: _urlController,
              style: TextStyle(color: GeniusWalletColors.textPrimary),
              decoration: InputDecoration(
                hintText: "Enter URL...",
                hintStyle: TextStyle(color: GeniusWalletColors.textPrimary70),
                filled: true,
                fillColor: GeniusWalletColors.deepBlueTertiary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _loadUrl(),
            ),
          ),
          const SizedBox(width: GeniusWalletConsts.space4),
          _BookmarkButton(
            currentUrl:
                _tabUrls.isNotEmpty ? _tabUrls[_currentTabIndex] : widget.url,
          ),
          const SizedBox(width: GeniusWalletConsts.space4),
          TextButton(
            onPressed: () => {
              setState(() => _showTabManager = true),
              captureScreenshot(),
            },
            style: TextButton.styleFrom(
              minimumSize: const Size(30, 30),
              maximumSize: const Size(30, 30),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: GeniusWalletColors.textPrimary),
              ),
              backgroundColor: GeniusWalletColors.deepBlueTertiary,
            ),
            child: Text(
              "${_controllers.length}",
              style: TextStyle(
                color: GeniusWalletColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabManager() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(GeniusWalletConsts.space6),
            itemCount: _controllers.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _switchTab(index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    children: [
                      SizedBox(
                        height: GeniusWalletConsts.space10,
                        child: Stack(
                          children: [
                            if (_tabImages[index] != null)
                              Positioned.fill(
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationX(pi),
                                  child: Image.memory(
                                    _tabImages[index]!,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              )
                            else
                              Container(
                                color: GeniusWalletColors.deepBlue,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(
                                    GeniusWalletConsts.space4),
                                child: Text(
                                  _tabUrls[index],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: GeniusWalletTypography.bodyMd.copyWith(
                                    color: GeniusWalletColors.textPrimary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: GeniusWalletColors.deepBlue,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            Image.network(
                              _getFaviconUrl(_tabUrls[index]),
                              width: 22,
                              height: 22,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                Icons.language,
                                color: GeniusWalletColors.textPrimary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: GeniusWalletConsts.space4),
                            Expanded(
                              child: FutureBuilder<String?>(
                                future: _controllers[index].getTitle(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Text(
                                      "Loading...",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GeniusWalletTypography.bodyMd
                                          .copyWith(
                                        color: GeniusWalletColors.textPrimary,
                                      ),
                                    );
                                  }
                                  return Text(
                                    snapshot.data ?? _tabUrls[index],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: GeniusWalletColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: GeniusWalletColors.textPrimary,
                                size: 24,
                              ),
                              onPressed: () => _closeTab(index),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: GeniusWalletConsts.space12,
              vertical: GeniusWalletConsts.space6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.add,
                    color: GeniusWalletColors.textPrimary, size: 30),
                onPressed: () => _addNewTab("https://www.duckduckgo.com"),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close,
                    color: GeniusWalletColors.textPrimary, size: 30),
                onPressed: () => setState(() => _showTabManager = false),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  String _getFaviconUrl(String url) {
    Uri uri = Uri.parse(url);
    return "https://www.google.com/s2/favicons?domain=${uri.host}&sz=32";
  }
}

class _BookmarkButton extends StatelessWidget {
  const _BookmarkButton({required this.currentUrl});
  final String currentUrl;

  String _hostName(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host;
      if (host.isEmpty) return url;
      return host.startsWith('www.') ? host.substring(4) : host;
    } catch (_) {
      return url;
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<BrowserStorage>();
    final isFav = storage.isFavorite(currentUrl);
    return IconButton(
      tooltip: isFav ? 'Remove bookmark' : 'Bookmark',
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      onPressed: () {
        storage.toggleFavorite(name: _hostName(currentUrl), url: currentUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content:
                Text(isFav ? 'Removed from favorites' : 'Added to favorites'),
            backgroundColor: GeniusWalletColors.deepBlueTertiary,
          ),
        );
      },
      icon: Icon(
        isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
        color: isFav
            ? GeniusWalletColors.brandPrimary
            : GeniusWalletColors.textPrimary,
        size: 22,
      ),
    );
  }
}
