import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:genius_wallet/submit_job/submit_job_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

class SubmitJobScreen extends StatelessWidget {
  const SubmitJobScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubmitJobCubit, SubmitJobState>(
        builder: (context, state) {
      final submitJobCubit = context.read<SubmitJobCubit>();
      final walletDetailsCubitState = submitJobCubit.walletDetailsCubit.state;
      final walletAddress = walletDetailsCubitState.selectedWallet?.address;
      final network = walletDetailsCubitState.selectedNetwork;
      final uploadedFileName = state.uploadedFileName;
      final uploadedJson = state.uploadedJson;
      final jobCost = state.jobCost ?? 0;
      final isPurchaseable = jobCost < (state.gnusBalance ?? 0);
      final txHash = state.txHash;

      // if purchase was successful
      if (txHash != null) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(20),
          actionsAlignment: MainAxisAlignment.center,
          title: Center(
              child: txHash == null
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.x,
                          color: Colors.red,
                          size: 24,
                        ),
                        SizedBox(width: 8), // Add space between icon and text
                        Text(
                          'Oops there was an issue!',
                        )
                      ],
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.check,
                          color: Colors.green,
                          size: 24,
                        ),
                        SizedBox(width: 8), // Add space between icon and text
                        Text(
                          'Job Submitted!',
                        )
                      ],
                    )),
          content: Container(
              child: state.txHash == null
                  ? const Text(
                      "Failed to pay for job") // TODO: handle error better
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                          const SizedBox(height: 12),
                          const Text('Hash:', style: TextStyle(fontSize: 16)),
                          SelectableText('$txHash',
                              style: const TextStyle(fontSize: 16))
                        ])),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // reset form state
                submitJobCubit.resetState();
              },
              child: const Text('Close'),
            ),
          ],
        );
      }

      return Scaffold(
          appBar: AppBar(
            title: const Text("Submit a New Job"),
            actions: [
              TextButton.icon(
                onPressed: submitJobCubit.openFilePicker,
                style: const ButtonStyle(
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(
                          GeniusWalletConsts.borderRadiusButton)))),
                  padding: WidgetStatePropertyAll(
                      EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8)),
                ),
                icon: const Icon(FontAwesomeIcons.upload),
                label: const Text('Upload'),
              ),
            ],
          ),
          body: SingleChildScrollView(
              child: // if wallet or network is not selected...
                  (walletAddress == null || network == null)
                      ? Container(
                          padding: const EdgeInsets.all(40),
                          alignment: Alignment.center,
                          child: Text("Wallet / Network must be selected"))
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Expanded(
                                  child: Container(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(children: [
                                        Align(
                                            alignment: Alignment.centerRight,
                                            child: Wrap(
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                runSpacing: 16,
                                                spacing: 16,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Image.asset(
                                                          'assets/images/crypto/gnus.png',
                                                          height: 30,
                                                          width: 30),
                                                      const SizedBox(width: 8),
                                                      SizedBox(
                                                          width: 100,
                                                          child: Text(
                                                            '${(state.gnusBalance ?? 0)}',
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ))
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(
                                                        FontAwesomeIcons
                                                            .gasPump,
                                                        color: Colors.red,
                                                        size: 24,
                                                      ),
                                                      const SizedBox(
                                                          width:
                                                              8), // Add space between icon and text
                                                      SizedBox(
                                                          width: 100,
                                                          child: Text(
                                                            '${state.jobGasCost ?? 0}',
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )),
                                                    ],
                                                  )
                                                ])),
                                        const SizedBox(height: 24),
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const SizedBox(
                                                height: 32,
                                              ),
                                              if (uploadedFileName != null)
                                                Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Wrap(
                                                          crossAxisAlignment:
                                                              WrapCrossAlignment
                                                                  .center,
                                                          runSpacing: 12,
                                                          spacing: 12,
                                                          children: [
                                                            Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  const Text(
                                                                      'Uploaded File: ',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                      )),
                                                                  Text(
                                                                    uploadedFileName,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color: GeniusWalletColors
                                                                            .lightGreenPrimary),
                                                                  ),
                                                                ]),
                                                            Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  const Text(
                                                                    'Cost: ',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    "$jobCost GNUS",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .red),
                                                                  ),
                                                                ]),
                                                            if (uploadedJson !=
                                                                null)
                                                              TextButton.icon(
                                                                style: TextButton
                                                                    .styleFrom(
                                                                  disabledForegroundColor:
                                                                      GeniusWalletColors
                                                                          .gray500,
                                                                  disabledBackgroundColor:
                                                                      GeniusWalletColors
                                                                          .deepBlueSecondary,
                                                                  shape: const RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(GeniusWalletConsts.borderRadiusButton))),
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      left: 16,
                                                                      right: 16,
                                                                      top: 8,
                                                                      bottom:
                                                                          8),
                                                                ),
                                                                // disable button if not enought gnus balance to pay for the job
                                                                onPressed:
                                                                    !isPurchaseable
                                                                        ? null
                                                                        : () {
                                                                            submitJobCubit.bridgeTokens();
                                                                          },
                                                                label: const Text(
                                                                    'Purchase'),
                                                              )
                                                          ]),
                                                      if (!isPurchaseable) ...[
                                                        const SizedBox(
                                                            height: 8),
                                                        const Text(
                                                            '* You do not have enough GNUS to submit this job',
                                                            style: TextStyle(
                                                                color:
                                                                    GeniusWalletColors
                                                                        .red,
                                                                fontSize: 18))
                                                      ]
                                                    ]),
                                              const SizedBox(height: 16),
                                              if (uploadedJson != null)
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  decoration: const BoxDecoration(
                                                      borderRadius: BorderRadius
                                                          .all(Radius.circular(
                                                              GeniusWalletConsts
                                                                  .borderRadiusCard)),
                                                      color: GeniusWalletColors
                                                          .deepBlueCardColor),
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: SelectableText(
                                                        const JsonEncoder
                                                                .withIndent(
                                                                '   ')
                                                            .convert(
                                                                uploadedJson),
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              'monospace', // Use a monospaced font
                                                          fontSize: 14,
                                                          color: Colors.white,
                                                        )),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        )
                                      ])))
                            ])));
    });
  }
}
