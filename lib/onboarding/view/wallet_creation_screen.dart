import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/widgets/components/wallet_button/type_create.g.dart';
import 'package:genius_wallet/widgets/components/wallet_button/type_existing.g.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScreenView(
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
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
                height: 50,
                width: 450,
                child: LayoutBuilder(
                  builder: (context, constraints) => TypeCreate(constraints),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              SizedBox(
                height: 50,
                width: 450,
                child: LayoutBuilder(
                  builder: (context, constraints) => TypeExisting(constraints),
                ),
              ),

              /***  Below is the test code to test native c/c++ code ***/

              // Container(
              //   margin: const EdgeInsets.only(top: 10.0),
              //   child: ElevatedButton(
              //     onPressed: () {
              //       context.read<AppBloc>().add(FFITestEvent());
              //     },
              //     child: const Text("Test C++ native code!"),
              //   ),
              // ),
              BlocBuilder<AppBloc, AppState>(
                builder: (context, state) {
                  if (state.ffiString != null) {
                    return Text('Value: ${state.ffiString}');
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
