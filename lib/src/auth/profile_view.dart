import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:beercrackerz/src/settings/settings_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key, required this.controller});

  static const routeName = '/auth';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: controller.isLoggedIn == false
            ? const Text('Login')
            : const Text('Profile'),
        shadowColor: Theme.of(context).colorScheme.shadow,
      ),
      body: controller.isLoggedIn == false
          ? LoginForm(controller: controller)
          : displayProfileContent(),
    );
  }
}

/* Profile page view */

Column displayProfileContent() {
  return const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Submit'),
          ),
        ],
      )
    ],
  );
}

/* Auth Login/Register zone */

class LoginForm extends StatefulWidget {
  const LoginForm({super.key, required this.controller});

  final SettingsController controller;

  @override
  LoginFormState createState() {
    return LoginFormState();
  }
}

bool _showPassword = false;

class LoginFormState extends State<LoginForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<LoginFormState>.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    String username = '';
    String password = '';

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
            child: TextFormField(
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                labelText: AppLocalizations.of(context)!.inputLoginUsername,
              ),
              onSaved: (String? value) {
                username = value!;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!
                      .emptyInput(AppLocalizations.of(context)!.username);
                }
                return null;
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
            child: TextFormField(
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                labelText: AppLocalizations.of(context)!.inputLoginPassword,
                suffixIcon: Align(
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                    icon: Icon(
                      Icons.remove_red_eye,
                      color: (_showPassword == true)
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                ),
              ),
              obscureText: (_showPassword == true) ? false : true,
              enableSuggestions: false,
              autocorrect: false,
              onSaved: (String? value) {
                password = value!;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!
                      .emptyInput(AppLocalizations.of(context)!.password);
                }
                return null;
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      submitLogin(username, password).then((response) {
                        if (response.statusCode != 200) {
                          print('Handle dat error code');
                        } else {
                          if (response.headers['set-cookie'] != null) {
                            widget.controller.isLoggedIn = true;
                            widget.controller.updateSessionCookie(
                                response.headers['set-cookie']!);
                          }
                        }
                      }).catchError((handleError) {
                        throw Exception(handleError);
                      });
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

Future<http.Response> submitLogin(String username, String password) async {
  return await http.post(
    Uri.parse('https://beercrackerz.org/api/auth/login/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
        <String, String>{'username': username, 'password': password}),
  );
}
