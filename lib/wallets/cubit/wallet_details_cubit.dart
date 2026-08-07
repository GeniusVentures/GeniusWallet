import 'dart:async';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/assets/read_asset.dart';
import 'package:genius_wallet/dev/dev_flags.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';

part 'wallet_details_state.dart';

class WalletDetailsCubit extends Cubit<WalletDetailsState> {
  GeniusApi geniusApi;
  NetworkTokensProvider networkTokensProvider;

  // DEV-ONLY: dev switch flipped by DevMockHoldings-driven bubble buttons
  // (kDebugMode && kShowDevTools call sites only). Contains no fixtures
  // itself — fixtures stay in lib/dev/dev_mock_holdings.dart.
  bool mockMode = false;

  // DEV-ONLY: stash for the real selected wallet, set the FIRST time
  // injectMockWallet is called (guarded by _hasStashedWallet so a repeated
  // press does not overwrite the stash with the fixture itself). Restored
  // by clearMock. Fixtures themselves stay in lib/dev/dev_mock_sgnus.dart —
  // this cubit takes only a plain Wallet, never the fixture singleton.
  Wallet? _stashedWallet;
  bool _hasStashedWallet = false;

  WalletDetailsCubit({
    WalletDetailsState initialState = const WalletDetailsState(),
    required this.geniusApi,
    required this.networkTokensProvider,
  }) : super(initialState);

  /// DEV-ONLY: injects offline mock holdings, short-circuiting the live
  /// read until [clearMock] is called.
  void injectMockCoins(List<Coin> coins, {required String balance}) {
    mockMode = true;
    emit(
      state.copyWith(
        coinsStatus: WalletStatus.successful,
        coins: coins,
        selectedWalletBalance: balance,
      ),
    );
  }

  /// DEV-ONLY: injects a fixture wallet as the selected wallet, short-
  /// circuiting the live selection until [clearMock] is called. Stashes
  /// whatever wallet was selected before injection the FIRST time this is
  /// called (guarded by [_hasStashedWallet] so a repeated press cannot
  /// overwrite the stash with the fixture itself).
  void injectMockWallet(Wallet wallet) {
    if (!_hasStashedWallet) {
      _stashedWallet = state.selectedWallet;
      _hasStashedWallet = true;
    }
    mockMode = true;
    emit(state.copyWith(selectedWallet: wallet));
  }

  /// DEV-ONLY: turns mock-mode off, resumes the real (live) data path, and
  /// restores whatever wallet [injectMockWallet] stashed via the same
  /// copyWith call below.
  ///
  /// Ceiling: `copyWith` here is hand-written `x ?? this.x`, so passing a
  /// null [_stashedWallet] means "keep the current value" — a stash of null
  /// cannot be used to restore `selectedWallet` to null. On a machine where
  /// no wallet was selected before [injectMockWallet] was called, Clear
  /// therefore leaves the fixture wallet in place until the app restarts.
  /// Do not restructure `copyWith` to fix that; it is a shared state class
  /// and the change would reach far beyond this gap.
  void clearMock() {
    mockMode = false;
    emit(
      state.copyWith(
        coinsStatus: WalletStatus.successful,
        coins: const [],
        selectedWalletBalance: '0',
        selectedWallet: _stashedWallet,
      ),
    );
    _stashedWallet = null;
    _hasStashedWallet = false;
    getCoins();
  }

  Future<void> loadInitial({
    required Wallet selectedWallet,
    required Network selectedNetwork,
  }) async {
    emit(state.copyWith(initStatus: WalletStatus.loading));

    final balance = selectedWallet.balance.toString();

    // DEV-ONLY, release-safe: same const-led gate, same reason, different
    // mechanism from the two in `getCoins()`.
    //
    // The emit below is the one place in this cubit that builds a state from
    // the CONSTRUCTOR rather than `copyWith`, so it resets every field it does
    // not name - including `coins`, back to its `const []` default. Nothing
    // guarded it, so a `LoadWallets` (boot, but also the dashboard's
    // pull-to-refresh, one accidental overscroll away on a phone) wiped the
    // injected holdings outright.
    //
    // That was the WORSE of the two: `mockMode` stayed true afterwards, so the
    // guard at the top of `getCoins()` then blocked the refetch as well and
    // the panel sat EMPTY until Clear - it did not even revert to real data.
    //
    // The mock branch still does the reload's real work (wallet, network,
    // initStatus) through `copyWith`, which preserves `coins`. It deliberately
    // does NOT write `selectedWalletBalance` from `balance` above: that field
    // belongs to the fixture total `injectMockCoins` set, and overwriting it
    // with the real wallet's balance would half-revert the injection - a
    // fixture list under a live total, which is a state neither path produces.
    if (kDebugMode && kShowDevTools && mockMode) {
      emit(
        state.copyWith(
          selectedWallet: selectedWallet,
          selectedNetwork: selectedNetwork,
          initStatus: WalletStatus.successful,
        ),
      );
      return;
    }

    emit(
      WalletDetailsState(
        selectedWallet: selectedWallet,
        selectedWalletBalance: balance,
        selectedNetwork: selectedNetwork,
      ),
    );

    emit(state.copyWith(initStatus: WalletStatus.successful));
  }

  void selectNetwork(Network network) {
    emit(state.copyWith(selectedNetwork: network));
    getCoins();
  }

  void selectCoin(Coin coin) {
    emit(state.copyWith(selectedCoin: coin));
  }

  void selectWallet(Wallet wallet) {
    emit(state.copyWith(selectedWallet: wallet));
    getCoins();
  }

  void setSelectedWalletBalance(String balance) {
    if (balance != state.selectedWalletBalance) {
      emit(state.copyWith(selectedWalletBalance: balance));
    }
  }

