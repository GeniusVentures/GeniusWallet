part of 'app_bloc.dart';

class AppState extends Equatable {
  //? We might not need this user model if we get rid of auth
  final User userModel;
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
    this.wallets = const [],
  });

  AppState copyWith({
    User? userModel,
    List<Wallet>? wallets,
  }) {
    return AppState(
      userModel: userModel ?? this.userModel,
      wallets: wallets ?? this.wallets,
    );
  }

  @override
  List<Object?> get props => [userModel, wallets];
}
