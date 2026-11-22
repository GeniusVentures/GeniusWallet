// Escape must pop the topmost pushed route, one per press: keyboard users
// are trapped on /send and /token-info otherwise. The harness mirrors the
// app shell - MaterialApp.builder wrapping the navigator - without the
// escape handler (today's behaviour), then with EscapeToPop mounted.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/navigation/escape_to_pop.dart';

Future<void> _mount(WidgetTester tester, {required bool withEscapePop}) async {
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) {
        final wrapped = withEscapePop
            ? EscapeToPop(child: child ?? const SizedBox.shrink())
            : (child ?? const SizedBox.shrink());
        return wrapped;
      },
      home: const Scaffold(body: Text('home')),
    ),
  );
}

Future<NavigatorState> _pushPage(WidgetTester tester, Widget page) async {
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  unawaited(navigator.push(MaterialPageRoute<void>(builder: (_) => page)));
  await tester.pumpAndSettle();
  return navigator;
}

void main() {
  testWidgets('without the handler escape pops nothing (today)', (
    tester,
  ) async {
    await _mount(tester, withEscapePop: false);
    await _pushPage(tester, const Scaffold(body: Text('pushed')));

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('pushed'), findsOneWidget);
  });

  testWidgets('escape pops the pushed route', (tester) async {
    await _mount(tester, withEscapePop: true);
    await _pushPage(tester, const Scaffold(body: Text('pushed')));

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('pushed'), findsNothing);
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('one press pops one route', (tester) async {
    await _mount(tester, withEscapePop: true);
    await _pushPage(tester, const Scaffold(body: Text('first')));
    await _pushPage(tester, const Scaffold(body: Text('second')));

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('second'), findsNothing);
    expect(find.text('first'), findsOneWidget);
  });

  testWidgets('a route that refuses to pop stays put', (tester) async {
    await _mount(tester, withEscapePop: true);
    await _pushPage(
      tester,
      const PopScope(canPop: false, child: Scaffold(body: Text('guarded'))),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('guarded'), findsOneWidget);
  });

  testWidgets('a dialog closes before the route under it', (tester) async {
    await _mount(tester, withEscapePop: true);
    await _pushPage(tester, const Scaffold(body: Text('pushed')));
    unawaited(
      showDialog<void>(
        context: tester.element(find.text('pushed')),
        builder: (_) => const AlertDialog(title: Text('dialog')),
      ),
    );
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('dialog'), findsNothing);
    expect(find.text('pushed'), findsOneWidget);
  });

  testWidgets('escape on the lone home route does not blank the app', (
    tester,
  ) async {
    await _mount(tester, withEscapePop: true);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
