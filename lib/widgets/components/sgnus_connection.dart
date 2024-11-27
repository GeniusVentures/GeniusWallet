import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_wallet/app/utils/wallet_utils.dart';

class SGNSConnection extends StatefulWidget {
  const SGNSConnection({Key? key}) : super(key: key);

  @override
  SGNSConnectionWidgetState createState() => SGNSConnectionWidgetState();
}

class SGNSConnectionWidgetState extends State<SGNSConnection> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SGNUSConnection>(
      stream: context.read<GeniusApi>().getSGNSConnectionStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Text('No connection data available'),
          );
        }

        final connection = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                const Text(
                  'SGNUS Connection Status: ',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Icon(
                  connection.isConnected ? Icons.check_circle : Icons.cancel,
                  color: connection.isConnected ? Colors.green : Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (connection.isConnected)
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Row(children: [
                  const Text(
                    'Connected Wallet: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    WalletUtils.getAddressForDisplay(connection.walletAddress),
                    style: const TextStyle(fontSize: 16),
                  )
                ]),
                Row(children: [
                  const Text(
                    'SGNS Wallet: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    WalletUtils.getAddressForDisplay(connection.sgnusAddress),
                    style: const TextStyle(fontSize: 16),
                  )
                ])
              ]),
          ],
        );
      },
    );
  }
}
