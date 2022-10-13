import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_cubit.dart';

class WalletAddressCustom extends StatefulWidget {
  final Widget? child;
  WalletAddressCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _WalletAddressCustomState createState() => _WalletAddressCustomState();
}

class _WalletAddressCustomState extends State<WalletAddressCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletCubit, WalletState>(
      listener: (context, state) {
        var message = '';
        switch (state.copyAddressStatus) {
          case WalletStatus.error:
            message = 'Something went wrong while copying the address!';
            break;
          case WalletStatus.successful:
            message = 'Address copied successfully.';
            break;
          default:
        }

        /// Display snackbar if we have a change in status
        if (message.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.selectedWallet == null) {
          return widget.child!;
        }
        return MaterialButton(
          onPressed: () {
            context.read<WalletCubit>().copyWalletAddress();
          },
          child: widget.child!,
        );
      },
    );
  }
}
