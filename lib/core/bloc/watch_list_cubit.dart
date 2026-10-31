import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../result/api_result.dart';
import 'list_state.dart';

/// Base cubit that mirrors a reactive list stream into [ListState].
abstract class WatchListCubit<T> extends Cubit<ListState<T>> {
  StreamSubscription<ApiResult<List<T>>>? _subscription;

  WatchListCubit() : super(ListLoading<T>());

  /// Replaces any previous subscription with [stream].
  void listenTo(Stream<ApiResult<List<T>>> stream) {
    _subscription?.cancel();
    _subscription = stream.listen(
      (result) => result.when(
        success: (items) => emit(ListLoaded<T>(items)),
        failure: (failure) => emit(ListError<T>(failure)),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
