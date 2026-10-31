import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/list_state.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/error/failure_message.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/subject_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/color_dot.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/star_rating.dart';
import '../../../subjects/domain/entities/subject_entity.dart';
import '../../../subjects/presentation/bloc/subjects_cubit.dart';
import '../../../subjects/presentation/widgets/subject_dialog.dart';
import '../../domain/entities/session_entity.dart';
import '../bloc/session_form_cubit.dart';
import '../bloc/session_form_state.dart';

/// Opens the quick "log session" sheet. Pass [session] to edit instead.
Future<void> showSessionFormSheet(
  BuildContext context, {
  required int studentId,
  String? studentName,
  SessionEntity? session,
}) async {
  // Captured up front: the calling tile may be gone after an edit moves it.
  final messenger = ScaffoldMessenger.of(context);
  final savedText = context.tr('session.saved');
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BlocProvider(
      create: (_) =>
          getIt<SessionFormCubit>()
            ..load(studentId: studentId, editing: session),
      child: _SessionFormSheet(
        studentName: studentName ?? session?.studentName,
        session: session,
      ),
    ),
  );
  if (saved == true) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(savedText)));
  }
}

/// Opens the sheet to edit an existing [session].
Future<void> showSessionFormSheetFor(
  BuildContext context,
  SessionEntity session,
) => showSessionFormSheet(
  context,
  studentId: session.studentId,
  session: session,
);

class _SessionFormSheet extends StatelessWidget {
  final String? studentName;
  final SessionEntity? session;

