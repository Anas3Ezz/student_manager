import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/domain/entities/theme_settings_entity.dart';
import 'features/settings/presentation/bloc/theme_cubit.dart';
import 'features/settings/presentation/theme_mappers.dart';

class TeacherApp extends StatelessWidget {
  const TeacherApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme affects the whole app, so this is the one top-level builder.
    return BlocBuilder<ThemeCubit, ThemeSettingsEntity>(
      builder: (context, settings) {
        final seed = settings.palette.seedColor;
        return MaterialApp.router(
          onGenerateTitle: (context) => context.tr('app_title'),
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: AppTheme.build(seed: seed, brightness: Brightness.light),
          darkTheme: AppTheme.build(seed: seed, brightness: Brightness.dark),
          themeMode: settings.mode.themeMode,
        );
      },
    );
  }
}
