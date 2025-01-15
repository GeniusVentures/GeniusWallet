import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

class NetworkDropdown extends StatefulWidget {
  final Wallet wallet;
  final Network? network;
  final List<Network> networkList;
  const NetworkDropdown(
      {super.key,
      required this.wallet,
      this.network,
      required this.networkList});

  @override
  State<NetworkDropdown> createState() => _NetworkDropdownState();
}

class _NetworkDropdownState extends State<NetworkDropdown> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
        builder: (context, state) {
      final walletCubit = context.read<WalletDetailsCubit>();
      if (state.selectedNetwork == null) {
        return const SizedBox();
      }
      return DropdownMenu<Network>(
        menuHeight: 400,
        width: 250,
        helperText: 'Network',
        trailingIcon: const Icon(Icons.arrow_drop_down, size: 32),
        selectedTrailingIcon: const Icon(Icons.arrow_drop_down, size: 32),
        menuStyle: const MenuStyle(
            shadowColor:
                WidgetStatePropertyAll(GeniusWalletColors.deepBlueTertiary),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft:
                        Radius.circular(GeniusWalletConsts.borderRadiusCard),
                    bottomRight:
                        Radius.circular(GeniusWalletConsts.borderRadiusCard)))),
            backgroundColor:
                WidgetStatePropertyAll(GeniusWalletColors.deepBlueCardColor)),
        inputDecorationTheme: const InputDecorationTheme(
            contentPadding: EdgeInsets.all(0),
            border: InputBorder.none, // Removes all borders
            enabledBorder:
                InputBorder.none, // Removes border when TextField is enabled
            focusedBorder:
                InputBorder.none), // Removes border when TextField is focused),
        initialSelection: state.selectedNetwork,
        leadingIcon: state.selectedNetwork?.iconPath == null ||
                state.selectedNetwork?.iconPath == ""
            ? const SizedBox(height: 40, width: 40)
            : Row(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(width: 8),
                Image.asset(
                  state.selectedNetwork?.iconPath ?? "",
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(height: 40, width: 40);
                  },
                ),
                const SizedBox(width: 8)
              ]),
        onSelected: (Network? value) {
          setState(() {
            walletCubit.selectNetwork(value!);
          });
        },
        dropdownMenuEntries:
            widget.networkList.map<DropdownMenuEntry<Network>>((Network value) {
          return DropdownMenuEntry<Network>(
            style: const ButtonStyle(
                padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(vertical: 16, horizontal: 8))),
            value: value,
            label: value.name ?? "",
            leadingIcon: Image.asset(
              value.iconPath ?? '',
              height: 40,
              width: 40,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(height: 40, width: 40);
              },
            ),
          );
        }).toList(),
      );
    });
  }
}
