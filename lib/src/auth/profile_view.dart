import 'package:beercrackerz/src/auth/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:beercrackerz/src/settings/settings_controller.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key, required this.controller});

  final SettingsController controller;

  @override
  ProfileViewState createState() {
    return ProfileViewState();
  }
}

class ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed: () {
                    ProfileService.submitLogout(widget.controller.sessionCookie).then((response) {
                        if (response.statusCode != 200) {
                          throw Exception('/api/auth/logout/ failed : Status ${response.statusCode}, ${response.body}');
                        } else {
                          widget.controller.isLoggedIn = false;
                          widget.controller.updateSessionCookie('');
                        }
                      }).catchError((handleError) {
                        throw Exception(handleError);
                      });
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
