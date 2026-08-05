import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
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
  // Cached per-tab page title. Kept off the render path on purpose: reading it
  // via FutureBuilder(getTitle()) inline in build re-fired on every setState
  // (e.g. a hover), flashing "Loading..." across all tabs. Updated once per
  // page load in onPageFinished instead.
  final List<String> _tabTitles = [];

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
  // editable TextField (on focus). On focus, seed the field with the FULL url;
  // EditableText then selects all of it (selectAllOnFocus defaults to true on
  // desktop), so typing replaces the address like any browser omnibox.
  void _onUrlFocusChange() {
    if (_urlFocusNode.hasFocus && _tabUrls.isNotEmpty) {
      _urlController.text = _tabUrls[_currentTabIndex];
    } else {
      // At rest the favicon+host cover IS the address display, so keep the
      // underlying field empty — otherwise its long URL text bleeds through the
      // cover as faint marks across the field (#4, 2026-07-24).
      _urlController.clear();
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
            debugPrint('[DEBUG] onPageStarted: $loadedUrl');
            _onNav(controller!, loadedUrl);
          },
          onUrlChange: (UrlChange change) {
            final u = change.url;
            if (u != null) {
              _onNav(controller!, u);
            }
          },
          onPageFinished: (String loadedUrl) async {
            debugPrint('[DEBUG] onPageFinished: $loadedUrl');
            _onNav(controller!, loadedUrl);
            unawaited(_syncTitle(controller));
            if (!Platform.isMacOS &&
                url.contains('uniswap.org') &&
                loadedUrl == 'about:blank') {
              debugPrint(
                '[DEBUG] Injecting localStorage for Uniswap (about:blank)',
              );
              await _safeRunJavaScript(controller, '''
              localStorage.setItem("interface_color_theme", "\\"Dark\\"");
              localStorage.setItem("uni-theme", "\\"dark\\"");
              document.title = "DARK MODE SET";
            ''', context: 'uniswap-about-blank-theme');
              await Future.delayed(const Duration(milliseconds: 80));
              unawaited(controller.loadRequest(Uri.parse(url)));
              return;
            }

            // Only retry ONCE if still not dark
            if (!Platform.isMacOS && loadedUrl.contains('uniswap.org')) {
              if (!retried) {
                debugPrint(
                  '[DEBUG] Uniswap loaded, attempting one retry for dark mode.',
                );
                retried = true;
                await Future.delayed(const Duration(milliseconds: 350));
                await _safeRunJavaScript(controller, '''
                if (!document.body.classList.contains('dark')) {
                  localStorage.setItem("interface_color_theme", "\\"Dark\\"");
                  localStorage.setItem("uni-theme", "\\"dark\\"");
                  window.dispatchEvent(new Event('storage'));
                  setTimeout(() => { window.location.reload(); }, 100);
                }
              ''', context: 'uniswap-retry-theme');
              } else {
                debugPrint(
                  '[DEBUG] Already retried dark mode once. Not repeating.',
                );
              }
            } else {
              debugPrint(
                '[DEBUG] Non-Uniswap or macOS, injecting generic dark mode.',
              );
              await forceDarkModeAndRemoveBanner(_currentTabIndex);
            }
          },
        ),
      );

    if (!Platform.isMacOS && url.contains('uniswap.org')) {
      debugPrint(
        '[DEBUG] Loading about:blank before Uniswap for reliable dark theme',
      );
      controller.loadRequest(Uri.parse('about:blank'));
    } else {
      controller.loadRequest(Uri.parse(url));
    }
    setState(() {
      debugPrint('[DEBUG] Add controller, set tab index');
      _controllers.add(controller!);
      _tabUrls.add(url);
      _tabTitles.add(
        url,
      ); // URL as fallback until onPageFinished sets the title
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

  // Keep the omnibox honest: the WebView itself drives the address text and the
  // back/forward enabled-state, not just our explicit _loadUrl/_addNewTab. Any
  // real navigation (link tap, goBack, goForward, redirect) fires
  // onUrlChange/onPageStarted/onPageFinished → we resync that tab's URL and
  // rebuild, so the host label and the canGoBack()/canGoForward() FutureBuilders
  // re-query instead of freezing on the last typed URL. about:blank is the
  // internal Uniswap dark-mode shim, never a real destination — skip it.
  void _onNav(WebViewController c, String url) {
    if (!mounted || url.isEmpty || url == 'about:blank') {
      return;
    }
    final i = _controllers.indexOf(c);
    if (i < 0) {
      return;
    }
    _tabUrls[i] = url;
    // NEVER rebuild while the URL bar is being edited. A background nav event
    // (pages like DuckDuckGo fire onUrlChange freely) rebuilding the focused
    // TextField mid-keystroke drops the KeyUp and trips HardwareKeyboard's
    // "physical key already pressed" assert, which silently blocks typing. The
    // host + arrows refresh on the next natural rebuild (blur / tab switch).
    if (_urlFocusNode.hasFocus) {
      return;
    }
    setState(() {});
  }

  // Refresh a tab's cached title once its page has loaded (title is only ready
  // at onPageFinished). Setting it here keeps getTitle() OFF the build path.
  Future<void> _syncTitle(WebViewController c) async {
    final t = await c.getTitle();
    if (!mounted) {
      return;
    }
    final i = _controllers.indexOf(c);
    if (i < 0 || i >= _tabTitles.length) {
      return;
    }
    final title = (t == null || t.trim().isEmpty) ? _tabUrls[i] : t;
    if (_tabTitles[i] == title) {
      return;
    }
    _tabTitles[i] = title;
    // Same rule as _onNav: don't rebuild the focused TextField mid-keystroke.
    if (_urlFocusNode.hasFocus) {
      return;
    }
    setState(() {});
  }

  void _loadUrl() {
    String input = _urlController.text.trim();
    if (input.isEmpty) {
      return;
    }
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
    // Closing the ONLY tab resets it to a fresh home tab (kWebHomeUrl) rather than
    // leaving the browser with zero tabs. ponytail: this is a reset, not an
    // "exit browser" — swap in Navigator.pop() here if a real exit is ever wanted.
    if (_controllers.length == 1) {
      _addNewTab(kWebHomeUrl);
      setState(() {
        _controllers.removeAt(index);
        _tabUrls.removeAt(index);
        _tabTitles.removeAt(index);
        _currentTabIndex = 0;
      });
      return;
    }
    setState(() {
      _controllers.removeAt(index);
      _tabUrls.removeAt(index);
      _tabTitles.removeAt(index);
      _currentTabIndex = _currentTabIndex > 0 ? _currentTabIndex - 1 : 0;
    });
  }

  void _switchTab(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  Widget _buildWebView(int index) {
    return WebViewWidget(controller: _controllers[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.gw.deepBlueTertiary,
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
  // home tab (kWebHomeUrl). Tab mechanics (_switchTab / _closeTab / _addNewTab) verbatim.
  // Tab currently under the mouse — drives the hover-only close affordance.
  int? _hoveredTabIndex;

  Widget _buildTabStrip() {
    return Container(
      height: 46,
      color: context.gw.deepBlueCardColor,
      // space6 matches the omnibox bar below so the first tab's left edge lines
      // up with the omnibox field's left edge.
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space6,
      ),
      // Brave-style: tabs scroll left-aligned and the "+" rides as the LAST list
      // item, right after the final tab (not pinned to the far edge), fronted by a
      // light vertical separator. Overflow still scrolls horizontally.
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _controllers.length + 1,
        separatorBuilder: (_, _) =>
            const SizedBox(width: GeniusWalletConsts.space2),
        itemBuilder: (context, index) {
          if (index == _controllers.length) {
            return Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 1,
                    height: 20,
                    color: context.gw.borderSubtle,
                  ),
                  const SizedBox(width: GeniusWalletConsts.space2),
                  IconButton(
                    icon: Icon(
                      Icons.add,
                      size: 20,
                      color: context.gw.textPrimary,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                    splashRadius: 18,
                    tooltip: 'New tab',
                    onPressed: () => _addNewTab(kWebHomeUrl),
                  ),
                ],
              ),
            );
          }
          return _buildTabChip(index);
        },
      ),
    );
  }

  Widget _buildTabChip(int index) {
    final active = index == _currentTabIndex;
    final hovered = index == _hoveredTabIndex;
    final labelColor = active
        ? context.gw.textPrimary
        : context.gw.textPrimary60;
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredTabIndex = index),
      onExit: (_) => setState(() {
        if (_hoveredTabIndex == index) {
          _hoveredTabIndex = null;
        }
      }),
      child: GestureDetector(
        onTap: () => _switchTab(index),
        child: Container(
          width: 168,
          height: 30,
          // FIXED width pins the close-× to the right edge. height 30 + 8+8 vertical
          // margin = 46 (the strip height), so the chip is centered by CONSTRUCTION
          // regardless of how the ListView constrains item cross-axis height.
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? context.gw.surfaceElevated : Colors.transparent,
            borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
            border: Border.all(
              color: active ? Colors.transparent : context.gw.borderSubtle,
            ),
          ),
          // Stack: content vertically centered in the band; the active underline
          // is OVERLAID at the bottom edge so it never pushes the content upward.
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: GeniusWalletConsts.space4,
                ),
                child: Row(
                  children: [
                    Image.network(
                      _getFaviconUrl(_tabUrls[index]),
                      width: 19,
                      height: 19,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.language, color: labelColor, size: 19),
                    ),
                    const SizedBox(width: GeniusWalletConsts.space2),
                    Expanded(
                      child: Text(
                        _tabTitles[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: labelColor,
                          fontSize: 16,
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    // Close (D-06): hover-only, pinned to the chip's RIGHT edge
                    // (Expanded title pushes it there); lights up as the target.
                    if (hovered) ...[
                      const SizedBox(width: GeniusWalletConsts.space2),
                      InkWell(
                        borderRadius: BorderRadius.circular(
                          GeniusWalletConsts.radiusXs,
                        ),
                        onTap: () => _closeTab(index),
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: context.gw.surfaceElevated,
                            borderRadius: BorderRadius.circular(
                              GeniusWalletConsts.radiusXs,
                            ),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 17,
                            color: context.gw.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Active mark (D-05): 2px brandCta gradient underline overlaid on
              // the bottom edge.
              if (active)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: _activeUnderlineGradient(),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(
                          GeniusWalletConsts.radiusMd,
                        ),
                        bottomRight: Radius.circular(
                          GeniusWalletConsts.radiusMd,
                        ),
                      ),
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
    if (context.gw.surfaceMenu.computeLuminance() <= 0.5) {
      return GeniusWalletGradient.brandCta;
    }
    final safe = context.gw.brandPrimaryOnSurface;
    return LinearGradient(colors: [safe, safe]);
  }

  // 035-B unified omnibox toolbar (~54px): one cohesive field — back/forward
  // nested into the LEFT edge, favicon + https lock + host in the middle (or the
  // editable URL when focused), refresh at the RIGHT edge. Chrome only: submit
  // still routes through _loadUrl and no navigation mechanic changed.
  Widget _buildSearchBar() {
    return Container(
      color: context.gw.deepBlueCardColor,
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space6,
        vertical: GeniusWalletConsts.space4,
      ),
      child: _buildOmniboxField(),
    );
  }

  Widget _buildOmniboxField() {
    final editing = _urlFocusNode.hasFocus;
    final currentUrl = _tabUrls.isNotEmpty
        ? _tabUrls[_currentTabIndex]
        : widget.url;
    return Container(
      height: 40,
      // The outer field stays neutral on focus — only the inner text area lights
      // up (see _buildOmniboxCenter). Jakub: highlight the inner, not the bar.
      decoration: BoxDecoration(
        color: context.gw.surfaceSunken,
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusBase),
        border: Border.all(color: context.gw.borderSubtle, width: 1),
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
                ? context.gw.brandPrimaryOnSurface
                : context.gw.textPrimary38,
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
      icon: Icon(icon, size: 18, color: context.gw.textPrimary),
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
    return Container(
      // Focus highlight lives HERE — the inner text area — not on the whole bar
      // (Jakub: highlight the inner, not the outer bar).
      //
      // The decoration is ALWAYS non-null — only its border colour changes. A
      // null decoration makes Container skip its DecoratedBox entirely, so
      // toggling it would change the tree's SHAPE on focus: the Stack below
      // would be matched against a DecoratedBox, forcing Flutter to unmount and
      // rebuild the whole subtree. That disposed the freshly-focused
      // EditableText and closed its text-input connection one frame after
      // _handleFocusChanged had consumed the focus node's single keyboard
      // token — leaving a focused field that could not be typed into until it
      // was blurred and re-focused (macOS routes ALL text editing, arrows
      // included, through that connection, so every key came back unhandled
      // and AppKit beeped). Keep this decoration unconditional.
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusSm),
        border: Border.all(
          color: editing ? context.gw.brandPrimary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // The field is kept EMPTY at rest (cleared on blur in _onUrlFocusChange),
          // so there is nothing to bleed through the host cover (#4) — no Opacity
          // wrapper, which on macOS interfered with the text-input connection.
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
                        Icon(
                          Icons.lock,
                          color: context.gw.statusSuccess,
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
      ),
    );
  }

  String _getFaviconUrl(String url) {
    final Uri uri = Uri.parse(url);
    return "https://www.google.com/s2/favicons?domain=${uri.host}&sz=32";
  }
}
