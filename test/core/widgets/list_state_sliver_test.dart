import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher_system/core/bloc/list_state.dart';
import 'package:teacher_system/core/widgets/list_state_sliver.dart';
import 'package:teacher_system/core/widgets/loading_view.dart';

Future<void> _pump(WidgetTester tester, ListState<String> state) =>
    tester.pumpWidget(
      MaterialApp(
        home: CustomScrollView(
          slivers: [
            ListStateSliver<String>(
              state: state,
              empty: const Text('empty'),
              builder: (items) => CardSliverList(
                itemCount: items.length,
                itemBuilder: (_, i) => Text(items[i]),
              ),
            ),
          ],
        ),
      ),
    );

void main() {
  testWidgets('shows the loading view while loading', (tester) async {
    await _pump(tester, const ListLoading());

    expect(find.byType(LoadingView), findsOneWidget);
  });

  testWidgets('shows the empty widget for an empty list', (tester) async {
    await _pump(tester, const ListLoaded([]));

    expect(find.text('empty'), findsOneWidget);
  });

  testWidgets('builds every loaded item', (tester) async {
    await _pump(tester, const ListLoaded(['a', 'b']));

    expect(find.text('a'), findsOneWidget);
    expect(find.text('b'), findsOneWidget);
    expect(find.text('empty'), findsNothing);
  });
}
