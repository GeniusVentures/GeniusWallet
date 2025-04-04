import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';

part 'genius_wallet_details_state.dart';

class GeniusWalletDetailsCubit extends Cubit<GeniusWalletDetailsState> {
  GeniusApi geniusApi;
  GeniusWalletDetailsCubit({
    GeniusWalletDetailsState initialState = const GeniusWalletDetailsState(),
    required this.geniusApi,
  }) : super(initialState);
}
