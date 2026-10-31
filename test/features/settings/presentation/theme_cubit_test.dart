import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:teacher_system/core/error/failures.dart';
import 'package:teacher_system/core/result/api_result.dart';
import 'package:teacher_system/features/settings/domain/entities/theme_settings_entity.dart';
import 'package:teacher_system/features/settings/domain/usecases/get_theme_settings_usecase.dart';
import 'package:teacher_system/features/settings/domain/usecases/save_theme_settings_usecase.dart';
import 'package:teacher_system/features/settings/presentation/bloc/theme_cubit.dart';

class _MockGet extends Mock implements GetThemeSettingsUseCase {}

class _MockSave extends Mock implements SaveThemeSettingsUseCase {}

void main() {
  late _MockGet getSettings;
  late _MockSave saveSettings;

  const dark = ThemeSettingsEntity(mode: AppThemeMode.dark);

  setUpAll(() => registerFallbackValue(const ThemeSettingsEntity()));

  setUp(() {
    getSettings = _MockGet();
    saveSettings = _MockSave();
    when(() => saveSettings(any()))
        .thenAnswer((_) async => const ApiResult<void>.success(null));
  });

  blocTest<ThemeCubit, ThemeSettingsEntity>(
    'load emits the stored settings',
    setUp: () =>
        when(() => getSettings())
            .thenAnswer((_) async => const ApiResult.success(dark)),
    build: () => ThemeCubit(getSettings, saveSettings),
    act: (cubit) => cubit.load(),
    expect: () => [dark],
  );

  blocTest<ThemeCubit, ThemeSettingsEntity>(
    'load keeps defaults when reading fails',
    setUp: () => when(() => getSettings())
        .thenAnswer((_) async => const ApiResult.failure(DatabaseFailure('x'))),
    build: () => ThemeCubit(getSettings, saveSettings),
    act: (cubit) => cubit.load(),
    expect: () => <ThemeSettingsEntity>[],
  );

  blocTest<ThemeCubit, ThemeSettingsEntity>(
    'setPalette emits and persists the new palette',
    build: () => ThemeCubit(getSettings, saveSettings),
    act: (cubit) => cubit.setPalette(AppPalette.orange),
    expect: () => [const ThemeSettingsEntity(palette: AppPalette.orange)],
    verify: (_) => verify(
      () => saveSettings(const ThemeSettingsEntity(palette: AppPalette.orange)),
    ).called(1),
  );

  blocTest<ThemeCubit, ThemeSettingsEntity>(
    'setMode with the current mode does nothing',
    build: () => ThemeCubit(getSettings, saveSettings),
    act: (cubit) => cubit.setMode(AppThemeMode.system),
    expect: () => <ThemeSettingsEntity>[],
    verify: (_) => verifyNever(() => saveSettings(any())),
  );
}
