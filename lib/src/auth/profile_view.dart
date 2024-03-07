import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:toastification/toastification.dart';

import 'package:beercrackerz/src/auth/profile_service.dart';
import 'package:beercrackerz/src/settings/settings_view.dart';
import 'package:beercrackerz/src/settings/settings_controller.dart';
import 'package:beercrackerz/src/settings/size_config.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key, required this.controller, required this.setAuthPage});

  final SettingsController controller;
  final Function setAuthPage;

  @override
  ProfileViewState createState() {
    return ProfileViewState();
  }
}

class ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    // TODO get user info

    void requestLogout() async {
      // Don't perform anything if token is invalid, force return to login page
      if (await widget.controller.isAuthTokenExpired() == true) {
        widget.controller.updateAuthToken('', ''); // Clear remainning token and expiry
        widget.controller.isLoggedIn = false;
        widget.setAuthPage(0);
        return;
      }
      // Perform logout if token remains valid, request is valid aswell
      await ProfileService.submitLogout(await widget.controller.getAuthToken()).then((response) {
        if (response.statusCode != 204) {
          toastification.show(
            context: context,
            title: const Text('Logout error'),
            description: Text(
              'Unexpected response from server (${response.statusCode}). Please contact support for assistance.',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            type: ToastificationType.error,
            style: ToastificationStyle.flatColored,
            autoCloseDuration: const Duration(seconds: 5),
            showProgressBar: false,
          );
          throw Exception('/auth/logout/ failed : Status ${response.statusCode}, ${response.body}');
        } else {
          widget.controller.updateAuthToken('', ''); // Clear remainning token and expiry
          widget.controller.isLoggedIn = false;
          widget.setAuthPage(0);
          toastification.show(
            context: context,
            title: const Text('Logout success'),
            description: const Text(
              "You've been successfully logged out of your account. See you soon!",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            type: ToastificationType.success,
            style: ToastificationStyle.flatColored,
            autoCloseDuration: const Duration(seconds: 5),
            showProgressBar: false,
          );
        }
      }).catchError((handleError) {
        toastification.show(
          context: context,
          title: const Text('Logout error'),
          description: const Text(
            'Something went wrong when trying to reach the server. Please contact support for assistance.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          autoCloseDuration: const Duration(seconds: 5),
          showProgressBar: false,
        );
        throw Exception(handleError);
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.authProfileTitle,
        ),
        shadowColor: Theme.of(context).colorScheme.shadow,
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
            ButtonTheme(
              height: SizeConfig.defaultSize * 5,
              minWidth: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () => requestLogout(),
                child: Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
