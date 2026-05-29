import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/web/web_utils.dart';

class LegalScreen extends StatelessWidget {
  final bool accepted;
  final VoidCallback onToggle;
  final VoidCallback onContinue;

  const LegalScreen({
    super.key,
    required this.accepted,
    required this.onToggle,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: GeniusBreakpoints.small * 2 / 3,
        child: Column(mainAxisSize: MainAxisSize.min, spacing: 20.0, children: [
          Text(
            "Legal",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          Text(
              'Please review the privacy policy and terms of service before proceeding.'),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => launchWebSite(
                  context, 'https://www.gnus.ai/privacypolicy.html'),
              child: Text('Privacy Policy'),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () =>
                  launchWebSite(context, 'https://www.gnus.ai/tos.html'),
              child: Text('Terms of Service'),
            ),
          ),
          CheckboxListTile(
            value: accepted,
            onChanged: (value) => onToggle(),
            title: AutoSizeText(
              'I\'ve read and accept the Terms of Service and Privacy Policy',
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: accepted ? onContinue : null,
              child: Text("Continue"),
            ),
          ),
        ]),
      ),
    );
  }
}
