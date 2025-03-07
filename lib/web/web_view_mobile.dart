import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:screenshot/screenshot.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewMobile extends StatefulWidget {
  final String url;

  const WebViewMobile({Key? key, required this.url}) : super(key: key);

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

  void _addNewTab(String url) {
    WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (_currentTabIndex < _tabUrls.length) {
              setState(() {
                _tabUrls[_currentTabIndex] = url;
                _urlController.text = url;
              });
            }
          },
          onPageFinished: (String url) async {
            setState(() {
              _tabUrls[_currentTabIndex] = url;
              _showTabManager = false;
            });
            await Future.delayed(const Duration(milliseconds: 300));
            captureScreenshot();
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    setState(() {
      _controllers.add(controller);
      _tabUrls.add(url);
      _tabImages.add(null);
      _currentTabIndex = _controllers.length - 1;
    });
  }

  void captureScreenshot() {
    screenshotController.capture().then(
          (screenshot) => {
            setState(() {
              _tabImages[_currentTabIndex] = screenshot;
            }),
          },
        );
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
    String url = _urlController.text.trim();
    if (url.isNotEmpty && !url.startsWith("http")) {
      url = "https://$url";
    }
    _controllers[_currentTabIndex].loadRequest(Uri.parse(url));

    setState(() {
      _tabUrls[_currentTabIndex] = url;
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
    return Container(
      color: GeniusWalletColors.deepBlueCardColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
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
                );
              },
            ),
            onPressed: _goBack,
          ),
          IconButton(
            icon: FutureBuilder<bool>(
              future: _controllers[_currentTabIndex].canGoForward(),
              builder: (context, snapshot) {
                final canGoForward = snapshot.data ?? false;
                return Icon(
                  Icons.arrow_forward,
                  color: canGoForward
                      ? GeniusWalletColors.lightGreenPrimary
                      : Colors.grey,
                );
              },
            ),
            onPressed: _goForward,
          ),
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
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: .52, // Adjust to fit header and preview
            ),
            itemCount: _controllers.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _switchTab(index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            if (_tabImages[index] != null)
                              Positioned.fill(
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationX(
                                    pi,
                                  ), // Flip upside-down
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
                            // Favicon
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

  // Function to get Favicon URL from the site's domain
  String _getFaviconUrl(String url) {
    Uri uri = Uri.parse(url);
    return "https://www.google.com/s2/favicons?domain=${uri.host}&sz=32";
  }
}