  /// Method that clears the state of `copyAddressStatus` once
  /// the Snackbar has been shown to the user.
  void messageShowed() {
    emit(state.copyWith(copyAddressStatus: WalletStatus.initial));
  }

  FutureOr<void> copyWalletAddress() async {
    try {
      emit(state.copyWith(copyAddressStatus: WalletStatus.loading));
      await FlutterClipboard.copy(state.selectedWallet!.address);
      emit(state.copyWith(copyAddressStatus: WalletStatus.successful));
    } catch (e) {
      emit(state.copyWith(copyAddressStatus: WalletStatus.error));
    }
  }

  FutureOr<void> getCurrentFees() async {
    try {
      emit(state.copyWith(gasFeesStatus: WalletStatus.loading));
      final gasFee = await geniusApi.getGasFees();
      emit(
        state.copyWith(gasFeesStatus: WalletStatus.successful, gasFees: gasFee),
      );
    } catch (e) {
      emit(state.copyWith(gasFeesStatus: WalletStatus.error));
    }
  }

  FutureOr<void> getCoins() async {
    // DEV-ONLY, release-safe: while mock-mode is ON, the live read (and the
    // selectNetwork/selectWallet re-fetches that call this) must not
    // overwrite the injected mock holdings.
    //
    // `mockMode` alone was the gate here, and it was the one dev branch in
    // this repo that a release build still evaluated - every other one leads
    // with the two const bools and constant-folds away. It could not
    // actually fire in release (the only writers are the dev-tools bubble's
    // injectMock* calls, which are themselves gated), but "unreachable in
    // practice" is not the same guarantee as "not compiled in", and this is
    // the guarantee dev_flags.dart asks every call site for. Ordering is
    // load-bearing: the const bools lead, so the field read is dropped too.
    if (kDebugMode && kShowDevTools && mockMode) {
      return;
    }
    // TEMPORARY (removed by plan 13-05): measures the coins/holdings leg's
    // boot-time latency to answer 13-RESEARCH open question 1 / assumption
    // A2. Not a feature — delete alongside the [boot-timing] debugPrint
    // below once 13-03 has consumed the recorded figures.
    final stopwatch = Stopwatch()..start();
    try {
      emit(state.copyWith(coinsStatus: WalletStatus.loading));
      if (state.selectedWallet == null || state.selectedNetwork == null) {
        emit(state.copyWith(coinsStatus: WalletStatus.error));
        return;
      }
      final walletAddress = state.selectedWallet?.address;
      final selectedNetwork = state.selectedNetwork!;

      if (walletAddress == null) {
        debugPrint("Can't get coin info: wallet address is null");
        emit(state.copyWith(coinsStatus: WalletStatus.error));
        return;
      }

      // Use native SDK for Super Genius wallets, or if the selected network
      // is a Super Genius network; otherwise use RPC.
      final isSgnusWallet =
          state.selectedWallet?.walletType == WalletType.sgnus;

      final Future<List<Coin>> coinFuture;
      if (isSgnusWallet || isSuperGeniusNetwork(selectedNetwork)) {
        coinFuture = readSuperGeniusTokenAssets(
          walletAddress: walletAddress,
          network: selectedNetwork,
          networkTokensProvider: networkTokensProvider,
          geniusApi: geniusApi,
        );
      } else {
        final rpcUrl = selectedNetwork.rpcUrl;
        final networkSymbol = selectedNetwork.symbol;
        if (rpcUrl == null || rpcUrl.isEmpty || networkSymbol == null) {
          debugPrint("Can't get coin info: no RPC URL or network symbol");
          emit(state.copyWith(coinsStatus: WalletStatus.error));
          return;
        }
        coinFuture = readTokenAssets(
          walletAddress: walletAddress,
          network: selectedNetwork,
          networkTokensProvider: networkTokensProvider,
        );
      }

      final coinList = await coinFuture;
      // DEV-ONLY, release-safe: the SECOND half of the guard at the top of
      // this method, and it is not redundant with it - it is the `act` half
      // of a check-then-act pair whose `check` is now stale.
      //
      // The guard above runs BEFORE `await coinFuture`. A read that has
      // already passed it keeps running while the network takes its time, so
      // pressing a MOCK button during that window injects fixtures into a
      // cubit that is still holding a live result it is about to emit - and
      // this emit then silently replaced them. That is the whole "rows appear,
      // then vanish on their own a while later" report
      // (`.planning/debug/260807-mock-data-vanishes.md`); the delay the user
      // sees is simply however long the fetch had left to run, measured at
      // 28517ms on device with the RPC timing out and CoinGecko rate-limiting.
      //
      // `mockMode` must therefore be re-read AFTER the await, never cached
      // across it. Same ordering rule as the guard above: the two const bools
      // lead, so a release build folds this to `false`, drops the field read
      // with it, and this method's executed behaviour is byte-for-byte what it
      // was - the live read still wins for every real wallet, which is what
      // the third case in `test/dev/dev_mock_holdings_race_test.dart` pins.
      if (kDebugMode && kShowDevTools && mockMode) {
        return;
      }
      if (!isClosed) {
        emit(
          state.copyWith(
            coinsStatus: WalletStatus.successful,
            coins: coinList,
            // update selected coin to updated values after retrieval
            selectedCoin: state.selectedCoin != null
                ? coinList.firstWhere(
                    (coin) => coin.address == state.selectedCoin?.address,
                    orElse: () =>
                        state.selectedCoin!, // Keep the old coin if not found
                  )
                : null,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(coinsStatus: WalletStatus.error));
    } finally {
      debugPrint(
        '[boot-timing] getCoins settled in '
        '${stopwatch.elapsedMilliseconds}ms status=${state.coinsStatus}',
      );
    }
  }
}
