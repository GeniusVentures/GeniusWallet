import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/app/widgets/app_screen_with_header_desktop.dart';
import 'package:genius_wallet/app/widgets/desktop_body_container.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/widgets/recovery_words.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_font_size.dart';
import 'package:genius_wallet/theme/genius_wallet_text.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_true.g.dart';
import 'package:genius_wallet/widgets/components/registration_header.g.dart';

class RecoveryPhraseScreen extends StatefulWidget {
  const RecoveryPhraseScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RecoveryPhraseScreenState();
  }
}

class _RecoveryPhraseScreenState extends State<RecoveryPhraseScreen> {
  @override
  Widget build(BuildContext context) {
    context.read<NewWalletBloc>().add(LoadRecoveryPhrase());
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (GeniusBreakpoints.useDesktopLayout(context)) {
            return const _RecoveryPhraseViewDesktop();
          }
          return const _RecoveryPhraseViewMobile();
        },
      ),
    );
  }
}

class _RecoveryPhraseViewDesktop extends StatelessWidget {
  const _RecoveryPhraseViewDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScreenWithHeaderDesktop(
      title: GeniusWalletText.titleRecovery,
      subtitle: GeniusWalletText.helpRecoveryPhrase,
      body: Center(
        child: DesktopBodyContainer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              const _WordsAndCopy(),
              const SizedBox(height: 80),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                height: 50,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return MaterialButton(
                      onPressed: () {
                        context
                            .read<NewWalletBloc>()
                            .add(RecoveryPhraseContinue());
                      },
                      child: IsactiveTrue(constraints),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecoveryPhraseViewMobile extends StatelessWidget {
  const _RecoveryPhraseViewMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScreenView(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 280,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return RegistrationHeader(
                  constraints,
                  ovrTitle: GeniusWalletText.titleRecovery,
                  ovrSubtitle: GeniusWalletText.helpRecoveryPhrase,
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 20),
            width: MediaQuery.of(context).size.width * 0.8,
            child: const _WordsAndCopy(),
          ),
        ],
      ),
      footer: SizedBox(
        width: MediaQuery.of(context).size.width * .8,
        height: 50,
        child: MaterialButton(
          onPressed: () {
            context.read<NewWalletBloc>().add(RecoveryPhraseContinue());
          },
          child: LayoutBuilder(builder: (context, constraints) {
            return IsactiveTrue(constraints);
          }),
        ),
      ),
    );
  }
}

class _WordsAndCopy extends StatefulWidget {
  const _WordsAndCopy({Key? key}) : super(key: key);

  @override
  State<_WordsAndCopy> createState() => _WordsAndCopyState();
}

class _WordsAndCopyState extends State<_WordsAndCopy> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BlocBuilder<NewWalletBloc, NewWalletState>(
          builder: (context, state) {
            if (state.recoveryPhraseStatus == NewWalletStatus.loaded) {
              return RecoveryWords(recoveryWords: state.recoveryWords);
            }
            return const CircularProgressIndicator();
          },
        ),
        const SizedBox(
          height: 20,
        ),
        TextButton.icon(
          onPressed: () async {
            await FlutterClipboard.copy(
                context.read<NewWalletBloc>().state.recoveryWords.join(' '));
            if (!mounted) {
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Recovery phrase copied to clipboard!'),
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            side: const BorderSide(
                width: 1.0, color: GeniusWalletColors.btnCopyBorder),
          ),
          icon: const Icon(Icons.content_copy,
              color: Colors.white, size: GeniusWalletFontSize.base),
          label: const Text(
            ' ${GeniusWalletText.btnCopy}',
            style: TextStyle(
                fontSize: GeniusWalletFontSize.medium, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
