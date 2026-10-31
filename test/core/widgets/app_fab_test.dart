import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher_system/core/theme/app_icons.dart';
import 'package:teacher_system/core/widgets/app_fab.dart';

/// Two tabs kept alive side by side, like the bottom-nav shell.
Widget _tabs(Widget Function(String label) fab) => IndexedStack(
  children: [
    Scaffold(floatingActionButton: fab('A')),
    Scaffold(floatingActionButton: fab('B')),
  ],
);

Future<void> _pushPageAbove(WidgetTester tester, Widget home) async {
  final navigatorKey = GlobalKey<NavigatorState>();
  await tester.pumpWidget(MaterialApp(navigatorKey: navigatorKey, home: home));
  navigatorKey.currentState!.push(
    MaterialPageRoute<void>(builder: (_) => const Scaffold()),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('default FABs in kept-alive tabs collide on navigation', (
    tester,
  ) async {
    await _pushPageAbove(
      tester,
      _tabs(
        (label) =>
            FloatingActionButton.extended(onPressed: () {}, label: Text(label)),
      ),
    );

    expect(tester.takeException(), isFlutterError);
  });

  testWidgets('AppFab in kept-alive tabs navigates without hero errors', (
    tester,
  ) async {
    await _pushPageAbove(
      tester,
      _tabs(
        (label) => AppFab(icon: AppIcons.add, label: label, onPressed: () {}),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
