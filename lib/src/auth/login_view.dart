import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:toastification/toastification.dart';

import '/src/auth/profile_service.dart';
import '/src/map/map_view.dart';
import '/src/utils/size_config.dart';
import '/src/settings/settings_controller.dart';
import '/src/settings/settings_view.dart';
// Pretty straightforward, the LoginView handle the whole app login process
// and handle form validation, aswel as front/back errors upon login.
// When credentials are validated, the server returns a JWT token
// that is stored in the SettingsController.
class LoginView extends StatefulWidget {
  const LoginView({
    super.key,
    required this.settingsController,
    required this.setAuthPage,
  });

  final SettingsController settingsController;
  final Function setAuthPage;

  @override
  LoginViewState createState() => LoginViewState();
}
// Store variable outside state widget to ensure data preservation
bool showPassword = false;
String? errorMsg; // Shared error feedback under Username/Password field

class LoginViewState extends State<LoginView> {
  String username = '';
  String password = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    errorMsg = null; // Clear any previous displayed errors
    super.dispose();
  }

  void formValidation(
    BuildContext context,
    String username,
    String password,
  ) {
    setState(() => errorMsg = null);
    _formKey.currentState!.save();
    // Dismiss keyboard by removing focus on current input if any
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    // Only go further if form fields are validated (see TextFormField for validator)
    if (_formKey.currentState!.validate()) {
      // Start loading overlay during server call
      context.loaderOverlay.show();
      ProfileService.submitLogin(
        username,
        password,
      ).then((response) async {
        if (response.statusCode == 200) { // HTTP/200, Alrighty
          final parsedJson = jsonDecode(utf8.decode(response.bodyBytes));
          // Check server response validity, it must contain the token and its expiration date
          if (parsedJson['expiry'] != null && parsedJson['token'] != null) {
            bool authTokenUpdated = await widget.settingsController.updateAuthToken(
              parsedJson['expiry'],
              parsedJson['token'],
            );

            if (authTokenUpdated == false) {
              if (context.mounted) {
                // Issue when saving token and expiry date
                // Error LGI4
                toastification.show(
                  context: context,
                  title: Text(
                    AppLocalizations.of(context)!.authLoginTokenErrorToastTitle,
                  ),
                  description: Text(
                    AppLocalizations.of(context)!.authLoginTokenErrorToastDescription,
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
            } else {
              widget.settingsController.isLoggedIn = await widget.settingsController.getUserInfo();
              // Ensure context is mounted, then redirect user to MapView
              if (context.mounted) {
                if (widget.settingsController.isLoggedIn == false) {
                  // Unable to get user info from server
                  // Error LGI5
                  toastification.show(
                    context: context,
                    title: Text(
                      AppLocalizations.of(context)!.authLoginUserInfoErrorToastTitle,
                    ),
                    description: Text(
                      AppLocalizations.of(context)!.authLoginUserInfoErrorToastDescription,
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
                } else {
                  Navigator.popAndPushNamed(
                    context,
                    MapView.routeName
                  );
                  // Inform user that login went OK
                  toastification.show(
                    context: context,
                    title: Text(
                      AppLocalizations.of(context)!.authLoginSuccessToastTitle,
                    ),
                    description: Text(
                      AppLocalizations.of(context)!.authLoginSuccessToastDescription,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    type: ToastificationType.success,
                    style: ToastificationStyle.flatColored,
                    autoCloseDuration: const Duration(
                      seconds: 5,
                    ),
                    showProgressBar: false,
                  );
                }
              }
            }
          } else {
            if (context.mounted) {
              // No token nor expiry sent through the response, not supposed to happen
              // Error LGI1
              toastification.show(
                context: context,
                title: Text(
                  AppLocalizations.of(context)!.httpServerErrorToastTitle,
                ),
                description: Text(
                  AppLocalizations.of(context)!.httpServerErrorToastDescription('LGI1'),
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
        } else {
          // Check server response to check for known errors
          final parsedJson = jsonDecode(utf8.decode(response.bodyBytes));
          if (parsedJson['detail'] != null && parsedJson['detail'] == 'Invalid credentials') {
            setState(() => errorMsg = AppLocalizations.of(context)!.authLoginInvalidCredentials);
          } else if (parsedJson['detail'] != null && parsedJson['detail'] == 'No credentials provided') {
            setState(() => errorMsg = AppLocalizations.of(context)!.authLoginEmptyCredentials);
          } else {
            if (context.mounted) {
              // Unexpected response code from server
              // Error LGI2
              toastification.show(
                context: context,
                title: Text(
                  AppLocalizations.of(context)!.httpWrongResponseToastTitle,
                ),
                description: Text(
                  AppLocalizations.of(context)!.httpWrongResponseToastDescription('LGI2 (${response.statusCode})'),
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
          // Error LGI3
          toastification.show(
            context: context,
            title: Text(
              AppLocalizations.of(context)!.httpFrontErrorToastTitle,
            ),
            description: Text(
              AppLocalizations.of(context)!.httpFrontErrorToastDescription('LGI3'),
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
          // Hide overlay loader in any case
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
    double formHeight = (SizeConfig.defaultSize * 45);
    bool isPortrait = (MediaQuery.of(context).orientation == Orientation.portrait);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.authLoginTitle,
        ),
        shadowColor: Theme.of(context).colorScheme.shadow,
        actions: [
          // Open application SettingsView
          IconButton(
            icon: const Icon(
              Icons.settings,
            ),
            onPressed: () => Navigator.restorablePushNamed(
              context,
              SettingsView.routeName,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                          bottom: SizeConfig.padding,
                          left: SizeConfig.padding,
                          right: SizeConfig.padding,
                          top: (SizeConfig.defaultSize * 6),
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
                              scrollPadding: EdgeInsets.only(
                                bottom: (formHeight / 2),
                              ),
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.authLoginUsernameInput,
                                labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                filled: true,
                                prefixIcon: Icon(
                                  Icons.account_circle,
                                  size: SizeConfig.inputIcon,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                enabledBorder: OutlineInputBorder(
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
                                errorText: errorMsg,
                              ),
                              inputFormatters: [
                                // See https://github.com/MesseBasseProduction/BeerCrackerz backend for this char limitation
                                LengthLimitingTextInputFormatter(100),
                              ],
                              onChanged: (String? value) => username = value!,
                              validator: (value) {
                                // Field value can not be empty to be a valid input
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!.emptyInput(AppLocalizations.of(context)!.authLoginUsername);
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
                                bottom: (formHeight / 2),
                              ),
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.authLoginPasswordInput,
                                labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
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
                                    onPressed: () => setState(() => showPassword = !showPassword),
                                    icon: Icon(
                                      Icons.remove_red_eye,
                                      size: SizeConfig.inputIcon,
                                      color: (showPassword == true)
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.onSurface,
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
                                errorText: errorMsg,
                              ),
                              inputFormatters: [
                                // See https://github.com/MesseBasseProduction/BeerCrackerz backend for this char limitation
                                LengthLimitingTextInputFormatter(64),
                              ],
                              obscureText: (showPassword == true) ? false : true,
                              enableSuggestions: false,
                              autocorrect: false,
                              onChanged: (String? value) => password = value!,
                              validator: (value) {
                                // Field value can not be empty to be a valid input
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!.emptyInput(AppLocalizations.of(context)!.authLoginPassword);
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: SizeConfig.padding,
                            ),
                            // Forgogt password link
                            Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                child: Text(
                                  AppLocalizations.of(context)!.authLoginForgotPassword,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                onTap: () => widget.setAuthPage(3),
                              ),
                            ),
                            SizedBox(
                              height: SizeConfig.padding,
                            ),
                            // Submit login form
                            ButtonTheme(
                              height: (SizeConfig.defaultSize * 5),
                              minWidth: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                onPressed: () => formValidation(context, username, password),
                                child: Text(AppLocalizations.of(context)!.authLoginSubmit),
                              ),
                            ),
                            SizedBox(
                              height: SizeConfig.padding,
                            ),
                            // Register link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  AppLocalizations.of(context)!.authLoginNoAccount,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => widget.setAuthPage(1),
                                  child: Text(
                                    AppLocalizations.of(context)!.authLoginRegister,
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
                // App title wrapper, placed after for "z-index"
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
