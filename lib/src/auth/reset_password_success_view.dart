import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:beercrackerz/src/settings/settings_controller.dart';
import 'package:beercrackerz/src/settings/size_config.dart';

class ResetPasswordSuccessView extends StatefulWidget {
  const ResetPasswordSuccessView({super.key, required this.controller, required this.setAuthPage});

  final SettingsController controller;
  final Function setAuthPage;

  @override
  ResetPasswordSuccessViewState createState() {
    return ResetPasswordSuccessViewState();
  }
}

class ResetPasswordSuccessViewState extends State<ResetPasswordSuccessView> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    double formHeight = SizeConfig.defaultSize * 25;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.authResetPasswordSuccessTitle),
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
                      left: SizeConfig.defaultSize * 3,
                      right: SizeConfig.defaultSize * 3
                    ),
                    child: Container(
                        height: formHeight,
                        margin: EdgeInsets.only(top: (MediaQuery.of(context).size.height / 2) - (formHeight / 2) - (SizeConfig.defaultSize * 4)),
                        padding: EdgeInsets.only(
                          top: SizeConfig.defaultSize * 4,
                          bottom: SizeConfig.defaultSize * 2,
                          left: SizeConfig.defaultSize * 2,
                          right: SizeConfig.defaultSize * 2
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            // Username input field
                            Text(
                              AppLocalizations.of(context)!.authResetPasswordSuccessHeader,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18
                              ),
                            ),
                            SizedBox(
                              height: SizeConfig.defaultSize * 2,
                            ),
                            Text(
                              AppLocalizations.of(context)!.authResetPasswordSuccessContent,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: SizeConfig.defaultSize * 2,
                            ),
                            ButtonTheme(
                              height: SizeConfig.defaultSize * 5,
                              minWidth: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                onPressed: () { Navigator.of(context).pop(); },
                                child: Text(AppLocalizations.of(context)!.authResetPasswordSuccessSubmit),
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
                    margin: EdgeInsets.only(top: (MediaQuery.of(context).size.height / 2) - (formHeight / 2) - ((SizeConfig.defaultSize * 5) / 2) - (SizeConfig.defaultSize * 4)),
                    height: SizeConfig.defaultSize * 5,
                    width: SizeConfig.defaultSize * 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
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
                          fontWeight: FontWeight.bold,
                          fontSize: 18
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
