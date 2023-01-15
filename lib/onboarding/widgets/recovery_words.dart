import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/widgets/components/recoveryword.g.dart';

class RecoveryWords extends StatelessWidget {
  final List<String> recoveryWords;
  final bool inputEnabled;

  static const _numCols = 3;

  const RecoveryWords({
    super.key,
    required this.recoveryWords,
    this.inputEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final numRows = (recoveryWords.length / _numCols).ceil();
    final isDesktop = GeniusBreakpoints.useDesktopLayout(context);
    return SizedBox(
      height:
          isDesktop ? numRows * 60 : MediaQuery.of(context).size.height * 0.5,
      child: GridView.builder(
        physics: isDesktop ? const NeverScrollableScrollPhysics() : null,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _numCols,
          mainAxisSpacing: 10,
          crossAxisSpacing: 20,
          childAspectRatio: isDesktop
              ? 3
              : MediaQuery.of(context).size.width /
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
