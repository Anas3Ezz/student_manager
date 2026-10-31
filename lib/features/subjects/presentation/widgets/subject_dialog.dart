import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/subject_colors.dart';
import '../../../../core/widgets/color_swatch_circle.dart';
import '../../domain/entities/subject_entity.dart';

typedef SubjectDialogResult = ({String name, int colorValue});

/// Asks for a subject name and color. Returns null when cancelled.
Future<SubjectDialogResult?> showSubjectDialog(
  BuildContext context, {
  SubjectEntity? subject,
}) => showDialog<SubjectDialogResult>(
  context: context,
  builder: (_) => _SubjectDialog(subject: subject),
);

class _SubjectDialog extends StatefulWidget {
  final SubjectEntity? subject;
  const _SubjectDialog({this.subject});

  @override
  State<_SubjectDialog> createState() => _SubjectDialogState();
}

class _SubjectDialogState extends State<_SubjectDialog> {
  late final TextEditingController _name;
  late int _colorValue;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.subject?.name);
    _colorValue =
        widget.subject?.colorValue ?? SubjectColors.options.first.toARGB32();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() =>
      Navigator.of(context).pop((name: _name.text, colorValue: _colorValue));

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.subject != null;
    return AlertDialog(
      title: Text(context.tr(isEditing ? 'subjects.edit' : 'subjects.add')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: context.tr('subjects.name')),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('subjects.color'),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final color in SubjectColors.options)
                _ColorOption(
                  color: color,
                  selected: color.toARGB32() == _colorValue,
                  onTap: () => setState(() => _colorValue = color.toARGB32()),
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr('common.cancel')),
        ),
        TextButton(onPressed: _submit, child: Text(context.tr('common.save'))),
      ],
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkResponse(
    onTap: onTap,
    customBorder: const CircleBorder(),
    child: ColorSwatchCircle(color: color, selected: selected, size: 34),
  );
}
