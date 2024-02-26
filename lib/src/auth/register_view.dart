import 'package:beercrackerz/src/auth/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

bool showPassword1 = false;
bool showPassword2 = false;

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
      _formKey.currentState!.save();
      if (_formKey.currentState!.validate()) {
        ProfileService.submitRegister(username, email, password1, password2).then((response) {
          if (response.statusCode != 200) {
            throw Exception('/api/auth/register/ failed : Status ${response.statusCode}, ${response.body}');
          } else {
            // Moving forward to register succes, go check mail and login then
            widget.setAuthPage(2);
          }
        }).catchError((handleError) {
          throw Exception(handleError);
        });
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.authRegisterTitle),
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
                      left: SizeConfig.defaultSize * 3,
                      right: SizeConfig.defaultSize * 3
                    ),
                    child: Form(
                      key: _formKey,
                      child: Container(
                        height: formHeight,
                        margin: EdgeInsets.only(top: (MediaQuery.of(context).size.height / 2) - (formHeight / 2) - (SizeConfig.defaultSize * 4)),
                        padding: EdgeInsets.only(
                          top: SizeConfig.defaultSize * 6,
                          bottom: SizeConfig.defaultSize * 2,
                          left: SizeConfig.defaultSize * 2,
                          right: SizeConfig.defaultSize * 2
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            // Username input field
                            TextFormField(
                              scrollPadding: EdgeInsets.only(bottom: (formHeight / 2)),
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.authRegisterUsernameInput,
                                labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                                filled: true,
                                prefixIcon: Icon(
                                  Icons.account_circle,
                                  size: SizeConfig.defaultSize * 2,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)
                                ),
                              ),
                              onSaved: (String? value) {
                                username = value!;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!.emptyInput(AppLocalizations.of(context)!.authRegisterUsername);
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: SizeConfig.defaultSize * 2,
                            ),
                            // Mail input field
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              scrollPadding: EdgeInsets.only(bottom: (formHeight / 2)),
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.authRegisterEmailInput,
                                labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                                filled: true,
                                prefixIcon: Icon(
                                  Icons.mail,
                                  size: SizeConfig.defaultSize * 2,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)
                                ),
                              ),
                              onSaved: (String? value) {
                                email = value!;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!.emptyInput(AppLocalizations.of(context)!.authRegisterEmail);
                                }

                                final bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
                                if (emailValid != true) {
                                  return AppLocalizations.of(context)!.authRegisterInvalidEmail;
                                }

                                return null;
                              },
                            ),
                            SizedBox(
                              height: SizeConfig.defaultSize * 2,
                            ),
                            // Password input field
                            TextFormField(
                              scrollPadding: EdgeInsets.only(bottom: (formHeight / 3)),
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.authRegisterPasswordInput,
                                labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                                filled: true,
                                prefixIcon: Icon(
                                  Icons.lock,
                                  size: SizeConfig.defaultSize * 2,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                suffixIcon: Align(
                                  widthFactor: 1.0,
                                  heightFactor: 1.0,
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        showPassword1 = !showPassword1;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.remove_red_eye,
                                      size: SizeConfig.defaultSize * 2,
                                      color: (showPassword1 == true) ? Theme.of(context).colorScheme.primary : null,
                                    ),
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)
                                ),
                              ),
                              obscureText: (showPassword1 == true) ? false : true,
                              enableSuggestions: false,
                              autocorrect: false,
                              onSaved: (String? value) {
                                password1 = value!;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!.emptyInput(AppLocalizations.of(context)!.authRegisterPassword);
                                }

                                return null;
                              },
                            ),
                            SizedBox(
                              height: SizeConfig.defaultSize * 2,
                            ),
                            // Repeat password input field
                            TextFormField(
                              scrollPadding: EdgeInsets.only(bottom: (formHeight / 3)),
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.authRegisterRepeatPasswordInput,
                                labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                                filled: true,
                                prefixIcon: Icon(
                                  Icons.lock,
                                  size: SizeConfig.defaultSize * 2,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                suffixIcon: Align(
                                  widthFactor: 1.0,
                                  heightFactor: 1.0,
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        showPassword2 = !showPassword2;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.remove_red_eye,
                                      size: SizeConfig.defaultSize * 2,
                                      color: (showPassword2 == true) ? Theme.of(context).colorScheme.primary : null,
                                    ),
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)
                                ),
                              ),
                              obscureText: (showPassword2 == true) ? false : true,
                              enableSuggestions: false,
                              autocorrect: false,
                              onSaved: (String? value) {
                                password2 = value!;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!.emptyInput(AppLocalizations.of(context)!.authRegisterRepeatPassword);
                                }

                                if (value != password1) {
                                  return AppLocalizations.of(context)!.authRegisterPasswordNotMatching;
                                }

                                return null;
                              },
                            ),
                            SizedBox(
                              height: SizeConfig.defaultSize * 2,
                            ),
                            ButtonTheme(
                              height: SizeConfig.defaultSize * 5,
                              minWidth: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                onPressed: () { formValidation(); },
                                child: Text(AppLocalizations.of(context)!.authRegisterSubmit),
                              ),
                            ),
                            SizedBox(
                              height: SizeConfig.defaultSize * 2,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  AppLocalizations.of(context)!.authRegisterHaveAccount,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    widget.setAuthPage(0);
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.authRegisterLogin,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: SizeConfig.defaultSize * 2,
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
                    margin: EdgeInsets.only(top: (MediaQuery.of(context).size.height / 2) - (formHeight / 2) - ((SizeConfig.defaultSize * 5) / 2) - (SizeConfig.defaultSize * 4)),
                    height: SizeConfig.defaultSize * 5,
                    width: SizeConfig.defaultSize * 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 6,
                          offset: const Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'BeerCrackerz',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18
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
