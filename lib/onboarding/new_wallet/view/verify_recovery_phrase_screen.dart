import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:genius_wallet/utils/breakpoints.dart';

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
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final isNarrow = MediaQuery.sizeOf(context).width < GeniusBreakpoints.small;
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
          // Walk-driven (06-03 Task 3), same systemic gutter fix as
          // recovery_phrase_screen and 06-01's 67e2821: Padding OUTSIDE the
          // ConstrainedBox so the inset is additive and wide-window centring is
          // unchanged by construction.
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: GeniusWalletConsts.space8,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: GeniusBreakpoints.small,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 16.0,
                  children: [
                    Text(
                      "Verify Your Recovery Phrase",
                      style: GeniusWalletTypography.headlineLg.copyWith(
                        color: gw.textPrimary,
                      ),
                    ),
                    Text(
                      "Tap the words to put them next to each other in the correct order",
                      style: GeniusWalletTypography.bodyMd.copyWith(
                        color: gw.textSecondary,
                      ),
                    ),
                    _InputAndWords(key: _inputAndWordsKey),
                    // Walk-driven: full-width CTA on mobile; the 300px cap is a
                    // desktop affordance.
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isNarrow ? double.infinity : 300,
                      ),
                      child: GWButton(
                        label: 'Continue',
                        variant: GWButtonVariant.gradient,
                        size: GWButtonSize.lg,
                        expand: true,
                        onPressed: _triggerContinue,
                      ),
                    ),
                  ],
                ),
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
  static const selectWordCount = 4;
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
    const int emptyCount = selectWordCount;

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
        final String wordToReturn = userInputWords[index];
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
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    // Freeze rule (test/freeze_rule_test.dart): no dimension may be derived
    // CONTINUOUSLY from constraints. This replaces a FittedBox(scaleDown),
    // which ran a per-frame scale search on every drag-resize — the same defect
    // that hung the app from the dashboard chart. The size below is a discrete
    // choice between exactly TWO tokens, so the set is bounded.
    //
    // Deliberately NOT ellipsised: truncating a recovery word makes it
    // unreadable, and this is the one screen where that is unacceptable.
    final isNarrow = MediaQuery.sizeOf(context).width < GeniusBreakpoints.small;
    final baseWordStyle =
        (isNarrow
                ? GeniusWalletTypography.bodySm
                : GeniusWalletTypography.bodyLg)
            .copyWith(fontFamily: 'JetBrainsMono');

    return Column(
      spacing: 16.0,
      children: [
        Container(
          decoration: GWDecorations.surface(
            radius: GeniusWalletConsts.radiusLg,
            border: gw.borderSubtle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.count(
              shrinkWrap: true,
              // Walk-driven (06-03 Task 3), matching recovery_phrase_screen:
              // 3 columns clipped long words at narrow widths. Two columns buy
              // the width back; the aspect ratio rises in step so six rows do
              // not grow the grid vertically. Discrete literals — freeze rule
              // holds.
              crossAxisCount: isNarrow ? 2 : 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 6,
              childAspectRatio: isNarrow ? 4.5 : 3.0,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(userInputWords.length, (index) {
                final isEmpty = emptyIndices.contains(index);
                final isHighlighted = highlightedEmptyIndex == index;
                final hasUserInput =
                    isEmpty && userInputWords[index].isNotEmpty;
                // Same three-way outcome as develop's nested conditional:
                // placeholder only when the slot is empty AND unfilled.
                final isPlaceholder = isEmpty && userInputWords[index].isEmpty;

                return GestureDetector(
                  onTap: isEmpty ? () => _onEmptyBoxClick(index) : null,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        GeniusWalletConsts.radiusMd,
                      ),
                      border: Border.all(
                        color: isEmpty
                            ? (isHighlighted
                                  ? context.gw.brandPrimaryStrong
                                  : (hasUserInput
                                        ? context.gw.brandGreen
                                        : gw.borderSubtle))
                            : gw.borderSubtle,
                        width: isHighlighted ? 2.0 : 1.0,
                      ),
                      color: isEmpty
                          ? (isHighlighted
                                ? context.gw.brandPrimaryStrong.withAlpha(26)
                                : gw.surfaceSunken)
                          : gw.surfaceSunken,
                    ),
                    // Left-aligned to match recovery_phrase_screen's grid
                    // (walk-driven): the numbered words read as a list, not as
                    // centred chips. Placeholders inherit the same alignment so
                    // both grids share one visual language.
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      isPlaceholder
                          ? (isHighlighted ? '???' : '---')
                          : '${(index + 1).toString().padLeft(2, '0')}. ${userInputWords[index]}',
                      maxLines: 1,
                      style: baseWordStyle.copyWith(
                        color: isPlaceholder
                            ? gw.textSecondary
                            : gw.textPrimary,
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
