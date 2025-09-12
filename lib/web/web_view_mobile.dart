import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:screenshot/screenshot.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    _addNewTab(widget.url);
  }

  void forceDarkModeAndRemoveBanner(int tabIndex) {
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
    _controllers[tabIndex].runJavaScript(js);
  }

  void _addNewTab(String url) {
    WebViewController? controller;
    bool retried = false; // Track if we've retried already

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String loadedUrl) {
            print('[DEBUG] onPageStarted: $loadedUrl');
          },
          onPageFinished: (String loadedUrl) async {
            print('[DEBUG] onPageFinished: $loadedUrl');
            if (!Platform.isMacOS &&
                url.contains('uniswap.org') &&
                loadedUrl == 'about:blank') {
              print('[DEBUG] Injecting localStorage for Uniswap (about:blank)');
              await controller!.runJavaScript('''
              localStorage.setItem("interface_color_theme", "\\"Dark\\"");
              localStorage.setItem("uni-theme", "\\"dark\\"");
              document.title = "DARK MODE SET";
            ''');
              await Future.delayed(const Duration(milliseconds: 80));
              controller.loadRequest(Uri.parse(url));
              return;
            }

            // Only retry ONCE if still not dark
            if (!Platform.isMacOS && loadedUrl.contains('uniswap.org')) {
              if (!retried) {
                print(
                    '[DEBUG] Uniswap loaded, attempting one retry for dark mode.');
                retried = true;
                await Future.delayed(const Duration(milliseconds: 350));
                await controller!.runJavaScript('''
                if (!document.body.classList.contains('dark')) {
                  localStorage.setItem("interface_color_theme", "\\"Dark\\"");
                  localStorage.setItem("uni-theme", "\\"dark\\"");
                  window.dispatchEvent(new Event('storage'));
                  setTimeout(() => { window.location.reload(); }, 100);
                }
              ''');
              } else {
                print('[DEBUG] Already retried dark mode once. Not repeating.');
              }
            } else {
              print(
                  '[DEBUG] Non-Uniswap or macOS, injecting generic dark mode.');
              forceDarkModeAndRemoveBanner(_currentTabIndex);
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              print('[DEBUG] Capturing screenshot');
              captureScreenshot();
            });
          },
        ),
      );

    if (!Platform.isMacOS && url.contains('uniswap.org')) {
      print(
          '[DEBUG] Loading about:blank before Uniswap for reliable dark theme');
      controller.loadRequest(Uri.parse('about:blank'));
    } else {
      controller.loadRequest(Uri.parse(url));
    }
    setState(() {
      print('[DEBUG] Add controller, set tab index');
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                        : Colors.grey,
                    size: 20,
                  );
                },
              ),
              onPressed: _goBack,
            ),
            const SizedBox(width: 8),
          ],
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
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _loadUrl(),
            ),
          ),
          const SizedBox(width: 12),
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
                side: const BorderSide(color: Colors.white),
              ),
              backgroundColor: GeniusWalletColors.deepBlueTertiary,
            ),
            child: Text(
              "${_controllers.length}",
              style: const TextStyle(
                color: Colors.white,
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
            padding: const EdgeInsets.all(12),
            itemCount: _controllers.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _switchTab(index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
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
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  _tabUrls[index],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: GeniusWalletColors.deepBlue,
                          borderRadius: BorderRadius.only(
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
                                  const Icon(
                                Icons.language,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FutureBuilder<String?>(
                                future: _controllers[index].getTitle(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Text(
                                      "Loading...",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    );
                                  }
                                  return Text(
                                    snapshot.data ?? _tabUrls[index],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white, size: 30),
                onPressed: () => _addNewTab("https://www.duckduckgo.com"),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
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
