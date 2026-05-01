import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';

class RecoveryWords extends StatefulWidget {
  final List<String> recoveryWords;
  final bool isIncludeIndex;
  const RecoveryWords(
      {super.key, required this.recoveryWords, this.isIncludeIndex = true});

  @override
  State<StatefulWidget> createState() {
    return _RecoveryWords();
  }
}

class _RecoveryWords extends State<RecoveryWords> {
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.topCenter,
        width: 450,
        child: Wrap(
            alignment: WrapAlignment.center,
            runSpacing: 4,
            spacing: 8,
            children: widget.recoveryWords
                .asMap()
                .entries
                .map((entry) => RecoveryWordButton(
                      value: entry.value,
                      index: entry.key + 1,
                      isIncludeIndex: widget.isIncludeIndex,
                    ))
                .toList()));
  }
}

class RecoveryWordButton extends StatefulWidget {
  final bool isIncludeIndex;
  final int index;
  final String value;
  const RecoveryWordButton({
    super.key,
    required this.index,
    required this.value,
    required this.isIncludeIndex,
  });

  @override
  State<StatefulWidget> createState() {
    return _RecoveryWordButton();
  }
}

class _RecoveryWordButton extends State<RecoveryWordButton> {
  bool isEnabled = true;

  void disable() {
    setState(() {
      isEnabled = false;
    });
  }

  void enable() {
    setState(() {
      isEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (context.read<NewWalletBloc>().state.verificationStatus ==
        VerificationStatus.failed) {
      enable();
    }

    return MaterialButton(
      onPressed: isEnabled
          ? () {
              context
                  .read<NewWalletBloc>()
                  .add(RecoveryWordTapped(wordTapped: widget.value));
              disable();
            }
          : null,
      child: LayoutBuilder(builder: (context, constraints) {
        return RecoveryWord(
          isEnabled: isEnabled,
          constraints,
          ovrWord: widget.isIncludeIndex
              ? "${widget.index}. ${widget.value}"
              : widget.value,
        );
      }),
    );
  }
}

class RecoveryWord extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrWord;
  final bool isEnabled;
  const RecoveryWord(this.constraints,
      {super.key, this.ovrWord, this.isEnabled = true});
  @override
  State<RecoveryWord> createState() => _Recoveryword();
}

class _Recoveryword extends State<RecoveryWord> {
  _Recoveryword();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(),
        child: Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(48)),
              border: widget.isEnabled
                  ? Border.all(
                      color: GeniusWalletColors.lightGreenSecondary,
                      width: 1.0,
                    )
                  : Border.all(
                      color: GeniusWalletColors.borderGrey,
                      width: 1.0,
                    ),
            ),
            child: AutoSizeText(
              widget.ovrWord ?? '1 limb',
              style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.0,
                  color: widget.isEnabled
                      ? Colors.white
                      : GeniusWalletColors.btnTextDisabled),
              textAlign: TextAlign.center,
            )));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
