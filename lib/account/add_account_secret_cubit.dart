import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';

/// Whether the add-account field holds a secret the SDK would accept. Only the
/// verdict is state: the phrase or key itself is checked and never kept.
class AddAccountSecretCubit extends Cubit<bool> {
  AddAccountSecretCubit(this._api) : super(false);

  final GeniusApi _api;

  void check({required bool phrase, required String value}) => emit(
    phrase ? _api.isValidMnemonic(value) : _api.isValidPrivateKey(value),
  );
}
