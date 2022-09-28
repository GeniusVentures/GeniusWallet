import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/widgets/app_screen_with_header.dart';
import 'package:genius_wallet/landing/existing_wallet/bloc/existing_wallet_bloc.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_true.g.dart';
import 'package:genius_wallet/widgets/components/passcode_entry.g.dart';

class CreatePasscodeScreen extends StatelessWidget {
  const CreatePasscodeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScreenWithHeader(
        title: 'Set Passcode',
        subtitle: 'Adds an extra layer of security when using the app',
        bodyWidgets: [
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 100,
              maxHeight: MediaQuery.of(context).size.height * 0.6,
              minWidth: MediaQuery.of(context).size.width * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Create Passcode'),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 50,
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return PasscodeEntry(constraints);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
        footer: SizedBox(
          height: 50,
          width: MediaQuery.of(context).size.width * 0.8,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return MaterialButton(
                onPressed: () {
                  context
                      .read<ExistingWalletBloc>()
                      .add(ChangeStep(step: FlowStep.confirmPasscode));
                },
                child: IsactiveTrue(constraints),
              );
            },
          ),
        ),
      ),
    );
  }
}
