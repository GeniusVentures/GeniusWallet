import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/landing/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/widgets/components/recoveryword.g.dart';

class RecoveryWords extends StatelessWidget {
  const RecoveryWords({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewWalletBloc, NewWalletState>(
        bloc: context.watch<NewWalletBloc>(),
        builder: (context, state) {
          if (state.recoveryPhraseStatus == NewWalletStatus.loaded) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              width: MediaQuery.of(context).size.width *0.8,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: MediaQuery.of(context).size.width /
                      (MediaQuery.of(context).size.height / 4),
                ),
                itemCount: state.recoveryWords.length,
                itemBuilder: (context, index) {
                  return LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return Recoveryword(
                        constraints,
                        ovrWord: '${index + 1}. ${state.recoveryWords[index]}',
                      );
                    },
                  );
                },
              ),
            );
          } else if (state.recoveryPhraseStatus == NewWalletStatus.error) {
            return const Center(
              child: Text(
                  'We\'ve run into an unexpected issue. Please try again!'),
            );
          }
          return const CircularProgressIndicator();
        });
  }
}
