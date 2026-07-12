import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';

class BackupPhraseScreen extends StatelessWidget {
  const BackupPhraseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: GeniusBreakpoints.small * 0.75),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20.0,
          children: [
            Text(
              "Wallet Backup",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const Text(
              'In the next step you will see 12 words that allow you to recover a wallet.',
            ),
            CheckboxListTile(
              value: context.watch<NewWalletBloc>().state.acceptedWarning,
              onChanged: (value) {
                context.read<NewWalletBloc>().add(ToggleCheckbox());
              },
              title: const Text(
                'I understand that if I lose my recovery words, I will not be able to access my wallet.',
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            BlocBuilder<NewWalletBloc, NewWalletState>(
              builder: (context, state) {
                return GWButton(
                  label: 'Continue',
                  variant: GWButtonVariant.gradient,
                  size: GWButtonSize.lg,
                  expand: true,
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
