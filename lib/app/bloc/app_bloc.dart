import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({
    required GeniusApi geniusApi,
  }) : super(AppState(geniusApi: geniusApi)) {
    on<FetchWallets>((event, emit) async {
      final userWallets = await geniusApi.getUserWallets('userId');
      emit(state.copyWith(wallets: userWallets));
    });
  }
}
