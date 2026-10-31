import '../../../../core/bloc/watch_list_cubit.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/usecases/watch_students_usecase.dart';

class StudentsCubit extends WatchListCubit<StudentEntity> {
  final WatchStudentsUseCase _watchStudents;
  String _query = '';

  StudentsCubit(this._watchStudents);

  bool get hasQuery => _query.isNotEmpty;

  void watch() => listenTo(_watchStudents(query: _query));

  void search(String query) {
    final trimmed = query.trim();
    if (trimmed == _query) return;
    _query = trimmed;
    watch();
  }
}
