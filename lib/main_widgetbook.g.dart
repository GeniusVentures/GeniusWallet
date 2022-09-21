// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
// 
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************
    

    import 'package:widgetbook/widgetbook.dart';
    import 'package:flutter/material.dart';
    import 'package:genius_wallet/widgets/components/save_button.g.dart';
import 'package:genius_wallet/widgets/components/order_book_header.g.dart';
import 'package:genius_wallet/widgets/components/changepassword.g.dart';
import 'package:genius_wallet/widgets/components/detailed_transaction.g.dart';
import 'package:genius_wallet/widgets/components/change_profile_picture.g.dart';
import 'package:genius_wallet/widgets/components/back_button_dashboard.g.dart';
import 'package:genius_wallet/widgets/components/header.g.dart';
import 'package:genius_wallet/widgets/components/navbar_group22.g.dart';
import 'package:genius_wallet/widgets/components/market_graph.g.dart';
import 'package:genius_wallet/widgets/components/profile_completeness.g.dart';
import 'package:genius_wallet/widgets/components/coin_stats_card.g.dart';
import 'package:genius_wallet/widgets/components/profile_info_form.g.dart';
import 'package:genius_wallet/widgets/components/bottom_navbar/property1_navbar_dashboard.g.dart';
import 'package:genius_wallet/widgets/components/bottom_navbar/property1_navbar_transactions.g.dart';
import 'package:genius_wallet/widgets/components/bottom_navbar/property1_navbar_wallets.g.dart';
import 'package:genius_wallet/widgets/components/bottom_navbar/property1_navbar_markets.g.dart';
import 'package:genius_wallet/widgets/components/registration_header.g.dart';
import 'package:genius_wallet/widgets/components/enter_amount.g.dart';
import 'package:genius_wallet/widgets/components/conversion_result.g.dart';
import 'package:genius_wallet/widgets/components/аdd_wallet_text.g.dart';
import 'package:genius_wallet/widgets/components/crypto_chart.g.dart';
import 'package:genius_wallet/widgets/components/wallet_button/type_create.g.dart';
import 'package:genius_wallet/widgets/components/wallet_preview.g.dart';
import 'package:genius_wallet/widgets/components/price_chart.g.dart';
import 'package:genius_wallet/widgets/components/wallet_toggle.g.dart';
import 'package:genius_wallet/widgets/components/transaction_counter.g.dart';
import 'package:genius_wallet/widgets/components/export_history.g.dart';
import 'package:genius_wallet/widgets/components/crypto_market_overview.g.dart';
import 'package:genius_wallet/widgets/components/recoveryword.g.dart';
import 'package:genius_wallet/widgets/components/markets_module.g.dart';
import 'package:genius_wallet/widgets/components/wallet_button/type_existing.g.dart';
import 'package:genius_wallet/widgets/components/genius_back_button.g.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_false.g.dart';
import 'package:genius_wallet/widgets/components/wallet_module.g.dart';
import 'package:genius_wallet/widgets/components/transaction_filter.g.dart';
import 'package:genius_wallet/widgets/components/date_selector.g.dart';
import 'package:genius_wallet/widgets/components/appbar.g.dart';
import 'package:genius_wallet/widgets/components/transaction_card.g.dart';
import 'package:genius_wallet/widgets/components/wallet_information.g.dart';
import 'package:genius_wallet/widgets/components/currency_selector.g.dart';
import 'package:genius_wallet/widgets/components/order_history.g.dart';
import 'package:genius_wallet/widgets/components/add_wallet_block.g.dart';
import 'package:genius_wallet/widgets/components/wallets_overview.g.dart';
import 'package:genius_wallet/widgets/components/monthselector.g.dart';
import 'package:genius_wallet/widgets/components/transactions.g.dart';
import 'package:genius_wallet/widgets/components/coin_toggle_selector.g.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_true.g.dart';
import 'package:genius_wallet/widgets/components/orderbook.g.dart';
import 'package:genius_wallet/widgets/mobile/white_arrow/pointing_left.g.dart';
import 'package:genius_wallet/widgets/mobile/white_arrow/pointing_right.g.dart';
import 'package:genius_wallet/widgets/mobile/wallet_agreement.g.dart';
import 'package:genius_wallet/widgets/mobile/passcode_entry.g.dart';
import 'package:genius_wallet/widgets/mobile/wallet_address.g.dart';
import 'package:genius_wallet/widgets/mobile/wallet_card.g.dart';


    void main() {
      runApp(const MyApp());
    }

    class MyApp extends StatelessWidget {
      const MyApp({Key? key}) : super(key: key);

      @override
      Widget build(BuildContext context){
        return Widgetbook(
          themes: [
            WidgetbookTheme(name: 'Light', data: ThemeData.light()),
          ],
          devices: const [
            Apple.iPhone11ProMax,
            Samsung.s10,
          ],
          categories: [
                  WidgetbookCategory(
        name: 'Parabeac-Generated',
        folders: [
      WidgetbookFolder(
        name: 'components',
        widgets: [
      WidgetbookWidget(
        name: 'Save Button',
        useCases: [
      WidgetbookUseCase(
        name: 'SaveButton',
        builder: (context) => Center(child:       SizedBox(
        height: 35.0,width: 311.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return SaveButton(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'OrderBookHeader',
        useCases: [
      WidgetbookUseCase(
        name: 'OrderBookHeader',
        builder: (context) => Center(child:       SizedBox(
        height: 19.0,width: 270.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return OrderBookHeader(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'Changepassword',
        useCases: [
      WidgetbookUseCase(
        name: 'Changepassword',
        builder: (context) => Center(child:       SizedBox(
        height: 75.0,width: 291.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return Changepassword(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'DetailedTransaction',
        useCases: [
      WidgetbookUseCase(
        name: 'DetailedTransaction',
        builder: (context) => Center(child:       SizedBox(
        height: 189.0,width: 316.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return DetailedTransaction(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'ChangeProfilePicture',
        useCases: [
      WidgetbookUseCase(
        name: 'ChangeProfilePicture',
        builder: (context) => Center(child:       SizedBox(
        height: 89.0,width: 253.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return ChangeProfilePicture(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'Back Button Dashboard',
        useCases: [
      WidgetbookUseCase(
        name: 'BackButtonDashboard',
        builder: (context) => Center(child:       SizedBox(
        height: 35.0,width: 79.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return BackButtonDashboard(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'Header',
        useCases: [
      WidgetbookUseCase(
        name: 'Header',
        builder: (context) => Center(child:       SizedBox(
        height: 28.0,width: 312.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return Header(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'navbar/Group22',
        useCases: [
      WidgetbookUseCase(
        name: 'NavbarGroup22',
        builder: (context) => Center(child:       SizedBox(
        height: 41.0,width: 311.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return NavbarGroup22(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'MarketGraph',
        useCases: [
      WidgetbookUseCase(
        name: 'MarketGraph',
        builder: (context) => Center(child:       SizedBox(
        height: 192.0,width: 311.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return MarketGraph(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'ProfileCompleteness',
        useCases: [
      WidgetbookUseCase(
        name: 'ProfileCompleteness',
        builder: (context) => Center(child:       SizedBox(
        height: 165.0,width: 311.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return ProfileCompleteness(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'CoinStatsCard',
        useCases: [
      WidgetbookUseCase(
        name: 'CoinStatsCard',
        builder: (context) => Center(child:       SizedBox(
        height: 192.0,width: 311.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return CoinStatsCard(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'ProfileInfoForm',
        useCases: [
      WidgetbookUseCase(
        name: 'ProfileInfoForm',
        builder: (context) => Center(child:       SizedBox(
        height: 603.0,width: 314.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return ProfileInfoForm(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'bottom-navbar',
        useCases: [
      WidgetbookUseCase(
        name: 'Property1NavbarDashboard',
        builder: (context) => Center(child:       SizedBox(
        height: 63.0,width: 375.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return Property1NavbarDashboard(
constraints,
)
;
}
),
      ),
    ),
      ),
    
      WidgetbookUseCase(
        name: 'Property1NavbarTransactions',
        builder: (context) => Center(child:       SizedBox(
        height: 63.0,width: 375.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return Property1NavbarTransactions(
constraints,
)
;
}
),
      ),
    ),
      ),
    
      WidgetbookUseCase(
        name: 'Property1NavbarWallets',
        builder: (context) => Center(child:       SizedBox(
        height: 63.0,width: 375.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return Property1NavbarWallets(
constraints,
)
;
}
),
      ),
    ),
      ),
    
      WidgetbookUseCase(
        name: 'Property1NavbarMarkets',
        builder: (context) => Center(child:       SizedBox(
        height: 63.0,width: 375.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return Property1NavbarMarkets(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'RegistrationHeader',
        useCases: [
      WidgetbookUseCase(
        name: 'RegistrationHeader',
        builder: (context) => Center(child:       SizedBox(
        height: 190.0,width: 375.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return RegistrationHeader(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'EnterAmount',
        useCases: [
      WidgetbookUseCase(
        name: 'EnterAmount',
        builder: (context) => Center(child:       SizedBox(
        height: 104.0,width: 315.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return EnterAmount(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'ConversionResult',
        useCases: [
      WidgetbookUseCase(
        name: 'ConversionResult',
        builder: (context) => Center(child:       SizedBox(
        height: 115.0,width: 315.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return ConversionResult(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'Аdd Wallet Text',
        useCases: [
      WidgetbookUseCase(
        name: 'АddWalletText',
        builder: (context) => Center(child:       SizedBox(
        height: 14.0,width: 76.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return DdWalletText(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'CryptoChart',
        useCases: [
      WidgetbookUseCase(
        name: 'CryptoChart',
        builder: (context) => Center(child:       SizedBox(
        height: 714.0,width: 311.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return CryptoChart(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'Wallet Button',
        useCases: [
      WidgetbookUseCase(
        name: 'TypeCreate',
        builder: (context) => Center(child:       SizedBox(
        height: 46.0,width: 315.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return TypeCreate(
constraints,
)
;
}
),
      ),
    ),
      ),
    
      WidgetbookUseCase(
        name: 'TypeExisting',
        builder: (context) => Center(child:       SizedBox(
        height: 46.0,width: 315.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return TypeExisting(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'WalletPreview',
        useCases: [
      WidgetbookUseCase(
        name: 'WalletPreview',
        builder: (context) => Center(child:       SizedBox(
        height: 100.0,width: 200.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return WalletPreview(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'PriceChart',
        useCases: [
      WidgetbookUseCase(
        name: 'PriceChart',
        builder: (context) => Center(child:       SizedBox(
        height: 371.0,width: 314.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return PriceChart(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'WalletToggle',
        useCases: [
      WidgetbookUseCase(
        name: 'WalletToggle',
        builder: (context) => Center(child:       SizedBox(
        height: 35.0,width: 312.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return WalletToggle(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'Transaction Counter',
        useCases: [
      WidgetbookUseCase(
        name: 'TransactionCounter',
        builder: (context) => Center(child:       SizedBox(
        height: 40.0,width: 196.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return TransactionCounter(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'Export History',
        useCases: [
      WidgetbookUseCase(
        name: 'ExportHistory',
        builder: (context) => Center(child:       SizedBox(
        height: 35.0,width: 120.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return ExportHistory(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'CryptoMarketOverview',
        useCases: [
      WidgetbookUseCase(
        name: 'CryptoMarketOverview',
        builder: (context) => Center(child:       SizedBox(
        height: 47.0,width: 271.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return CryptoMarketOverview(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'Recoveryword',
        useCases: [
      WidgetbookUseCase(
        name: 'Recoveryword',
        builder: (context) => Center(child:       SizedBox(
        height: 28.0,width: 111.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return Recoveryword(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'MarketsModule',
        useCases: [
      WidgetbookUseCase(
        name: 'MarketsModule',
        builder: (context) => Center(child:       SizedBox(
        height: 319.0,width: 311.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return MarketsModule(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'Genius Back Button',
        useCases: [
      WidgetbookUseCase(
        name: 'GeniusBackButton',
        builder: (context) => Center(child:       SizedBox(
        height: 9.0,width: 5.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return GeniusBackButton(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'Continue Button',
        useCases: [
      WidgetbookUseCase(
        name: 'IsactiveFalse',
        builder: (context) => Center(child:       SizedBox(
        height: 46.0,width: 315.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return IsactiveFalse(
constraints,
)
;
}
),
      ),
    ),
      ),
    
      WidgetbookUseCase(
        name: 'IsactiveTrue',
        builder: (context) => Center(child:       SizedBox(
        height: 46.0,width: 315.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return IsactiveTrue(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'WalletModule',
        useCases: [
      WidgetbookUseCase(
        name: 'WalletModule',
        builder: (context) => Center(child:       SizedBox(
        height: 297.0,width: 311.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return WalletModule(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'Transaction Filter ',
        useCases: [
      WidgetbookUseCase(
        name: 'TransactionFilter',
        builder: (context) => Center(child:       SizedBox(
        height: 13.0,width: 133.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return TransactionFilter(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'Date selector ',
        useCases: [
      WidgetbookUseCase(
        name: 'DateSelector',
        builder: (context) => Center(child:       SizedBox(
        height: 29.0,width: 271.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return DateSelector(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'Appbar',
        useCases: [
      WidgetbookUseCase(
        name: 'Appbar',
        builder: (context) => Center(child:       SizedBox(
        height: 41.0,width: 311.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return Appbar(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'TransactionCard',
        useCases: [
      WidgetbookUseCase(
        name: 'TransactionCard',
        builder: (context) => Center(child:       SizedBox(
        height: 53.0,width: 271.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return TransactionCard(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'WalletInformation',
        useCases: [
      WidgetbookUseCase(
        name: 'WalletInformation',
        builder: (context) => Center(child:       SizedBox(
        height: 213.0,width: 312.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return WalletInformation(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'CurrencySelector',
        useCases: [
      WidgetbookUseCase(
        name: 'CurrencySelector',
        builder: (context) => Center(child:       SizedBox(
        height: 78.0,width: 311.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return CurrencySelector(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'OrderHistory',
        useCases: [
      WidgetbookUseCase(
        name: 'OrderHistory',
        builder: (context) => Center(child:       SizedBox(
        height: 692.0,width: 311.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return OrderHistory(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'Add Wallet Block',
        useCases: [
      WidgetbookUseCase(
        name: 'AddWalletBlock',
        builder: (context) => Center(child:       SizedBox(
        height: 297.0,width: 311.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return AddWalletBlock(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'WalletsOverview',
        useCases: [
      WidgetbookUseCase(
        name: 'WalletsOverview',
        builder: (context) => Center(child:       SizedBox(
        height: 290.0,width: 311.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return WalletsOverview(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'Monthselector',
        useCases: [
      WidgetbookUseCase(
        name: 'Monthselector',
        builder: (context) => Center(child:       SizedBox(
        height: 29.0,width: 311.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return Monthselector(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'Transactions',
        useCases: [
      WidgetbookUseCase(
        name: 'Transactions',
        builder: (context) => Center(child:       SizedBox(
        height: 366.0,width: 311.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return Transactions(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'CoinToggleSelector',
        useCases: [
      WidgetbookUseCase(
        name: 'CoinToggleSelector',
        builder: (context) => Center(child:       SizedBox(
        height: 35.0,width: 109.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return CoinToggleSelector(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'Orderbook',
        useCases: [
      WidgetbookUseCase(
        name: 'Orderbook',
        builder: (context) => Center(child:       SizedBox(
        height: 642.0,width: 271.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return Orderbook(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    
],

      ),
    
      WidgetbookFolder(
        name: 'mobile',
        widgets: [
      WidgetbookWidget(
        name: 'White Arrow',
        useCases: [
      WidgetbookUseCase(
        name: 'PointingLeft',
        builder: (context) => Center(child:       SizedBox(
        height: 9.0,width: 5.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return PointingLeft(
constraints,
)
;
}
),
      ),
    ),
      ),
    
      WidgetbookUseCase(
        name: 'PointingRight',
        builder: (context) => Center(child:       SizedBox(
        height: 9.0,width: 5.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return PointingRight(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'Wallet Agreement',
        useCases: [
      WidgetbookUseCase(
        name: 'WalletAgreement',
        builder: (context) => Center(child:       SizedBox(
        height: 34.0,width: 327.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return WalletAgreement(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'Passcode Entry',
        useCases: [
      WidgetbookUseCase(
        name: 'PasscodeEntry',
        builder: (context) => Center(child:       SizedBox(
        height: 50.0,width: 317.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return PasscodeEntry(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'WalletAddress',
        useCases: [
      WidgetbookUseCase(
        name: 'WalletAddress',
        builder: (context) => Center(child:       SizedBox(
        height: 38.0,width: 315.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return WalletAddress(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    ,
      WidgetbookWidget(
        name: 'walletCard',
        useCases: [
      WidgetbookUseCase(
        name: 'WalletCard',
        builder: (context) => Center(child:       SizedBox(
        height: 55.0,width: 311.0,
        child: LayoutBuilder( 
  builder: (context, constraints) {
    return WalletCard(
constraints,
)
;
}
),
      ),
    ),
      ),
    
],

      )
    
],

      ),
    
],

        
      )
    ,
          ],
          appInfo: AppInfo(name: 'MyApp'),
        );
      }
    }
    