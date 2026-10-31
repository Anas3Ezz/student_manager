import '../error/failures.dart';

sealed class ListState<T> {
  const ListState();
}

final class ListLoading<T> extends ListState<T> {
  const ListLoading();
}

final class ListLoaded<T> extends ListState<T> {
  final List<T> items;
  const ListLoaded(this.items);
}

final class ListError<T> extends ListState<T> {
  final Failure failure;
  const ListError(this.failure);
}
