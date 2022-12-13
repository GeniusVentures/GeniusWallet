import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/navigation/router.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

void main() {
  const geniusApi = GeniusApi();
  runApp(const MyApp(
    geniusApi: geniusApi,
  ));
}

class MyApp extends StatelessWidget {
  final GeniusApi geniusApi;
  const MyApp({
    super.key,
    required this.geniusApi,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: geniusApi,
      child: BlocProvider(
        create: (context) => AppBloc(),
        child: MaterialApp.router(
          title: 'Flutter Demo',
          theme: ThemeData(
            buttonTheme: const ButtonThemeData(padding: EdgeInsets.all(0)),
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: GeniusWalletColors.gray900,
            colorScheme: const ColorScheme
                .dark(), //TODO: replace this once we have theme generated
          ),
          routerConfig: geniusWalletRouter,
        ),
      ),
    );
  }
}
