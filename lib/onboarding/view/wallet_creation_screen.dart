import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/widgets/components/wallet_button/type_create.g.dart';
import 'package:genius_wallet/widgets/components/wallet_button/type_existing.g.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GeniusWalletColors.deepBlue,
      body: AppScreenView(
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 80,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/logo_and_title.png',
                  package: 'genius_wallet',
                ),
              ),
              Align(
                  alignment: Alignment.center,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 50,
                          width: 450,
                          child: LayoutBuilder(
                            builder: (context, constraints) =>
                                TypeExisting(constraints),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          height: 50,
                          width: 450,
                          child: LayoutBuilder(
                            builder: (context, constraints) =>
                                TypeCreate(constraints),
                          ),
                        ),

                        /***  Below is the test code to test native c/c++ code ***/

                        //SizedBox(
                        //  width: 450,
                        //  height: 50,
                        // child: Container(
                        //    decoration: BoxDecoration(
                        //    borderRadius: BorderRadius.circular(68),
                        //    border: Border.all(
                        //        width: 1.0, color: GeniusWalletColors.lightGreenPrimary)),
                        //   margin: const EdgeInsets.only(top: 10.0),
                        //   child: ElevatedButton(
                        //      style: ButtonStyle(
                        //        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent), // Set the background color to transparent
                        //        foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Set the text color to white
                        //        padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0)), // Add some padding
                        //        textStyle: MaterialStateProperty.all<TextStyle>(
                        //          TextStyle(
                        //            fontSize: 8.0, // Set the font size
                        //          ),
                        //        ),
                        //        shadowColor: MaterialStateProperty.all<Color>(Colors.transparent), // Remove the shadow
                        //      ),
                        //     onPressed: () {
                        //       context.read<AppBloc>().add(FFITestEvent());
                        //     },
                        //     child: 
                        //      const Text("Test Process MNN",
                        //      style: TextStyle(
                        //        color: Colors.white, // Set the text color to white
                        //        fontSize: 13.0, // Set the font size
                        //      ), )
                        //   ),
                        // ),
                        //),


                        BlocBuilder<AppBloc, AppState>(
                          builder: (context, state) {
                            if (state.ffiString != null) {
                              return Text(' ${state.ffiString}');
                            }
                            return const SizedBox();
                          },
                        ),
                      ]))
            ],
          ),
        ),
      ),
    );
  }
}
