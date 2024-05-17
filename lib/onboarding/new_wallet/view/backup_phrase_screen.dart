import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/app/widgets/app_screen_with_header_desktop.dart';
import 'package:genius_wallet/app/widgets/desktop_body_container.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/theme/genius_wallet_text.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_false.g.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_true.g.dart';
import 'package:genius_wallet/widgets/components/custom/wallet_agreement_custom.dart';
import 'package:genius_wallet/widgets/components/registration_header.g.dart';

class BackupPhraseScreen extends StatelessWidget {
  const BackupPhraseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        if (GeniusBreakpoints.useDesktopLayout(context)) {
          return const _BackupPhraseViewDesktop();
        }
        return const _BackupPhraseViewMobile();
      }),
    );
  }
}

class _BackupPhraseViewMobile extends StatelessWidget {
  const _BackupPhraseViewMobile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScreenView(
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 190,
            child: LayoutBuilder(builder: (context, constraints) {
              return RegistrationHeader(
                constraints,
                ovrSubtitle: GeniusWalletText.helpTextWalletBackup,
              );
            }),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.58,
          ),
          SizedBox(
            height: 60,
            width: MediaQuery.of(context).size.width * 0.86,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return WalletAgreementCustom(
                  value: context.watch<NewWalletBloc>().state.acceptedWarning,
                  onChanged: (value) {
                    context.read<NewWalletBloc>().add(ToggleCheckbox());
                  },
                  text: GeniusWalletText.helpRecoveryWords,
                );
              },
            ),
          ),
        ],
      ),
      footer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 46,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return BlocBuilder<NewWalletBloc, NewWalletState>(
              builder: (context, state) {
                if (state.acceptedWarning) {
                  return MaterialButton(
                    onPressed: () {
                      context.read<NewWalletBloc>().add(
                            AgreementAccepted(
                              userExists:
                                  context.read<AppBloc>().state.userStatus ==
                                      UserStatus.exists,
                            ),
                          );
                    },
                    child: IsactiveTrue(constraints),
                  );
                }
                return IsactiveFalse(constraints);
              },
            );
          },
        ),
      ),
    );
  }
}

class _BackupPhraseViewDesktop extends StatelessWidget {
  const _BackupPhraseViewDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScreenWithHeaderDesktop(
      title: '',
      subtitle: '',
      body: Center(
        child: DesktopBodyContainer(
          title: "Wallet Backup",
          subText:
              'In the next step you will see 12 words that allow you to recover a wallet.',
          child: Column(
            children: [
              SizedBox(
                height: 50,
                width: 400,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return WalletAgreementCustom(
                      value:
                          context.watch<NewWalletBloc>().state.acceptedWarning,
                      onChanged: (value) {
                        context.read<NewWalletBloc>().add(ToggleCheckbox());
                      },
                      text: GeniusWalletText.helpRecoveryWords,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 400,
                height: 46,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return BlocBuilder<NewWalletBloc, NewWalletState>(
                      builder: (context, state) {
                        if (state.acceptedWarning) {
                          return MaterialButton(
                            onPressed: () {
                              context.read<NewWalletBloc>().add(
                                    AgreementAccepted(
                                      userExists: context
                                              .read<AppBloc>()
                                              .state
                                              .userStatus ==
                                          UserStatus.exists,
                                    ),
                                  );
                            },
                            child: IsactiveTrue(constraints),
                          );
                        }
                        return IsactiveFalse(constraints);
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
