import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/src/settings/settings_controller.dart';
import '/src/utils/size_config.dart';
// After successfull password request, we ask use to check emails,
// so he can update password in the web app. Once done, he can come
// back on mobile app to login again.
class ResetPasswordSuccessView extends StatefulWidget {
  const ResetPasswordSuccessView({
    super.key,
    required this.controller,
    required this.setAuthPage,
  });

  final SettingsController controller;
  final Function setAuthPage;

  @override
  ResetPasswordSuccessViewState createState() {
    return ResetPasswordSuccessViewState();
  }
}

class ResetPasswordSuccessViewState extends State<ResetPasswordSuccessView> {
  @override
  Widget build(
    BuildContext context,
  ) {
    SizeConfig().init(context);
    double formHeight = SizeConfig.defaultSize * 25;
    bool isPortrait = (MediaQuery.of(context).orientation == Orientation.portrait);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.authResetPasswordSuccessTitle,
        ),
        shadowColor: Theme.of(context).colorScheme.shadow,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                // Form box wrapper
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: (SizeConfig.defaultSize * 3),
                      left: (SizeConfig.defaultSize * 3),
                      right: (SizeConfig.defaultSize * 3),
                      top: (isPortrait == false)
                        ? (SizeConfig.defaultSize * 3) // Avoid form to be sticked to AppBar in landscape
                        : 0.0,
                    ),
                    child: Container(
                        height: formHeight,
                        margin: EdgeInsets.only(
                          top: (isPortrait == true)
                            ? (SizeConfig.screenHeight / 2) - (formHeight / 2) - (SizeConfig.defaultSize * 4)
                            : 0.0,
                        ),
                        padding: EdgeInsets.only(
                          bottom: SizeConfig.padding,
                          left: SizeConfig.padding,
                          right: SizeConfig.padding,
                          top: (SizeConfig.defaultSize * 4),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                          color: Theme.of(context).colorScheme.background,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context)!.authResetPasswordSuccessHeader,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: SizeConfig.fontTextLargeSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: SizeConfig.padding,
                            ),
                            Text(
                              AppLocalizations.of(context)!.authResetPasswordSuccessContent,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: SizeConfig.padding,
                            ),
                            // Go to login button
                            ButtonTheme(
                              height: (SizeConfig.defaultSize * 5),
                              minWidth: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  AppLocalizations.of(context)!.authResetPasswordSuccessSubmit,
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
                      top: (isPortrait == true)
                        ? (SizeConfig.screenHeight / 2) - (formHeight / 2) - ((SizeConfig.defaultSize * 5) / 2) - (SizeConfig.defaultSize * 4)
                        : (SizeConfig.defaultSize * 3) / 2,
                    ),
                    height: (SizeConfig.defaultSize * 5),
                    width: (SizeConfig.defaultSize * 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
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
                        AppLocalizations.of(context)!.appTitleWithCase,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: SizeConfig.fontTextLargeSize,
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
