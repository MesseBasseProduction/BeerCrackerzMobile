import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';

import '/src/settings/settings_controller.dart';
import '/src/utils/app_const.dart';
import '/src/utils/size_config.dart';
// This settings view handle global app settings.
// They are stored on the phone so they are permanent.
// This view allow the end user to modify those settings.
class SettingsView extends StatefulWidget {
  const SettingsView({
    super.key,
    required this.settingsController,
  });

  static const routeName = '/settings';
  final SettingsController settingsController;

  @override
  SettingsViewState createState() {
    return SettingsViewState();
  }
}

class SettingsViewState extends State<SettingsView> {
  @override
  Widget build(
    BuildContext context,
  ) {
    SizeConfig().init(context);
    Locale localeValue = widget.settingsController.appLocale;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settingsTitle,
        ),
        shadowColor: Theme.of(context).colorScheme.shadow,
      ),
      body: SettingsList(
        sections: [
          // Interface section
          SettingsSection(
            title: Text(
              AppLocalizations.of(context)!.settingsInterfaceSection,
            ),
            tiles: [
              // App locale selection
              SettingsTile.navigation(
                leading: const Icon(
                  Icons.language,
                ),
                title: Text(
                  AppLocalizations.of(context)!.settingsInterfaceLanguageSetting,
                ),
                value: Text(
                  AppLocalizations.of(context)!.settingsInterfaceLanguage(localeValue.toString()),
                ),
                onPressed: (
                  context,
                ) {
                  showDialog(
                    context: context,
                    builder: (
                      context,
                    ) {
                      return StatefulBuilder(
                        builder: (
                          context,
                          setDialogState,
                        ) {
                          // Internal method to build supported lang Dialog ListTiles
                          List<RadioListTile<Locale>> buildSupportedLocale() {
                            List<RadioListTile<Locale>> output = [];
                            for (var locale in AppConst.supportedLang) {
                              output.add(
                                RadioListTile<Locale>(
                                  title: Text(
                                    AppLocalizations.of(context)!.settingsInterfaceLanguage(locale),
                                    style: TextStyle(
                                      fontSize: SizeConfig.fontTextSize,
                                    ),
                                  ),
                                  visualDensity: const VisualDensity(
                                    horizontal: 0,
                                    vertical: -4, // Tighten list entries
                                  ),
                                  value: Locale.fromSubtags(
                                    languageCode: locale,
                                  ),
                                  groupValue: localeValue,
                                  onChanged: (
                                    Locale? value,
                                  ) {
                                    localeValue = value!;
                                    setDialogState(() {});
                                  },
                                ),
                              );
                            }
                            return output;
                          }
                          // Build locale update radio dialog
                          return Dialog(
                            child: Padding(
                              padding: EdgeInsets.all(
                                SizeConfig.padding,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  // Dialog title
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: SizeConfig.paddingSmall,
                                          bottom: SizeConfig.paddingSmall,
                                        ),
                                        child: Text(
                                          AppLocalizations.of(context)!.settingsInterfaceLanguageDialogTitle,
                                          style: TextStyle(
                                            fontSize: SizeConfig.fontTextBigSize,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Lists for all supported lang
                                  Column(
                                    children: buildSupportedLocale(),
                                  ),
                                  // Close dialog text button
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        child: Text(
                                          AppLocalizations.of(context)!.settingsInterfaceClose,
                                        ),
                                        onPressed: () => Navigator.of(context).pop(),
                                      ),
                                    ]
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ).then((_) async {
                    // Update app locale then update SettingsView state
                    await widget.settingsController.updateAppLocale(localeValue);
                    setState(() {});
                  });
                }
              ),
              // UI dark theme switch
              SettingsTile.switchTile(
                initialValue: (widget.settingsController.themeMode == ThemeMode.dark)
                  ? true
                  : false,
                leading: const Icon(
                  Icons.palette,
                ),
                title: Text(
                  AppLocalizations.of(context)!.settingsInterfaceTheme,
                ),
                onToggle: (
                  checked,
                ) async {
                  if (checked == true) {
                    await widget.settingsController.updateThemeMode(ThemeMode.dark);
                  } else {
                    await widget.settingsController.updateThemeMode(ThemeMode.light);
                  }
                },
              ),
            ],
          ),
          SettingsSection(
            title: Text(
              AppLocalizations.of(context)!.settingsAppSection,
            ),
            tiles: [
              // App welcome screen to explain BeerCrackerz
              SettingsTile.switchTile(
                initialValue: (widget.settingsController.showWelcomeScreen == true)
                  ? true
                  : false,
                leading: const Icon(
                  Icons.not_listed_location,
                ),
                title: Text(
                  AppLocalizations.of(context)!.settingsAppShowWelcomeScreenSetting,
                ),
                description: Text(
                  AppLocalizations.of(context)!.settingsAppShowWelcomeScreenSettingDescription,
                ),
                onToggle: (
                  checked,
                ) async {
                  if (checked == true) {
                    await widget.settingsController.updateShowWelcomeScreen(true);
                  } else {
                    await widget.settingsController.updateShowWelcomeScreen(false);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
