import 'dart:math';

import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
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

    // Check if all empty fields are filled
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
              height: 700,
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  _InputAndWords(key: _inputAndWordsKey),
                  const SizedBox(height: 0),
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
  late final List<String> userInputWords;
  late final Set<int> emptyIndices;
  late final List<String> originalWords;
  late final List<String> shuffledAvailableWords;
  static const SELECT_WORD_COUNT = 4;
  int? highlightedEmptyIndex;

  @override
  void initState() {
    super.initState();
    _initializeWords();
  }

  void _initializeWords() {
    final words = context.read<NewWalletBloc>().state.recoveryWords;
    originalWords = List<String>.from(words);
    final random = Random();
    int emptyCount = SELECT_WORD_COUNT;

    // Select random indices to be empty
    emptyIndices = <int>{};
    while (emptyIndices.length < emptyCount) {
      emptyIndices.add(random.nextInt(words.length));
    }

    // Initialize user input words - empty for missing indices, original for filled
    userInputWords = List<String>.generate(words.length, (i) {
      return emptyIndices.contains(i) ? '' : words[i];
    });

    // Create shuffled list of only the missing words (SELECT_WORD_COUNT words)
    shuffledAvailableWords = [];
    for (int index in emptyIndices) {
      shuffledAvailableWords.add(originalWords[index]);
    }

    // Shuffle the missing words
    shuffledAvailableWords.shuffle(random);

    // Set the first empty box as highlighted
    _updateHighlightedIndex();
  }

  void _updateHighlightedIndex() {
    // Get sorted empty indices to process in order
    final sortedEmptyIndices = emptyIndices.toList()..sort();

    // Find the first empty index in sorted order to highlight
    highlightedEmptyIndex = null;
    for (int index in sortedEmptyIndices) {
      if (userInputWords[index].isEmpty) {
        highlightedEmptyIndex = index;
        break;
      }
    }
  }

  void _onWordClick(String word) {
    // Get sorted empty indices to fill in order
    final sortedEmptyIndices = emptyIndices.toList()..sort();

    // Find the first empty slot in order
    int? targetIndex;
    for (int index in sortedEmptyIndices) {
      if (userInputWords[index].isEmpty) {
        targetIndex = index;
        break;
      }
    }

    if (targetIndex != null) {
      setState(() {
        userInputWords[targetIndex!] = word;
        // Remove the word from available words
        shuffledAvailableWords.remove(word);
        _updateHighlightedIndex();
      });
    }
  }

  void _onEmptyBoxClick(int index) {
    if (emptyIndices.contains(index) && userInputWords[index].isNotEmpty) {
      setState(() {
        // Return the word to available words
        String wordToReturn = userInputWords[index];
        userInputWords[index] = '';
        shuffledAvailableWords.add(wordToReturn);
        shuffledAvailableWords.shuffle();
        _updateHighlightedIndex();
      });
    }
  }

  List<String> get completeWordsList {
    return List<String>.from(userInputWords);
  }

  @override
  Widget build(BuildContext context) {
    return GeniusBreakpoints.useDesktopLayout(context)
        ? Column(
            children: [
              // Recovery phrase grid
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
                  children: List.generate(userInputWords.length, (index) {
                    final isEmpty = emptyIndices.contains(index);
                    final isHighlighted = highlightedEmptyIndex == index;
                    final hasUserInput =
                        isEmpty && userInputWords[index].isNotEmpty;

                    return Row(
                      children: [
                        SizedBox(
                          width: 30,
                          child: Text(
                            '${index + 1}.',
                            style: TextStyle(
                              fontSize:
                                  GeniusBreakpoints.useDesktopLayout(context)
                                      ? 16
                                      : 10,
                              color: GeniusWalletColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: GestureDetector(
                            onTap:
                                isEmpty ? () => _onEmptyBoxClick(index) : null,
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isEmpty
                                      ? (isHighlighted
                                          ? Colors.blue
                                          : (hasUserInput
                                              ? Colors.green
                                              : Colors.blue.withOpacity(0.5)))
                                      : GeniusWalletColors.gray500,
                                  width: isHighlighted ? 2.0 : 1.0,
                                ),
                                color: isEmpty
                                    ? (isHighlighted
                                        ? Colors.blue.withOpacity(0.1)
                                        : GeniusWalletColors.grayPrimary
                                            .withOpacity(0.3))
                                    : GeniusWalletColors.grayPrimary
                                        .withOpacity(0.3),
                              ),
                              child: Center(
                                child: Text(
                                  isEmpty
                                      ? (userInputWords[index].isEmpty
                                          ? (isHighlighted ? '?' : '')
                                          : userInputWords[index])
                                      : userInputWords[index],
                                  style: TextStyle(
                                    fontSize:
                                        GeniusBreakpoints.useDesktopLayout(
                                                context)
                                            ? 16
                                            : 10,
                                    color:
                                        isEmpty && userInputWords[index].isEmpty
                                            ? Colors.blue.withOpacity(0.7)
                                            : GeniusWalletColors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 30),

              // Available words to click
              if (shuffledAvailableWords.isNotEmpty) ...[
                Text(
                  'Click on a word to fill the highlighted box:',
                  style: TextStyle(
                    fontSize:
                        GeniusBreakpoints.useDesktopLayout(context) ? 16 : 10,
                    color: GeniusWalletColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: shuffledAvailableWords.map((word) {
                      return GestureDetector(
                        onTap: () => _onWordClick(word),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.blue,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            word,
                            style: const TextStyle(
                              fontSize: 14,
                              color: GeniusWalletColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          )
        : SingleChildScrollView(
            child: Column(
              children: [
                // Recovery phrase grid
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
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
                  padding: const EdgeInsets.all(16),
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2, // 2 columns for mobile
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 10,
                    childAspectRatio: 3.5,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(userInputWords.length, (index) {
                      final isEmpty = emptyIndices.contains(index);
                      final isHighlighted = highlightedEmptyIndex == index;
                      final hasUserInput =
                          isEmpty && userInputWords[index].isNotEmpty;

                      return GestureDetector(
                        onTap: isEmpty ? () => _onEmptyBoxClick(index) : null,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isEmpty
                                  ? (isHighlighted
                                      ? Colors.blue
                                      : (hasUserInput
                                          ? Colors.green
                                          : Colors.blue.withOpacity(0.5)))
                                  : GeniusWalletColors.gray500,
                              width: isHighlighted ? 2.0 : 1.0,
                            ),
                            color: isEmpty
                                ? (isHighlighted
                                    ? Colors.blue.withOpacity(0.1)
                                    : GeniusWalletColors.grayPrimary
                                        .withOpacity(0.3))
                                : GeniusWalletColors.grayPrimary
                                    .withOpacity(0.3),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: GeniusWalletColors.gray500
                                      .withOpacity(0.3),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(11),
                                    bottomLeft: Radius.circular(11),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: GeniusWalletColors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    isEmpty
                                        ? (userInputWords[index].isEmpty
                                            ? (isHighlighted ? '?' : '')
                                            : userInputWords[index])
                                        : userInputWords[index],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isEmpty &&
                                              userInputWords[index].isEmpty
                                          ? Colors.blue.withOpacity(0.7)
                                          : GeniusWalletColors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 30),

                // Available words to click
                if (shuffledAvailableWords.isNotEmpty) ...[
                  const Text(
                    'Tap a word to fill the highlighted box:',
                    style: TextStyle(
                      fontSize: 16,
                      color: GeniusWalletColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                    ),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: shuffledAvailableWords.map((word) {
                        return GestureDetector(
                          onTap: () => _onWordClick(word),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.blue,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              word,
                              style: const TextStyle(
                                fontSize: 16,
                                color: GeniusWalletColors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ] else ...[
                  // Show completion message when all words are filled
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green,
                        width: 1.5,
                      ),
                    ),
                    child: const Text(
                      'All words have been filled.              Press continue.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                const SizedBox(height: 30),
              ],
            ),
          );
  }
}

class _VerifyRecoveryPhraseViewMobile extends StatefulWidget {
  final String title;
  final String subtitle;

  const _VerifyRecoveryPhraseViewMobile({
    required this.title,
    required this.subtitle,
    Key? key,
  }) : super(key: key);

  @override
  State<_VerifyRecoveryPhraseViewMobile> createState() =>
      _VerifyRecoveryPhraseViewMobileState();
}

class _VerifyRecoveryPhraseViewMobileState
    extends State<_VerifyRecoveryPhraseViewMobile> {
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

    // Check if all empty fields are filled
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
    newWalletBloc.add(RecoveryVerificationContinue());
  }

  @override
  Widget build(BuildContext context) {
    return AppScreenView(
      body: Column(
        children: [
          // Fixed header - works well on mobile
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 180,
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
          // Expanded middle section - takes remaining space
         Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _InputAndWords(key: _inputAndWordsKey),
            ),
        ],
      ),
      footer: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 50,
          child: MaterialButton(
            onPressed: _triggerContinue,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return IsactiveTrue(constraints);
              },
            ),
          ),
        ),
      ),
    );
  }}
