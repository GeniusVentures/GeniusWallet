import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';

class VerifyRecoveryPhraseScreen extends StatefulWidget {
  const VerifyRecoveryPhraseScreen({super.key});

  @override
  State<VerifyRecoveryPhraseScreen> createState() =>
      _VerifyRecoveryPhraseScreenState();
}

class _VerifyRecoveryPhraseScreenState
    extends State<VerifyRecoveryPhraseScreen> {
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<_InputAndWordsState> _inputAndWordsKey =
      GlobalKey<_InputAndWordsState>();

  @override
  void initState() {
    super.initState();
    context.read<NewWalletBloc>().add(LoadRecoveryPhrase());
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

    if (completeWordsList == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields before continuing.'),
        ),
      );
      return;
    }

    if (completeWordsList.any((word) => word.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all missing words.')),
      );
      return;
    }

    final newWalletBloc = context.read<NewWalletBloc>();
    newWalletBloc.add(RecoveryWordAssign(recoverywords: completeWordsList));
    newWalletBloc.add(RecoveryVerificationContinue());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NewWalletBloc, NewWalletState>(
      listener: (context, state) {
        if (state.verificationStatus == VerificationStatus.failed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification failed. Please try again.'),
            ),
          );
        }
      },
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
            _triggerContinue();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: GeniusBreakpoints.small),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 16.0,
                children: [
                  Text(
                    "Verify Your Recovery Phrase",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  Text(
                    "Tap the words to put them next to each other in the correct order",
                  ),
                  _InputAndWords(key: _inputAndWordsKey),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: FilledButton(
                      onPressed: _triggerContinue,
                      child: const Text("Continue"),
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
  const _InputAndWords({super.key});

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

    emptyIndices = <int>{};
    while (emptyIndices.length < emptyCount) {
      emptyIndices.add(random.nextInt(words.length));
    }

    userInputWords = List<String>.generate(words.length, (i) {
      return emptyIndices.contains(i) ? '' : words[i];
    });

    shuffledAvailableWords = [];
    for (int index in emptyIndices) {
      shuffledAvailableWords.add(originalWords[index]);
    }

    shuffledAvailableWords.shuffle(random);

    _updateHighlightedIndex();
  }

  void _updateHighlightedIndex() {
    final sortedEmptyIndices = emptyIndices.toList()..sort();

    highlightedEmptyIndex = null;
    for (int index in sortedEmptyIndices) {
      if (userInputWords[index].isEmpty) {
        highlightedEmptyIndex = index;
        break;
      }
    }
  }

  void _onWordClick(String word) {
    final sortedEmptyIndices = emptyIndices.toList()..sort();

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
        shuffledAvailableWords.remove(word);
        _updateHighlightedIndex();
      });
    }
  }

  void _onEmptyBoxClick(int index) {
    if (emptyIndices.contains(index) && userInputWords[index].isNotEmpty) {
      setState(() {
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
    return Column(
      spacing: 16.0,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 6,
              childAspectRatio: 3.0,
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
                                        : Colors.blue.withValues(alpha: 0.5)))
                            : Colors.grey,
                        width: isHighlighted ? 2.0 : 1.0,
                      ),
                      color: isEmpty
                          ? (isHighlighted
                                ? Colors.blue.withValues(alpha: 0.1)
                                : GeniusWalletColors.grayPrimary.withValues(
                                    alpha: 0.3,
                                  ))
                          : GeniusWalletColors.grayPrimary.withValues(
                              alpha: 0.3,
                            ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isEmpty
                          ? (userInputWords[index].isEmpty
                                ? (isHighlighted ? '???' : '---')
                                : '${(index + 1).toString().padLeft(2, '0')}. ${userInputWords[index].padRight(8)}')
                          : '${(index + 1).toString().padLeft(2, '0')}. ${userInputWords[index].padRight(8)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'JetBrainsMono',
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        // Available words to click
        if (shuffledAvailableWords.isNotEmpty)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: shuffledAvailableWords.map((word) {
              return ActionChip(
                label: Text(word),
                onPressed: () => _onWordClick(word),
              );
            }).toList(),
          ),
      ],
    );
  }
}
