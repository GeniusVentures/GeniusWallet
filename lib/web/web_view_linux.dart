import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:genius_wallet/web/web_chrome_helpers.dart';
import 'package:genius_wallet/web/web_overlay_gate.dart';
import 'package:webview_all/webview_all.dart';
import 'package:webview_all_linux/webview_all_linux.dart';

/// The mobile browser's chrome over the vendored WebKitGTK controller.
/// ponytail: two copies of the mobile browser can drift; share the body once a
/// third controller type appears or the copies diverge.
class WebViewLinux extends StatefulWidget {
  final String url;
  final bool? includeBackButton;

  const WebViewLinux({
    super.key,
    required this.url,
    this.includeBackButton = false,
  });

  @override
  WebViewLinuxState createState() => WebViewLinuxState();
}

class WebViewLinuxState extends State<WebViewLinux> {
  final List<WebViewController> _controllers = [];
  final List<String> _tabUrls = [];
  // Titles are cached because reading one inside build re-fired on every
  // rebuild and flashed "Loading..." across all tabs; onPageFinished updates it.
  final List<String> _tabTitles = [];
  // Tabs whose main-frame load failed. The native page cannot show a Flutter
  // message, so these hide it and show the retry panel instead.
  final Set<WebViewController> _failedTabs = {};

  int _currentTabIndex = 0;
  // Own notifier so a hover repaints one chip, not the whole screen.
  final ValueNotifier<int?> _hoveredTab = ValueNotifier<int?>(null);

  final TextEditingController _urlController = TextEditingController();
  final FocusNode _urlFocusNode = FocusNode();

