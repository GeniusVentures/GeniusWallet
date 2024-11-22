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
          const SizedBox(height: 32),
          const SingleChildScrollView(
            child: Column(
              children: [SubmitJobForm()],
            ),
          )
        ]));
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
        });
      }
    } catch (e) {
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
      setState(() {
        _uploadedFileName = null;
        _jsonData = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  style: const ButtonStyle(
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(
                            GeniusWalletConsts.borderRadiusButton)))),
                    backgroundColor: WidgetStatePropertyAll(
                        GeniusWalletColors.lightGreenPrimary),
                    padding: WidgetStatePropertyAll(EdgeInsets.only(
                        left: 16, right: 16, top: 8, bottom: 8)),
                  ),
                  onPressed: () {
                    context
                        .read<GeniusApi>()
                        .requestGeniusSDKProcess(jobJson: _jsonData.toString());
                  },
                  child: const Text(
                    'Submit Job',
                    style:
                        TextStyle(color: GeniusWalletColors.deepBlueCardColor),
                  ),
                ),
            ],
          ),
          const SizedBox(
            height: 64,
          ),
          if (_uploadedFileName != null)
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text(
                'Uploaded File: ',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                "$_uploadedFileName",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                    color: GeniusWalletColors.lightGreenPrimary),
              )
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