  const _SessionFormSheet({required this.studentName, required this.session});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetTitle(
            titleKey: session == null ? 'session.log' : 'session.edit',
            studentName: studentName,
          ),
          // Flexible lets the form scroll when the keyboard takes space.
          Flexible(
            child: BlocConsumer<SessionFormCubit, SessionFormState>(
              listenWhen: (_, current) => current is SessionFormSaved,
              listener: (context, _) => Navigator.of(context).pop(true),
              buildWhen: (previous, current) =>
                  current is! SessionFormSaved &&
                  previous.runtimeType != current.runtimeType,
              builder: (context, state) => switch (state) {
                SessionFormLoading() || SessionFormSaved() => const Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator()),
                ),
                SessionFormLoadError(:final failure) => ErrorView(
                  failure: failure,
                ),
                // No subjects yet: let the teacher assign one right here.
                SessionFormReady(subjects: []) => BlocProvider(
                  create: (_) => getIt<SubjectsCubit>()..watch(),
                  child: const _AssignSubjectPrompt(),
                ),
                SessionFormReady() => _SessionForm(
                  ready: state,
                  session: session,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  final String titleKey;
  final String? studentName;

  const _SheetTitle({required this.titleKey, required this.studentName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = studentName;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: Row(
        children: [
          if (name != null) ...[
            AppAvatar(name: name, size: 44),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr(titleKey), style: theme.textTheme.titleLarge),
                if (name != null)
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionForm extends StatefulWidget {
  final SessionFormReady ready;
  final SessionEntity? session;

  const _SessionForm({required this.ready, required this.session});

  @override
  State<_SessionForm> createState() => _SessionFormState();
}

class _SessionFormState extends State<_SessionForm> {
  late final TextEditingController _notesController;
  late int? _subjectId;
  late DateTime _date;
  late int _rating;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.session?.notes);
    _subjectId = widget.ready.initialSubjectId;
    _date = widget.ready.initialDate;
    _rating = widget.session?.rating ?? 0;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = widget.ready.today;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      // An edited session dated after "today" (clock change) must stay valid.
      lastDate: _date.isAfter(today) ? _date : today,
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    final subjectId = _subjectId;
    if (subjectId == null) return;
    context.read<SessionFormCubit>().save(
      subjectId: subjectId,
      date: _date,
      rating: _rating,
      notes: _notesController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = widget.ready.today;
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Label('session.subject'),
          _SubjectChoices(
            subjects: widget.ready.subjects,
            selectedId: _subjectId,
            onSelected: (id) => setState(() => _subjectId = id),
          ),
          const SizedBox(height: 20),
          const _Label('session.date'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ChoiceChip(
                label: Text(context.tr('session.today')),
                selected: DateUtils.isSameDay(_date, today),
                onSelected: (_) => setState(() => _date = today),
              ),
              ChoiceChip(
                label: Text(context.tr('session.yesterday')),
                selected: DateUtils.isSameDay(_date, yesterday),
                onSelected: (_) => setState(() => _date = yesterday),
              ),
              ActionChip(
                avatar: const AppIcon(AppIcons.calendar, size: 18),
                label: Text(AppDateFormat.fullDate(_date, context.locale)),
                onPressed: _pickDate,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _Label('session.rating'),
          _RatingPicker(
            rating: _rating,
            onChanged: (value) => setState(() => _rating = value),
          ),
          const SizedBox(height: 20),
          const _Label('session.notes'),
          TextField(
            controller: _notesController,
            minLines: 3,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: context.tr('session.notes_hint'),
            ),
          ),
          const SizedBox(height: 20),
          const _SaveFailureText(),
          BlocSelector<SessionFormCubit, SessionFormState, bool>(
            selector: (state) => state is SessionFormReady && state.isSaving,
            builder: (context, isSaving) => FilledButton(
              onPressed: isSaving || _subjectId == null || _rating == 0
                  ? null
                  : _save,
              child: isSaving
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Text(context.tr('common.save')),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when the student has no subjects: pick one (or create one)
/// to assign, and the form opens with it selected.
class _AssignSubjectPrompt extends StatelessWidget {
  const _AssignSubjectPrompt();

  Future<void> _createSubject(BuildContext context) async {
    final cubit = context.read<SessionFormCubit>();
    final result = await showSubjectDialog(context);
    if (result == null) return;
    await cubit.createAndAssignSubject(
      name: result.name,
      colorValue: result.colorValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.tr('session.no_subjects'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          BlocBuilder<SubjectsCubit, ListState<SubjectEntity>>(
            builder: (context, state) => switch (state) {
              ListLoading() => const SizedBox(height: 40),
              ListError(:final failure) => ErrorView(failure: failure),
              ListLoaded(:final items) =>
                BlocSelector<SessionFormCubit, SessionFormState, bool>(
                  selector: (state) =>
                      state is SessionFormReady && state.isSaving,
                  builder: (context, isBusy) => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final subject in items)
                        ActionChip(
                          avatar: ColorDot(
                            color: SubjectColors.resolve(
                              subject.colorValue,
                              theme.colorScheme,
                            ),
                          ),
                          label: Text(subject.name),
                          onPressed: isBusy
                              ? null
                              : () => context
                                    .read<SessionFormCubit>()
                                    .assignSubject(subject.id),
                        ),
                      ActionChip(
                        avatar: const AppIcon(AppIcons.add, size: 18),
                        label: Text(context.tr('subjects.add')),
                        onPressed: isBusy
                            ? null
                            : () => _createSubject(context),
                      ),
                    ],
                  ),
                ),
            },
          ),
          const SizedBox(height: 12),
          const _SaveFailureText(),
        ],
      ),
    );
  }
}

/// Shown inline: a snackbar would sit behind the modal sheet.
class _SaveFailureText extends StatelessWidget {
  const _SaveFailureText();

  @override
  Widget build(BuildContext context) =>
      BlocSelector<SessionFormCubit, SessionFormState, Failure?>(
        selector: (state) =>
            state is SessionFormReady ? state.saveFailure : null,
        builder: (context, failure) => failure == null
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  context.tr(failure.messageKey),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
      );
}

/// Big stars with a word describing the chosen rating.
class _RatingPicker extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChanged;

  const _RatingPicker({required this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: StarRating.starColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          StarRating(rating: rating, size: 42, onChanged: onChanged),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              context.tr(
                rating == 0
                    ? 'session.rating_hint'
                    : 'session.rating_labels.$rating',
              ),
              key: ValueKey(rating),
              style: theme.textTheme.labelLarge?.copyWith(
                color: rating == 0
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectChoices extends StatelessWidget {
  final List<SubjectEntity> subjects;
  final int? selectedId;
  final ValueChanged<int> onSelected;

  const _SubjectChoices({
    required this.subjects,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final subject in subjects)
          _subjectChip(
            subject,
            SubjectColors.resolve(subject.colorValue, scheme),
            subject.id == selectedId,
          ),
      ],
    );
  }

  Widget _subjectChip(SubjectEntity subject, Color color, bool selected) {
    return ChoiceChip(
      avatar: ColorDot(color: color),
      label: Text(subject.name),
      selected: selected,
      selectedColor: color.withValues(alpha: 0.16),
      side: selected ? BorderSide(color: color, width: 1.4) : null,
      onSelected: (_) => onSelected(subject.id),
    );
  }
}

class _Label extends StatelessWidget {
  final String keyName;
  const _Label(this.keyName);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      context.tr(keyName),
      style: Theme.of(context).textTheme.labelLarge
          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
  );
}
