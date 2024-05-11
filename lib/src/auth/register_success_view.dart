import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/src/settings/settings_controller.dart';
import '/src/settings/size_config.dart';
// Displayed when the registration process went successfull.
// Invite user to confirm its account from its mail address and
// when done, invite to click on button to go to login.
class RegisterSuccessView extends StatefulWidget {
  const RegisterSuccessView({
    super.key,
    required this.controller,
    required this.setAuthPage,
  });

  final SettingsController controller;
  final Function setAuthPage;

  @override
  RegisterSuccessViewState createState() {
    return RegisterSuccessViewState();
  }
}

class RegisterSuccessViewState extends State<RegisterSuccessView> {
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
          AppLocalizations.of(context)!.authRegisterSuccessTitle,
        ),
        shadowColor: Theme.of(context).colorScheme.shadow,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // We use stack to properly position form and app title all together
            Stack(
              children: <Widget>[
                // Form box wrapper
                Center(
                  // Form outter panning
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
                      // Form inner padding
                      padding: EdgeInsets.only(
                        top: (SizeConfig.defaultSize * 4),
                        bottom: (SizeConfig.defaultSize * 2),
                        left: (SizeConfig.defaultSize * 2),
                        right: (SizeConfig.defaultSize * 2),
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
                            AppLocalizations.of(context)!.authRegisterSuccessHeader,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: SizeConfig.fontTextLargeSize,
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
                          // Back to Login button, once mail confirmed
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
                      top: (isPortrait == true)
                        ? (SizeConfig.screenHeight / 2) - (formHeight / 2) - ((SizeConfig.defaultSize * 5) / 2) - (SizeConfig.defaultSize * 4)
                        : (SizeConfig.defaultSize * 3) / 2, // Half padding on main Form container to keep "offset"
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
