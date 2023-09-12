import 'dart:async';

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

  late int _fakeBalance = 0;

  get timer => null;
  InfluxDBClient createInfluxClient()
  {
    final dbClient = InfluxDBClient(
      url: 'http://192.168.16.33:8086',
      token: 'fdLxG5FIZnDDVOBl4gozJr5wy6mXDlBgbvOtAdzG3XfcmMzwP3_RVdHiTuK4s39pIrYoTuiJRexpQpTUTr1U1w==',
      org: 'GNUS.AI',
      bucket: 'WalletDB',
      debug: true
    );

    return dbClient;
  }
  Future<Point> getNextVal(InfluxDBClient clientDB, String walletAddr) async {

      var insertValue = Point('wallet').addTag('address', widget.curr_wallet.address).addField('balance', 1);
      var queryService = clientDB.getQueryService();
      var fluxQuery = '''
          from(bucket: "${clientDB.bucket}")
                |> range(start: -20d)
                |> filter(fn: (r) => r["_measurement"] == "wallet" 
                                and r.address == "$walletAddr")''';
                                
      var recordStream = await queryService.query(fluxQuery);

      await recordStream.last.then((value)
      {
          insertValue.fields['balance'] += value['_value'];
          print('\n\n Last record DB ${value['_value']} \n');
          print('\n\n New record DB ${insertValue.fields['balance']} \n');
      }).catchError((exception) {
          print('\n\n Empty DB: Starting value ${insertValue.fields['balance']}\n');
      });

      return insertValue;
  }
  void writeNextVal(InfluxDBClient clientDB, Point nextVal) async
  {
      var writeApi = clientDB.getWriteService(WriteOptions().merge(
      precision: WritePrecision.s,
      batchSize: 100,
      flushInterval: 5000,
      gzip: true));

      await writeApi.write(nextVal).then((value) {
        print('Write completed 1');
      }).catchError((exception) {
        print('Handle write error here!');
        print(exception);
      });
  }

  @override
  void initState() {
    super.initState();
    // Start a timer to refresh the value every 5 seconds
    Timer.periodic(Duration(seconds: 5), (timer) {
      // Update the value and trigger a rebuild
      void postWallet() async{
        final dbClient = createInfluxClient();

        var newBalancePoint = await getNextVal(dbClient, widget.curr_wallet.address);
        writeNextVal(dbClient, newBalancePoint);
        
        _fakeBalance = newBalancePoint.fields['balance'];

        dbClient.close();
      }
      setState(() {
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
                          ovrQuantity: (_fakeBalance.toDouble()*0.0001).toStringAsFixed(4),
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
