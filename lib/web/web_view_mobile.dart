import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/web/web_chrome_helpers.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewMobile extends StatefulWidget {
  final String url;
  final bool? includeBackButton;

  const WebViewMobile({
    super.key,
    required this.url,
    this.includeBackButton = false,
  });

  @override
  WebViewMobileState createState() => WebViewMobileState();
}

class WebViewMobileState extends State<WebViewMobile> {
  final List<WebViewController> _controllers = [];
  final List<String> _tabUrls = [];

  int _currentTabIndex = 0;

  final TextEditingController _urlController = TextEditingController();
  final FocusNode _urlFocusNode = FocusNode();

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
    _urlFocusNode.addListener(_onUrlFocusChange);
  }

  @override
  void dispose() {
    _urlFocusNode.removeListener(_onUrlFocusChange);
    _urlFocusNode.dispose();
    _urlController.dispose();
    super.dispose();
  }

  // The omnibox swaps between a static favicon+lock+host row (at rest) and the
  // editable TextField (on focus). On focus, seed the field with the FULL url
  // and select-all so the user edits the real address, not the collapsed host.
  void _onUrlFocusChange() {
    if (_urlFocusNode.hasFocus && _tabUrls.isNotEmpty) {
      final full = _tabUrls[_currentTabIndex];
      _urlController.text = full;
      _urlController.selection =
          TextSelection(baseOffset: 0, extentOffset: full.length);
    }
    setState(() {}); // toggle rest-display <-> editable field
  }

  void _reload() {
    _controllers[_currentTabIndex].reload();
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
            print('[DEBUG] onPageStarted: $loadedUrl');
          },
          onPageFinished: (String loadedUrl) async {
            print('[DEBUG] onPageFinished: $loadedUrl');
            if (!Platform.isMacOS &&
                url.contains('uniswap.org') &&
                loadedUrl == 'about:blank') {
              print('[DEBUG] Injecting localStorage for Uniswap (about:blank)');
              await _safeRunJavaScript(controller!, '''
              localStorage.setItem("interface_color_theme", "\\"Dark\\"");
              localStorage.setItem("uni-theme", "\\"dark\\"");
              document.title = "DARK MODE SET";
            ''', context: 'uniswap-about-blank-theme');
              await Future.delayed(const Duration(milliseconds: 80));
              controller.loadRequest(Uri.parse(url));
              return;
            }

            // Only retry ONCE if still not dark
            if (!Platform.isMacOS && loadedUrl.contains('uniswap.org')) {
              if (!retried) {
                print(
                  '[DEBUG] Uniswap loaded, attempting one retry for dark mode.',
                );
                retried = true;
                await Future.delayed(const Duration(milliseconds: 350));
                await _safeRunJavaScript(controller!, '''
                if (!document.body.classList.contains('dark')) {
                  localStorage.setItem("interface_color_theme", "\\"Dark\\"");
                  localStorage.setItem("uni-theme", "\\"dark\\"");
                  window.dispatchEvent(new Event('storage'));
                  setTimeout(() => { window.location.reload(); }, 100);
                }
              ''', context: 'uniswap-retry-theme');
              } else {
                print('[DEBUG] Already retried dark mode once. Not repeating.');
              }
            } else {
              print(
                '[DEBUG] Non-Uniswap or macOS, injecting generic dark mode.',
              );
              await forceDarkModeAndRemoveBanner(_currentTabIndex);
            }
          },
        ),
      );

    if (!Platform.isMacOS && url.contains('uniswap.org')) {
      print(
        '[DEBUG] Loading about:blank before Uniswap for reliable dark theme',
      );
      controller.loadRequest(Uri.parse('about:blank'));
    } else {
      controller.loadRequest(Uri.parse(url));
    }
    setState(() {
      print('[DEBUG] Add controller, set tab index');
      _controllers.add(controller!);
      _tabUrls.add(url);
      _currentTabIndex = _controllers.length - 1;
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
      _currentTabIndex = _currentTabIndex > 0 ? _currentTabIndex - 1 : 0;
      _urlController.text = _tabUrls[_currentTabIndex];
    });
  }

  void _switchTab(int index) {
    setState(() {
      _currentTabIndex = index;
      _urlController.text = _tabUrls[index];
    });
  }

  Widget _buildWebView(int index) {
    return WebViewWidget(controller: _controllers[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GeniusWalletColors.deepBlueTertiary,
      body: SafeArea(
        child: Column(
          children: [
            _buildTabStrip(),
            _buildSearchBar(),
            Expanded(child: _buildWebView(_currentTabIndex)),
          ],
        ),
      ),
    );
  }

  // 036-A always-visible horizontal tab strip (~46px), between the app navbar
  // and the omnibox (D-04/D-08). Each tab = favicon + title (getTitle() with URL
  // fallback) + close; the active tab wears the navbar's own mark (surfaceElevated
  // fill + a 2px brandCta gradient underline, D-05); a trailing `+` adds a
  // DuckDuckGo tab. Tab mechanics (_switchTab / _closeTab / _addNewTab) verbatim.
  // Tab currently under the mouse — drives the hover-only close affordance.
  int? _hoveredTabIndex;

  Widget _buildTabStrip() {
    final canClose = webTabCanClose(_controllers.length);
    return Container(
      height: 46,
      color: GeniusWalletColors.deepBlueCardColor,
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space4,
      ),
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _controllers.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: GeniusWalletConsts.space2),
              itemBuilder: (context, index) =>
                  Center(child: _buildTabChip(index, canClose)),
            ),
          ),
          const SizedBox(width: GeniusWalletConsts.space2),
          IconButton(
            icon: Icon(
              Icons.add,
              size: 20,
              color: GeniusWalletColors.textPrimary,
            ),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            splashRadius: 18,
            tooltip: 'New tab',
            onPressed: () => _addNewTab("https://www.duckduckgo.com"),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip(int index, bool canClose) {
    final active = index == _currentTabIndex;
    final hovered = index == _hoveredTabIndex;
    final labelColor = active
        ? GeniusWalletColors.textPrimary
        : GeniusWalletColors.textPrimary60;
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredTabIndex = index),
      onExit: (_) => setState(() {
        if (_hoveredTabIndex == index) _hoveredTabIndex = null;
      }),
      child: GestureDetector(
      onTap: () => _switchTab(index),
      child: Container(
        height: 34,
        // ~1/3 shorter than the old 190 cap (Jakub 2026-07-24).
        constraints: const BoxConstraints(maxWidth: 128),
        decoration: BoxDecoration(
          color: active
              ? GeniusWalletColors.surfaceElevated
              : Colors.transparent,
          borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusSm),
          border: Border.all(
            color: active
                ? Colors.transparent
                : GeniusWalletColors.borderSubtle,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: GeniusWalletConsts.space4,
                  right: GeniusWalletConsts.space2,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.network(
                      _getFaviconUrl(_tabUrls[index]),
                      width: 16,
                      height: 16,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.language,
                        color: labelColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: GeniusWalletConsts.space2),
                    Flexible(
                      child: FutureBuilder<String?>(
                        future: _controllers[index].getTitle(),
                        builder: (context, snapshot) {
                          final title = snapshot.connectionState ==
                                  ConnectionState.waiting
                              ? "Loading..."
                              : (snapshot.data ?? _tabUrls[index]);
                          return Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: labelColor,
                              fontSize: 13,
                              fontWeight:
                                  active ? FontWeight.w600 : FontWeight.w400,
                            ),
                          );
                        },
                      ),
                    ),
                    // Close affordance (D-06 last-tab-locked): shown ONLY on
                    // hover, right-aligned at the chip's trailing edge, and it
                    // lights up (surfaceElevated pill + bright glyph) so it reads
                    // as the live target. The lone tab never gets one.
                    if (canClose && hovered) ...[
                      const SizedBox(width: GeniusWalletConsts.space2),
                      InkWell(
                        borderRadius: BorderRadius.circular(
                          GeniusWalletConsts.radiusXs,
                        ),
                        onTap: () => _closeTab(index),
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: GeniusWalletColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(
                              GeniusWalletConsts.radiusXs,
                            ),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: GeniusWalletColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Active mark reuses the navbar language (D-05): a 2px brandCta
            // gradient underline under the active chip; inactive draws nothing.
            Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: active ? _activeUnderlineGradient() : null,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(GeniusWalletConsts.radiusSm),
                  bottomRight: Radius.circular(GeniusWalletConsts.radiusSm),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  // The active-tab underline reuses the sketch 022 B2 active mark. Dark keeps
  // the real brandCta stops; on the light canvas those stops fall well below
  // WCAG 1.4.11's 3:1 (gradientBlue #0AAEE6 is 2.56:1 on white), so light
  // degrades to the flat, light-safe brandPrimaryOnSurface (#0A6885, 6.30:1) —
  // the exact routing transactions_slim_view._activeLabelShader uses. Keyed off
  // surfaceMenu's luminance as the appearance proxy (not a new GWColors import),
  // so this cannot disagree with the shipped mark.
  LinearGradient _activeUnderlineGradient() {
    if (GeniusWalletColors.surfaceMenu.computeLuminance() <= 0.5) {
      return GeniusWalletGradient.brandCta;
    }
    final safe = GeniusWalletColors.brandPrimaryOnSurface;
    return LinearGradient(colors: [safe, safe]);
  }

  // 035-B unified omnibox toolbar (~54px): one cohesive field — back/forward
  // nested into the LEFT edge, favicon + https lock + host in the middle (or the
  // editable URL when focused), refresh at the RIGHT edge — plus a `⋯` overflow
  // affordance OUTSIDE the field. Chrome only: submit still routes through
  // _loadUrl and no navigation mechanic changed.
  Widget _buildSearchBar() {
    final includeBackButton = widget.includeBackButton ?? false;
    return Container(
      color: GeniusWalletColors.deepBlueCardColor,
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space6,
        vertical: GeniusWalletConsts.space4,
      ),
      child: Row(
        children: [
          if (includeBackButton) ...[
            InkWell(
              borderRadius:
                  BorderRadius.circular(GeniusWalletConsts.radiusXs),
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                Icons.cancel,
                size: 20,
                color: GeniusWalletColors.textPrimary60,
              ),
            ),
            const SizedBox(width: GeniusWalletConsts.space4),
          ],
          Expanded(child: _buildOmniboxField()),
          const SizedBox(width: GeniusWalletConsts.space4),
          // ponytail: `⋯` is a placeholder affordance only. This phase is a
          // chrome re-skin (D-09) — no history/bookmarks feature — so it stays
          // a no-op until a future phase gives it real menu entries.
          IconButton(
            icon: Icon(
              Icons.more_horiz,
              size: 20,
              color: GeniusWalletColors.textPrimary60,
            ),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            splashRadius: 18,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildOmniboxField() {
    final editing = _urlFocusNode.hasFocus;
    final currentUrl = _tabUrls.isNotEmpty
        ? _tabUrls[_currentTabIndex]
        : widget.url;
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: GeniusWalletColors.surfaceSunken,
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusBase),
        border: Border.all(
          color: editing
              ? GeniusWalletColors.brandPrimary
              : GeniusWalletColors.borderSubtle,
          width: editing ? 2 : 1,
        ),
        boxShadow: editing
            ? [
                BoxShadow(
                  color: GeniusWalletColors.brandPrimarySubtle,
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          _omniboxNavButton(
            icon: Icons.arrow_back,
            future: _controllers[_currentTabIndex].canGoBack(),
            onEnabled: _goBack,
          ),
          _omniboxNavButton(
            icon: Icons.arrow_forward,
            future: _controllers[_currentTabIndex].canGoForward(),
            onEnabled: _goForward,
          ),
          Expanded(child: _buildOmniboxCenter(editing, currentUrl)),
          _omniboxGhostButton(Icons.refresh, _reload),
          const SizedBox(width: GeniusWalletConsts.space2),
        ],
      ),
    );
  }

  // Back / forward driven by the real controller state (D-02): brand-tinted and
  // tappable only when canGoBack() / canGoForward() resolves true, muted and
  // inert otherwise. Same FutureBuilder pattern the old back button used.
  Widget _omniboxNavButton({
    required IconData icon,
    required Future<bool> future,
    required VoidCallback onEnabled,
  }) {
    return FutureBuilder<bool>(
      future: future,
      builder: (context, snapshot) {
        final enabled = snapshot.data ?? false;
        return IconButton(
          icon: Icon(
            icon,
            size: 18,
            color: enabled
                ? GeniusWalletColors.brandPrimaryOnSurface
                : GeniusWalletColors.textPrimary38,
          ),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          padding: EdgeInsets.zero,
          splashRadius: 18,
          onPressed: enabled ? onEnabled : null,
        );
      },
    );
  }

  Widget _omniboxGhostButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(
        icon,
        size: 18,
        color: GeniusWalletColors.textPrimary,
      ),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      padding: EdgeInsets.zero,
      splashRadius: 18,
      onPressed: onPressed,
    );
  }

  // The TextField is ALWAYS in the tree so _urlFocusNode stays attached and the
  // rest-display's tap can requestFocus() it. When not editing, an opaque cover
  // paints the favicon + https lock + host over the field; focusing lifts it.
  Widget _buildOmniboxCenter(bool editing, String currentUrl) {
    final secure = webIsSecure(currentUrl);
    final host = webDisplayHost(currentUrl);
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        TextField(
          controller: _urlController,
          focusNode: _urlFocusNode,
          style: TextStyle(color: GeniusWalletColors.textPrimary, fontSize: 14),
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
                color: GeniusWalletColors.surfaceSunken,
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
                        color: GeniusWalletColors.textPrimary60,
                        size: 16,
                      ),
                    ),
                    if (secure) ...[
                      const SizedBox(width: GeniusWalletConsts.space2),
                      Icon(
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
                          color: GeniusWalletColors.textPrimary,
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

  String _getFaviconUrl(String url) {
    Uri uri = Uri.parse(url);
    return "https://www.google.com/s2/favicons?domain=${uri.host}&sz=32";
  }
}
