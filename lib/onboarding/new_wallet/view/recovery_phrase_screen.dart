import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';

class RecoveryPhraseScreen extends StatefulWidget {
  const RecoveryPhraseScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RecoveryPhraseScreenState();
  }
}

class _RecoveryPhraseScreenState extends State<RecoveryPhraseScreen> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    context.read<NewWalletBloc>().add(LoadRecoveryPhrase());
    return Center(
      child: SizedBox(
        width: GeniusBreakpoints.small,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16.0,
          children: [
            Text("Your Recovery Phrase",
                style: Theme.of(context).textTheme.headlineLarge),
            Text(
                "Write down this 12-word Secret Recovery Phrase and save it in a place that you trust and only you can access."),
            _buildWordsGridWithCopyAndToggle(),
            SizedBox(
              width: 300,
              child: FilledButton(
                onPressed: () {
                  context.read<NewWalletBloc>().add(RecoveryPhraseContinue());
                },
                child: Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordsGridWithCopyAndToggle() {
    return BlocBuilder<NewWalletBloc, NewWalletState>(
      builder: (context, state) {
        if (state.recoveryPhraseStatus != NewWalletStatus.loaded) {
          return const Center(child: Loading());
        }

        final words = state.recoveryWords;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8.0,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 3.0,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(words.length, (index) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: GeniusWalletColors.gray500,
                          width: 1.0,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${(index + 1).toString().padLeft(2, '0')}. ${_isVisible ? words[index].padRight(8) : '••••••'}',
                        style: const TextStyle(
                            fontSize: 16, fontFamily: "JetBrainsMono"),
                      ),
                    );
                  }),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    await FlutterClipboard.copy(words.join(' '));
                    if (!mounted) return;
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
          ],
        );
      },
    );
  }
}
