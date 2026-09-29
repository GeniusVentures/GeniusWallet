import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dev/dev_flags.dart';
import 'package:genius_wallet/dev/dev_mock_child_wallets.dart';

/// [minions] (1 Minion = 1e-6 GNUS) as an exact GNUS string. Integer division
/// only -- a float divide would lose precision a wallet balance cannot.
String minionsToGnus(BigInt minions) {
  final million = BigInt.from(1000000);
  final whole = minions ~/ million;
  final remainder = (minions % million).toString().padLeft(6, '0');
  return '$whole.$remainder';
}

/// One child, ready to render: its own address, its linked wallet (or none)
/// and its exact GNUS balance string. Never a key or a mnemonic.
class ChildWallet {
  const ChildWallet({
    required this.address,
    required this.name,
    required this.linkedWallet,
    required this.balanceGnus,
  });

  final String address;
  final String name;
  final Wallet? linkedWallet;
  final String balanceGnus;
}

/// Why the list looks the way it does -- distinct from an empty, successful
/// read, which is still [loaded].
enum ChildWalletsStatus { loaded, nodeNotRunning, error }

class ChildWalletsState {
  const ChildWalletsState({
    required this.status,
    required this.mainAddress,
    this.mainName = 'Unlinked',
    this.children = const [],
    this.parentMain,
  });

  final ChildWalletsStatus status;
  final String mainAddress;
  final String mainName;
  final List<ChildWallet> children;

  /// The other own SDK account whose registrations list this screen's own
  /// account as a child, or null when none does. Only meaningful when
  /// [status] is [ChildWalletsStatus.loaded] -- a disconnected or failed
  /// read never sets it.
  final String? parentMain;

  ChildWalletsState copyWith({
    ChildWalletsStatus? status,
    String? mainName,
    List<ChildWallet>? children,
    String? parentMain,
  }) => ChildWalletsState(
    status: status ?? this.status,
    mainAddress: mainAddress,
    mainName: mainName ?? this.mainName,
    children: children ?? this.children,
    parentMain: parentMain,
  );
}

/// The children registered under one main account, read through [GeniusApi]
/// only -- no FFI or Hive here. [readAppState] supplies the live link/wallet
/// map each read needs to resolve a child's name.
class ChildWalletsCubit extends Cubit<ChildWalletsState> {
  ChildWalletsCubit({
    required GeniusApi api,
    required AppState Function() readAppState,
    required String mainAddress,
  }) : _api = api,
       _readAppState = readAppState,
       super(
         ChildWalletsState(
           status: ChildWalletsStatus.loaded,
           mainAddress: mainAddress,
         ),
       ) {
    refresh();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) => refresh());
    if (kDebugMode && kShowDevTools) {
      // Removed in close() below, under the identical gate, so a listener
      // never outlives its cubit -- same idiom as SubmitJobCubit's
      // _devJobScenario listener.
      DevMockChildWallets.instance.preset.addListener(refresh);
    }
  }

  final GeniusApi _api;
  final AppState Function() _readAppState;
  Timer? _pollTimer;

  void refresh() {
    final appState = _readAppState();
    final mainName = AppBloc.sdkAccountName(
      state.mainAddress,
      appState.sdkAccountLinks,
      appState.wallets,
    );

    // DEV-ONLY: null unless both gates hold, so the branches below are
    // unreachable outside a dev-tools debug build. An armed preset bypasses
    // the no-selected-account check -- it stands in for the SDK read that
    // check exists to guard.
    final devPreset = (kDebugMode && kShowDevTools)
        ? DevMockChildWallets.instance.preset.value
        : null;

    if (devPreset == null && appState.selectedSDKAccount == null) {
      emit(
        state.copyWith(
          status: ChildWalletsStatus.nodeNotRunning,
          mainName: mainName,
          children: const [],
        ),
      );
      return;
    }
    final registrations = _registrationsFor(
      state.mainAddress,
      appState,
      devPreset,
    );

    if (registrations.isNotInitialized) {
      emit(
        state.copyWith(
          status: ChildWalletsStatus.nodeNotRunning,
          mainName: mainName,
          children: const [],
        ),
      );
      return;
    }
    if (!registrations.isOk) {
      emit(
        state.copyWith(
          status: ChildWalletsStatus.error,
          mainName: mainName,
          children: const [],
        ),
      );
      return;
    }

    final children = registrations.entries
        .map(
          (entry) => ChildWallet(
            address: entry.childAddress,
            name: AppBloc.sdkAccountName(
              entry.childAddress,
              appState.sdkAccountLinks,
              appState.wallets,
            ),
            linkedWallet: AppBloc.linkedWallet(
              entry.childAddress,
              appState.sdkAccountLinks,
              appState.wallets,
            ),
            balanceGnus: minionsToGnus(
              devPreset != null
                  ? DevMockChildWallets.balanceFor(entry.childAddress)
                  : _api.getChildBalance(entry.childAddress),
            ),
          ),
        )
        .toList();

    emit(
      state.copyWith(
        status: ChildWalletsStatus.loaded,
        mainName: mainName,
        children: children,
        parentMain: _findParentMain(appState, devPreset),
      ),
    );
  }

  /// Routes a registrations read for [main] through the dev-preset branch
  /// when one is armed, or the real SDK otherwise -- the one place both the
  /// main list and the parent-main lookup below read registrations, so a
  /// dev preset covers both.
  ChildRegistrations _registrationsFor(
    String main,
    AppState appState,
    DevChildWalletsPreset? devPreset,
  ) {
    if (devPreset != null) {
      return DevMockChildWallets.registrationsFor(devPreset, appState, main);
    }
    return _api.getChildRegistrations(main);
  }

  /// The first of the user's other own SDK accounts whose OK-read
  /// registrations list this screen's own account as a child, in any case --
  /// the subject itself is never queried as its own main, and a non-OK read
  /// for one account is simply skipped. A main registered by someone else's
  /// account stays undiscoverable, since the SDK has no by-child query.
  // ponytail: one registrations read per own account per poll -- fine for a
  // handful of SDK accounts; upgrade path is an SDK by-child query.
  String? _findParentMain(AppState appState, DevChildWalletsPreset? devPreset) {
    final subject = state.mainAddress.toLowerCase();
    for (final account in appState.sdkAccounts) {
      if (account.toLowerCase() == subject) {
        continue;
      }
      final registrations = _registrationsFor(account, appState, devPreset);
      if (!registrations.isOk) {
        continue;
      }
      if (registrations.entries.any(
        (entry) => entry.childAddress.toLowerCase() == subject,
      )) {
        return account;
      }
    }
    return null;
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    if (kDebugMode && kShowDevTools) {
      DevMockChildWallets.instance.preset.removeListener(refresh);
    }
    return super.close();
  }
}
