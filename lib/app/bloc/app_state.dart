part of 'app_bloc.dart';

class AppState {
  //? We might not need this user model if we get rid of auth
  final User userModel;
  final GeniusApi geniusApi;
  //? Maybe we can add a bool to easily see if the user is authenticated in the state.
  final List<Wallet> wallets;

  const AppState({
    this.userModel = const User(
      firstName: '',
      lastName: '',
      dateOfBirth: '',
      email: '',
      nickname: '',
      profilePictureUrl: '',
      wallets: [],
    ),
    required this.geniusApi,
    this.wallets = const [],
  });

  AppState copyWith({
    User? userModel,
    GeniusApi? geniusApi,
    List<Wallet>? wallets,
  }) {
    return AppState(
      userModel: userModel ?? this.userModel,
      geniusApi: geniusApi ?? this.geniusApi,
      wallets: wallets ?? this.wallets,
    );
  }
}
