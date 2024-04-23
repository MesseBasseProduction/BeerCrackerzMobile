import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:loader_overlay/loader_overlay.dart';
import 'package:toastification/toastification.dart';

import 'package:beercrackerz/src/map/map_view.dart';
import 'package:beercrackerz/src/auth/profile_service.dart';
import 'package:beercrackerz/src/settings/settings_view.dart';
import 'package:beercrackerz/src/settings/settings_controller.dart';
import 'package:beercrackerz/src/settings/size_config.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key, required this.controller, required this.setAuthPage});

  final SettingsController controller;
  final Function setAuthPage;

  @override
  LoginViewState createState() {
    return LoginViewState();
  }
}
// Needs to be outside state to ensure data perenity
bool showPassword = false;
String? errorMsg;

class LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Clear any error fields on leaving widget
    showPassword = false;
    errorMsg = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    double formHeight = SizeConfig.defaultSize * 45;
    String username = '';
    String password = '';

    void formValidation() {
      setState(() => errorMsg = null);
      _formKey.currentState!.save();
      if (_formKey.currentState!.validate()) {
        // Dismiss keyboard by removing focus on current input if any
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
        // Start loading overlay during server call
        context.loaderOverlay.show();
        ProfileService.submitLogin(username, password).then((response) async {
          // HTTP/200, Alrighty
          if (response.statusCode == 200) {
            final parsedJson = jsonDecode(response.body);
            if (parsedJson['expiry'] != null && parsedJson['token'] != null) {
              await widget.controller.updateAuthToken(parsedJson['expiry'], parsedJson['token']);
              widget.controller.isLoggedIn = await widget.controller.processUserInfo();
              // Ensure context is mounted before calling action into it
              if (context.mounted) {
                Navigator.popAndPushNamed(context, MapView.routeName);
                // Login success toast
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
            } else {
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
          } else {
            // Check server response to check for known errors
            final parsedJson = jsonDecode(response.body);
            if (parsedJson['detail'] != null && parsedJson['detail'] == 'Invalid credentials') {
              setState(() => errorMsg = AppLocalizations.of(context)!.authLoginInvalidCredentials);
            } else {
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
        }).catchError((handleError) {
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
        }).whenComplete(() {
          // Hide overlay loader anyway
          context.loaderOverlay.hide();
        });
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.authLoginTitle,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.restorablePushNamed(context, SettingsView.routeName),
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
                          top: (SizeConfig.screenHeight / 2) - (formHeight / 2) - (SizeConfig.defaultSize * 4),
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
                                labelText: AppLocalizations.of(context)!.authLoginUsernameInput,
                                labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                filled: true,
                                prefixIcon: Icon(
                                  Icons.account_circle,
                                  size: (SizeConfig.defaultSize * 2),
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                enabledBorder: OutlineInputBorder(
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
                                errorText: errorMsg,
                              ),
                              inputFormatters: [
                                // See https://github.com/MesseBasseProduction/BeerCrackerz backend for this char limitation
                                LengthLimitingTextInputFormatter(100),
                              ],
                              onSaved: (String? value) => username = value!,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!.emptyInput(AppLocalizations.of(context)!.authLoginUsername);
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: (SizeConfig.defaultSize * 2),
                            ),
                            // Password input field
                            TextFormField(
                              scrollPadding: EdgeInsets.only(bottom: (formHeight / 3)),
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.authLoginPasswordInput,
                                labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
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
                                    onPressed: () => setState(() => showPassword = !showPassword),
                                    icon: Icon(
                                      Icons.remove_red_eye,
                                      size: (SizeConfig.defaultSize * 2),
                                      color: (showPassword == true) ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
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
                                errorText: errorMsg,
                              ),
                              inputFormatters: [
                                // See https://github.com/MesseBasseProduction/BeerCrackerz backend for this char limitation
                                LengthLimitingTextInputFormatter(64),
                              ],
                              obscureText: (showPassword == true) ? false : true,
                              enableSuggestions: false,
                              autocorrect: false,
                              onSaved: (String? value) => password = value!,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!.emptyInput(AppLocalizations.of(context)!.authLoginPassword);
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: (SizeConfig.defaultSize * 2),
                            ),
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
                              height: (SizeConfig.defaultSize * 2),
                            ),
                            ButtonTheme(
                              height: (SizeConfig.defaultSize * 5),
                              minWidth: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                onPressed: () => formValidation(),
                                child: Text(AppLocalizations.of(context)!.authLoginSubmit),
                              ),
                            ),
                            SizedBox(
                              height: (SizeConfig.defaultSize * 2),
                            ),
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
                      top: (SizeConfig.screenHeight / 2) - (formHeight / 2) - ((SizeConfig.defaultSize * 5) / 2) - (SizeConfig.defaultSize * 4),
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
