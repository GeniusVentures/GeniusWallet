import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

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
        return SizedBox();
      }
      return DropdownMenu<Network>(
        helperText: 'Network',
        menuStyle: const MenuStyle(
            backgroundColor:
                WidgetStatePropertyAll(GeniusWalletColors.deepBlueCardColor)),
        inputDecorationTheme: const InputDecorationTheme(
            border: UnderlineInputBorder(), contentPadding: EdgeInsets.all(0)),
        initialSelection: state.selectedNetwork,
        leadingIcon: Container(
            padding: const EdgeInsets.all(8),
            child: state.selectedNetwork?.iconPath == null ||
                    state.selectedNetwork?.iconPath == ""
                ? SizedBox()
                : Image.asset(state.selectedNetwork?.iconPath ?? "",
                    width: 16, height: 16)),
        onSelected: (Network? value) {
          setState(() {
            walletCubit.selectNetwork(value!);
          });
        },
        dropdownMenuEntries:
            widget.networkList.map<DropdownMenuEntry<Network>>((Network value) {
          return DropdownMenuEntry<Network>(
            value: value,
            label: value?.name ?? "",
            leadingIcon: Image.asset(
              value.iconPath ?? '',
              height: 32,
              width: 32,
            ),
          );
        }).toList(),
      );
    });
  }
}
