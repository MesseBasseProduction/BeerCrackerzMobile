import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:loader_overlay/loader_overlay.dart';
import 'package:toastification/toastification.dart';

import 'package:beercrackerz/src/auth/auth_view.dart';
import 'package:beercrackerz/src/map/map_view.dart';
import 'package:beercrackerz/src/settings/settings_view.dart';
import 'package:beercrackerz/src/settings/settings_controller.dart';
import 'package:beercrackerz/src/settings/theme_controller.dart';

class BeerCrackerzMobile extends StatelessWidget {
  const BeerCrackerzMobile({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    // First get Themes for proper customization
    ThemeData mainTheme = ThemeController.mainTheme();
    ThemeData altTheme = ThemeController.lightTheme();
    // MaterialApp encapsulated in loading overlay, itself encapsulated in Listenable for settings updates
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return GlobalLoaderOverlay(
          duration: const Duration(
            milliseconds: 250,
          ),
          reverseDuration: const Duration(
            milliseconds: 250,
          ),
          switchInCurve: Curves.bounceIn,
          switchOutCurve: Curves.bounceOut,
          useDefaultLoading: false,
          overlayWidgetBuilder: (_) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(mainTheme.colorScheme.primary),
              ),
            );
          },
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            restorationScopeId: 'app',
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('fr', ''),
              Locale('de', ''),
              Locale('es', ''),
            ],
            // Attach app locale to settings value
            locale: settingsController.appLocale,
            onGenerateTitle: (BuildContext context) => AppLocalizations.of(context)!.appTitle,
            theme: mainTheme,
            darkTheme: altTheme,
            // Attach app theme to settings value
            themeMode: settingsController.themeMode,
            onGenerateRoute: (RouteSettings routeSettings) {
              return MaterialPageRoute<void>(
                settings: routeSettings,
                builder: (BuildContext context) {
                  switch (routeSettings.name) {
                    case AuthView.routeName:
                      return AuthView(
                        controller: settingsController,
                      );
                    case SettingsView.routeName:
                      return SettingsView(
                        controller: settingsController,
                      );
                    case MapView.routeName:
                    default:
                      return const MapView();
                  }
                },
              );
            },
            // Toast notification global configuration
            builder: (context, child) {
              return ToastificationConfigProvider(
                config: const ToastificationConfig(
                  alignment: Alignment.topCenter,
                  animationDuration: Duration(
                    milliseconds: 500,
                  ),
                ),
                child: child!,
              );
            },
          ),
        );
      },
    );
  }
}
