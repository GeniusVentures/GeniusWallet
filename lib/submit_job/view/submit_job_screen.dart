import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_cubit.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_state.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';

class SubmitJobScreen extends StatelessWidget {
  const SubmitJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubmitJobCubit, SubmitJobState>(
      listenWhen: (previous, current) =>
          (previous.filePickerError != current.filePickerError) ||
          (previous.processErrorMessage != current.processErrorMessage) ||
          (previous.txHash != current.txHash),
      listener: (context, state) {
        final submitJobCubit = context.read<SubmitJobCubit>();

        // listen for file picker errors
        if (state.filePickerError.message.isNotEmpty) {
          submitJobCubit.resetFilePickerError();
          ToastManager.instance.showToast(
            context: context,
            title: "File Picker Error",
            message: state.filePickerError.message,
            type: ToastType.error,
          );
        }

        if (state.processErrorMessage.isNotEmpty) {
          submitJobCubit.resetProcessError();
          ToastManager.instance.showToast(
            context: context,
            title: "Job Submission Error",
            message: state.processErrorMessage,
            type: ToastType.error,
          );
        }

        if (state.txHash.isNotEmpty) {
          submitJobCubit.resetState();
          ToastManager.instance.showToast(
            context: context,
            title: "Job Successfully Submitted",
            message: state.txHash,
            type: ToastType.success,
          );
        }
      },
      builder: (context, state) {
        final submitJobCubit = context.read<SubmitJobCubit>();
        final uploadedFileName = state.uploadedFileName;
        final uploadedJson = state.uploadedJson;
        final jobCost = state.jobCost;
        final gnusBalance = state.gnusBalance;
        final isBridgingTokens = state.isBridgingTokens;
        final isPurchaseable = jobCost != 0 && jobCost < gnusBalance;
        final isFilePickerOpen = state.isFilePickerOpen;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Submit a New Job"),
            actions: [
              TextButton.icon(
                onPressed: submitJobCubit.openFilePicker,
                icon: const Icon(Icons.upload),
                label: const Text('Upload'),
              ),
            ],
          ),
          body: Stack(
            children: [
              Align(
                alignment: AlignmentGeometry.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: GeniusBreakpoints.large,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      spacing: 12.0,
                      children: [
                        Row(
                          spacing: 8.0,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/crypto/gnus.png',
                              height: 25,
                              width: 25,
                            ),
                            Text(
                              '$gnusBalance',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10.0),
                            const FaIcon(
                              FontAwesomeIcons.gasPump,
                              color: Colors.red,
                              size: 20,
                            ),
                            AutoSizeText(
                              maxLines: 1,
                              state.jobGasCost,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (uploadedFileName.isNotEmpty) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const AutoSizeText(
                                'Uploaded File: ',
                                style: TextStyle(fontSize: 16),
                              ),
                              AutoSizeText(
                                uploadedFileName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: GeniusWalletColors.lightGreenPrimary,
                                  fontFamily: "JetBrainsMono",
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const AutoSizeText(
                                'Cost: ',
                                style: TextStyle(fontSize: 16),
                              ),
                              AutoSizeText(
                                "$jobCost GNUS",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                          if (uploadedJson.isNotEmpty)
                            FilledButton.icon(
                              onPressed: !isPurchaseable || isBridgingTokens
                                  ? null
                                  : () {
                                      submitJobCubit.bridgeTokens();
                                    },
                              label: const Text('Purchase'),
                            ),
                          if (!isPurchaseable)
                            Text(
                              '* You do not have enough GNUS',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 14,
                              ),
                            ),
                        ],
                        if (uploadedJson.isNotEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SelectableText(
                                const JsonEncoder.withIndent(
                                  '  ',
                                ).convert(uploadedJson),
                                style: const TextStyle(
                                  fontFamily: 'JetBrainsMono',
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isFilePickerOpen)
                ModalBarrier(
                  color: Colors.black.withValues(alpha: 0.5),
                  dismissible: false,
                ),
              if (isFilePickerOpen)
                const Center(child: Loading(text: "Preparing AI job...")),
            ],
          ),
        );
      },
    );
  }
}
