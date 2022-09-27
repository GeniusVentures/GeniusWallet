import 'package:flutter/material.dart';
import 'package:genius_wallet/app/widgets/app_screen_with_header.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_false.g.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_true.g.dart';
import 'package:genius_wallet/widgets/components/passcode_entry.g.dart';

class ConfirmPasscodeScreen extends StatelessWidget {
  const ConfirmPasscodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScreenWithHeader(
        title: 'Confirm your passcode',
        subtitle: 'Enter your passcode once more',
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
                const Text('Confirm Passcode'),
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
              return IsactiveFalse(constraints);
            },
          ),
        ),
      ),
    );
  }
}
