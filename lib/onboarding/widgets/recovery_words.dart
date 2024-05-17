import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/widgets/components/recoveryword.g.dart';

class RecoveryWords extends StatelessWidget {
  final List<String> recoveryWords;
  final bool inputEnabled;

  const RecoveryWords(
      {super.key, required this.recoveryWords, this.inputEnabled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.topCenter,
        height: 150,
        width: 450,
        child: Wrap(alignment: WrapAlignment.center, runSpacing: 8, children: [
          for (var word in recoveryWords)
            MaterialButton(
              onPressed: inputEnabled
                  ? () {
                      context
                          .read<NewWalletBloc>()
                          .add(RecoveryWordTapped(wordTapped: word));
                    }
                  : null,
              child: LayoutBuilder(builder: (context, constraints) {
                return Recoveryword(
                  constraints,
                  ovrWord: word,
                );
              }),
            )
        ]));
  }
}
