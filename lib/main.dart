import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/app/bloc/overlay/navigation_overlay_cubit.dart';
import 'package:genius_wallet/navigation/router.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:local_secure_storage/local_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final secureStorage = await LocalWalletStorage.create();
  final geniusApi = GeniusApi(secureStorage: secureStorage);
  runApp(MyApp(
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
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AppBloc(api: geniusApi),
          ),
          BlocProvider(
            create: (context) => NavigationOverlayCubit(),
          ),
        ],
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
