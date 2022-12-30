import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/widgets/components/wallet_button/type_create.g.dart';
import 'package:genius_wallet/widgets/components/wallet_button/type_existing.g.dart';
import 'package:genius_wallet/ffi_bridge.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //TODO: Can make this future based instead
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
                  builder: (context, constraints) => TypeCreate(constraints),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 50,
                child: LayoutBuilder(
                  builder: (context, constraints) => TypeExisting(constraints),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(40),
                  child: ElevatedButton(
                      onPressed: () {
                        final dylib = DynamicLibrary.open('libnative.so');
                        final getTemperature = dylib.lookupFunction<
                            TemperatureFunction,
                            TemperatureFunctionDart>('get_temperature');
                        final valueTest = getTemperature();
                        debugPrint('Getting valueTest From C++: $valueTest');

                        // final FFIBridge ffiBridge = FFIBridge();
                        // final valueFromC = ffiBridge.getValueFromNative();
                        // debugPrint('Getting Value From C++: $valueFromC');
                      },
                      child: Text("Test C++ code in iOS!")))
            ],
          ),
        ),
      ),
    );
  }
}
