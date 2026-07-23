# Redesign forward-port — regression audit (2026-07-15)

Total 37 findings vs origin/develop. 24-agent line-by-line audit.

## [1] BLOCKER · known · routing — `lib/banxa/user_kyc/kyc_registration.dart:47`
Banxa KYC completion redirect URL replaced with the literal placeholder 'your.redirect.url', so the completion deep-link is never matched and the screen never pops.
- **develop:** origin/develop line 60: `if (request.url.contains(BanxaApiService.redirectUrl))` then `Navigator.pop(context, true)` — matches the real deep link 'geniuswallet://banxa/callback' (BanxaApiService.redirectUrl still exists in banxa_api_services.dart line 17) to detect KYC completion and return true to the caller.
- **HEAD:** HEAD line 47: `if (request.url.contains('your.redirect.url'))` — a placeholder string that never matches the real callback URL, so Navigator.pop(context, true) is unreachable; after finishing KYC the user is stranded on the webview and the caller never receives the success result.
- **fix:** Restore `BanxaApiService.redirectUrl` in the navigationRequest check: `if (request.url.contains(BanxaApiService.redirectUrl))`, keeping the redesign skin unchanged.

## [2] BLOCKER · known · dropped-behavior — `lib/main.dart:140`
Startup wallet hydration call geniusApi.loadStoredWallets() was dropped from main().
- **develop:** origin/develop lib/main.dart:112 calls `await geniusApi.loadStoredWallets();` before the getWallets().first empty-check, populating stored wallets at boot.
- **HEAD:** HEAD lib/main.dart:~138-140 removed the call; a comment claims 'SDK initialization moved to AppBloc' but the getWallets().first check at line 140 now runs without prior loadStoredWallets(), so stored wallets may not be hydrated at startup.
- **fix:** Re-add `await geniusApi.loadStoredWallets();` before the `(await geniusApi.getWallets().first).isEmpty` check in main()'s appRunner, or verify AppBloc truly performs the equivalent load before any consumer reads wallets; keep the redesign untouched.

## [3] BLOCKER · known · lifecycle — `lib/reown/reown_connect_button.dart:193`
maybeInitWalletKit replaced develop's idempotent Completer-based init guard with an x86/x64 architecture skip based on Platform.version, which prevents WalletKit from ever initializing on x64 desktop/macOS builds.
- **develop:** origin/develop reown_connect_button.dart lines 188-206: maybeInitWalletKit uses `if (_isInitialized) return;` + `_initCompleter` (Completer<void>) to guarantee a single, idempotent, concurrency-safe init that ALWAYS calls WalletKitInstance().initOnce() regardless of CPU arch, and sets `_isInitialized = true` on success.
- **HEAD:** HEAD lines 192-210: `final arch = Platform.version.toLowerCase();` then `if ((arch.contains('x86') || arch.contains('x64') || arch.contains('ia32')) && !arch.contains('windows')) { debugPrint('Skipping WalletKit init...'); return; }`. Platform.version is the Dart SDK version string (e.g. `... on "linux_x64"` / `"macos_x64"`), so on any non-Windows x64 desktop it matches 'x64' and returns early WIT
- **fix:** Restore develop's `_isInitialized`/`_initCompleter` idempotent init guard (re-add the `bool _isInitialized` field and `Completer<void>? _initCompleter`, and `import 'dart:async'`). If an emulator arch skip is genuinely needed, gate it on a real ABI signal (e.g. package_info/native channel or `Platform.operatingSystem` + a proper arch plugin), not `Platform.version`, and do not skip on real x64 des

## [4] HIGH · known · dropped-behavior — `lib/account/account_dropdown_selector.dart:139`
Wallet 'Rename' action dropped from the account drawer row
- **develop:** origin/develop had `_confirmRenameWallet(context, wallet)` plus a `MenuAnchor` trailing menu with a 'Rename' MenuItemButton (develop lines ~66-100 and the trailing MenuAnchor in `_buildDrawerRow`), letting users rename a non-sgnus wallet via a dialog that dispatched `RenameWallet(wallet.address, newName)` and updated `selectedWallet` locally.
- **HEAD:** HEAD `_buildDrawerRow` (line 139) replaced the trailing `MenuAnchor` with only a Copy IconButton; `_confirmRenameWallet` and the Rename menu item are entirely removed, so users can no longer rename wallets.
- **fix:** Re-add `_confirmRenameWallet` and expose it from the redesigned row (e.g. a styled trailing menu/overflow button or long-press) so `AppBloc.add(RenameWallet(...))` and the local `selectedWallet` update are restored, keeping the new token/skin styling.

