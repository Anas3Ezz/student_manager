import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/color_swatch_circle.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/theme_settings_entity.dart';
import '../bloc/theme_cubit.dart';
import '../theme_mappers.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const PageHeader(titleKey: 'settings.title'),
          const SliverList(
            delegate: SliverChildListDelegate.fixed([
              SectionHeader(titleKey: 'settings.appearance'),
              _Group(child: _ThemeModeSelector()),
              SectionHeader(titleKey: 'settings.color'),
              _Group(child: _PaletteSelector()),
              SectionHeader(titleKey: 'settings.language'),
              _Group(child: _LanguageSelector()),
              SizedBox(height: 32),
            ]),
          ),
        ],
      ),
    );
  }
}

/// A settings group card.
class _Group extends StatelessWidget {
  final Widget child;
  const _Group({required this.child});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    ),
  );
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ThemeCubit, ThemeSettingsEntity, AppThemeMode>(
      selector: (state) => state.mode,
      builder: (context, selected) => Row(
        children: [
          for (final (mode, icon, key) in const [
            (AppThemeMode.system, AppIcons.systemMode, 'settings.mode_system'),
            (AppThemeMode.light, AppIcons.lightMode, 'settings.mode_light'),
            (AppThemeMode.dark, AppIcons.darkMode, 'settings.mode_dark'),
          ])
            Expanded(
              child: _ModeOption(
                icon: icon,
                label: context.tr(key),
                selected: mode == selected,
                onTap: () => context.read<ThemeCubit>().setMode(mode),
              ),
            ),
        ],
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  final AppIconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: selected ? scheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              children: [
                AppIcon(
                  icon,
                  color: selected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: selected
                        ? scheme.onPrimaryContainer
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaletteSelector extends StatelessWidget {
  const _PaletteSelector();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ThemeCubit, ThemeSettingsEntity, AppPalette>(
      selector: (state) => state.palette,
      builder: (context, selected) => Row(
        children: [
          for (final palette in AppPalette.values)
            Expanded(
              child: _PaletteOption(
                palette: palette,
                selected: palette == selected,
                onTap: () => context.read<ThemeCubit>().setPalette(palette),
              ),
            ),
        ],
      ),
    );
  }
}

class _PaletteOption extends StatelessWidget {
  final AppPalette palette;
  final bool selected;
  final VoidCallback onTap;

  const _PaletteOption({
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = palette.seedColor;
    return Semantics(
      selected: selected,
      button: true,
      label: context.tr('settings.palette_${palette.name}'),
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              ColorSwatchCircle(color: color, selected: selected),
              const SizedBox(height: 6),
              Text(
                context.tr('settings.palette_${palette.name}'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context) {
    final current = context.locale.languageCode;
    return Column(
      children: [
        _LanguageTile(
          badge: 'En',
          label: 'English',
          selected: current == 'en',
          onTap: () => context.setLocale(const Locale('en')),
        ),
        _LanguageTile(
          badge: 'ع',
          label: 'العربية',
          selected: current == 'ar',
          onTap: () => context.setLocale(const Locale('ar')),
        ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String badge;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.badge,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: selected
            ? scheme.primaryContainer
            : scheme.surfaceContainerHigh,
        foregroundColor: selected
            ? scheme.onPrimaryContainer
            : scheme.onSurfaceVariant,
        child: Text(badge, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      title: Text(label),
      trailing: AnimatedOpacity(
        opacity: selected ? 1 : 0,
        duration: const Duration(milliseconds: 150),
        child: AppIcon(AppIcons.checkCircle, color: scheme.primary),
      ),
    );
  }
}