  // WebKitGTK 2.40 and later fail a script whose result is a Promise, so such a
  // script must end by returning undefined.
  Future<bool> _safeRunJavaScript(
    WebViewController controller,
    String script, {
    required String context,
  }) async {
    try {
      await controller.runJavaScript(script);
      return true;
    } on PlatformException catch (e) {
      // The page can reject script evaluation while a navigation is in flight.
      debugPrint('JS eval failed ($context): ${e.message ?? e.code}');
      return false;
    } catch (e) {
      debugPrint('JS eval failed ($context): $e');
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _addNewTab(widget.url);
    _urlFocusNode.addListener(_onUrlFocusChange);
  }

  // Each controller owns a native WebKitWebView; a GC finalizer is the only
  // other thing that would free it. Disposing a view whose native side never
  // opened throws, and there is nobody left to tell.
  void _disposeController(WebViewController c) {
    final platform = c.platform;
    if (platform is LinuxWebViewController) {
      unawaited(
        platform.dispose().catchError(
          (Object e) => debugPrint('Web view dispose failed: $e'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controllers.forEach(_disposeController);
    _urlFocusNode.removeListener(_onUrlFocusChange);
    _urlFocusNode.dispose();
    _urlController.dispose();
    _hoveredTab.dispose();
    super.dispose();
  }

  // The omnibox shows a static favicon, lock and host at rest and the editable
  // field on focus. Focus seeds the field with the full URL, which the field
  // selects whole, so typing replaces the address like any browser.
  void _onUrlFocusChange() {
    if (_urlFocusNode.hasFocus && _tabUrls.isNotEmpty) {
      _urlController.text = _tabUrls[_currentTabIndex];
    } else {
      // The host display covers the field at rest; an empty field keeps its
      // long URL from bleeding through the cover.
      _urlController.clear();
    }
    setState(() {});
  }

  void _reload() {
    final controller = _controllers[_currentTabIndex];
    unawaited(controller.reload().catchError((_) => _markFailed(controller)));
  }

  // The native view is created on first use and can fail to open.
  void _load(WebViewController controller, Uri uri) {
    unawaited(
      controller.loadRequest(uri).catchError((_) => _markFailed(controller)),
    );
  }

  void _markFailed(WebViewController controller) {
    if (!mounted || !_controllers.contains(controller)) {
      return;
    }
    setState(() => _failedTabs.add(controller));
  }

  void _clearFailed(WebViewController controller) {
    if (mounted && _failedTabs.remove(controller)) {
      setState(() {});
    }
  }

  Future<void> forceDarkModeAndRemoveBanner(
    WebViewController controller,
  ) async {
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
    if (!_controllers.contains(controller)) {
      return;
    }
    await _safeRunJavaScript(
      controller,
      js,
      context: 'forceDarkModeAndRemoveBanner',
    );
  }

  void _addNewTab(String url) {
    WebViewController? controller;
    bool retried = false;

    controller = WebViewController();
    // Creating the native view can fail; that shows the retry panel rather
    // than an uncaught error.
    final setup = Future.wait([
      controller.setJavaScriptMode(JavaScriptMode.unrestricted),
      controller.setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String loadedUrl) {
            _clearFailed(controller!);
            _onNav(controller, loadedUrl);
          },
          onUrlChange: (UrlChange change) {
            final u = change.url;
            if (u != null) {
              _onNav(controller!, u);
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (error.isForMainFrame ?? false) {
              _markFailed(controller!);
            }
          },
          onPageFinished: (String loadedUrl) async {
            _onNav(controller!, loadedUrl);
            unawaited(_syncTitle(controller));
            // Uniswap reads its theme from localStorage, which needs a
            // same-origin page, so it is seeded from about:blank and reloaded.
            if (url.contains('uniswap.org') && loadedUrl == 'about:blank') {
              await _safeRunJavaScript(controller, '''
              localStorage.setItem("interface_color_theme", "\\"Dark\\"");
              localStorage.setItem("uni-theme", "\\"dark\\"");
              document.title = "DARK MODE SET";
            ''', context: 'uniswap-about-blank-theme');
              await Future.delayed(const Duration(milliseconds: 80));
              _load(controller, Uri.parse(url));
              return;
            }

            if (loadedUrl.contains('uniswap.org')) {
              // Retry once if the page is still not dark.
              if (!retried) {
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
              }
            } else {
              await forceDarkModeAndRemoveBanner(controller);
            }
          },
        ),
      ),
    ]);
    unawaited(
      setup.then<void>((_) {}).catchError((Object e) {
        debugPrint('WebViewLinux: setup failed: $e');
        _markFailed(controller!);
      }),
    );

    if (url.contains('uniswap.org')) {
      _load(controller, Uri.parse('about:blank'));
    } else {
      _load(controller, Uri.parse(url));
    }
    setState(() {
      _controllers.add(controller!);
      _tabUrls.add(url);
      _tabTitles.add(
        url,
      ); // URL as fallback until onPageFinished sets the title
      _currentTabIndex = _controllers.length - 1;
    });
  }

  // The tab can change while canGoBack is awaited, so both calls use the
  // controller taken before the first await. Closing that tab meanwhile
  // disposes it, so a failure there is dropped rather than left uncaught.
  void _goBack() async {
    final controller = _controllers[_currentTabIndex];
    try {
      if (await controller.canGoBack()) {
        await controller.goBack();
      }
    } catch (e) {
      debugPrint('WebViewLinux: back failed: $e');
    }
  }

  void _goForward() async {
    final controller = _controllers[_currentTabIndex];
    try {
      if (await controller.canGoForward()) {
        await controller.goForward();
      }
    } catch (e) {
      debugPrint('WebViewLinux: forward failed: $e');
    }
  }

  // The page drives the address text and the back/forward state, not only our
  // own _loadUrl and _addNewTab, so link taps, redirects and history moves
  // resync the tab. about:blank is the Uniswap theme shim, never a destination.
  void _onNav(WebViewController c, String url) {
    if (!mounted || url.isEmpty || url == 'about:blank') {
      return;
    }
    final i = _controllers.indexOf(c);
    if (i < 0) {
      return;
    }
    _tabUrls[i] = url;
    // Never rebuild while the URL bar is being edited: a background nav event
    // rebuilding the focused field mid-keystroke drops the key-up and trips
    // HardwareKeyboard's "already pressed" assert, which blocks typing. The host
    // and arrows refresh on the next rebuild.
    if (_urlFocusNode.hasFocus) {
      return;
    }
    setState(() {});
  }

  // A page's title is only ready at onPageFinished, so it is cached here
  // instead of being read during build.
  Future<void> _syncTitle(WebViewController c) async {
    String? t;
    try {
      t = await c.getTitle();
    } catch (e) {
      // The tab can be closed, and its controller disposed, while this waits.
      debugPrint('Title read failed: $e');
      return;
    }
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
    // Same rule as _onNav: don't rebuild the focused field mid-keystroke.
    if (_urlFocusNode.hasFocus) {
      return;
    }
    setState(() {});
  }

  void _loadUrl() {
    final target = omniboxTarget(_urlController.text);
    if (target == null) {
      return;
    }
    _load(_controllers[_currentTabIndex], target);
    setState(() {
      _tabUrls[_currentTabIndex] = target.toString();
    });
  }

  void _closeTab(int index) {
    // The address field would otherwise keep the closed tab's URL.
    _urlFocusNode.unfocus();
    _disposeController(_controllers[index]);
    _failedTabs.remove(_controllers[index]);
    // Closing the only tab resets it to a fresh home tab rather than leaving
    // the browser with none. ponytail: swap in Navigator.pop() here if a real
    // exit is ever wanted.
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
      _currentTabIndex = tabIndexAfterClose(
        active: _currentTabIndex,
        closed: index,
        newLength: _controllers.length,
      );
    });
  }

  // Leaving the omnibox on a tab switch makes the focus listener drop the old
  // tab's address, so Enter cannot load it into the new tab.
  void _switchTab(int index) {
    _urlFocusNode.unfocus();
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controllers[_currentTabIndex];
    final failed = _failedTabs.contains(controller);
    final currentUrl = _tabUrls[_currentTabIndex];
    return Scaffold(
      backgroundColor: context.gw.deepBlueTertiary,
      body: SafeArea(
        child: Column(
          children: [
            _TabStrip(
              urls: _tabUrls,
              titles: _tabTitles,
              currentIndex: _currentTabIndex,
              hovered: _hoveredTab,
              onSwitch: _switchTab,
              onClose: _closeTab,
              onAdd: () => _addNewTab(kWebHomeUrl),
            ),
            _SearchBar(
              showClose: widget.includeBackButton ?? false,
              currentUrl: currentUrl,
              editing: _urlFocusNode.hasFocus,
              canGoBack: controller.canGoBack(),
              canGoForward: controller.canGoForward(),
              urlController: _urlController,
              urlFocusNode: _urlFocusNode,
              onBack: _goBack,
              onForward: _goForward,
              onReload: _reload,
              onSubmit: () {
                _loadUrl();
                _urlFocusNode.unfocus();
              },
            ),
            Expanded(
              child: Stack(
                children: [
                  WebOverlayGate(
                    hidden: failed,
                    child: WebViewWidget(controller: controller),
                  ),
                  if (failed)
                    _LoadFailed(
                      onRetry: () => _load(controller, Uri.parse(currentUrl)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Always-visible horizontal tab strip. The `+` rides as the last list item,
/// after the final tab; overflow scrolls.
class _TabStrip extends StatelessWidget {
  const _TabStrip({
    required this.urls,
    required this.titles,
    required this.currentIndex,
    required this.hovered,
    required this.onSwitch,
    required this.onClose,
    required this.onAdd,
  });

  final List<String> urls;
  final List<String> titles;
  final int currentIndex;
  final ValueNotifier<int?> hovered;
  final ValueChanged<int> onSwitch;
  final ValueChanged<int> onClose;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      color: context.gw.deepBlueCardColor,
      // Matches the omnibox bar below so the first tab lines up with the field.
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space6,
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length + 1,
        separatorBuilder: (_, _) =>
            const SizedBox(width: GeniusWalletConsts.space2),
        itemBuilder: (context, index) {
          if (index == urls.length) {
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
                      color: context.gw.textOnDarkChrome,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                    splashRadius: 18,
                    tooltip: 'New tab',
                    onPressed: onAdd,
                  ),
                ],
              ),
            );
          }
          return _TabChip(
            index: index,
            url: urls[index],
            title: titles[index],
            active: index == currentIndex,
            hovered: hovered,
            onSwitch: onSwitch,
            onClose: onClose,
          );
        },
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.index,
    required this.url,
    required this.title,
    required this.active,
    required this.hovered,
    required this.onSwitch,
    required this.onClose,
  });

  final int index;
  final String url;
  final String title;
  final bool active;
  final ValueNotifier<int?> hovered;
  final ValueChanged<int> onSwitch;
  final ValueChanged<int> onClose;

  @override
  Widget build(BuildContext context) {
    // The inactive chip has no fill of its own, so it reads the navy strip.
    final labelColor = active ? context.gw.textPrimary : context.gw.gray500;
    return MouseRegion(
      onEnter: (_) => hovered.value = index,
      onExit: (_) {
        if (hovered.value == index) {
          hovered.value = null;
        }
      },
      child: GestureDetector(
        onTap: () => onSwitch(index),
        child: Container(
          width: 168,
          height: 30,
          // A fixed width pins the close button to the right edge; 30 plus the
          // 8+8 margin is the strip height, so the chip is centred by
          // construction.
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? context.gw.surfaceElevated : null,
            borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
            border: Border.all(
              color: context.gw.borderSubtle.withAlpha(active ? 0 : 255),
            ),
          ),
          // The active underline is overlaid so it never pushes the content up.
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
                      _faviconUrl(url),
                      width: 19,
                      height: 19,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.language, color: labelColor, size: 19),
                    ),
                    const SizedBox(width: GeniusWalletConsts.space2),
                    Expanded(
                      child: Text(
                        title,
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
                    ValueListenableBuilder<int?>(
                      valueListenable: hovered,
                      builder: (context, hoveredIndex, _) {
                        if (hoveredIndex != index) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(
                            left: GeniusWalletConsts.space2,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              GeniusWalletConsts.radiusXs,
                            ),
                            onTap: () => onClose(index),
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
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (active)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: _activeUnderlineGradient(context),
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
}

// Dark keeps the brand gradient. On the light canvas its stops fall below the
// 3:1 non-text contrast minimum (#0AAEE6 is 2.56:1 on white), so light uses the
// flat, light-safe brand colour, as the transactions tab underline does.
LinearGradient _activeUnderlineGradient(BuildContext context) {
  if (context.gw.surfaceMenu.computeLuminance() <= 0.5) {
    return GeniusWalletGradient.brandCta;
  }
  final safe = context.gw.brandPrimaryOnSurface;
  return LinearGradient(colors: [safe, safe]);
}

String _faviconUrl(String url) {
  final Uri uri = Uri.parse(url);
  return "https://www.google.com/s2/favicons?domain=${uri.host}&sz=32";
}

/// The toolbar: back and forward at the left edge, favicon, lock and host in
/// the middle (the editable URL when focused), refresh at the right edge.
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.showClose,
    required this.currentUrl,
    required this.editing,
    required this.canGoBack,
    required this.canGoForward,
    required this.urlController,
    required this.urlFocusNode,
    required this.onBack,
    required this.onForward,
    required this.onReload,
    required this.onSubmit,
  });

  final bool showClose;
  final String currentUrl;
  final bool editing;
  final Future<bool> canGoBack;
  final Future<bool> canGoForward;
  final TextEditingController urlController;
  final FocusNode urlFocusNode;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback onReload;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final field = Container(
      height: 40,
      // The outer field stays neutral on focus; only the inner text area lights.
      decoration: BoxDecoration(
        color: context.gw.surfaceWell,
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusBase),
        border: Border.all(color: context.gw.borderSubtle, width: 1),
      ),
      child: Row(
        children: [
          _NavButton(
            icon: Icons.arrow_back,
            future: canGoBack,
            onEnabled: onBack,
          ),
          _NavButton(
            icon: Icons.arrow_forward,
            future: canGoForward,
            onEnabled: onForward,
          ),
          Expanded(
            child: _OmniboxCenter(
              editing: editing,
              currentUrl: currentUrl,
              controller: urlController,
              focusNode: urlFocusNode,
              onSubmit: onSubmit,
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, size: 18, color: context.gw.textPrimary),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            splashRadius: 18,
            onPressed: onReload,
          ),
          const SizedBox(width: GeniusWalletConsts.space2),
        ],
      ),
    );
    return Container(
      color: context.gw.deepBlueCardColor,
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space6,
        vertical: GeniusWalletConsts.space4,
      ),
      child: showClose
          ? Row(
              children: [
                const WebPageCloseButton(),
                const SizedBox(width: GeniusWalletConsts.space4),
                Expanded(child: field),
              ],
            )
          : field,
    );
  }
}

// Brand-tinted and tappable only when the controller says the move is
// possible, muted and inert otherwise.
class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.future,
    required this.onEnabled,
  });

  final IconData icon;
  final Future<bool> future;
  final VoidCallback onEnabled;

  @override
  Widget build(BuildContext context) {
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
}

// The TextField stays in the tree so its focus node stays attached and a tap on
// the cover can focus it. At rest an opaque cover paints the favicon, lock and
// host over it; focusing lifts the cover.
class _OmniboxCenter extends StatelessWidget {
  const _OmniboxCenter({
    required this.editing,
    required this.currentUrl,
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
  });

  final bool editing;
  final String currentUrl;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final secure = webIsSecure(currentUrl);
    final host = webDisplayHost(currentUrl);
    return Container(
      // The decoration must never be null: Container then drops its DecoratedBox
      // and focus changes the tree's shape, which remounts the focused field and
      // leaves it unable to take input until it is re-focused.
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusSm),
        border: Border.all(
          color: context.gw.brandPrimary.withAlpha(editing ? 255 : 0),
          width: 1.5,
        ),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          TextField(
            controller: controller,
            focusNode: focusNode,
            style: TextStyle(color: context.gw.textPrimary, fontSize: 14),
            textAlignVertical: TextAlignVertical.center,
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 4),
            ),
            onSubmitted: (_) => onSubmit(),
          ),
          if (!editing)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: focusNode.requestFocus,
                child: Container(
                  color: context.gw.surfaceWell,
                  padding: const EdgeInsets.symmetric(
                    horizontal: GeniusWalletConsts.space2,
                  ),
                  child: Row(
                    children: [
                      Image.network(
                        _faviconUrl(currentUrl),
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
}

/// Sits on the navy scaffold, which stays dark in light mode too.
class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "This page didn't load",
            style: TextStyle(
              color: context.gw.textOnDarkChrome,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: GeniusWalletConsts.space2),
          Text(
            'Check the address and your connection, then try again.',
            style: TextStyle(color: context.gw.gray500, fontSize: 14),
          ),
          const SizedBox(height: GeniusWalletConsts.space6),
          // Tertiary carries its own fill; the secondary outline's light-mode
          // blue is only 3.2:1 on this navy.
          GWButton(
            variant: GWButtonVariant.tertiary,
            label: 'Try again',
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

/// Leaves a page that was opened from a link, back to the screen that opened it.
/// It sits on the omnibox's own fill because the bar behind it is dark in both modes.
class WebPageCloseButton extends StatelessWidget {
  const WebPageCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: context.gw.surfaceWell,
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusBase),
        border: Border.all(color: context.gw.borderSubtle, width: 1),
      ),
      child: GWButton.icon(
        icon: Icon(Icons.cancel, size: 20, color: context.gw.textPrimary),
        tooltip: 'Close',
        semanticLabel: 'Close',
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}
