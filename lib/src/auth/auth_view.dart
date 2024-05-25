import 'package:flutter/material.dart';

import '/src/auth/login_view.dart';
import '/src/auth/profile_view.dart';
import '/src/auth/register_success_view.dart';
import '/src/auth/register_view.dart';
import '/src/auth/reset_password_success_view.dart';
import '/src/auth/reset_password_view.dart';
import '/src/settings/settings_controller.dart';
// AuthView class is the router for authentication view
// Its main purpose is to redirect user to the proper widget
// depending on its state. There are 6 pages for the 6 allowed states :
//
// 0. LoginView -> allow user to log in
// 1. Register -> allow user to create an account
// 2. RegisterSuccess -> notify user the registration went OK
// 3. ResetPassword -> allow user to request a password update
// 4. ResetPasswordSuccess -> notify user the password update went OK
// 5. Profile -> allow logged user to consult their own profile
//
// This class is an internal, and should not contain any view code
class AuthView extends StatefulWidget  {
  const AuthView({
    super.key,
    required this.settingsController,
  });

  static const routeName = '/auth';
  final SettingsController settingsController;

  @override
  AuthViewState createState() => AuthViewState();
}

class AuthViewState extends State<AuthView> {
  // Initialize authPage to Login by default
  int authPage = 0;
  // Callback for view to change the AuthView current widget, must be given as parameters to each AuthViews
  void setAuthpage(
    int number
  ) {
    // Trigger setState on stateful widget to update the current AuthView
    if (number >= 0 && number <= 5) setState(() => authPage = number);
  }

  @override
  Widget build(
    BuildContext context
  ) {
    // Logged in, the user only can see his profile. Must logout for other auth pages
    if (widget.settingsController.isLoggedIn == true) authPage = 5;
    // Select the AuthView to display depending on the current state
    if (authPage == 5) {
      return ProfileView(
        settingsController: widget.settingsController,
        setAuthPage: setAuthpage,
      );
    } else if (authPage == 4) {
      return ResetPasswordSuccessView(
        setAuthPage: setAuthpage,
      );
    } else if (authPage == 3) {
      return ResetPasswordView(
        setAuthPage: setAuthpage,
      );
    } else if (authPage == 2) {
      return RegisterSuccessView(
        setAuthPage: setAuthpage,
      );
    } else if (authPage == 1) {
      return RegisterView(
        setAuthPage: setAuthpage,
      );
    } else { // By default, display page
      return LoginView(
        settingsController: widget.settingsController,
        setAuthPage: setAuthpage,
      );
    }
  }
}
