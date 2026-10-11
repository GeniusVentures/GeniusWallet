import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/overlay/global_swap_fab_host.dart';
import 'package:genius_wallet/web/web_overlay_gate.dart';

int _created = 0;

class _Page extends StatefulWidget {
  const _Page();

  @override
  State<_Page> createState() => _PageState();
}

class _PageState extends State<_Page> {
  @override
  void initState() {
    super.initState();
    _created++;
  }

  @override
  Widget build(BuildContext context) => const SizedBox(height: 40);
}

bool _offstage(WidgetTester tester) => tester
    .widget<Offstage>(
      find.descendant(
        of: find.byType(WebOverlayGate),
        matching: find.byType(Offstage),
      ),
    )
    .offstage;

Widget _app({
  required GlobalKey<NavigatorState> shellKey,
  bool hidden = false,
}) => MaterialApp(
  navigatorObservers: [GlobalSwapFabHost.popupRoutes],
  home: Scaffold(
    body: Column(
      children: [
        Expanded(
          child: Navigator(
            key: shellKey,
            observers: [WebOverlayGate.shellPopupRoutes],
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (context) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => const AlertDialog(title: Text('dlg')),
                      ),
                      child: const Text('dialog'),
                    ),
                    TextButton(
                      onPressed: () => showModalBottomSheet<void>(
                        context: context,
                        builder: (_) => const SizedBox(height: 80),
                      ),
                      child: const Text('sheet'),
                    ),
                    TextButton(
                      onPressed: () => showMenu<void>(
                        context: context,
                        position: const RelativeRect.fromLTRB(10, 10, 10, 10),
                        items: const [PopupMenuItem<void>(child: Text('item'))],
                      ),
                      child: const Text('menu'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        WebOverlayGate(hidden: hidden, child: const _Page()),
      ],
    ),
  ),
);

void main() {
  late GlobalKey<NavigatorState> shellKey;

  setUp(() {
    _created = 0;
    shellKey = GlobalKey<NavigatorState>();
  });

  testWidgets('no popup: the child is onstage', (tester) async {
    await tester.pumpWidget(_app(shellKey: shellKey));

    expect(_offstage(tester), isFalse);
  });

  testWidgets(
    'a dialog on the root navigator hides the child until it closes',
    (tester) async {
      await tester.pumpWidget(_app(shellKey: shellKey));

      await tester.tap(find.text('dialog'));
      await tester.pumpAndSettle();
      expect(_offstage(tester), isTrue);

      Navigator.of(tester.element(find.text('dlg')), rootNavigator: true).pop();
      await tester.pumpAndSettle();
      expect(_offstage(tester), isFalse);
    },
  );

  testWidgets(
    'a bottom sheet on the shell navigator hides the child until it closes',
    (tester) async {
      await tester.pumpWidget(_app(shellKey: shellKey));

      await tester.tap(find.text('sheet'));
      await tester.pumpAndSettle();
      expect(_offstage(tester), isTrue);

      shellKey.currentState!.pop();
      await tester.pumpAndSettle();
      expect(_offstage(tester), isFalse);
    },
  );

  testWidgets('a popup menu on the shell navigator hides the child', (
    tester,
  ) async {
    await tester.pumpWidget(_app(shellKey: shellKey));

    await tester.tap(find.text('menu'));
    await tester.pumpAndSettle();
    expect(_offstage(tester), isTrue);

    shellKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(_offstage(tester), isFalse);
  });

  testWidgets('hidden keeps the child offstage with no popup open', (
    tester,
  ) async {
    await tester.pumpWidget(_app(shellKey: shellKey, hidden: true));

    expect(_offstage(tester), isTrue);
  });

  testWidgets('the child is built once across open and close', (tester) async {
    await tester.pumpWidget(_app(shellKey: shellKey));
    expect(_created, 1);

    await tester.tap(find.text('dialog'));
    await tester.pumpAndSettle();
    shellKey.currentState!.pop();
    await tester.pumpAndSettle();

    expect(_created, 1);
  });
}
