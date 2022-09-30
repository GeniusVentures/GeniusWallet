import 'package:flutter/material.dart';
import 'package:genius_wallet/app/widgets/app_screen_with_header.dart';
import 'package:genius_wallet/landing/widgets/recovery_words.dart';
import 'package:genius_wallet/landing/widgets/recovery_words_input.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_false.g.dart';

class VerifyRecoveryPhraseScreen extends StatelessWidget {
  const VerifyRecoveryPhraseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScreenWithHeader(
        title: 'Verify Your Recovery Phrase',
        subtitle:
            'Tap the words to put them next to each other in the correct order',
        bodyWidgets: const [
          RecoveryWordsInput(),
          SizedBox(
            height: 50,
          ),
          RecoveryWords(),
          SizedBox(
            height: 100,
          ),
        ],
        footer: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 50,
          child: LayoutBuilder(builder: (context, constraints) {
            return IsactiveFalse(constraints);
          }),
        ),
      ),
    );
  }
}
