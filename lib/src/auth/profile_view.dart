import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:toastification/toastification.dart';

import '/src/auth/profile_service.dart';
import '/src/settings/settings_controller.dart';
import '/src/settings/settings_view.dart';
import '/src/utils/app_const.dart';
import '/src/utils/size_config.dart';
// Displays the user profile with its profile picture,
// username and email. Also provide BeerCrackerz description
// and version, and finally offer a logout button.
class ProfileView extends StatefulWidget {
  const ProfileView({
    super.key,
    required this.settingsController,
    required this.setAuthPage,
  });

  final SettingsController settingsController;
  final Function setAuthPage;

  @override
  ProfileViewState createState() {
    return ProfileViewState();
  }
}

class ProfileViewState extends State<ProfileView> {
  // Image picker for edit profile pic
  final ImagePicker _picker = ImagePicker();

  void requestLogout(
    BuildContext context,
  ) async {
    // Don't perform anything if token is invalid, force return to login page
    if (await widget.settingsController.isAuthTokenExpired() == true) {
      widget.settingsController.updateAuthToken('', ''); // Clear remainning token and expiry
      widget.settingsController.isLoggedIn = widget.settingsController.resetUserInfo();
      widget.setAuthPage(0);
      return;
    }
    // Start loading overlay during server call, only if context is still mounted
    if (context.mounted) {
      context.loaderOverlay.show();
    }
    // Perform logout if token remains valid, request is valid aswell
    await ProfileService.submitLogout(
      await widget.settingsController.getAuthToken(),
    ).then((response) {
      if (response.statusCode != 204) {
        if (context.mounted) {
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
            autoCloseDuration: const Duration(
              seconds: 5,
            ),
            showProgressBar: false,
          );
        }
      } else {
        widget.settingsController.updateAuthToken('', ''); // Clear remainning token and expiry
        widget.settingsController.isLoggedIn = widget.settingsController.resetUserInfo();
        widget.setAuthPage(0);
        if (context.mounted) {
          // Notify user he successfully logged out
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
            autoCloseDuration: const Duration(
              seconds: 5,
            ),
            showProgressBar: false,
          );
        }
      }
    }).catchError((handleError) {
      if (context.mounted) {
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

  Future<void> onImageButtonPressed(
    BuildContext context,
    ImageSource source,
  ) async {
    try {
      // Ask user to pick a file from gallery
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      // Then, only if context is mounted, call cropper to prepare PP for upload
      if (context.mounted) {
        ImageCropper ac = ImageCropper();
        // Await for user submit the cropped image
        CroppedFile? croppedFile = await ac.cropImage(
          sourcePath: pickedFile!.path,
          aspectRatio: const CropAspectRatio(
            ratioX: 1.0,
            ratioY: 1.0,
          ),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: AppLocalizations.of(context)!.authProfileCropTitle,
              toolbarColor: Theme.of(context).colorScheme.surface,
              toolbarWidgetColor: Theme.of(context).colorScheme.onSurface,
              backgroundColor: Theme.of(context).colorScheme.surface,
              lockAspectRatio: true, // Force 1:1 aspxect ratio, forbid user to resize zone
              hideBottomControls: false,
            ),
            IOSUiSettings(
              title: AppLocalizations.of(context)!.authProfileCropTitle,
            ),
          ],
        );
        // Read cropped image bytes
        List<int> imageBytes = File(
          croppedFile!.path,
        ).readAsBytesSync();
        var decodedImage = await decodeImageFromList(
          File(croppedFile.path).readAsBytesSync(),
        );
        // Only submit if cropped image match the minimal requirements for server
        if (decodedImage.height >= 512 && decodedImage.width >= 512) {
          String base64Image = base64Encode(imageBytes);
          // Submit new image to the server as base 64 image
          if (context.mounted) {
            // Sending squared image to the server
            submitProfilePicture(
              context,
              'data:image/jpeg;base64,$base64Image',
            );
          }
        } else {
          // Under profile picture minimal size
          if (context.mounted) {
            toastification.show(
              context: context,
              title: Text(
                AppLocalizations.of(context)!.authProfileErrorMinimalPPSizeTitle,
              ),
              description: Text(
                AppLocalizations.of(context)!.authProfileErrorMinimalPPSizeContent,
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
    } catch (e) {
      // User canceled the image cropper, nothing to do here.
    }
  }

  void submitProfilePicture(
    BuildContext context,
    String base64Image,
  ) async {
    // Start loading overlay during server call
    if (context.mounted) {
      context.loaderOverlay.show();
    }
    // Perform logout if token remains valid, request is valid aswell
    await ProfileService.submitProfilePicture(
      await widget.settingsController.getAuthToken(),
      widget.settingsController.userId,
      base64Image,
    ).then((response) async {
      if (response.statusCode == 204) {
        // Request user info from server and perform a view refresh 
        await widget.settingsController.getUserInfo();
        setState(() {});
      } else {
        if (context.mounted) {
          // Invalid/incomplete data sent
          // Error UPP1
          toastification.show(
            context: context,
            title: Text(
              AppLocalizations.of(context)!.authProfileErrorPPUploadErrorTitle,
            ),
            description: Text(
              AppLocalizations.of(context)!.authProfileErrorPPUploadErrorDescription('UPP1'),
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
      if (context.mounted) {
        // Unable to perform server call
        // Error UPP2
        toastification.show(
          context: context,
          title: Text(
            AppLocalizations.of(context)!.httpFrontErrorToastTitle,
          ),
          description: Text(
            AppLocalizations.of(context)!.httpFrontErrorToastDescription('UPP2'),
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

  @override
  Widget build(
    BuildContext context
  ) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.authProfileTitle,
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
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: SizeConfig.padding,
              ),
              // Image container, with upload new profile picture icon
              Container(
                height: (MediaQuery.of(context).size.width / 2),
                width: (MediaQuery.of(context).size.width / 2),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: (widget.settingsController.ppPath.contains('profile.png') == true) 
                      ? AssetImage(widget.settingsController.ppPath) as ImageProvider // Load local default PP
                      : NetworkImage('${AppConst.baseURL}${widget.settingsController.ppPath}'), // Load server one
                    fit: BoxFit.fill,
                  ),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: (widget.settingsController.leftHanded == true)
                        ? Alignment.bottomLeft
                        : Alignment.bottomRight,
                      child: FractionalTranslation(
                        translation: Offset(
                          (widget.settingsController.leftHanded == true)
                            ? -0.2
                            : 0.2, 
                          0.2,
                        ),
                        child: FloatingActionButton(
                          onPressed: () => onImageButtonPressed(
                            context,
                            ImageSource.gallery
                          ),
                          child: const Icon(
                            Icons.upload
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: SizeConfig.padding,
              ),
              // Username as title
              Text(
                widget.settingsController.username,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: SizeConfig.fontTextTitleSize,
                ),
              ),
              // User email adress
              Text(
                widget.settingsController.email,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                  fontSize: SizeConfig.fontTextSize,
                ),
              ),
              SizedBox(
                height: SizeConfig.padding,
              ),
              // Generic marker stats
              Text(
                AppLocalizations.of(context)!.authProfileUserTotalAddedMarkers(
                  widget.settingsController.userSpotAdded + widget.settingsController.userShopAdded + widget.settingsController.userBarAdded,
                  widget.settingsController.totalMarks,
                ),
                textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: SizeConfig.fontTextSize,
                  ),
              ),
              Text(
                AppLocalizations.of(context)!.authProfileUserAddedSpots(widget.settingsController.userSpotAdded),
                  style: TextStyle(
                    fontSize: SizeConfig.fontTextSize,
                  ),
              ),
              Text(
                AppLocalizations.of(context)!.authProfileUserAddedShops(widget.settingsController.userShopAdded),
                  style: TextStyle(
                    fontSize: SizeConfig.fontTextSize,
                  ),
              ),
              Text(
                AppLocalizations.of(context)!.authProfileUserAddedBars(widget.settingsController.userBarAdded),
                  style: TextStyle(
                    fontSize: SizeConfig.fontTextSize,
                  ),
              ),
              SizedBox(
                height: SizeConfig.padding,
              ),
              // BeerCrackerz presentation text
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.padding
                ),
                child: Text(
                  AppLocalizations.of(context)!.authProfileAboutBeerCrackerz,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: SizeConfig.fontTextSize,
                  ),
                ),
              ),
              SizedBox(
                height: SizeConfig.padding,
              ),
              // Logout button
              ButtonTheme(
                height: (SizeConfig.defaultSize * 5),
                minWidth: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () => requestLogout(context),
                  child: Text(
                    AppLocalizations.of(context)!.authProfileLogout,
                  ),
                ),
              ),
              SizedBox(
                height: SizeConfig.padding,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
