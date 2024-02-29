import 'package:beercrackerz/src/auth/profile_view.dart';
import 'package:beercrackerz/src/auth/login_view.dart';
import 'package:beercrackerz/src/auth/register_view.dart';
import 'package:beercrackerz/src/auth/register_success_view.dart';
import 'package:beercrackerz/src/auth/reset_password_view.dart';
import 'package:beercrackerz/src/auth/reset_password_success_view.dart';
import 'package:flutter/material.dart';

import 'package:beercrackerz/src/settings/settings_controller.dart';

class AuthView extends StatefulWidget  {
  const AuthView({super.key, required this.controller});

  static const routeName = '/auth';
  final SettingsController controller;

  @override
  AuthViewState createState() => AuthViewState();
}

class AuthViewState extends State<AuthView> {
  // 0 = login, 1 = register, 2 = register success, 3 = reset pass, 4 = reset password success, 5 = profile
  int authPage = 0;

  void setAuthpage(int number) {
    if (number >= 0 && number <= 5) {
      setState(() => authPage = number);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (authPage == 5 && widget.controller.isLoggedIn == true) {
      return ProfileView(controller: widget.controller);
    } else if (authPage == 4) {
      return ResetPasswordSuccessView(controller: widget.controller, setAuthPage: setAuthpage);
    } else if (authPage == 3) {
      return ResetPasswordView(controller: widget.controller, setAuthPage: setAuthpage);
    } else if (authPage == 2) {
      return RegisterSuccessView(controller: widget.controller, setAuthPage: setAuthpage);
    } else if (authPage == 1) {
      return RegisterView(controller: widget.controller, setAuthPage: setAuthpage);
    } else {
      return LoginView(controller: widget.controller, setAuthPage: setAuthpage);
    }
  }
}
