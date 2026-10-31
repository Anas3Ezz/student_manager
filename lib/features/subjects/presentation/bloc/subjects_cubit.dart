import '../../../../core/bloc/watch_list_cubit.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/entities/subject_entity.dart';
import '../../domain/usecases/add_subject_usecase.dart';
import '../../domain/usecases/delete_subject_usecase.dart';
import '../../domain/usecases/update_subject_usecase.dart';
import '../../domain/usecases/watch_subjects_usecase.dart';

class SubjectsCubit extends WatchListCubit<SubjectEntity> {
  final WatchSubjectsUseCase _watchSubjects;
  final AddSubjectUseCase _addSubject;
  final UpdateSubjectUseCase _updateSubject;
  final DeleteSubjectUseCase _deleteSubject;

  SubjectsCubit(
    this._watchSubjects,
    this._addSubject,
    this._updateSubject,
    this._deleteSubject,
  );

  void watch() => listenTo(_watchSubjects());

  Future<Failure?> add({required String name, int? colorValue}) async =>
      (await _addSubject(name: name, colorValue: colorValue)).failureOrNull;

  Future<Failure?> update(SubjectEntity subject) async =>
      (await _updateSubject(subject)).failureOrNull;

  Future<Failure?> delete(int id) async =>
      (await _deleteSubject(id)).failureOrNull;
}
