// TODO: Move this logic into the token info screen.. more actions button

//  child: CoinCardContainer(
//                         child: StreamBuilder<SGNUSConnection>(
//                             stream: context
//                                 .read<GeniusApi>()
//                                 .getSGNUSConnectionStream(),
//                             builder: (context, snapshot) {
//                               final connection = snapshot.data;
//                               return CoinCardRow(
//                                 iconPath: coin.iconPath ?? "",
//                                 balance: coin.balance ?? 0.0,
//                                 name: coin.name ?? "",
//                                 symbol: coin.symbol ?? "",
//                                 // hardcode for gnus to bridge
//                                 // should not be able to bridge unless this wallet is connected to the sgnus network
//                                 additionalCardWidget: coin.symbol
//                                                 ?.toLowerCase() ==
//                                             'gnus' &&
//                                         state.selectedWallet?.address ==
//                                             connection?.walletAddress
//                                     ? TextButton(
//                                         style: TextButton.styleFrom(
//                                             backgroundColor: Colors.transparent,
//                                             padding: const EdgeInsets.only(
//                                                 left: 12, right: 12)),
//                                         onPressed: (coin.balance == 0 ||
//                                                 (!(connection
//                                                         ?.isConnected ?? // only allow bridging if connected to sgnus network
//                                                     false)))
//                                             ? null
//                                             : () async {
//                                                 walletCubit.selectCoin(coin);
//                                                 await context.push('/bridge',
//                                                     extra: walletCubit);
//                                                 // after we come back to coins screen reload coins / balance
//                                                 walletCubit.getCoins();
//                                                 walletCubit.getWalletBalance();
//                                               },
//                                         child: const AutoSizeText(
//                                           "Bridge Tokens",
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       )
//                                     : null,
//                               );
//                             })),