import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_cubit.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_state.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/widgets/components/toast/toast_manager.dart';

class SubmitJobScreen extends StatelessWidget {
  const SubmitJobScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubmitJobCubit, SubmitJobState>(
      listenWhen: (previous, current) =>
          (previous.filePickerError != current.filePickerError) ||
          (previous.txHash != current.txHash),
      listener: (context, state) {
        final submitJobCubit = context.read<SubmitJobCubit>();

        // listen for file picker errors
        if (state.filePickerError.message.isNotEmpty) {
          submitJobCubit.resetFilePickerError();
          ToastManager().showToast(
            context: context,
            title: "File Picker Error",
            message: state.filePickerError.message,
            type: ToastType.error,
          );
        }

        if (state.txHash.isNotEmpty) {
          submitJobCubit.resetState();
          ToastManager().showToast(
              context: context,
              title: "Job Successfully Submitted",
              message: state.txHash,
              type: ToastType.success);
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

        return Stack(children: [
          Scaffold(
            appBar: AppBar(
              title: const Text("Submit a New Job"),
              actions: [
                TextButton.icon(
                  onPressed: submitJobCubit.openFilePicker,
                  style: const ButtonStyle(
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                              GeniusWalletConsts.borderRadiusButton),
                        ),
                      ),
                    ),
                    padding: WidgetStatePropertyAll(
                      EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                    ),
                  ),
                  icon: const Icon(Icons.upload, size: 20),
                  label: const Text('Upload'),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              runSpacing: 16,
                              spacing: 16,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/crypto/gnus.png',
                                      height: 30,
                                      width: 30,
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        '$gnusBalance',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      FontAwesomeIcons.gasPump,
                                      color: Colors.red,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        state.jobGasCost,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 32),
                                if (uploadedFileName.isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        runSpacing: 12,
                                        spacing: 12,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                'Uploaded File: ',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                uploadedFileName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: GeniusWalletColors
                                                      .lightGreenPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                'Cost: ',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                "$jobCost GNUS",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (uploadedJson.isNotEmpty)
                                            TextButton.icon(
                                              style: TextButton.styleFrom(
                                                disabledForegroundColor:
                                                    GeniusWalletColors.gray500,
                                                disabledBackgroundColor:
                                                    GeniusWalletColors
                                                        .deepBlueSecondary,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(
                                                      GeniusWalletConsts
                                                          .borderRadiusButton,
                                                    ),
                                                  ),
                                                ),
                                                padding: const EdgeInsets.only(
                                                  left: 16,
                                                  right: 16,
                                                  top: 8,
                                                  bottom: 8,
                                                ),
                                              ),
                                              onPressed: !isPurchaseable ||
                                                      isBridgingTokens
                                                  ? null
                                                  : () {
                                                      submitJobCubit
                                                          .bridgeTokens();
                                                    },
                                              label: const Text('Purchase'),
                                            )
                                        ],
                                      ),
                                      if (!isPurchaseable) ...[
                                        const SizedBox(height: 8),
                                        const Text(
                                          '* You do not have enough GNUS to submit this job',
                                          style: TextStyle(
                                            color: GeniusWalletColors.red,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                const SizedBox(height: 16),
                                if (uploadedJson.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(
                                          GeniusWalletConsts.borderRadiusCard,
                                        ),
                                      ),
                                      color:
                                          GeniusWalletColors.deepBlueCardColor,
                                    ),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: SelectableText(
                                        const JsonEncoder.withIndent('   ')
                                            .convert(uploadedJson),
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          // Show a modal barrier and a loader when file picker is open
          if (isFilePickerOpen)
            ModalBarrier(
              color: Colors.black.withOpacity(0.5),
              dismissible: false, // Prevent dismissing the overlay
            ),
          if (isFilePickerOpen)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ]);
      },
    );
  }
}
