import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppState()) {
    on<CacheWallets>(onCacheWallets);
  }

  Future<void> onCacheWallets(CacheWallets event, Emitter emit) async {
    emit(state.copyWith(wallets: event.wallets));
  }
}
