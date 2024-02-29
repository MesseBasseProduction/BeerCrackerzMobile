import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsTitle),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text(AppLocalizations.of(context)!.settingsInterfaceSection),
            tiles: [
              SettingsTile(
                title: Text(AppLocalizations.of(context)!.settingsInterfaceLanguage),
                leading: const Icon(Icons.language),
                trailing: DropdownMenu<Locale>(
                  initialSelection: controller.appLocale,
                  onSelected: controller.updateAppLocale,
                  inputDecorationTheme: const InputDecorationTheme(),
                  dropdownMenuEntries: [
                    DropdownMenuEntry(
                      value: const Locale.fromSubtags(languageCode: 'en'),
                      label: AppLocalizations.of(context)!.settingsInterfaceLanguageEn,
                    ),
                    DropdownMenuEntry(
                      value: const Locale.fromSubtags(languageCode: 'fr'),
                      label: AppLocalizations.of(context)!.settingsInterfaceLanguageFr,
                    ),
                    DropdownMenuEntry(
                      value: const Locale.fromSubtags(languageCode: 'es'),
                      label: AppLocalizations.of(context)!.settingsInterfaceLanguageEs,
                    ),
                    DropdownMenuEntry(
                      value: const Locale.fromSubtags(languageCode: 'de'),
                      label: AppLocalizations.of(context)!.settingsInterfaceLanguageDe,
                    ),
                  ],
                ),
                onPressed: (BuildContext context) {},
              ),
              SettingsTile(
                title: Text(AppLocalizations.of(context)!.settingsInterfaceTheme),
                leading: const Icon(Icons.palette),
                trailing: DropdownMenu<ThemeMode>(
                  initialSelection: controller.themeMode,
                  onSelected: controller.updateThemeMode,
                  inputDecorationTheme: const InputDecorationTheme(
                    border: null,
                    contentPadding: EdgeInsets.only(left: 10),
                  ),
                  dropdownMenuEntries: [
                    DropdownMenuEntry(
                      value: ThemeMode.light,
                      label: AppLocalizations.of(context)!.settingsInterfaceThemeDark,
                    ),
                    DropdownMenuEntry(
                      value: ThemeMode.light,
                      label: AppLocalizations.of(context)!.settingsInterfaceThemeLight,
                    ),
                  ],
                ),
                onPressed: (BuildContext context) {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
