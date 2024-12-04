import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

class SubmitJobScreen extends StatelessWidget {
  const SubmitJobScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(36.0),
        child: SingleChildScrollView(
            child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height, // Minimum height
                ),
                child: Column(children: [
                  Text(
                    'Submit a New Job',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use this file upload to submit a new job process to the Genius SDK.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '* You must have enough GNUS to pay for the job',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 32),
                  const SubmitJobForm()
                ]))));
  }
}

class SubmitJobForm extends StatefulWidget {
  const SubmitJobForm({Key? key}) : super(key: key);

  @override
  SubmitJobFormState createState() => SubmitJobFormState();
}

class SubmitJobFormState extends State<SubmitJobForm> {
  String? _uploadedFileName;
  Map<String, dynamic>? _jsonData;
  int _cost = 0;

  void resetState() {
    setState(() {
      _uploadedFileName = null;
      _jsonData = null;
      _cost = 0;
    });
  }

  // Function to pick a JSON file
  Future<void> _pickJsonFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final jsonData = jsonDecode(content);

        setState(() {
          _uploadedFileName = result.files.single.name;
          _jsonData = jsonData;
          final jobJson = jsonEncode(_jsonData);
          _cost =
              context.read<GeniusApi>().requestGeniusSDKCost(jobJson: jobJson);
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: GeniusWalletColors.containerGray,
            content:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Failed to upload JSON file:',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              Text('$e',
                  style: const TextStyle(
                      color: GeniusWalletColors.red, fontSize: 18))
            ]),
          ),
        );
      }
      resetState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final geniusApi = context.read<GeniusApi>();
    final geniusBalance = geniusApi.getSGNUSBalance();
    final isPurchaseable = _cost < geniusBalance;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: _pickJsonFile,
                style: const ButtonStyle(
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(
                          GeniusWalletConsts.borderRadiusButton)))),
                  padding: WidgetStatePropertyAll(
                      EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8)),
                ),
                child: const Text('Upload JSON File'),
              ),
              const SizedBox(width: 16),
              if (_uploadedFileName != null && _jsonData != null)
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: GeniusWalletColors.deepBlueCardColor,
                    disabledForegroundColor: GeniusWalletColors.gray500,
                    disabledBackgroundColor:
                        GeniusWalletColors.deepBlueSecondary,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(
                            GeniusWalletConsts.borderRadiusButton))),
                    backgroundColor: GeniusWalletColors.lightGreenPrimary,
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 8, bottom: 8),
                  ),
                  // disable button if not enought gnus balance to pay for the job
                  onPressed: !isPurchaseable
                      ? null
                      : () {
                          final jobJson = jsonEncode(_jsonData);
                          geniusApi.requestGeniusSDKProcess(jobJson: jobJson);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: GeniusWalletColors.containerGray,
                              content: Row(children: [
                                const Text('Successfully Submitted Job:   ',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18)),
                                Text('$_uploadedFileName',
                                    style: const TextStyle(
                                        color: GeniusWalletColors.successGreen,
                                        fontSize: 18))
                              ]),
                            ),
                          );
                          resetState();
                        },
                  child: const Text(
                    'Submit Job',
                  ),
                ),
            ],
          ),
          const SizedBox(
            height: 64,
          ),
          if (_uploadedFileName != null)
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(runSpacing: 12, spacing: 12, children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Uploaded File: ',
                      style: TextStyle(fontSize: 16, letterSpacing: 1.2)),
                  Text(
                    "$_uploadedFileName",
                    style: const TextStyle(
                        fontSize: 16,
                        letterSpacing: 1.5,
                        color: GeniusWalletColors.lightGreenPrimary),
                  ),
                ]),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text(
                    'Cost: ',
                    style: TextStyle(fontSize: 16, letterSpacing: 1.2),
                  ),
                  Text(
                    "$_cost GNUS",
                    style: const TextStyle(
                        fontSize: 16,
                        letterSpacing: 1.5,
                        color: GeniusWalletColors.red),
                  ),
                ]),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text(
                    'Available: ',
                    style: TextStyle(fontSize: 16, letterSpacing: 1.2),
                  ),
                  Text(
                    "$geniusBalance GNUS",
                    style: const TextStyle(
                        fontSize: 16,
                        letterSpacing: 1.5,
                        color: GeniusWalletColors.blue500),
                  )
                ])
              ]),
              if (!isPurchaseable) ...[
                const SizedBox(height: 8),
                const Text('* You do not have enough GNUS to submit this job',
                    style:
                        TextStyle(color: GeniusWalletColors.red, fontSize: 18))
              ]
            ]),
          const SizedBox(height: 16),
          if (_jsonData != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(GeniusWalletConsts.borderRadiusCard)),
                  color: GeniusWalletColors.deepBlueCardColor),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText(
                    const JsonEncoder.withIndent('   ').convert(_jsonData),
                    style: const TextStyle(
                      fontFamily: 'monospace', // Use a monospaced font
                      fontSize: 14,
                      color: Colors.white,
                    )),
              ),
            ),
        ],
      ),
    );
  }
}
