import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/theme/genius_wallet_text.dart';

class BackupPhraseScreen extends StatelessWidget {
  const BackupPhraseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: GeniusBreakpoints.small * 0.75,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20.0,
          children: [
            Text("Wallet Backup",
                style: Theme.of(context).textTheme.headlineLarge),
            Text(
                'In the next step you will see 12 words that allow you to recover a wallet.'),
            CheckboxListTile(
              value: context.watch<NewWalletBloc>().state.acceptedWarning,
              onChanged: (value) {
                context.read<NewWalletBloc>().add(ToggleCheckbox());
              },
              title: Text(GeniusWalletText.helpRecoveryWords),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            BlocBuilder<NewWalletBloc, NewWalletState>(
                builder: (context, state) {
              return SizedBox(
                width: 250,
                child: FilledButton(
                  onPressed: state.acceptedWarning
                      ? () {
                          context.read<NewWalletBloc>().add(
                                AgreementAccepted(
                                  userExists: context
                                          .read<AppBloc>()
                                          .state
                                          .userStatus ==
                                      UserStatus.exists,
                                ),
                              );
                        }
                      : null,
                  child: Text("Continue"),
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}
