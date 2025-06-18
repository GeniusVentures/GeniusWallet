import 'dart:math';

import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/components/app_screen_with_header_desktop.dart';
import 'package:genius_wallet/components/app_screen_with_header_mobile.dart';
import 'package:genius_wallet/components/desktop_body_container.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/widgets/recovery_words.dart';
import 'package:genius_wallet/onboarding/widgets/recovery_words_input.dart';
import 'package:genius_wallet/components/continue_button/isactive_true.g.dart';
import 'package:flutter/services.dart';

import '../../../components/app_screen_view.dart';
import '../../../components/registration_header.g.dart';
import '../../../theme/genius_wallet_text.dart';

class VerifyRecoveryPhraseScreen extends StatelessWidget {
  static const title = 'Verify Your Recovery Phrase';
  static const subtitle =
      'Tap the words to put them next to each other in the correct order';

  const VerifyRecoveryPhraseScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<NewWalletBloc, NewWalletState>(
      listener: (context, state) {
        if (state.verificationStatus == VerificationStatus.passed) {
          final newWalletBloc = context.read<NewWalletBloc>();
          newWalletBloc.add(
            AddWallet(wallet: newWalletBloc.wallet),
          );

          context.flow<NewWalletState>().complete();
        } else if (state.verificationStatus == VerificationStatus.failed) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Verification failed. Please try again.')));
        }
      },
      child: Scaffold(
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (GeniusBreakpoints.useDesktopLayout(context)) {
              return const _VerifyRecoveryPhraseViewDesktop(
                title: title,
                subtitle: subtitle,
              );
            }
            return const _VerifyRecoveryPhraseViewMobile(
              title: title,
              subtitle: subtitle,
            );
          },
        ),
      ),
    );
  }
}

class _VerifyRecoveryPhraseViewDesktop extends StatefulWidget {
  final String title;
  final String subtitle;

  const _VerifyRecoveryPhraseViewDesktop({
    required this.title,
    required this.subtitle,
    Key? key,
  }) : super(key: key);

  @override
  State<_VerifyRecoveryPhraseViewDesktop> createState() =>
      _VerifyRecoveryPhraseViewDesktopState();
}

