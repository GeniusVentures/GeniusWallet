import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/gnus_bridge/gnus_connection_store.dart';
import 'package:genius_wallet/gnus_bridge/gnus_origin.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';
import 'package:genius_wallet/settings/connected_sites_section.dart';
import 'package:genius_wallet/settings/developer_mode.dart';
import 'package:genius_wallet/settings/developer_settings_cubit.dart';
import 'package:genius_wallet/settings/settings_screen.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';

import '../gnus_bridge/gnus_fakes.dart';
import '../theme/theme_contrast_test.dart' show themeFor;

final _older = webOrigin('https://older.example');
final _newer = webOrigin('https://${'n' * 90}.example');

/// The config files the screen reads at start are not there.
class _SettingsApi extends FakeGnusApi {
  @override
  Future<String> get jsonFilePath async => 'no-such-dir/';
}

class _RefusingStore extends GnusConnectionStore {
  _RefusingStore(super.box);

  @override
  Future<void> revoke(GnusOrigin origin) async {
    throw StateError('box closed');
  }
}

Widget _host(GnusConnectionStore store, GWAppearanceMode mode) =>
    RepositoryProvider<GnusConnectionStore>.value(
      value: store,
      child: MaterialApp(
        theme: themeFor(mode),
        home: const Scaffold(
          body: SingleChildScrollView(child: ConnectedSitesSection()),
        ),
      ),
    );

void main() {
  late GnusHarness h;
  late GnusConnectionStore store;

  Future<void> seed(WidgetTester tester) async {
    await tester.runAsync(() async {
      await store.connect(_older, DateTime.utc(2026, 10, 1, 9));
      await store.connect(_newer, DateTime.utc(2026, 10, 20, 15, 30));
    });
  }

  Future<void> boot(WidgetTester tester) async {
    h = (await tester.runAsync(GnusHarness.create))!;
    store = h.connections;
  }

  Future<void> shutdown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(h.dispose);
  }

  testWidgets('lists the sites newest first with their full origin', (
    tester,
  ) async {
    await boot(tester);
    await seed(tester);

    await tester.pumpWidget(_host(store, GWAppearanceMode.dark));

    expect(find.text(_newer.value), findsOneWidget);
    expect(find.text(_older.value), findsOneWidget);
    expect(find.textContaining('In-app browser, connected '), findsNWidgets(2));
    expect(
      tester.getTopLeft(find.text(_newer.value)).dy,
      lessThan(tester.getTopLeft(find.text(_older.value)).dy),
    );
    await shutdown(tester);
  });

  testWidgets('Revoke removes that row and leaves the other', (tester) async {
    await boot(tester);
    await seed(tester);
    await tester.pumpWidget(_host(store, GWAppearanceMode.dark));

    await tester.tap(find.widgetWithText(GWButton, 'Revoke').first);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();

    expect(find.text(_newer.value), findsNothing);
    expect(find.text(_older.value), findsOneWidget);
    expect(store.isConnected(_newer), isFalse);
    expect(store.isConnected(_older), isTrue);
    await shutdown(tester);
  });

  testWidgets('a revoke the store refuses says so and keeps the row', (
    tester,
  ) async {
    await boot(tester);
    await seed(tester);
    store = _RefusingStore(h.connectionBox);
    await tester.pumpWidget(_host(store, GWAppearanceMode.dark));

    await tester.tap(find.widgetWithText(GWButton, 'Revoke').first);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();

    expect(
      find.text('Could not revoke this site. It is still connected.'),
      findsOneWidget,
    );
    expect(find.text(_newer.value), findsOneWidget);
    expect(store.isConnected(_newer), isTrue);
    ToastManager.instance.disposeAll();
    await shutdown(tester);
  });

  testWidgets('an empty store reads No sites connected, with no button', (
    tester,
  ) async {
    await boot(tester);

    await tester.pumpWidget(_host(store, GWAppearanceMode.dark));

    expect(find.text('No sites connected'), findsOneWidget);
    expect(find.byType(GWButton), findsNothing);
    await shutdown(tester);
  });

  testWidgets('a site connected while the section is shown appears', (
    tester,
  ) async {
    await boot(tester);
    await tester.pumpWidget(_host(store, GWAppearanceMode.dark));
    expect(find.text(_older.value), findsNothing);

    await tester.runAsync(() async {
      await store.connect(_older, DateTime.utc(2026, 10, 1, 9));
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pump();

    expect(find.text(_older.value), findsOneWidget);
    expect(find.text('No sites connected'), findsNothing);
    await shutdown(tester);
  });

  testWidgets('after Revoke the origin has to ask again', (tester) async {
    await boot(tester);
    final handler = (await tester.runAsync(() async => h.build()))!;
    await tester.pumpWidget(_host(store, GWAppearanceMode.dark));

    await tester.runAsync(
      () => viaJson(handler, _older, GnusRpcMethod.getAccounts, null),
    );
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    expect(find.text(_older.value), findsOneWidget);
    expect(h.connects, [_older]);

    await tester.tap(find.widgetWithText(GWButton, 'Revoke'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    expect(find.text(_older.value), findsNothing);

    await tester.runAsync(
      () => viaJson(handler, _older, GnusRpcMethod.getAccounts, null),
    );
    expect(h.connects, [_older, _older]);
    await shutdown(tester);
  });

  testWidgets('Settings lists connected sites with developer mode off', (
    tester,
  ) async {
    await boot(tester);
    await seed(tester);
    expect(DeveloperMode.instance.value, isFalse);
    final cubit = DeveloperSettingsCubit(
      readNet: () async => SgnsNet.staging,
      writeNet: (_) async => false,
      leaveTestnets: () async {},
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<GeniusApi>.value(value: _SettingsApi()),
          RepositoryProvider<GnusConnectionStore>.value(value: store),
        ],
        child: BlocProvider<DeveloperSettingsCubit>.value(
          value: cubit,
          child: MaterialApp(
            theme: themeFor(GWAppearanceMode.dark),
            home: const SettingsScreen(),
          ),
        ),
      ),
    );

    expect(find.text('Connected sites'), findsOneWidget);
    expect(find.text(_older.value), findsOneWidget);
    expect(find.text('SDK Network'), findsNothing);
    await shutdown(tester);
  });

  for (final mode in GWAppearanceMode.values) {
    testWidgets('meets text contrast and labelled tap targets in $mode', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await boot(tester);
      await seed(tester);

      await tester.pumpWidget(_host(store, mode));

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      expect(
        find.bySemanticsLabel(RegExp('Revoke ${RegExp.escape(_older.value)}')),
        findsOneWidget,
      );
      semantics.dispose();
      await shutdown(tester);
    });
  }
}
