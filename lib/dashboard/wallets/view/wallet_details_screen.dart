import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/wallet.dart';
import 'package:genius_wallet/app/utils/wallet_utils.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/widgets/components/back_button_dashboard.g.dart';
import 'package:genius_wallet/widgets/components/crypto_chart.g.dart';
import 'package:genius_wallet/widgets/components/transactions.g.dart';
import 'package:genius_wallet/widgets/components/wallet_information.g.dart';
import 'package:genius_wallet/widgets/components/wallet_toggle.g.dart';
import 'package:influxdb_client/api.dart';

class WalletDetailsScreenStateful extends StatefulWidget {
  late Wallet curr_wallet;

  WalletDetailsScreenStateful(this.curr_wallet);

  @override
  State<WalletDetailsScreenStateful> createState() => WalletDetailsScreen();
}
class WalletDetailsScreen extends State<WalletDetailsScreenStateful> {

  static double _fakeBalance = 0.0;

  get timer => null;

  @override
  void initState() {
    super.initState();

    // Start a timer to refresh the value every 5 seconds
    Timer.periodic(Duration(seconds: 5), (timer) {
      // Update the value and trigger a rebuild

      void postWallet() async{
        final dbClient = InfluxDBClient(
          url: 'http://192.168.16.33:8086',
          token: 'fdLxG5FIZnDDVOBl4gozJr5wy6mXDlBgbvOtAdzG3XfcmMzwP3_RVdHiTuK4s39pIrYoTuiJRexpQpTUTr1U1w==',
          org: 'GNUS.AI',
          bucket: 'WalletInfo',
          debug: true
        );

        var writeApi = dbClient.getWriteService(WriteOptions().merge(
        precision: WritePrecision.s,
        batchSize: 100,
        flushInterval: 5000,
        gzip: true));


        var data = List<Point>.empty(growable: true);
          data.add(Point('wallet')
            .addTag('address', widget.curr_wallet.address)
            .addField('balance', _fakeBalance));

          print(
            '\n\n-------------------------------- Write data -------------------------------\n');
        await writeApi.write(data).then((value) {
          print('Write completed 1');
        }).catchError((exception) {
          print('Handle write error here!');
          print(exception);
        });

            // Create Query service and query
        //var queryService = dbClient.getQueryService();
        //var fluxQuery = '''
        //    from(bucket: "my-bucket")
        //          |> range(start: -20d)
        //          |> filter(fn: (r) => r["_measurement"] == "weather" 
        //                          and r["location"] == "Prague")''';
//
        //// query to stream and iterate all records
        //print(
        //    '\n\n---------------------------------- Query ---------------------------------\n');
        //var recordStream = await queryService.query(fluxQuery);
//
        //print(
        //    '\n\n------------------------------ Query result ------------------------------\n');
        //await recordStream.forEach((record) {
        //  print(
        //      'Temperature in ${record['location']} at ${record['_time']} is ${record['_value']} °C');
        //});
//
        //// delete data
        //print(
        //    '\n\n------------------------------- Delete data -------------------------------\n');
        //await dbClient
        //    .getDeleteService()
        //    .delete(
        //        predicate: '_measurement="weather"',
        //        start: DateTime.parse('1970-01-01T00:00:00Z'),
        //        stop: DateTime.now().toUtc(),
        //        bucket: 'my-bucket',
        //        org: 'my-org')
        //    .catchError((e) => print(e));
//
        //await Future.delayed(Duration(seconds: 10));
        dbClient.close();
      }
      setState(() {
        //print('Fake balance in $_fakeBalance');
        //print('Fake balance in ${widget.curr_wallet.balance}');
        //print('Fake balance in ${widget.curr_wallet.address}');
        //_fakeBalance = widget.curr_wallet.balance;
        _fakeBalance+=0.0001;
        //widget.curr_wallet = widget.curr_wallet.copyWith(balance: _fakeBalance);
        postWallet();
      });
    });
  }
    @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    timer.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
      builder: (context, state) {
        if (state.selectedWallet == null) {
          return const Center(
            child: Text('Error'),
          );
        }
        final selectedWallet = state.selectedWallet!;
        return Scaffold(
          body: AppScreenView(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 40,
                    width: 80,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return BackButtonDashboard(constraints);
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 40,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return WalletToggle(
                          constraints,
                          ovrCoinName: selectedWallet.currencyName,
                          ovrWalletName: selectedWallet.walletName,
                          ovrShape: WalletUtils.currencySymbolToImage(
                            selectedWallet.currencySymbol,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 220,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return WalletInformation(
                          constraints,
                          ovrYourbitcoinaddress:
                              'Your ${selectedWallet.currencyName} Wallet Address',
                          ovrQuantity: _fakeBalance.toStringAsFixed(4),
                          ovrCurrency: selectedWallet.currencySymbol,
                          ovrAddressField: selectedWallet.address,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 370,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return Transactions(constraints);
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 720,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return CryptoChart(constraints);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