## [5] HIGH · known · dropped-behavior — `lib/account/account_dropdown_selector.dart:139`
Wallet 'Delete' action (with keep-one guard and re-selection) dropped from the account drawer row
- **develop:** origin/develop had `_confirmDeleteWallet(context, wallet)` (develop lines ~102-160) with a guard requiring at least one wallet to remain (showAppSnackBar 'You must keep at least one wallet.'), a confirmation dialog, `appBloc.add(DeleteWallet(wallet.address))`, and re-selection of a remaining wallet when the deleted one was selected. Reached via a 'Delete' MenuItemButton in the row's MenuAnchor.
- **HEAD:** HEAD `_buildDrawerRow` (line 139) has no MenuAnchor and no delete path; `_confirmDeleteWallet` is removed, so users can no longer delete wallets and the keep-at-least-one guard / re-selection logic are gone.
- **fix:** Re-add `_confirmDeleteWallet` (guard, confirm dialog, `DeleteWallet` dispatch, re-selection) and surface it from the redesigned row, preserving the new visual skin.

## [6] HIGH · NEW · bug — `lib/banxa/checkout_qr.dart:75`
QR code container background changed from constant white to theme-aware textPrimary, making the QR unscannable in light theme.
- **develop:** Line 72: the QR Container uses `color: Colors.white` unconditionally, so the QR (whose data modules render black by default in QrImageView) always sits on a white background and is scannable in both light and dark themes.
- **HEAD:** Line 75: the Container decoration uses `color: GeniusWalletColors.textPrimary`. textPrimary resolves to `_inkLight = Color(0xFF10131A)` (near-black) in light theme (genius_wallet_colors.dart:86). QrImageView still renders its modules black by default, producing black-on-near-black in light mode = unscannable. It only happens to work in dark mode where textPrimary is white.
- **fix:** Give the QR quiet zone a background that is always light regardless of theme. Replace `GeniusWalletColors.textPrimary` with a constant light value (e.g. `Colors.white`, keeping develop's behavior) or an always-light token such as `GeniusWalletColors.surfaceElevatedLight`. Do not use a theme-flipping token for the QR background — QR modules render dark, so the background must stay light in both the

## [7] HIGH · known · crash — `lib/banxa/user_kyc/kyc_registration.dart:18`
Linux platform fallback removed; on Linux WebViewController() is constructed unconditionally although webview_flutter has no Linux implementation, causing a crash instead of the browser fallback.
- **develop:** origin/develop lines 27-33 + 78: initState checks `if (Platform.isLinux)` and calls `_openInBrowser()` (launchWebSite) then returns, plus a dedicated Linux Scaffold UI in build(); this avoids constructing an unsupported WebViewController on Linux.
- **HEAD:** HEAD lines 18-22: initState always runs `_controller = WebViewController()...`; the `dart:io` import, `_isLinux` flag, `_openInBrowser()` method, and Linux build() branch are all deleted, so Linux users hit an unimplemented-platform exception when opening Banxa KYC.
- **fix:** Re-add the `import 'dart:io'`, the `if (Platform.isLinux)` early-return with `_openInBrowser()`, and the Linux fallback Scaffold, applying the redesign tokens/skin to that branch rather than deleting it.

## [8] HIGH · known · data-binding — `lib/dashboard/chart/markets_screen.dart:16`
MarketsScreen converted from Stateful to Stateless with getMarketCoins()/fetchCoinsMarketData() created directly in build(), and the error-state retry actions removed.
- **develop:** Stateful widget: `_coinsFuture = getMarketCoins()` created once in initState, `_marketDataFuture` cached, `_retryCoins`/`_retryMarketData` passed as `onRetry:` to FutureStateWidget so error states show working retry buttons (origin/develop markets_screen.dart initState + _retry methods).
- **HEAD:** StatelessWidget calling `future: getMarketCoins()` (HEAD line 77) and `future: fetchCoinsMarketData(coinIds: coins.map(...))` (HEAD line 94) inline in build(): every rebuild (search open/close, orientation, parent rebuild) re-issues the network calls and resets the loading state, and both FutureStateWidget `onRetry` callbacks are gone so the error UI can no longer retry.
- **fix:** Restore the StatefulWidget: initialize _coinsFuture in initState, cache _marketDataFuture/_cachedCoinIds, and re-wire onRetry: _retryCoins / _retryMarketData; keep only the redesign's tokens/cosmetics.

## [9] HIGH · NEW · dropped-behavior — `lib/dashboard/home/view/dashboard_screen.dart:71`
Dashboard error state dropped — on wallet/account load error the redesign shows a spinner forever instead of an error message, and it no longer waits for accountStatus before rendering.
- **develop:** build() gates on BOTH statuses loaded, and handles error explicitly: `if (subscribeToWalletStatus == loaded && accountStatus == loaded) {...dashboard...}` then `if (subscribeToWalletStatus == error || accountStatus == error) return Center(child: Text('Something went wrong!'));` else LoadingScreen (origin/develop dashboard_screen.dart lines ~91-103).
- **HEAD:** HEAD only checks `if (appState.subscribeToWalletStatus != AppStatus.loaded) return const Center(child: GWSpinner(size: 48));` then renders the dashboard (HEAD lines 71-72). AppStatus.error therefore falls into the non-loaded branch and displays an infinite spinner with no error text and no recovery; accountStatus is no longer gated, so the hero balance can render before the account has loaded.
- **fix:** Restore the error branch and the accountStatus gate: show the dashboard only when subscribeToWalletStatus==loaded && accountStatus==loaded, return an error widget (styled with the new tokens) when either is AppStatus.error, and only fall back to GWSpinner for the genuine loading case.

## [10] HIGH · NEW · dropped-behavior — `lib/dashboard/transactions/transactions_screen.dart:21`
Pull-to-refresh removed from the transactions screen; users can no longer swipe down to reload coin balances.
- **develop:** origin/develop lines 16-18 wrap the body in RefreshIndicator with onRefresh: () async { context.read<WalletDetailsCubit>().getCoins(); }, giving pull-to-refresh that reloads coins.
- **HEAD:** HEAD line 21 replaces the RefreshIndicator with a plain Container(height: screenHeight)/Column; there is no RefreshIndicator, onRefresh, or getCoins() call anywhere in the redesigned file, so the refresh gesture and its data reload are gone.
- **fix:** Re-wrap the scrollable content in a RefreshIndicator (or keep the new Container skin inside it) with onRefresh: () async { context.read<WalletDetailsCubit>().getCoins(); } so pull-to-refresh reloads coins as in develop.

## [11] HIGH · known · crash — `lib/main.dart:279`
Global ErrorWidget.builder and FlutterError.onError handlers were removed from MyApp.build.
- **develop:** origin/develop lib/main.dart:223 sets `ErrorWidget.builder` to a branded 'Something went wrong' recovery screen with a Go-to-Dashboard button, and line 260 sets `FlutterError.onError` to present+log errors.
- **HEAD:** HEAD lib/main.dart:279 MyApp.build now returns RepositoryProvider directly (line 280) with both global handlers deleted, so build-time exceptions render the default red error box and framework errors are no longer routed/logged.
- **fix:** Re-install `ErrorWidget.builder` and `FlutterError.onError` at the top of MyApp.build (or in main) exactly as develop had them, keeping only color tokens re-skinned; do not drop the recovery UI or error routing.

## [12] HIGH · known · lifecycle — `lib/main.dart:192`
onWindowClose early-return now skips geniusApi.shutdownSDK() on non-Windows and Windows-without-webviews.
- **develop:** origin/develop lib/main.dart:150 onWindowClose always reaches `geniusApi.shutdownSDK()` (line 167); webview disposal was merely conditional on Windows+active webviews.
- **HEAD:** HEAD lib/main.dart:192-195 adds `if (!Platform.isWindows || !WindowsWebViewShutdown.instance.hasActiveWebViews) return;`, so on macOS/Linux (and Windows with no active webviews) the method returns before shutdownSDK() at line 215, leaking the SDK on window close.
- **fix:** Restore develop's control flow: keep the `_isClosing` guard and the Windows/webview-conditional disposeAll(), but ensure `geniusApi.shutdownSDK()` is always executed on window close regardless of platform/webview state.

## [13] MEDIUM · NEW · routing — `lib/components/bottom_drawer/responsive_drawer.dart:39`
Mobile bottom-sheet drawer no longer mounts on the root navigator; develop forced useRootNavigator:true, HEAD relies on showModalBottomSheet's default (false).
- **develop:** develop passed useRootNavigator: useRootNavigator (default true) to BOTH showDialog and showModalBottomSheet (origin/develop responsive_drawer.dart lines 30 and 58), so the drawer/dialog always mounted on the root Navigator and covered the whole app.
- **HEAD:** HEAD's showModalBottomSheet call (lines 39-62) omits useRootNavigator entirely, so it defaults to false — the sheet mounts on the nearest enclosing Navigator. showDialog (line 18) also omits it (default true, so unchanged there).
- **fix:** Add useRootNavigator: true to the showModalBottomSheet call (and keep the parameter configurable if any caller needs otherwise) so drawers opened from within a nested Navigator still overlay the full app as they did on develop.

## [14] MEDIUM · NEW · dropped-behavior — `lib/components/coins/view/coins_screen.dart:45`
Redesign changed the market-data refresh interval from develop's 1 minute to 20 seconds, tripling CoinGecko API polling frequency and risking free-tier rate-limiting (429s) that break balance/market-data updates.
- **develop:** origin/develop coins_screen initState: `_refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {...})` — polls every 60s (comment: 'periodically fetch market data to keep wallet balance up to date').
- **HEAD:** HEAD coins_screen initState line 45: `_refreshTimer = Timer.periodic(const Duration(seconds: 20), (timer) {...})` — polls every 20s (comment changed to 'every 20 seconds'). Each tick calls _fetchMarketData which issues 2 network calls (fetchAllCoinGeckoCoins + fetchCoinsMarketData), so this is ~6 calls/min vs develop's ~2.
- **fix:** Restore develop's behavior: change `const Duration(seconds: 20)` back to `const Duration(minutes: 1)` (and revert the comment). This is a logic/behavior change, not a visual one, so it should not have been carried over from the redesign.

## [15] MEDIUM · NEW · dropped-behavior — `lib/components/custom_future_builder.dart:47`
When a caller supplies a custom `error` widget, the redesign's `return error ?? GWErrorState(...)` short-circuits and silently drops the `onRetry` retry button that develop always rendered.
- **develop:** origin/develop:lib/components/custom_future_builder.dart lines 35-46 render a Column containing BOTH the error widget (`error ?? Icon(...)`, line 37) AND, independently, `if (onRetry != null) ...[ElevatedButton(onPressed: onRetry, child: Text("Retry"))]` (lines 38-44). So a custom error widget and the retry button coexisted.
- **HEAD:** HEAD:lib/components/custom_future_builder.dart lines 47-52: `return error ?? GWErrorState(title:..., message:..., onRetry: onRetry)`. When `error` is non-null it is returned directly and `onRetry` is never used, so no retry affordance is shown. dashboard_markets.dart (lines 46-50, unchanged from develop) passes both `error:` and `onRetry: _retry`, so the dashboard market-data failure state loses i
- **fix:** Preserve develop's behavior for the custom-error case: instead of `return error ?? GWErrorState(...)`, do e.g. `if (error != null) { return onRetry == null ? error! : Column(mainAxisAlignment: MainAxisAlignment.center, children: [error!, const SizedBox(height: 12), <retry button, e.g. GWButton/ElevatedButton onPressed: onRetry>]); } return GWErrorState(title: errorTitle ?? 'Something went wrong', 

## [16] MEDIUM · NEW · data-binding — `lib/components/qr/crypto_address_qr.dart:28`
Receive-address QR background changed from a fixed light color to a theme-dependent token that becomes dark in light appearance mode, making the QR unscannable there.
- **develop:** Line 26 (origin/develop): QrImageView backgroundColor: Colors.white.withValues(alpha: 0.8) — always a light background, so the default black QR modules always have contrast and scan.
- **HEAD:** Line ~28 (HEAD): backgroundColor: GeniusWalletColors.textPrimary60. textPrimary60 resolves via GWAppearance.isLight to Color(0x9910131A) (dark ink @60%) in light mode / Color(0x99FFFFFF) (white @60%) in dark mode. QrImageView uses no foregroundColor override, so modules render default black. In light appearance mode this is black-on-dark = no contrast, QR cannot be scanned; in dark mode contrast i
- **fix:** Restore a solid light background independent of theme, e.g. backgroundColor: Colors.white (or Colors.white.withValues(alpha: 0.8) as develop had). Do not bind the QR background to a foreground/text token that flips dark in light mode.

## [17] MEDIUM · known · dropped-behavior — `lib/dashboard/home/view/dashboard_screen.dart:79`
Pull-to-refresh removed from the dashboard — RefreshIndicator and the LoadWallets + getCoins refresh handler are gone.
- **develop:** OneColumnDashBoardView wraps its ListView in `RefreshIndicator(onRefresh: () => _onRefresh(context), ...)` where `_onRefresh` dispatches `context.read<AppBloc>().add(LoadWallets())` and calls `walletCubit.getCoins()` when a wallet+network are selected (origin/develop dashboard_screen.dart _onRefresh + RefreshIndicator).
- **HEAD:** HEAD renders a bare CustomScrollView with no RefreshIndicator and no LoadWallets dispatch anywhere; the user can no longer pull to refresh wallets/coins (HEAD build() slivers).
- **fix:** Wrap the CustomScrollView in a RefreshIndicator whose onRefresh re-adds LoadWallets to AppBloc and calls WalletDetailsCubit.getCoins(), preserving develop's refresh behavior under the new skin.

## [18] MEDIUM · NEW · dropped-behavior — `lib/dashboard/news/view/crypto_news_screen.dart:95`
Pull-to-refresh (RefreshIndicator) and the _retryNews reload path were dropped from the crypto news list
- **develop:** origin/develop wrapped the news grid in a RefreshIndicator(onRefresh: () async => _retryNews(), child: SingleChildScrollView(StaggeredGrid...)) and defined _retryNews() which re-issued fetchCoinTelegraphNews() via setState; FutureStateWidget was also given onRetry: _retryNews.
- **HEAD:** HEAD returns a bare MasonryGridView.count with no RefreshIndicator wrapper, deleted the _retryNews() method, and dropped onRetry from FutureStateWidget. After the initial load there is no way for the user to refresh/reload the news feed.
- **fix:** Re-introduce the reload capability on the redesigned screen: keep a _retryNews() that does setState(() { _newsFuture = fetchCoinTelegraphNews().then(...); }); wrap the MasonryGridView in a RefreshIndicator(onRefresh: () async => _retryNews()) (MasonryGridView scrolls, so it satisfies the scrollable requirement) and pass onRetry: _retryNews to FutureStateWidget.

## [19] MEDIUM · NEW · null-safety — `lib/onboarding/new_wallet/view/recovery_phrase_screen.dart:218`
Desktop 'Copy to clipboard' handler dropped the post-await mounted guard that develop had, allowing ScaffoldMessenger.of(context) to be called on an unmounted State.
- **develop:** develop's copy onPressed awaits FlutterClipboard.copy then has `if (!mounted) return;` before showing the SnackBar (origin/develop:lib/onboarding/new_wallet/view/recovery_phrase_screen.dart line 105).
- **HEAD:** In _WordsGridWithCopyAndToggleState the desktop copy button awaits FlutterClipboard.copy(words.join(' ')) (line 217) then calls ScaffoldMessenger.of(context).showSnackBar(...) at line 218 with NO mounted check. The mobile _WordsAndCopyState copy handler still keeps `if (!mounted) return;` (line 334), confirming the guard was intended and only the desktop path lost it.
- **fix:** Re-insert `if (!mounted) return;` immediately after `await FlutterClipboard.copy(words.join(' '));` and before `ScaffoldMessenger.of(context).showSnackBar(...)` in the desktop _WordsGridWithCopyAndToggleState copy button (line 217-218), matching develop and the mobile variant.

## [20] MEDIUM · NEW · dropped-behavior — `lib/reown/reown_connect_button.dart:212`
_connect() dropped develop's re-init call and post-init failure guard, so a failed WalletKit init no longer aborts the connect flow or surfaces the 'please restart the app' error to the user.
- **develop:** origin/develop _connect lines 218-231: `await maybeInitWalletKit();` then `if (!_isInitialized) { setState(_isConnecting=false; _hasError=true); debugPrint('Connection failed: WalletKit not initialized'); if (mounted && context.mounted) showAppSnackBar(context, 'WalletKit failed to initialize. Please restart the app.', ...); return; }` — a guaranteed re-init attempt on each connect plus explicit u
- **HEAD:** HEAD _connect (line 212+) removed both the `await maybeInitWalletKit();` call and the entire `if (!_isInitialized)` guard block; it proceeds straight to `walletKit.core.pairing.create()`. If startup init failed, connect no longer retries init and the user gets no 'restart the app' guidance (only the generic catch path).
- **fix:** Re-add `await maybeInitWalletKit();` at the top of _connect and re-instate the `if (!_isInitialized)` failure guard with the showAppSnackBar feedback (restore `_isInitialized` per finding above), keeping the redesign's token/color styling for the snackbar.

## [21] MEDIUM · NEW · dropped-behavior — `lib/squid_router/swap_screen.dart:388`
The redesign replaced develop's entire swap-submit flow (toast + success drawer + transaction recording + Hive persistence) with a bare 'demo' snackbar and a navigation to /dashboard, dropping several develop features.
- **develop:** origin/develop swap_screen.dart lines 347-423: onPressed builds a Transaction, calls ToastManager.instance.showToast('Swap Submitted'), opens SwapSuccessDrawer.show(...), calls transactionsCubit.addTransaction(transaction), and awaits TransactionStorageService().addTransaction(walletAddress, transaction).
- **HEAD:** HEAD lines 388-416: onPressed only does debugPrint, ScaffoldMessenger showSnackBar('Swap submitted (demo)'), then context.go('/dashboard'). SwapSuccessDrawer, ToastManager, TransactionsCubit and TransactionStorageService are no longer imported or called; the success drawer / tx-history entry no longer appears.
- **fix:** This deviation is documented as intentional (WIRE-1 / `REVIEW_FINDINGS_REDESIGN.md` — this finding [21], formerly cited as §B1) because develop fabricated a fake Transaction with hash:"" and wrong direction. If the parent wants develop behavior preserved with the new skin, re-add SwapSuccessDrawer.show, the success ToastManager toast, transactionsCubit.addTransaction and TransactionStorageService().addTransaction — but gate them on a real Squid ex

## [22] MEDIUM · NEW · dropped-behavior — `lib/squid_router/swap_screen.dart:154`
_fetchRoute lost its user-visible error feedback: develop showed a snackbar on route-fetch failure, HEAD only debugPrints so the failure is now silent to the user.
- **develop:** origin/develop swap_screen.dart lines 163-170: on catch, if (mounted) showAppSnackBar(context, 'Failed to fetch route. Check your input and try again.').
- **HEAD:** HEAD lines 154-156: on catch, only debugPrint("Route fetch failed: $e") — no snackbar, so a failed quote/route fetch gives the user no feedback (the You Receive field just stays stale).
- **fix:** Restore a user-facing error notice in the _fetchRoute catch block using the redesign's snackbar/toast style (e.g. ScaffoldMessenger.of(context).showSnackBar or ToastManager) guarded by mounted, matching develop's 'Failed to fetch route...' message. Note _loadTokens was intentionally converted to an error-state UI, but _fetchRoute's feedback was dropped with no replacement.

## [23] LOW · NEW · data-binding — `lib/account/account_dropdown_selector.dart:56`
Account drawer content is no longer reactive to AppBloc wallet updates while open
- **develop:** origin/develop's `_showAccountDrawer` wrapped the drawer child in `BlocBuilder<AppBloc, AppState>` and built rows from live `appState.wallets`, so wallet list/balance changes reflected live while the drawer was open.
- **HEAD:** HEAD `_showAccountDrawer(List<Wallet> wallets)` (line 56) builds `walletRows` once from a static snapshot passed from `build()`, so non-sgnus wallet balances/list changes no longer update while the drawer is open (sgnus row still self-updates via GeniusBalanceDisplay).
- **fix:** Wrap the drawer's row list in a `BlocBuilder<AppBloc, AppState>` (re-injecting the sgnus wallet as build() does) so rows stay reactive; purely additive over the redesign skin.

## [24] LOW · known · null-safety — `lib/chart/crypto_live_chart.dart:71`
setState after await in _fetchHistoricalData success path (and in the timer-driven _addNewPricePoint) runs without a mounted guard, matching the known finding; the redesign added a mounted guard only to the new error branch.
- **develop:** origin/develop line 65 (_fetchHistoricalData) and line 95 (_addNewPricePoint called from the periodic timer at line 89) call setState after an await with no `if (mounted)` guard.
- **HEAD:** HEAD line 71 success-branch setState and line 103 _addNewPricePoint setState are still unguarded, while the newly added else branch at line 85 does use `if (mounted)`; an in-flight fetch/timer completing after dispose calls setState on an unmounted State.
- **fix:** Wrap the post-await setState calls in `if (!mounted) return;` (success branch at line 71 and _addNewPricePoint at line 103), consistent with the guard already added at line 85.

## [25] LOW · NEW · dropped-behavior — `lib/components/bottom_drawer/responsive_drawer.dart:41`
Swipe-down-to-dismiss removed from the mobile drawer; enableDrag is now hardcoded false where develop allowed it (default true).
- **develop:** develop exposed enableDrag (default true) and passed it to showModalBottomSheet (origin/develop responsive_drawer.dart lines 14 and 59), so users could drag the sheet down to dismiss it.
- **HEAD:** HEAD hardcodes enableDrag: false (line 41) and drops the parameter, removing drag-to-dismiss for every drawer.
- **fix:** Re-expose an enableDrag parameter (default true) and pass it through, or at minimum set enableDrag: true to preserve develop's dismissal affordance; barrier-tap dismissal alone is a behavior reduction.

## [26] LOW · NEW · dropped-behavior — `lib/components/bottom_drawer/responsive_drawer.dart:15`
Desktop/mobile switch threshold shifted from 768 to 800, changing which layout (side dialog vs bottom sheet) renders for 768–799px-wide viewports.
- **develop:** develop switched on MediaQuery.sizeOf(context).width >= GeniusBreakpoints.medium, i.e. >= 768 (origin/develop responsive_drawer.dart line 17; breakpoints.dart medium=768).
- **HEAD:** HEAD uses a private _desktopBreakpoint = 800 and switches on width >= 800 (lines 6 and 15), so 768–799px viewports now get the mobile bottom sheet instead of the desktop side dialog.
- **fix:** Reuse GeniusBreakpoints.medium (768) for the threshold instead of the hardcoded 800 to keep the develop breakpoint, or confirm the shift is intentional design.

## [27] LOW · NEW · routing — `lib/components/overlay/responsive_overlay.dart:73`
The mobile/desktop Web nav tab destination was changed from develop's '/web' to '/browser', pointing the tab at a different screen than develop shipped.
- **develop:** Line 62 (origin/develop): _TabDestination(path: '/web', ...) — the Web tab navigates to the '/web' route (WebViewScreen).
- **HEAD:** Line 73 (HEAD): path: '/browser' (a route/screen not present in origin/develop's router); _currentIndex (lines 105-107) adds a '/web'->'/browser' alias to compensate. This changes the destination screen the Web tab opens.
- **fix:** Confirm this destination change is intended (redesign introduced a new BrowserScreen). If preserving develop behavior, the tab should still resolve to develop's '/web' route; otherwise verify the new '/browser' route + WebViewScreen('/web') push flow fully replaces the old behavior. Not a broken go_router path (both routes exist in HEAD), so low severity.

## [28] LOW · NEW · dropped-behavior — `lib/dashboard/bridge/bridge_screen.dart:251`
Bridge success/error toast notification dropped in the redesign; only the result dialog remains.
- **develop:** origin/develop bridge_screen.dart:220 calls ToastManager.instance.showToast(...) right after the `if (!context.mounted) return;` guard (line 218) and before showDialog (line 233), showing a 'Success'/'Error' toast ('Bridge transaction completed.'/'Bridge transaction failed.') on every bridgeOut result.
- **HEAD:** HEAD bridge_screen.dart goes straight from `if (!context.mounted) return;` (line 251) to showDialog (line 253); the ToastManager import (was `package:genius_wallet/components/toast/toast_manager.dart`) and the showToast() call are both removed, so the toast no longer fires.
- **fix:** Re-add the ToastManager.instance.showToast(...) call between the context.mounted guard and showDialog in the bridgeOut onPressed handler, restoring the toast_manager.dart import. Keep the redesigned dialog styling; just re-apply develop's toast notification behavior.

## [29] LOW · NEW · lifecycle — `lib/dashboard/home/view/dashboard_screen.dart:43`
initState now calls getCoins() unconditionally instead of only when a wallet and network are selected.
- **develop:** initState post-frame callback: `if (walletCubit.state.selectedWallet != null && walletCubit.state.selectedNetwork != null) walletCubit.getCoins();` (origin/develop dashboard_screen.dart lines ~67-72).
- **HEAD:** HEAD calls `context.read<WalletDetailsCubit>().getCoins();` inside a bare `try { } catch (_) {}` with no selectedWallet/selectedNetwork guard (HEAD lines 42-45), firing a coin fetch even when no wallet/network is selected and silently swallowing any resulting error.
- **fix:** Re-add the selectedWallet != null && selectedNetwork != null guard before calling getCoins() so it isn't invoked without a selected wallet/network.

## [30] LOW · NEW · crash — `lib/dashboard/home/view/dashboard_screen.dart:682`
New _CoinRow letter-avatar fallback can throw on an empty symbol string.
- **develop:** develop rendered the asset list via CoinsScreen/WalletsOverview with no per-row `.characters.first` access (origin/develop ContributionsDashboardView -> CoinsScreen).
- **HEAD:** HEAD's `_RowIcon(letter: symbol.characters.first)` where `symbol = coin.symbol ?? '?'` (HEAD lines ~677-682): a null symbol becomes '?', but an empty-string symbol stays '' and `''.characters.first` throws a StateError, crashing the row build.
- **fix:** Guard the empty case, e.g. `final symbol = (coin.symbol?.isNotEmpty ?? false) ? coin.symbol! : '?';` or use `symbol.characters.firstOrNull ?? '?'` before passing to _RowIcon.

## [31] LOW · NEW · dropped-behavior — `lib/dashboard/home/widgets/transactions_slim_view.dart:84`
The transaction count footer ('Transactions: N') was removed from the slim view.
- **develop:** develop rendered a right-aligned `AutoSizeText("Transactions: ${txs.length}", ...)` beneath the list showing the filtered count (origin/develop transactions_slim_view.dart Align/AutoSizeText block).
- **HEAD:** HEAD's build() ends after the Expanded transactions list with no count display (HEAD build() Column children); the running transaction count is no longer shown to the user.
- **fix:** If the count is intended to stay, re-add a token-styled count line below the list showing filteredTransactions.length.

## [32] LOW · NEW · dropped-behavior — `lib/dashboard/transactions/transaction_item.dart:112`
Detail-drawer _buildRow lost the Flexible + ellipsis overflow guard develop had, so long values can cause a RenderFlex overflow
- **develop:** origin/develop transaction_displays.dart _buildRow wrapped the value Text in Flexible(child: Text(value, textAlign: TextAlign.right, overflow: TextOverflow.ellipsis)), preventing horizontal overflow for long values (fees, network fee strings).
- **HEAD:** The re-skinned _buildRow in transaction_item.dart (lines 112-126) uses a plain Text(value) with no Flexible wrapper and no overflow handling; a long value in the spaceBetween Row can overflow and throw a RenderFlex overflow.
- **fix:** Wrap the value Text in Flexible(child: Text(value, textAlign: TextAlign.right, overflow: TextOverflow.ellipsis, ...)) as develop did, keeping the new token colors.

## [33] LOW · NEW · dropped-behavior — `lib/dashboard/transactions/transaction_purchased_item.dart:235`
Purchase detail-drawer _buildRow lost the Flexible + ellipsis overflow guard develop had
- **develop:** origin/develop's shared _buildRow (transaction_displays.dart) wrapped the value Text in Flexible with textAlign right and TextOverflow.ellipsis so long detail values don't overflow.
- **HEAD:** transaction_purchased_item.dart _buildRow (lines 235-249) renders a plain Text(value) with no Flexible/overflow, so long values in the spaceBetween Row can overflow and throw.
- **fix:** Wrap the value Text in Flexible(child: Text(value, textAlign: TextAlign.right, overflow: TextOverflow.ellipsis, ...)) matching develop.

## [34] LOW · NEW · bug — `lib/dashboard/transactions/transactions_screen.dart:13`
Duplicate @override annotation on build().
- **develop:** origin/develop has a single @override before Widget build(BuildContext context).
- **HEAD:** HEAD lines 13-14 emit @override twice in a row before build(), which the analyzer flags (duplicate/redundant annotation).
- **fix:** Remove the extra @override so build() is annotated only once.

## [35] LOW · NEW · dropped-behavior — `lib/network/network_dropdown_selector.dart:52`
The 'Network Changed' success toast shown after switching networks was removed.
- **develop:** origin/develop lib/network/network_dropdown_selector.dart:72-74 calls `ToastManager.instance.showToast(... title: 'Network Changed', message: 'Switched to ...', type: ToastType.success)` after selectNetwork on a real change.
- **HEAD:** HEAD lib/network/network_dropdown_selector.dart:52 showNetworkPicker calls `walletCubit.selectNetwork(selected)` and persists the choice but no longer surfaces any toast/confirmation feedback; the ToastManager import was also dropped.
- **fix:** Re-add the success ToastManager.showToast inside showNetworkPicker after a confirmed change (when `selected.chainId != current?.chainId`), re-importing toast_manager; keep the new token-based row styling.

## [36] LOW · NEW · dropped-behavior — `lib/theme/theme.dart:168`
Global inputDecorationTheme dropped floatingLabelBehavior: FloatingLabelBehavior.always, changing label interaction behavior on every TextField/TextFormField in the app.
- **develop:** origin/develop lib/theme/theme.dart:159 sets `floatingLabelBehavior: FloatingLabelBehavior.always` inside the global inputDecorationTheme (also hintStyle at :158), so all form field labels stay pinned/floated above the field at all times.
- **HEAD:** HEAD lib/theme/theme.dart:168 rebuilds inputDecorationTheme as a const with only contentPadding/focusedBorder/border; floatingLabelBehavior is gone, so Material reverts to the default FloatingLabelBehavior.auto — labels now sit inside the field as placeholders and only float on focus/content.
- **fix:** Re-add `floatingLabelBehavior: FloatingLabelBehavior.always` to the global inputDecorationTheme in getThemeData() (note it must move out of the `const InputDecorationTheme(...)` or keep it const since the enum value is const-compatible), preserving develop's persistent-label form UX while keeping the new radii/border tokens.

## [37] LOW · NEW · dropped-behavior — `lib/tokens/token_info_screen.dart:336`
The 'More' action button lost develop's isGnusBridgeEnabled disabled-guard; on non-GNUS tokens it now opens an empty 'More Options' bottom sheet.
- **develop:** origin/develop lib/tokens/token_info_screen.dart:176-199 — the More ActionButton uses `onPressed: isGnusBridgeEnabled ? () { ResponsiveDrawer.show(... child: SlidingDrawerButton(...)) } : null`, so when the coin is not a GNUS bridge the button is disabled (non-tappable).
- **HEAD:** HEAD lib/tokens/token_info_screen.dart:333-357 — the More ActionButton is `onPressed: () { ResponsiveDrawer.show(... children: [ if (isGnusBridgeEnabled) SlidingDrawerButton(...) ]) }`. It is always enabled, so tapping More on a non-GNUS token opens a 'More Options' drawer with no children (empty sheet).
- **fix:** Re-apply develop's guard while keeping the redesign skin: set the More button's onPressed to null when `!isGnusBridgeEnabled` (e.g. `onPressed: isGnusBridgeEnabled ? () { ResponsiveDrawer.show(...) } : null`), or only render the More ActionButton when isGnusBridgeEnabled is true, so users can't open an empty drawer.
