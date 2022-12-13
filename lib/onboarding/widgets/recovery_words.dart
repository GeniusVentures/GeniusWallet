import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/widgets/components/recoveryword.g.dart';

class RecoveryWords extends StatelessWidget {
  final List<String> recoveryWords;
  final bool inputEnabled;
  const RecoveryWords({
    super.key,
    required this.recoveryWords,
    this.inputEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      width: MediaQuery.of(context).size.width * 0.8,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: MediaQuery.of(context).size.width /
              (MediaQuery.of(context).size.height / 4),
        ),
        itemCount: recoveryWords.length,
        itemBuilder: (context, index) {
          final currentWord = recoveryWords[index];
          if (inputEnabled) {
            return MaterialButton(
              onPressed: () {
                context
                    .read<NewWalletBloc>()
                    .add(RecoveryWordTapped(wordTapped: currentWord));
              },
              child: LayoutBuilder(builder: (context, constraints) {
                return Recoveryword(
                  constraints,
                  ovrWord: currentWord,
                );
              }),
            );
          }
          return LayoutBuilder(builder: (context, constraints) {
            return Recoveryword(
              constraints,
              ovrWord: '${index + 1}. $currentWord',
            );
          });
        },
      ),
    );
  }
}
