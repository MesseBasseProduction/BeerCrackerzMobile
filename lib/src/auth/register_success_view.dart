import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:beercrackerz/src/settings/settings_controller.dart';
import 'package:beercrackerz/src/settings/size_config.dart';

class RegisterSuccessView extends StatefulWidget {
  const RegisterSuccessView({super.key, required this.controller, required this.setAuthPage});

  final SettingsController controller;
  final Function setAuthPage;

  @override
  RegisterSuccessViewState createState() {
    return RegisterSuccessViewState();
  }
}

class RegisterSuccessViewState extends State<RegisterSuccessView> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    double formHeight = SizeConfig.defaultSize * 25;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.authRegisterSuccessTitle,
        ),
        shadowColor: Theme.of(context).colorScheme.shadow,
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                // Form box wrapper
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: (SizeConfig.defaultSize * 3),
                      right: (SizeConfig.defaultSize * 3),
                      bottom: (SizeConfig.defaultSize * 3),
                    ),
                    child: Container(
                        height: formHeight,
                        margin: EdgeInsets.only(
                          top: (MediaQuery.of(context).size.height / 2) - (formHeight / 2) - (SizeConfig.defaultSize * 4),
                        ),
                        padding: EdgeInsets.only(
                          top: (SizeConfig.defaultSize * 4),
                          bottom: (SizeConfig.defaultSize * 2),
                          left: (SizeConfig.defaultSize * 2),
                          right: (SizeConfig.defaultSize * 2),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).colorScheme.background,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            // Username input field
                            Text(
                              AppLocalizations.of(context)!.authRegisterSuccessHeader,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: (SizeConfig.defaultSize * 2),
                            ),
                            Text(
                              AppLocalizations.of(context)!.authRegisterSuccessContent,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(
                              height: (SizeConfig.defaultSize * 2),
                            ),
                            ButtonTheme(
                              height: (SizeConfig.defaultSize * 5),
                              minWidth: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  AppLocalizations.of(context)!.authRegisterSuccessSubmit,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ),
                ),
                // App title wrapper
                Center(
                  child: Container(
                    margin: EdgeInsets.only(
                      top: (MediaQuery.of(context).size.height / 2) - (formHeight / 2) - ((SizeConfig.defaultSize * 5) / 2) - (SizeConfig.defaultSize * 4),
                    ),
                    height: (SizeConfig.defaultSize * 5),
                    width: (SizeConfig.defaultSize * 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.shadow,
                          blurRadius: 6,
                          offset: const Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'BeerCrackerz',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
