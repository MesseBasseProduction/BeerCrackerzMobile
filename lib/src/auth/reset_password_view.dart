import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:loader_overlay/loader_overlay.dart';
import 'package:toastification/toastification.dart';

import '/src/auth/profile_service.dart';
import '/src/utils/size_config.dart';
// User request to reset password, to do so, we ask for email,
// then sent an email for user to confirm request.
class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({
    super.key,
    required this.setAuthPage,
  });

  final Function setAuthPage;

  @override
  ResetPasswordViewState createState() {
    return ResetPasswordViewState();
  }
}

class ResetPasswordViewState extends State<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  String email = '';

  void formValidation(
    BuildContext context,
    String email,
  ) {
    _formKey.currentState!.save();
    // Dismiss keyboard by removing focus on current input if any
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    if (_formKey.currentState!.validate()) {
      // Start loading overlay during server call
      context.loaderOverlay.show();
      ProfileService.submitResetPassword(
        email
      ).then((response) {
        // HTTP/204, Alrighty, move to password change success
        if (response.statusCode == 204) {
          widget.setAuthPage(4);
        } else {
          // Unexpected response code from server
          // Error RSP1
          toastification.show(
            context: context,
            title: Text(
              AppLocalizations.of(context)!.httpWrongResponseToastTitle,
            ),
            description: Text(
              AppLocalizations.of(context)!.httpWrongResponseToastDescription('RSP1 (${response.statusCode})'),
              style: const TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
            type: ToastificationType.error,
            style: ToastificationStyle.flatColored,
            autoCloseDuration: const Duration(
              seconds: 5,
            ),
            showProgressBar: false,
          );
        }
      }).catchError((handleError) {
        // Unable to perform server call
        // Error RSP2
        toastification.show(
          context: context,
          title: Text(
            AppLocalizations.of(context)!.httpFrontErrorToastTitle,
          ),
          description: Text(
            AppLocalizations.of(context)!.httpFrontErrorToastDescription('RSP2'),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          autoCloseDuration: const Duration(
            seconds: 5,
          ),
          showProgressBar: false,
        );
      }).whenComplete(() {
        // Hide overlay loader anyway
        context.loaderOverlay.hide();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double formHeight = SizeConfig.defaultSize * 30;
    bool isPortrait = (MediaQuery.of(context).orientation == Orientation.portrait);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.authResetPasswordTitle,
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
                      bottom: SizeConfig.paddingLarge,
                      left: SizeConfig.paddingLarge,
                      right: SizeConfig.paddingLarge,
                      top: (isPortrait == false)
                        ? SizeConfig.paddingLarge // Avoid form to be sticked to AppBar in landscape
                        : 0.0,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Container(
                        height: formHeight,
                        margin: EdgeInsets.only(
                          top: (isPortrait == true)
                            ? (SizeConfig.screenHeight / 2) - (formHeight / 2) - SizeConfig.paddingBig
                            : 0.0,
                        ),
                        padding: EdgeInsets.only(
                          bottom: SizeConfig.padding,
                          left: SizeConfig.padding,
                          right: SizeConfig.padding,
                          top: SizeConfig.paddingHuge,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                          color: Theme.of(context).colorScheme.background,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            // Mail input field
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              scrollPadding: EdgeInsets.only(
                                bottom: (formHeight / 2),
                              ),
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.authResetPasswordInput,
                                labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                filled: true,
                                prefixIcon: Icon(
                                  Icons.mail,
                                  size: SizeConfig.padding,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                                  borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                              inputFormatters: [
                                // See https://github.com/MesseBasseProduction/BeerCrackerz backend for this char limitation
                                LengthLimitingTextInputFormatter(100),
                              ],
                              onSaved: (
                                String? value,
                              ) => email = value!,
                              validator: (value) {
                                // Field value can not be empty to be a valid input
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!.emptyInput(AppLocalizations.of(context)!.authResetPassword);
                                }
                                // Field must contain '@', char(s) before, char(s) after, containing '.' and chars(s) after
                                final bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
                                if (emailValid != true) {
                                  return AppLocalizations.of(context)!.authResetPasswordInvalidEmail;
                                }

                                return null;
                              },
                            ),
                            SizedBox(
                              height: SizeConfig.padding,
                            ),
                            ButtonTheme(
                              height: (SizeConfig.defaultSize * 5),
                              minWidth: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                onPressed: () => formValidation(
                                  context,
                                  email,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.authResetPasswordSubmit,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: SizeConfig.padding,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // App title wrapper
                Center(
                  child: Container(
                    margin: EdgeInsets.only(
                      top: (SizeConfig.screenHeight / 2) - (formHeight / 2) - ((SizeConfig.defaultSize * 5) / 2) - SizeConfig.paddingBig,
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
