import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/widgets/components/wallet_button/type_create.g.dart';
import 'package:genius_wallet/widgets/components/wallet_button/type_existing.g.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    /// TODO: @David, edit this BlocBuilder according to your needs with FFI lib.
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (state.ffiStatus == AppStatus.loading) {
          return const CircularProgressIndicator();
        } else if (state.ffiStatus == AppStatus.loaded) {
          // final ffiBridgePrebuilt =
          //     context.read<AppBloc>().state.ffiInformation;
          final api = context.read<GeniusApi>();
          return Scaffold(
            body: AppScreenView(
              body: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo_and_title.png',
                      package: 'genius_wallet',
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 50,
                      child: LayoutBuilder(
                        builder: (context, constraints) =>
                            TypeCreate(constraints),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 50,
                      child: LayoutBuilder(
                        builder: (context, constraints) =>
                            TypeExisting(constraints),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(40),
                        child: ElevatedButton(
                            onPressed: () {
                              final valueTest = api.getNativeValue();
                              debugPrint(
                                  'Getting valueTest From xxx C++: $valueTest');
                            },
                            child: Text("Test C++ code in iOS!")))
                  ],
                ),
              ),
            ),
          );
        } else {
          return const Center(
            child: Text('Something went wrong!'),
          );
        }
      },
    );
  }
}
