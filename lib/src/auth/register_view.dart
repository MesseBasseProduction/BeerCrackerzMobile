import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:loader_overlay/loader_overlay.dart';
import 'package:toastification/toastification.dart';

import 'package:beercrackerz/src/auth/profile_service.dart';
import 'package:beercrackerz/src/settings/settings_controller.dart';
import 'package:beercrackerz/src/settings/size_config.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key, required this.controller, required this.setAuthPage});

  final SettingsController controller;
  final Function setAuthPage;

  @override
  RegisterViewState createState() {
    return RegisterViewState();
  }
}
// Needs to be outside state to ensure data perenity
bool showPassword1 = false;
bool showPassword2 = false;
String? usernameErrorMsg;
String? emailErrorMsg;
String? passwordErrorMsg;

class RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    double formHeight = SizeConfig.defaultSize * 65;
    String username = '';
    String email = '';
    String password1 = '';
    String password2 = '';

    void formValidation() {
      setState(() {
        usernameErrorMsg = null;
        emailErrorMsg = null;
        passwordErrorMsg = null;
      });
      _formKey.currentState!.save();
      if (_formKey.currentState!.validate()) {
        // Dismiss keyboard by removing focus on current input if any
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
        // Start loading overlay during server call
        context.loaderOverlay.show();
        ProfileService.submitRegister(username, email, password1, password2).then((response) {
          // HTTP/201, Created
          if (response.statusCode == 201) {
            // Moving forward to register succes, go check mail and login then
            widget.setAuthPage(2);
          } else {
            // Check server response to check for known errors
            final parsedJson = jsonDecode(response.body);
            // Server sent back input with issues
            if (parsedJson['username'] != null || parsedJson['password'] == null) {
              if (parsedJson['username'] != null) {
                for (var i = 0; i < parsedJson['username'].length; ++i) {
                  if (parsedJson['username'][i] == 'This field must be unique.') {
                    // Username has issues, password doesn't
                    setState(() => usernameErrorMsg = AppLocalizations.of(context)!.authRegisterUsernameAlreadyTaken);
                  }
                }
              }

              if (parsedJson['email'] != null) {
                for (var i = 0; i < parsedJson['email'].length; ++i) {
                  if (parsedJson['email'][i] == 'This field must be unique.') {
                    // Username has issues, password doesn't
                    setState(() => emailErrorMsg = AppLocalizations.of(context)!.authRegisterEmailAlreadyTaken);
                  }
                }
              }

              // Password has issues
              if (parsedJson['password'] != null) {
                // Too common password, (Caps, Digit and Spec char already validated)
                setState(() => passwordErrorMsg = AppLocalizations.of(context)!.authRegisterPasswordTooCommon);
              }
            } else {
              // Unexpected response code from server
              // Error REG1
              toastification.show(
                context: context,
                title: Text(
                  AppLocalizations.of(context)!.httpWrongResponseToastTitle,
                ),
                description: Text(
                  AppLocalizations.of(context)!.httpWrongResponseToastDescription('REG1 (${response.statusCode})'),
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
          }
          // Hide overlay loader anyway
          context.loaderOverlay.hide();
        }).catchError((handleError) {
          // Unable to perform server call
          // Error REG2
          toastification.show(
            context: context,
            title: Text(
              AppLocalizations.of(context)!.httpFrontErrorToastTitle,
            ),
            description: Text(
              AppLocalizations.of(context)!.httpFrontErrorToastDescription('REG2'),
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
          // Hide overlay loader anyway
          context.loaderOverlay.hide();
        });
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.authRegisterTitle,
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
                    child: Form(
                      key: _formKey,
                      child: Container(
                        height: formHeight,
                        margin: EdgeInsets.only(
                          top: (MediaQuery.of(context).size.height / 2) - (formHeight / 2) - (SizeConfig.defaultSize * 4),
                        ),
                        padding: EdgeInsets.only(
                          top: (SizeConfig.defaultSize * 6),
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
                            TextFormField(
                              scrollPadding: EdgeInsets.only(
                                bottom: (formHeight / 2),
                              ),
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.authRegisterUsernameInput,
                                labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                filled: true,
                                prefixIcon: Icon(
                                  Icons.account_circle,
                                  size: SizeConfig.defaultSize * 2,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                errorText: usernameErrorMsg,
                              ),
                              inputFormatters: [
                                // See https://github.com/MesseBasseProduction/BeerCrackerz backend for this char limitation
                                LengthLimitingTextInputFormatter(100),
                              ],
                              onSaved: (String? value) => username = value!,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!.emptyInput(AppLocalizations.of(context)!.authRegisterUsername);
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: (SizeConfig.defaultSize * 2),
                            ),
                            // Mail input field
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              scrollPadding: EdgeInsets.only(
                                bottom: (formHeight / 2),
                              ),
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.authRegisterEmailInput,
                                labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                filled: true,
                                prefixIcon: Icon(
                                  Icons.mail,
                                  size: (SizeConfig.defaultSize * 2),
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                errorText: emailErrorMsg,
                              ),
                              inputFormatters: [
                                // See https://github.com/MesseBasseProduction/BeerCrackerz backend for this char limitation
                                LengthLimitingTextInputFormatter(100),
                              ],
                              onSaved: (String? value) => email = value!,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!.emptyInput(AppLocalizations.of(context)!.authRegisterEmail);
                                }

                                final bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
                                if (emailValid != true) {
                                  return AppLocalizations.of(context)!.authRegisterEmailInvalid;
                                }

                                return null;
                              },
                            ),
                            SizedBox(
                              height: (SizeConfig.defaultSize * 2),
                            ),
                            // Password input field
                            TextFormField(
                              scrollPadding: EdgeInsets.only(
                                bottom: (formHeight / 3),
                              ),
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.authRegisterPasswordInput,
                                labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                filled: true,
                                prefixIcon: Icon(
                                  Icons.lock,
                                  size: (SizeConfig.defaultSize * 2),
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                suffixIcon: Align(
                                  widthFactor: 1.0,
                                  heightFactor: 1.0,
                                  child: IconButton(
                                    onPressed: () => setState(() => showPassword1 = !showPassword1),
                                    icon: Icon(
                                      Icons.remove_red_eye,
                                      size: (SizeConfig.defaultSize * 2),
                                      color: (showPassword1 == true) ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                errorText: passwordErrorMsg,
                              ),
                              inputFormatters: [
                                // See https://github.com/MesseBasseProduction/BeerCrackerz backend for this char limitation
                                LengthLimitingTextInputFormatter(64),
                              ],
                              obscureText: (showPassword1 == true) ? false : true,
                              enableSuggestions: false,
                              autocorrect: false,
                              onSaved: (String? value) => password1 = value!,
                              validator: (value) {
                                // Non-null test
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!.emptyInput(AppLocalizations.of(context)!.authRegisterPassword);
                                }
                                // Must contains at least 8 characters, an upper case, a digit and a special character
                                RegExp regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
                                if (!regex.hasMatch(value)) {
                                  toastification.show(
                                    context: context,
                                    title: Text(
                                      AppLocalizations.of(context)!.authRegisterPasswordNotStrongEnoughToastTitle,
                                    ),
                                    description: Text(
                                      AppLocalizations.of(context)!.authRegisterPasswordNotStrongEnoughToastDescription,
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    type: ToastificationType.info,
                                    style: ToastificationStyle.flatColored,
                                    autoCloseDuration: const Duration(
                                      seconds: 8,
                                    ),
                                    showProgressBar: false,
                                  );
                                  return AppLocalizations.of(context)!.authRegisterPasswordNotStrongEnough;
                                }
                                // Test validated, go ahead
                                return null;
                              },
                            ),
                            SizedBox(
                              height: (SizeConfig.defaultSize * 2),
                            ),
                            // Repeat password input field
                            TextFormField(
                              scrollPadding: EdgeInsets.only(
                                bottom: (formHeight / 3),
                              ),
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.authRegisterRepeatPasswordInput,
                                labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                filled: true,
                                prefixIcon: Icon(
                                  Icons.lock,
                                  size: (SizeConfig.defaultSize * 2),
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                suffixIcon: Align(
                                  widthFactor: 1.0,
                                  heightFactor: 1.0,
                                  child: IconButton(
                                    onPressed: () => setState(() => showPassword2 = !showPassword2),
                                    icon: Icon(
                                      Icons.remove_red_eye,
                                      size: (SizeConfig.defaultSize * 2),
                                      color: (showPassword2 == true) ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                errorText: passwordErrorMsg,
                              ),
                              inputFormatters: [
                                // See https://github.com/MesseBasseProduction/BeerCrackerz backend for this char limitation
                                LengthLimitingTextInputFormatter(64),
                              ],
                              obscureText: (showPassword2 == true) ? false : true,
                              enableSuggestions: false,
                              autocorrect: false,
                              onSaved: (String? value) => password2 = value!,
                              validator: (value) {
                                // Non-null test
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!.emptyInput(AppLocalizations.of(context)!.authRegisterRepeatPassword);
                                }
                                // Not matching password number 1
                                if (value != password1) {
                                  return AppLocalizations.of(context)!.authRegisterPasswordNotMatching;
                                }
                                // Must contains at least 8 characters, an upper case, a digit and a special character
                                RegExp regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
                                if (!regex.hasMatch(value)) {
                                  // Not showing notification in repet, only update eror label
                                  return AppLocalizations.of(context)!.authRegisterPasswordNotStrongEnough;
                                }
                                // Test validated, go ahead
                                return null;
                              },
                            ),
                            SizedBox(
                              height: (SizeConfig.defaultSize * 2),
                            ),
                            ButtonTheme(
                              height: (SizeConfig.defaultSize * 5),
                              minWidth: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                onPressed: () => formValidation(),
                                child: Text(
                                  AppLocalizations.of(context)!.authRegisterSubmit,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: (SizeConfig.defaultSize * 2),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  AppLocalizations.of(context)!.authRegisterHaveAccount,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => widget.setAuthPage(0),
                                  child: Text(
                                    AppLocalizations.of(context)!.authRegisterLogin,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
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
                          offset: const Offset(0, 2),
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
