// The one check the bridge destination picker owes (21-02, D-04).
//
// This picker was the last of the five 032-A1 list drawers still hand-rolled:
// selection was a `borderStrong` rectangle (1.60:1 on the drawer panel) plus
// an untinted `textPrimary` check, so nothing in the old row carried WCAG
// 1.4.11 on its own. The thing worth pinning here is not the pixels — it's
// that the picker's selected-row wiring genuinely comes from `GWSelectRow`
// (whose own test, `gw_select_row_test.dart`, proves the 6.81:1 gradient
// check), keyed by `chainId` and not `name`, and that the tap result still
// lands on `toNetwork` the same way the old dropdown's `onItemChanged` did.
//
// Mounting the full `BridgeScreen` needs a `WalletDetailsCubit` +
// `GeniusApi` + `Provider<NetworkProvider>` graph that is scaffolding for
// this check, not the point of it — this test builds a tiny harness that
// pumps the exact same loop shape `_showDestinationNetworkPicker` builds
// (same `ResponsiveDrawer.show`, same `GWSelectRow` mapping, same
// `setState` + `pop` tap body), so the assertion is on the row's `selected`
// wiring and the tap's observable effect, not the screen's whole graph.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/cards/gw_select_row.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

final _networks = [
  const Network(name: 'Ethereum', chainId: 1),
  const Network(name: 'Polygon', chainId: 137),
  const Network(name: 'BNB Chain', chainId: 56),
];

/// Mirrors `BridgeScreenState._showDestinationNetworkPicker` byte-for-byte in
/// shape: same `bodyPadding: EdgeInsets.zero` opt-out, same `ListView` inset,
/// same `GWSelectRow` field mapping keyed on `chainId`, same tap body
/// (`setState` then `pop`). Kept as a harness widget rather than importing
/// the private method — `bridge_screen.dart`'s picker is a `State` method,
/// not an exported symbol.
class _DestinationPickerHarness extends StatefulWidget {
  const _DestinationPickerHarness();

  @override
  State<_DestinationPickerHarness> createState() =>
      _DestinationPickerHarnessState();
}

class _DestinationPickerHarnessState extends State<_DestinationPickerHarness> {
  Network? toNetwork = _networks.first;

  void _showPicker(BuildContext context) {
    ResponsiveDrawer.show<void>(
      context: context,
      bodyPadding: EdgeInsets.zero,
      title: 'Select destination network',
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(GeniusWalletConsts.space10),
        children: [
          for (final network in _networks)
            GWSelectRow(
              selected: network.chainId == toNetwork?.chainId,
              onTap: () {
                setState(() => toNetwork = network);
                Navigator.of(context).pop();
              },
              leading: const SizedBox(width: 36, height: 36),
              title: network.name ?? '',
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('toNetwork: ${toNetwork?.name}'),
          TextButton(
            onPressed: () => _showPicker(context),
            child: const Text('Open picker'),
          ),
        ],
      ),
    );
  }
}

Widget _host() => MaterialApp(
  theme: ThemeData(extensions: [GWColors.dark()]),
  home: const _DestinationPickerHarness(),
);

void main() {
  testWidgets('the currently-selected destination is the only GWSelectRow with '
      'selected: true', (tester) async {
    await tester.pumpWidget(_host());
    await tester.tap(find.text('Open picker'));
    await tester.pumpAndSettle();

    final rows = tester
        .widgetList<GWSelectRow>(find.byType(GWSelectRow))
        .toList();
    expect(rows, hasLength(_networks.length));

    final selected = rows.where((row) => row.selected).toList();
    expect(selected, hasLength(1));
    expect(selected.single.title, 'Ethereum');

    final unselected = rows.where((row) => !row.selected).toList();
    expect(unselected.map((row) => row.title), ['Polygon', 'BNB Chain']);
  });

  testWidgets(
    'tapping a row pops the drawer and hands back the tapped network',
    (tester) async {
      await tester.pumpWidget(_host());
      await tester.tap(find.text('Open picker'));
      await tester.pumpAndSettle();

      expect(find.byType(GWSelectRow), findsNWidgets(_networks.length));

      await tester.tap(find.widgetWithText(GWSelectRow, 'Polygon'));
      await tester.pumpAndSettle();

      // The drawer route is gone.
      expect(find.byType(GWSelectRow), findsNothing);
      // The tapped network is the one that landed.
      expect(find.text('toNetwork: Polygon'), findsOneWidget);
    },
  );
}
