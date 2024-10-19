import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:loader_overlay/loader_overlay.dart';
import 'package:toastification/toastification.dart';

import '/src/auth/profile_service.dart';
import '/src/settings/settings_view.dart';
import '/src/utils/size_config.dart';
// Registration view to allow new user to create an account
// so they can add their marks to BeerCrackerz.
class RegisterView extends StatefulWidget {
  const RegisterView({
    super.key,
    required this.setAuthPage,
  });

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
  String username = '';
  String email = '';
  String password1 = '';
  String password2 = '';

  @override
  void dispose() {
    // Clear any previous displayed errors
    usernameErrorMsg = null;
    emailErrorMsg = null;
    passwordErrorMsg = null;
    super.dispose();
  }

  void formValidation(
    BuildContext context,
    String username,
    String email,
    String password1,
    String password2,
  ) {
    // Reset previous errors
    setState(() {
      usernameErrorMsg = null;
      emailErrorMsg = null;
      passwordErrorMsg = null;
    });
    _formKey.currentState!.save();
    // Dismiss keyboard by removing focus on current input if any
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    if (_formKey.currentState!.validate()) {
      // Start loading overlay during server call
      context.loaderOverlay.show();
      ProfileService.submitRegister(
        username,
        email,
        password1,
        password2,
      ).then((response) {
        // HTTP/201, Created
        if (response.statusCode == 201) {
          // Moving forward to register success, go check mail and login then
          widget.setAuthPage(2);
        } else {
          // Check server response to check for known errors
          final parsedJson = jsonDecode(utf8.decode(response.bodyBytes));
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
            // Email has issues
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
            if (context.mounted) {
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
        }
      }).catchError((handleError) {
        if (context.mounted) {
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
        }
      }).whenComplete(() {
        if (context.mounted) {
          // Hide overlay loader anyway
          context.loaderOverlay.hide();
        }
      });
    }
  }

  @override
  Widget build(
    BuildContext context
  ) {
    SizeConfig().init(context);
    double formHeight = SizeConfig.defaultSize * 65;
    bool isPortrait = (MediaQuery.of(context).orientation == Orientation.portrait);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.authRegisterTitle,
        ),
        shadowColor: Theme.of(context).colorScheme.shadow,
        actions: [
          // Open application SettingsView
          IconButton(
            icon: const Icon(
              Icons.settings
            ),
            onPressed: () => Navigator.restorablePushNamed(
              context,
              SettingsView.routeName
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: <Widget>[
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
                    child: Form(
                      key: _formKey,
                      child: Container(
                        height: formHeight,
                        margin: EdgeInsets.only(
                          top: (isPortrait == true)
                            ? (SizeConfig.screenHeight / 2) - (formHeight / 2) - (SizeConfig.defaultSize * 4)
                            : 0.0,
                        ),
                        // Form inner padding
                        padding: EdgeInsets.only(
                          top: (SizeConfig.defaultSize * 6),
                          bottom: SizeConfig.padding,
                          left: SizeConfig.padding,
                          right: SizeConfig.padding,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            // Username TextFormField input
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.authRegisterUsernameInput,
                                labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                filled: true,
                                prefixIcon: Icon(
                                  Icons.account_circle,
                                  size: SizeConfig.inputIcon,
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
                                errorText: usernameErrorMsg,
                              ),
                              inputFormatters: [
                                // See https://github.com/MesseBasseProduction/BeerCrackerz backend for this char limitation
                                LengthLimitingTextInputFormatter(100),
                              ],
                              onSaved: (String? value) => username = value!,
                              validator: (value) {
                                // Field value can not be empty to be a valid input
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!.emptyInput(AppLocalizations.of(context)!.authRegisterUsername);
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: SizeConfig.padding,
                            ),
                            // Email input field
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
                                  size: SizeConfig.inputIcon,
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
                                errorText: emailErrorMsg,
                              ),
                              inputFormatters: [
                                // See https://github.com/MesseBasseProduction/BeerCrackerz backend for this char limitation
                                LengthLimitingTextInputFormatter(100),
                              ],
                              onSaved: (String? value) => email = value!,
                              validator: (value) {
                                // Field value can not be empty to be a valid input
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!.emptyInput(AppLocalizations.of(context)!.authRegisterEmail);
                                }
                                // Field must contain '@', char(s) before, char(s) after, containing '.' and chars(s) after
                                final bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
                                if (emailValid != true) {
                                  return AppLocalizations.of(context)!.authRegisterEmailInvalid;
                                }

                                return null;
                              },
                            ),
                            SizedBox(
                              height: SizeConfig.padding,
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
                                  size: SizeConfig.inputIcon,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                suffixIcon: Align(
                                  widthFactor: 1.0,
                                  heightFactor: 1.0,
                                  child: IconButton(
                                    onPressed: () => setState(() => showPassword1 = !showPassword1),
                                    icon: Icon(
                                      Icons.remove_red_eye,
                                      size: SizeConfig.inputIcon,
                                      color: (showPassword1 == true) ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
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
                                // Field value can not be empty to be a valid input
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
                              height: SizeConfig.padding,
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
                                  size: SizeConfig.padding,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                suffixIcon: Align(
                                  widthFactor: 1.0,
                                  heightFactor: 1.0,
                                  child: IconButton(
                                    onPressed: () => setState(() => showPassword2 = !showPassword2),
                                    icon: Icon(
                                      Icons.remove_red_eye,
                                      size: SizeConfig.padding,
                                      color: (showPassword2 == true) ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
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
                                // Field value can not be empty to be a valid input
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
                              height: SizeConfig.padding,
                            ),
                            // Submit register to the server
                            ButtonTheme(
                              height: (SizeConfig.defaultSize * 5),
                              minWidth: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                onPressed: () => formValidation(
                                  context,
                                  username,
                                  email,
                                  password1,
                                  password2,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.authRegisterSubmit,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: SizeConfig.padding,
                            ),
                            // Go to login link
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
                          offset: const Offset(0, 2),
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
