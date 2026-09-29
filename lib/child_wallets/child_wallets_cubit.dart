import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';

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
  });

  final ChildWalletsStatus status;
  final String mainAddress;
  final String mainName;
  final List<ChildWallet> children;

  ChildWalletsState copyWith({
    ChildWalletsStatus? status,
    String? mainName,
    List<ChildWallet>? children,
  }) => ChildWalletsState(
    status: status ?? this.status,
    mainAddress: mainAddress,
    mainName: mainName ?? this.mainName,
    children: children ?? this.children,
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
  }

  final GeniusApi _api;
  final AppState Function() _readAppState;

  void refresh() {
    final appState = _readAppState();
    final mainName = AppBloc.sdkAccountName(
      state.mainAddress,
      appState.sdkAccountLinks,
      appState.wallets,
    );

    final registrations = _api.getChildRegistrations(state.mainAddress);
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
              _api.getChildBalanceAll(entry.childAddress),
            ),
          ),
        )
        .toList();

    emit(
      state.copyWith(
        status: ChildWalletsStatus.loaded,
        mainName: mainName,
        children: children,
      ),
    );
  }
}
