import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/widgets/components/custom/add_wallet_block_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:go_router/go_router.dart';

class AddWalletBlock extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrCombinedShape;
  final String? ovrAddwallet;
  const AddWalletBlock(
    this.constraints, {
    Key? key,
    this.ovrCombinedShape,
    this.ovrAddwallet,
  }) : super(key: key);
  @override
  _AddWalletBlock createState() => _AddWalletBlock();
}

class _AddWalletBlock extends State<AddWalletBlock> {
  _AddWalletBlock();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: GeniusWalletColors.deepBlueCardColor,
            borderRadius: const BorderRadius.all(
                Radius.circular(GeniusWalletConsts.borderRadiusCard)),
            border: Border.all(color: GeniusWalletColors.lightGreenPrimary)),
        child: AddWalletBlockCustom(
            child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth * 1.0,
            top: 0,
            height: widget.constraints.maxHeight * 1.0,
            child: Stack(children: [
              Positioned(
                left: 0,
                width: widget.constraints.maxWidth,
                top: widget.constraints.maxHeight * 0.1,
                height: widget.constraints.maxHeight,
                child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                          Radius.circular(GeniusWalletConsts.borderRadiusCard)),
                    ),
                    child: Stack(children: [
                      Positioned(
                        left: 0,
                        top: widget.constraints.maxHeight * 0.16,
                        child: Center(
                            child: SizedBox(
                                width: widget.constraints.maxWidth,
                                child: ElevatedButton(
                                    onPressed: () =>
                                        context.push('/landing_screen'),
                                    style: const ButtonStyle(
                                        overlayColor: MaterialStatePropertyAll(
                                            Colors.transparent),
                                        foregroundColor:
                                            MaterialStatePropertyAll(
                                                Colors.transparent),
                                        shadowColor: MaterialStatePropertyAll(
                                            Colors.transparent),
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                                Colors.transparent)),
                                    child: Column(children: [
                                      const Icon(Icons.add,
                                          color: GeniusWalletColors
                                              .lightGreenPrimary,
                                          size: 128),
                                      AutoSizeText(
                                          widget.ovrAddwallet ?? 'Add wallet',
                                          style: const TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: 0.32307693362236023,
                                            color: GeniusWalletColors
                                                .lightGreenPrimary,
                                          )),
                                    ])))),
                      ),
                    ])),
              ),
            ]),
          ),
        ])));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
