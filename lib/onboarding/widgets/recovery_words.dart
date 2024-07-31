import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/widgets/components/recoveryword.g.dart';

class RecoveryWords extends StatelessWidget {
  final List<String> recoveryWords;
  final bool inputEnabled;
  final bool isIncludeIndex;

  const RecoveryWords(
      {super.key,
      required this.recoveryWords,
      this.inputEnabled = false,
      this.isIncludeIndex = true});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.topCenter,
        width: 450,
        child: Wrap(
            alignment: WrapAlignment.center,
            runSpacing: 4,
            spacing: 8,
            children: recoveryWords
                .asMap()
                .entries
                .map((entry) => MaterialButton(
                      onPressed: inputEnabled
                          ? () {
                              context.read<NewWalletBloc>().add(
                                  RecoveryWordTapped(wordTapped: entry.value));
                            }
                          : null,
                      child: LayoutBuilder(builder: (context, constraints) {
                        return Recoveryword(
                          constraints,
                          ovrWord: isIncludeIndex
                              ? "${entry.key + 1}. ${entry.value}"
                              : entry.value,
                        );
                      }),
                    ))
                .toList()));
  }
}
