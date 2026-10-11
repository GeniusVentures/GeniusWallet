# Linux web view: wallet integration

## Requirements

From idea `linux-inapp-webview`:

- One Linux bundle for every distro: no build-time WebKit link; load libwebkit2gtk-4.1, else 4.0,
  at runtime; no WebKit means the app still runs and links open in the system browser.
- Call isAvailable() before creating a web view; fall back to url_launcher and say so.
- Route every external link through launchWebSite (9 call sites today, incl. Privacy Policy/Terms,
  news, explorer links); Banxa's checkout fallback and support link stay deliberate exceptions.
- Nothing may draw over a web view and no rounded clip/transform may sit above one: hide the view
  while an overlay/route is above it.
- Plugin must hand keyboard focus back to Flutter.
- CI image needs webkit2gtk3-devel (headers only).

## How to Build It

Reference implementation: `sources/005-wallet-surfaces-in-app/wallet-changes.diff` (against develop
`8cf5ddc7`). The plugin itself is covered in `linux-webview-plugin.md`.

1. **Dependency.** Vendor three packages as path deps: `webview_all` (pure Dart, plugin map stripped),
   `webview_all_linux`, `webview_platform_interface`. Nothing is added to other platforms.
   `webview_all`'s `WebViewController`, `NavigationDelegate`, `WebViewWidget` and permission request
   mirror `webview_flutter`, so Linux variants are the mobile files with one import changed.
2. **Probe once at startup** in `lib/web/web_utils.dart`, awaited in `main()` right after
   `WidgetsFlutterBinding.ensureInitialized()`, before the router and nav lists are built:

   ```dart
   bool linuxInAppWeb = false;

   Future<void> probeLinuxInAppWeb() async {
     if (!Platform.isLinux) {
       return;
     }
     try {
       linuxInAppWeb = await LinuxWebViewPlatform.isAvailable();
     } catch (_) {
       linuxInAppWeb = false;
     }
   }
   ```
   The probe pays the WebKit `dlopen` at launch; measure it or probe lazily.
3. **One entry point for external links.** `launchWebSite(context, url)` pushes `/web` when
   `linuxInAppWeb` is true, else `launchUrl`. Every caller goes through it. Call sites at develop
   `8cf5ddc7` (git grep, `lib/`):
   - `lib/onboarding/existing_wallet/view/legal_screen.dart` - Privacy Policy, Terms (2)
   - `lib/dashboard/news/view/crypto_news_screen.dart` - article cards (4)
   - `lib/dashboard/home/widgets/transaction_displays.dart` - explorer / recovery links (2)
   - `lib/reown/swap_result_drawer.dart` - explorer link (1)
   - `lib/web/web_utils.dart` - the definition itself

   That is 9 calls plus the definition (one more reference in
   `test/dashboard/transaction_recovery_states_test.dart`). The idea's "9 call sites" figure came
   from the session; re-count at build time.
4. **Two deliberate `launchUrl` exceptions** stay direct, not through `launchWebSite`:
   - `lib/banxa/checkout/checkout_screen.dart` - external fallback when there is no WebKit
     ("Finish paying in your browser").
   - `lib/banxa/banxa_components/order_drawer_footer.dart` - Banxa support link, always external.
5. **Web tab.** `nav_destinations.dart`: `visible: !Platform.isLinux || linuxInAppWeb`; register
   the `/web` route on Linux only when true.
6. **Checkout.** `checkoutHostKind('linux', linuxWebView: linuxInAppWeb)` returns a new
   `CheckoutHostKind.linux`, rendered by `CheckoutWebViewLinux` with the same allow-list, return-URL
   match and camera/mic-only-on-Banxa permission policy as mobile. `_CheckoutFrame` must not clip
   on Linux (`Clip.none`).
7. **Must also ship** (found broken in the walk):
   - Focus hand-back: plugin grabs focus back to `FlView` on a click outside the hole, or Dart
     calls a `releaseFocus` method when a Flutter field gains focus. Without it the omnibox is unusable.
   - An overlay/route hook (`RouteAware` or overlay count) that sets the view `visible:false`
     while a drawer, menu, dialog or toast is above it.
   - Keep the view hidden until the first `onPageFinished` so the loading indicator shows.
   - Articles and legal pages as a back-able full-screen route outside the shell, honouring
     `includeBackButton` (legal-in-onboarding has no way back on any platform today).
   - Fallback copy that says why: "Install WebKitGTK to pay inside GeniusWallet".
   - Re-read the tab title on `onUrlChange`.
8. **Clean-up before merge.** Drop the spike-only `GW_SPIKE_CHECKOUT_URL` hook. One source for the
   checkout permission rule (it takes `webview_flutter` types; the Linux copy duplicates it, marked
   `ponytail:`). Deduplicate `web_view_linux.dart` (a 760-line copy of the mobile browser) by passing
   the controller type in.

## What to Avoid

- **Rounded `Material` / `ClipRRect` above a web view.** The checkout dialog's `Clip.antiAlias`
  rounded shape hid the whole view (empty dialog).
- **Drawers, menus, scrims, toasts and the swap FAB over a page.** They are cut by the page and
  scrims do not dim it.
- **Opening articles as the shell `/web` tab.** The nav highlight jumps to Web, and going back to
  News loses the article.
- **`rsync --exclude banxa` unanchored.** It also drops `lib/banxa`; anchor as `/banxa`.
- **Setting the compiler only in `CMAKE_ARGUMENTS`.** `linux/CMakeLists.txt` applies those after
  `project()`, so sentry-native's libunwind `.S` files go to gcc and fail on `-gline-tables-only`.
  Export `CC`, `CXX`, `ASM` as clang in the environment.
- **Judging the Banxa embed by a replayed order URL.** A stale sandbox order ends blank in any
  WebKit (control-proved on 2.38 and 2.52). A fresh order needs the keyed CI build.

## Constraints

- Build: AlmaLinux 8 CI image + `webkit2gtk3-devel`, `-DGENIUS_DEPENDENCY_BRANCH=develop` (no token),
  clean release build 52-87 s with cached deps. Bundle 202 MB, plugin `.so` 160 KB with line tables.
  `readelf -d genius_wallet` has no WebKit `NEEDED`.
- With no WebKit (`nowebkit.c` LD_PRELOAD): app starts, Web tab hidden, News and checkout go to the
  browser. `dlerror()` names only the last candidate tried; cosmetic.
- Static checks on the spike's changed files were clean (`dart format`, scoped `flutter analyze`,
  `checkout_rules_test.dart` 48/48, `tool/check_brace_style.sh`). Full suite not run.
- Not walked: the Banxa email screen with a fresh sandbox order.

## Origin

Synthesized from spikes: 005 (plus session facts on `launchWebSite` routing)
Source files available in: sources/005-wallet-surfaces-in-app/
