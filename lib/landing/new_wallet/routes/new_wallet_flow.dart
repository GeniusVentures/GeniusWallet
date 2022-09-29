import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/landing/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/landing/view/backup_phrase_screen.dart';

class NewWalletFlow extends StatelessWidget {
  const NewWalletFlow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlowBuilder(
      onGeneratePages: (state, pages) {
        return [
          const MaterialPage(child: BackupPhraseScreen()),
        ];
      },
      state: context.watch<NewWalletBloc>().state,
    );
  }
}
