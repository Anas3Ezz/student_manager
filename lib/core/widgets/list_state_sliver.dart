import 'package:flutter/material.dart';

import '../bloc/list_state.dart';
import 'error_view.dart';
import 'loading_view.dart';

/// Renders a [ListState] as a sliver: loading, error and [empty] are shown
/// as boxes; loaded items are built by [builder] (which returns a sliver).
class ListStateSliver<T> extends StatelessWidget {
  final ListState<T> state;
  final Widget empty;
  final Widget Function(List<T> items) builder;

  /// Fill the rest of the viewport (full-page lists) instead of a box.
  final bool fillRemaining;

  const ListStateSliver({
    super.key,
    required this.state,
    required this.empty,
    required this.builder,
    this.fillRemaining = false,
  });

  @override
  Widget build(BuildContext context) => switch (state) {
    ListLoading() => _box(const LoadingView()),
    ListError(:final failure) => _box(ErrorView(failure: failure)),
    ListLoaded(items: []) => _box(empty),
    ListLoaded(:final items) => builder(items),
  };

  Widget _box(Widget child) => fillRemaining
      ? SliverFillRemaining(hasScrollBody: false, child: child)
      : SliverToBoxAdapter(child: child);
}

/// The app's standard card list: horizontal page padding, 10px gaps.
class CardSliverList extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry padding;

  const CardSliverList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: padding,
    sliver: SliverList.separated(
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: itemBuilder,
    ),
  );
}
