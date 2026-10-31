import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:teacher_system/core/theme/app_icons.dart';
import 'package:teacher_system/core/widgets/app_icon.dart';

void main() {
  testWidgets('keeps its size inside a slot with a larger minimum size', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: const AppIcon(AppIcons.add, size: 22),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(HugeIcon)), const Size(22, 22));
  });
}
