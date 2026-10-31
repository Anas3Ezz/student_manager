import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'features/settings/presentation/bloc/theme_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await configureDependencies();

  // Load the saved theme before the first frame to avoid a flash.
  final themeCubit = getIt<ThemeCubit>();
  await themeCubit.load();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      useOnlyLangCode: true,
      // Use real CLDR plural rules so Arabic counts read correctly (حصتان، ٣ حصص).
      ignorePluralRules: false,
      child: BlocProvider.value(value: themeCubit, child: const TeacherApp()),
    ),
  );
}
