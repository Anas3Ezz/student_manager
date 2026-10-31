import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure_message.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/utils/snackbars.dart';
import '../../../../core/widgets/app_bar_action.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../domain/entities/student_entity.dart';
import '../bloc/student_form_cubit.dart';
import '../bloc/student_form_state.dart';

/// Adds a new student, or edits [student] when provided.
class StudentFormScreen extends StatefulWidget {
  final StudentEntity? student;
  const StudentFormScreen({super.key, this.student});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.student?.name);
    _phone = TextEditingController(text: widget.student?.phone);
    _notes = TextEditingController(text: widget.student?.notes);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _save() => context.read<StudentFormCubit>().save(
    id: widget.student?.id,
    name: _name.text,
    phone: _phone.text,
    notes: _notes.text,
  );

  void _onStateChanged(BuildContext context, StudentFormState state) {
    switch (state) {
      case StudentFormSaved(:final newStudentId):
        context.showMessage('students.saved');
        if (newStudentId != null) {
          // Open the new student so the teacher can assign subjects right away.
          context.pushReplacement(AppRoutes.student(newStudentId));
        } else {
          context.pop();
        }
      case StudentFormError(failure: ValidationFailure()):
        break; // Shown inline under the name field.
      case StudentFormError(:final failure):
        context.showFailure(failure);
      case StudentFormIdle() || StudentFormSaving():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.student != null;
    return BlocListener<StudentFormCubit, StudentFormState>(
      listener: _onStateChanged,
      child: Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          leadingWidth: 64,
          title: Text(context.tr(isEditing ? 'students.edit' : 'students.add')),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            BlocSelector<StudentFormCubit, StudentFormState, String?>(
              selector: (state) => switch (state) {
                StudentFormError(failure: final ValidationFailure f) =>
                  f.messageKey,
                _ => null,
              },
              builder: (context, errorKey) => TextField(
                controller: _name,
                autofocus: !isEditing,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: context.tr('students.name'),
                  prefixIcon: const Icon(Icons.person_outline),
                  errorText: errorKey == null ? null : context.tr(errorKey),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.tr('students.phone'),
                helperText: context.tr('common.optional'),
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: context.tr('students.notes'),
                helperText: context.tr('common.optional'),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomActionBar(
          child: BlocSelector<StudentFormCubit, StudentFormState, bool>(
            selector: (state) => state is StudentFormSaving,
            builder: (context, isSaving) => FilledButton(
              onPressed: isSaving ? null : _save,
              child: Text(context.tr('common.save')),
            ),
          ),
        ),
      ),
    );
  }
}
