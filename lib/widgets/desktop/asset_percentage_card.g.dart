import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

enum Crypto {
  btc('BTC'),
  eth('ETH');

  const Crypto(this.label);
  final String label;
}

// TODO: wire this to real data / make it better
class AssetPercentageCard extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrSendto;
  final String? ovrAmount;
  final String? ovrWallet;
  final String? ovrReceiveBitcoin;
  final String? ovrBTC;
  final String? sendAmount;
  final String? toAddress;
  final String? ovrsend;
  final Widget? ovrMask;
  const AssetPercentageCard(
    this.constraints, {
    Key? key,
    this.ovrSendto,
    this.ovrAmount,
    this.ovrWallet,
    this.ovrReceiveBitcoin,
    this.ovrBTC,
    this.sendAmount,
    this.toAddress,
    this.ovrsend,
    this.ovrMask,
  }) : super(key: key);
  @override
  _AssetPercentageCard createState() => _AssetPercentageCard();
}

class _AssetPercentageCard extends State<AssetPercentageCard> {
  _AssetPercentageCard();
  Crypto? selectedCrypto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GeniusWalletConsts.horizontalPadding),
      decoration: const BoxDecoration(
        color: GeniusWalletColors.deepBlueCardColor,
        borderRadius: BorderRadius.all(
            Radius.circular(GeniusWalletConsts.borderRadiusCard)),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        runSpacing: 24,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: GeniusWalletConsts.horizontalPadding,
            runSpacing: 20,
            children: [
              Text(widget.ovrWallet ?? 'Wallet'),
              DropdownMenu<Crypto>(
                initialSelection: Crypto.btc,
                controller: TextEditingController(),
                requestFocusOnTap: true,
                onSelected: (Crypto? crypto) {
                  setState(() {
                    selectedCrypto = crypto;
                  });
                },
                dropdownMenuEntries: Crypto.values
                    .map<DropdownMenuEntry<Crypto>>((Crypto crypto) {
                  return DropdownMenuEntry<Crypto>(
                    value: crypto,
                    label: crypto.label,
                    enabled: true,
                  );
                }).toList(),
              ),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: GeniusWalletConsts.horizontalPadding,
                children: [
                  Text(widget.ovrAmount ?? 'Amount'),
                  SizedBox(
                      width: 140,
                      child: TextFormField(
                        controller:
                            TextEditingController(text: widget.sendAmount),
                        decoration: const InputDecoration(
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(
                                    GeniusWalletConsts.borderRadiusButton)),
                                borderSide: BorderSide(
                                    color: GeniusWalletColors
                                        .lightGreenSecondary)),
                            contentPadding: EdgeInsets.only(left: 20),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(
                                    GeniusWalletConsts.borderRadiusButton)))),
                      ))
                ],
              ),
            ],
          ),
          Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: GeniusWalletConsts.horizontalPadding,
              children: [
                Text(widget.ovrSendto ?? 'Send To'),
                SizedBox(
                    width: 340,
                    child: TextFormField(
                      controller:
                          TextEditingController(text: widget.sendAmount),
                      decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(
                                  GeniusWalletConsts.borderRadiusButton)),
                              borderSide: BorderSide(
                                  color:
                                      GeniusWalletColors.lightGreenSecondary)),
                          contentPadding: EdgeInsets.only(left: 20),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(
                                  GeniusWalletConsts.borderRadiusButton)))),
                    ))
              ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AutoSizeText(widget.ovrReceiveBitcoin ?? 'Receive Bitcoin'),
              FilledButton(
                  style: const ButtonStyle(
                      padding: MaterialStatePropertyAll(
                          EdgeInsets.only(left: 50, right: 50)),
                      backgroundColor: MaterialStatePropertyAll(
                          GeniusWalletColors.lightGreenPrimary)),
                  onPressed: null,
                  child: Text(
                    widget.ovrsend ?? 'Send',
                    style: const TextStyle(
                        color: GeniusWalletColors.deepBlueTertiary),
                  ))
            ],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
