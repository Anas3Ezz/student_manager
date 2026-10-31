import '../../../../core/bloc/watch_list_cubit.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/usecases/watch_students_by_subject_usecase.dart';

class SubjectStudentsCubit extends WatchListCubit<StudentEntity> {
  final WatchStudentsBySubjectUseCase _watchStudentsBySubject;

  SubjectStudentsCubit(this._watchStudentsBySubject);

  void watch(int subjectId) => listenTo(_watchStudentsBySubject(subjectId));
}
