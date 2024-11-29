import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_wallet/widgets/components/animation/checkmark_animation.dart';
import 'package:genius_wallet/widgets/components/animation/x_animation.dart';

class SGNUSConnectionWidget extends StatefulWidget {
  const SGNUSConnectionWidget({Key? key}) : super(key: key);

  @override
  SGNUSConnectionState createState() => SGNUSConnectionState();
}

class SGNUSConnectionState extends State<SGNUSConnectionWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SGNUSConnection>(
      stream: context.read<GeniusApi>().getSGNUSConnectionStream(),
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
                  'SGNUS Connection ',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                if (connection.isConnected) const CheckmarkAnimation(),
                if (!connection.isConnected) const XAnimation(),
              ],
            ),
          ],
        );
      },
    );
  }
}
