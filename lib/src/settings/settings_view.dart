import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';

import '/src/settings/settings_controller.dart';
import '/src/settings/size_config.dart';
/// Displays the various settings that can be customized by the user.
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatefulWidget {
  const SettingsView({
    super.key,
    required this.controller,
  });

  static const routeName = '/settings';

  final SettingsController controller;
  
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
    Locale localeValue = widget.controller.appLocale;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsTitle),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text(AppLocalizations.of(context)!.settingsInterfaceSection),
            tiles: [
              SettingsTile.navigation(
                leading: const Icon(Icons.language),
                title: Text(
                  AppLocalizations.of(context)!.settingsInterfaceLanguageSetting,
                ),
                value: Text(
                  AppLocalizations.of(context)!.settingsInterfaceLanguage(localeValue.toString()),
                ),
                onPressed: (context) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setDialogState) {
                          return Dialog(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 28.0, bottom: 8.0),
                                        child: Text(
                                          AppLocalizations.of(context)!.settingsInterfaceLanguageDialogTitle,
                                          style: TextStyle(
                                            fontSize: SizeConfig.fontTextBigSize,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  ListTile(
                                    title: Text(
                                      AppLocalizations.of(context)!.settingsInterfaceLanguage('en'),
                                      style: TextStyle(
                                        fontSize: SizeConfig.fontTextSize,
                                      ),
                                    ),
                                    visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                                    leading: Radio<Locale>(
                                      value: const Locale.fromSubtags(languageCode: 'en'),
                                      groupValue: localeValue,
                                      onChanged: (Locale? value) {
                                        localeValue = value!;
                                        setDialogState(() {});
                                      },
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      AppLocalizations.of(context)!.settingsInterfaceLanguage('fr'),
                                      style: TextStyle(
                                        fontSize: SizeConfig.fontTextSize,
                                      ),
                                    ),
                                    visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                                    leading: Radio<Locale>(
                                      value: const Locale.fromSubtags(languageCode: 'fr'),
                                      groupValue: localeValue,
                                      onChanged: (Locale? value) {
                                        localeValue = value!;
                                        setDialogState(() {});
                                      },
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      AppLocalizations.of(context)!.settingsInterfaceLanguage('es'),
                                      style: TextStyle(
                                        fontSize: SizeConfig.fontTextSize,
                                      ),
                                    ),
                                    visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                                    leading: Radio<Locale>(
                                      value: const Locale.fromSubtags(languageCode: 'es'),
                                      groupValue: localeValue,
                                      onChanged: (Locale? value) {
                                        localeValue = value!;
                                        setDialogState(() {});
                                      },
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      AppLocalizations.of(context)!.settingsInterfaceLanguage('de'),
                                      style: TextStyle(
                                        fontSize: SizeConfig.fontTextSize,
                                      ),
                                    ),
                                    visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                                    leading: Radio<Locale>(
                                      value: const Locale.fromSubtags(languageCode: 'de'),
                                      groupValue: localeValue,
                                      onChanged: (Locale? value) {
                                        localeValue = value!;
                                        setDialogState(() {});
                                      },
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      AppLocalizations.of(context)!.settingsInterfaceLanguage('it'),
                                      style: TextStyle(
                                        fontSize: SizeConfig.fontTextSize,
                                      ),
                                    ),
                                    visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                                    leading: Radio<Locale>(
                                      value: const Locale.fromSubtags(languageCode: 'it'),
                                      groupValue: localeValue,
                                      onChanged: (Locale? value) {
                                        localeValue = value!;
                                        setDialogState(() {});
                                      },
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      AppLocalizations.of(context)!.settingsInterfaceLanguage('pt'),
                                      style: TextStyle(
                                        fontSize: SizeConfig.fontTextSize,
                                      ),
                                    ),
                                    visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                                    leading: Radio<Locale>(
                                      value: const Locale.fromSubtags(languageCode: 'pt'),
                                      groupValue: localeValue,
                                      onChanged: (Locale? value) {
                                        localeValue = value!;
                                        setDialogState(() {});
                                      },
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        child: const Text('Close'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
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
                    await widget.controller.updateAppLocale(localeValue);
                    setState(() {});
                  });
                }
              ),
              SettingsTile.switchTile(
                onToggle: (value) async {
                  if (value == true) {
                    await widget.controller.updateThemeMode(ThemeMode.light);
                  } else {
                    await widget.controller.updateThemeMode(ThemeMode.dark);
                  }
                },
                initialValue: (widget.controller.themeMode == ThemeMode.dark)
                  ? false
                  : true,
                leading: const Icon(
                  Icons.palette,
                ),
                title: Text(
                  AppLocalizations.of(context)!.settingsInterfaceTheme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
