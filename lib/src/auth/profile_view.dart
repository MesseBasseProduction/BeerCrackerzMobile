import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:loader_overlay/loader_overlay.dart';
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
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    void requestLogout() async {
      // Don't perform anything if token is invalid, force return to login page
      if (await widget.controller.isAuthTokenExpired() == true) {
        widget.controller.updateAuthToken('', ''); // Clear remainning token and expiry
        widget.controller.isLoggedIn = widget.controller.resetUserInfo();
        widget.setAuthPage(0);
        return;
      }
      // Start loading overlay during server call
      if (context.mounted) {
        context.loaderOverlay.show();
      }
      // Perform logout if token remains valid, request is valid aswell
      await ProfileService.submitLogout(await widget.controller.getAuthToken()).then((response) {
        if (response.statusCode != 204) {
          // Unexpected response code from server
          // Error LGO1
          toastification.show(
            context: context,
            title: Text(
              AppLocalizations.of(context)!.httpWrongResponseToastTitle,
            ),
            description: Text(
              AppLocalizations.of(context)!.httpWrongResponseToastDescription('LGO1 (${response.statusCode})'),
              style: const TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
            type: ToastificationType.error,
            style: ToastificationStyle.flatColored,
            autoCloseDuration: const Duration(seconds: 5),
            showProgressBar: false,
          );
          throw Exception('/auth/logout/ failed : Status ${response.statusCode}, ${response.body}');
        } else {
          widget.controller.updateAuthToken('', ''); // Clear remainning token and expiry
          widget.controller.isLoggedIn = widget.controller.resetUserInfo();
          widget.setAuthPage(0);
          toastification.show(
            context: context,
            title: Text(
              AppLocalizations.of(context)!.authProfileLogoutSuccessToastTitle,
            ),
            description: Text(
              AppLocalizations.of(context)!.authProfileLogoutSuccessToastDescription,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
            type: ToastificationType.success,
            style: ToastificationStyle.flatColored,
            autoCloseDuration: const Duration(seconds: 5),
            showProgressBar: false,
          );
        }
      }).catchError((handleError) {
        // Unable to perform server call
        // Error LGO2
        toastification.show(
          context: context,
          title: Text(
            AppLocalizations.of(context)!.httpFrontErrorToastTitle,
          ),
          description: Text(
            AppLocalizations.of(context)!.httpFrontErrorToastDescription('LGO2'),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          autoCloseDuration: const Duration(seconds: 5),
          showProgressBar: false,
        );
        throw Exception(handleError);
      }).whenComplete(() {
        // Hide overlay loader anyway
        context.loaderOverlay.hide();
      });
    }

    void submitProfilePicture(String base64Image, int size) async {
// Start loading overlay during server call
      if (context.mounted) {
        context.loaderOverlay.show();
      }
      // Perform logout if token remains valid, request is valid aswell
      await ProfileService.submitProfilePicture(await widget.controller.getAuthToken(), widget.controller.userId, base64Image, size).then((response) {
        if (response.statusCode != 204) {
          print(response.body);
          //throw Exception('/auth/logout/ failed : Status ${response.statusCode}, ${response.body}');
        } else {
         
        }
      }).catchError((handleError) {
        // Unable to perform server call
        // Error 
        
        throw Exception(handleError);
      }).whenComplete(() {
        // Hide overlay loader anyway
        context.loaderOverlay.hide();
      });
    }

    Future<void> _onImageButtonPressed(ImageSource source, BuildContext context) async {
      try {
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery
        );

        if (context.mounted) {
          ImageCropper ac = ImageCropper();
          CroppedFile? croppedFile = await ac.cropImage(
            sourcePath: pickedFile!.path,
            aspectRatio: const CropAspectRatio(
              ratioX: 1.0,
              ratioY: 1.0,
            ),
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'Cropper',
                toolbarColor: Theme.of(context).colorScheme.surface,
                toolbarWidgetColor: Theme.of(context).colorScheme.onSurface,
                backgroundColor: Theme.of(context).colorScheme.background,
                lockAspectRatio: false,
                hideBottomControls: true
              ),
              IOSUiSettings(
                title: 'Cropper',
              ),
            ],
          );
//          List<int> imageBytes = File(pickedFile.path).readAsBytesSync();
//          String base64Image = base64Encode(imageBytes);
          List<int> imageBytes = File(croppedFile!.path).readAsBytesSync();
          var decodedImage = await decodeImageFromList(File(croppedFile.path).readAsBytesSync());
          if (decodedImage.height >= 512 && decodedImage.width >= 512) {
            String base64Image = base64Encode(imageBytes);
            submitProfilePicture('data:image/jpeg;base64,$base64Image', decodedImage.height);
          }
/*
          Image image = Image.asset(croppedFile!.path);
          print(image.width);
          print(image.height);
*/
        }
      } catch (e) {
        print(e);
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
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
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              Container(
                height: (MediaQuery.of(context).size.width / 2),
                width: (MediaQuery.of(context).size.width / 2),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://beercrackerz.org${widget.controller.ppPath}'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomRight,
                      child: FractionalTranslation(
                        translation: const Offset(0.2, 0.2),
                        child: FloatingActionButton(
                          onPressed: () {
                            _onImageButtonPressed(ImageSource.gallery, context);
                          },
                          child: const Icon(Icons.upload),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              Text(
                widget.controller.username,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              Text(
                widget.controller.email,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  AppLocalizations.of(context)!.authProfileAboutBeerCrackerz,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  AppLocalizations.of(context)!.authProfileAboutVersion,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              ButtonTheme(
                height: (SizeConfig.defaultSize * 5),
                minWidth: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () => requestLogout(),
                  child: Text(AppLocalizations.of(context)!.authProfileLogout),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