class _VerifyRecoveryPhraseViewDesktopState
    extends State<_VerifyRecoveryPhraseViewDesktop> {
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<_InputAndWordsState> _inputAndWordsKey =
      GlobalKey<_InputAndWordsState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _triggerContinue() {
    final completeWordsList = _inputAndWordsKey.currentState?.completeWordsList;

    // Add null check and validation
    if (completeWordsList == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields before continuing.'),
        ),
      );
      return;
    }

    print("test $completeWordsList");

    // Optional: Check if all empty fields are filled
    if (completeWordsList.any((word) => word.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all missing words.'),
        ),
      );
      return;
    }

    // Update the BLoC state
    final newWalletBloc = context.read<NewWalletBloc>();

    newWalletBloc.add(RecoveryWordAssign(recoverywords: completeWordsList));

    // Trigger the verification
    newWalletBloc.add(RecoveryVerificationContinue());
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
          _triggerContinue();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: AppScreenWithHeaderDesktop(
        title: '',
        subtitle: '',
        body: Center(
          child: DesktopBodyContainer(
            title: widget.title,
            subText: widget.subtitle,
            width: 700,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 640,
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  _InputAndWords(key: _inputAndWordsKey),
                  const SizedBox(height: 50),
                  SizedBox(
                    height: 50,
                    child: MaterialButton(
                      onPressed: _triggerContinue,
                      child: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return IsactiveTrue(constraints);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InputAndWords extends StatefulWidget {
  const _InputAndWords({Key? key}) : super(key: key);

  @override
  State<_InputAndWords> createState() => _InputAndWordsState();
}

class _InputAndWordsState extends State<_InputAndWords> {
  late final List<String> missingWords;
  late final Set<int> emptyIndices;
  late final List<TextEditingController> controllers;
  late final List<FocusNode> focusNodes;
  late final List<String> originalWords;
  int? focusedIndex;

  @override
  void initState() {
    super.initState();
    _initializeWords();
  }

  void _initializeWords() {
    final words = context.read<NewWalletBloc>().state.recoveryWords;
    originalWords = List<String>.from(words);
    final random = Random();
    int emptyCount = 3 + random.nextInt(2); // 3 or 4

    emptyIndices = <int>{};
    while (emptyIndices.length < emptyCount) {
      emptyIndices.add(random.nextInt(words.length));
    }

    missingWords = List<String>.generate(words.length, (i) {
      return emptyIndices.contains(i) ? '' : words[i];
    });

    // Initialize controllers and focus nodes only for empty slots
    controllers =
        List.generate(words.length, (index) => TextEditingController());
    focusNodes = List.generate(words.length, (index) {
      final focusNode = FocusNode();
      if (emptyIndices.contains(index)) {
        focusNode.addListener(() {
          setState(() {
            focusedIndex = focusNode.hasFocus ? index : null;
          });
        });
      }
      return focusNode;
    });
  }

  List<String> get completeWordsList {
    List<String> result = List<String>.from(originalWords);

    // Replace empty entries with user input
    for (int index in emptyIndices) {
      result[index] = controllers[index].text.trim();
    }

    return result;
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(
            maxHeight: 360,
            maxWidth: 640,
          ),
          decoration: BoxDecoration(
            color: GeniusWalletColors.grayPrimary,
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
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 6,
            childAspectRatio: 2.5,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(missingWords.length, (index) {
              final isEmpty = emptyIndices.contains(index);
              final isFocused = focusedIndex == index;

              return Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      '${index + 1}.',
                      style: const TextStyle(
                        fontSize: 16,
                        color: GeniusWalletColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isEmpty
                              ? Colors.blue
                              : GeniusWalletColors.gray500,
                          width: 1.0,
                        ),
                        color: GeniusWalletColors.grayPrimary.withOpacity(0.3),
                      ),
                      child: isEmpty
                          ? TextField(
                              controller: controllers[index],
                              focusNode: focusNodes[index],
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: GeniusWalletColors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                                fillColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                filled: true,
                              ),
                            )
                          : Center(
                              child: Text(
                                missingWords[index],
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
        const SizedBox(height: 20),
      ],
    );
  }

  // void _focusNextEmptyField(int currentIndex) {
  //   final emptyList = emptyIndices.toList()..sort();
  //   final currentEmptyIndex = emptyList.indexOf(currentIndex);

  //   if (currentEmptyIndex < emptyList.length - 1) {
  //     final nextIndex = emptyList[currentEmptyIndex + 1];
  //     focusNodes[nextIndex].requestFocus();
  //   } else {
  //     // Last field, unfocus
  //     FocusScope.of(context).unfocus();
  //     setState(() {
  //       focusedIndex = null;
  //     });
  //   }
  // }
}

class _VerifyRecoveryPhraseViewMobile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _VerifyRecoveryPhraseViewMobile({
    required this.title,
    required this.subtitle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScreenView(
      // title: 'Verify Your Recovery Phrase',
      // subtitle:
      //     'Tap the words to put them next to each other in the correct order',
      body:  Column(

        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 280,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return RegistrationHeader(
                  constraints,
                  ovrTitle: GeniusWalletText.titleverifyRecovery,
                  ovrSubtitle: GeniusWalletText.subtitleverifyRecovery,
                );
              },
            ),
          ),
          Container(
          padding: const EdgeInsets.only(top: 0),
          margin: const EdgeInsets.only(bottom: 20),
          width: MediaQuery.of(context).size.width * 0.8,
          child: const _InputAndWordsForMobile(),
          ), // Adjusted spacing for balance
        ],
      ),
      footer: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 50,
          child: MaterialButton(
            onPressed: () {
              context.read<NewWalletBloc>().add(RecoveryVerificationContinueForMobile());
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                return IsactiveTrue(constraints);
              },
            ),
          ),
        ),
      ),
    );
  }
}


class _InputAndWordsForMobile extends StatelessWidget {
  const _InputAndWordsForMobile({Key? key}) : super(key: key);
  static const SELECT_WORD_COUNT = 4;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RecoveryWordsInput(
          selectedWords: context.watch<NewWalletBloc>().state.selectedWords,
        ),
        const SizedBox(
          height: 50,
        ),
        RecoveryWords(
            recoveryWords: context.read<NewWalletBloc>().state.shuffledWords.take(SELECT_WORD_COUNT).toList(),
            isIncludeIndex: false),
      ],
    );
  }
}