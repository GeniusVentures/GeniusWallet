import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/components/app_screen_view.dart';
import 'package:genius_wallet/components/app_screen_with_header_desktop.dart';
import 'package:genius_wallet/components/desktop_body_container.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/widgets/recovery_words.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_font_size.dart';
import 'package:genius_wallet/theme/genius_wallet_text.dart';
import 'package:genius_wallet/components/continue_button/isactive_true.g.dart';
import 'package:genius_wallet/components/registration_header.g.dart';
import 'package:flutter/services.dart';

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

class _RecoveryPhraseViewDesktop extends StatefulWidget {
  const _RecoveryPhraseViewDesktop({Key? key}) : super(key: key);

  @override
  State<_RecoveryPhraseViewDesktop> createState() =>
      _RecoveryPhraseViewDesktopState();
}

class _RecoveryPhraseViewDesktopState
    extends State<_RecoveryPhraseViewDesktop> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus(); // Automatically focus after build
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _triggerContinue() {
    context.read<NewWalletBloc>().add(RecoveryPhraseContinue());
  }

  @override
  Widget build(BuildContext context) {
    return AppScreenWithHeaderDesktop(
      title: '',
      subtitle: '',
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              GeniusWalletText.titleRecovery,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            const Text(
              GeniusWalletText.helpRecoveryPhrase,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 60),
            const _WordsGridWithCopyAndToggle(), // grid with recovery words
            const SizedBox(height: 30),
            SizedBox(
              height: 50,
              width: 640,
              child: MaterialButton(
                onPressed: _triggerContinue,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return IsactiveTrue(constraints);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WordsGridWithCopyAndToggle extends StatefulWidget {
  const _WordsGridWithCopyAndToggle({super.key});

  @override
  State<_WordsGridWithCopyAndToggle> createState() =>
      _WordsGridWithCopyAndToggleState();
}

class _WordsGridWithCopyAndToggleState
    extends State<_WordsGridWithCopyAndToggle> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewWalletBloc, NewWalletState>(
      builder: (context, state) {
        if (state.recoveryPhraseStatus != NewWalletStatus.loaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final words = state.recoveryWords;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              constraints: const BoxConstraints(
                maxHeight: 360,
                maxWidth: 640,
              ),
              decoration: BoxDecoration(
                color: _isVisible
                    ? GeniusWalletColors.grayPrimary
                    : GeniusWalletColors.grayPrimary
                        .withOpacity(0.4), // darker effect
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: GeniusWalletColors.gray500,
                  width: 2.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
              child: SizedBox(
                height: 380,
                width: 650,
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 6,
                  childAspectRatio: 2.5,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(words.length, (index) {
                    return Row(
                      children: [
                        SizedBox(
                          width: 30,
                          child: Text(
                            '${index + 1}. ',
                            style: const TextStyle(
                              fontSize: 16,
                              color: GeniusWalletColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: GeniusWalletColors.gray500,
                                width: 1.0,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _isVisible ? words[index] : '••••••',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: GeniusWalletColors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 80),
            SizedBox(
              width: 640, // Match the maxWidth of AnimatedContainer
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      await FlutterClipboard.copy(words.join(' '));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text("Recovery phrase copied to clipboard!")),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text("Copy to clipboard"),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isVisible = !_isVisible;
                      });
                    },
                    icon: Icon(
                        _isVisible ? Icons.visibility_off : Icons.visibility),
                    label: Text(
                        _isVisible ? "Hide seed phrase" : "Show seed phrase"),
                  ),
                ],
              ),
            ),
          ],
        );
      },
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
            padding: const EdgeInsets.only(top: 0),
            margin: const EdgeInsets.only(bottom: 20),
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
