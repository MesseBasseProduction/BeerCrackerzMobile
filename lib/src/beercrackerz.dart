import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:loader_overlay/loader_overlay.dart';
import 'package:toastification/toastification.dart';

import '/src/auth/auth_view.dart';
import '/src/help/about_view.dart';
import '/src/help/welcome_screen_view.dart';
import '/src/map/map_view.dart';
import '/src/settings/settings_controller.dart';
import '/src/settings/settings_view.dart';
import '/src/utils/app_const.dart';
import '/src/utils/theme_config.dart';

class BeerCrackerzMobile extends StatelessWidget {
  const BeerCrackerzMobile({
    super.key,
    required this.settingsController,
  });
  // Global app settings controller
  final SettingsController settingsController;
  // Main widget building
  @override
  Widget build(
    BuildContext context,
  ) {
    // Build supported locale from app constants
    List<Locale> supportedLocales = [];
    for (var locale in AppConst.supportedLang) {
      supportedLocales.add(
        Locale(locale, ''),
      );
    }
    // Then get Themes from configuration
    ThemeData darkTheme = ThemeConfig.darkTheme();
    ThemeData lightTheme = ThemeConfig.lightTheme();
    // MaterialApp encapsulated in loading overlay, itself encapsulated in Listenable for settings updates
    return ListenableBuilder(
      listenable: settingsController,
      builder: (
        BuildContext context,
        Widget? child,
      ) {
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
                valueColor: AlwaysStoppedAnimation<Color>(darkTheme.colorScheme.primary),
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
            // App supported locale, based on AppConst.supportedLocales
            supportedLocales: supportedLocales,
            // Attach app locale to settings value
            locale: settingsController.appLocale,
            onGenerateTitle: (BuildContext context) => AppLocalizations.of(context)!.appTitle,
            theme: lightTheme,
            darkTheme: darkTheme,
            // Attach app theme to settings value
            themeMode: settingsController.themeMode,
            onGenerateRoute: (
              RouteSettings routeSettings,
            ) {
              return MaterialPageRoute<void>(
                settings: routeSettings,
                builder: (
                  BuildContext context,
                ) {
                  switch (routeSettings.name) {
                    case AuthView.routeName:
                      return AuthView(
                        settingsController: settingsController,
                      );
                    case SettingsView.routeName:
                      return SettingsView(
                        settingsController: settingsController,
                      );
                    case MapView.routeName:
                      return MapView(
                        settingsController: settingsController,
                      );
                    case AboutView.routeName:
                      return AboutView(
                        settingsController: settingsController,
                      );
                    default:
                      // Redirect to MapView if pref set to false
                      if (settingsController.showWelcomeScreen == false) {
                        return MapView(
                          settingsController: settingsController,
                        );
                      }
                      return WelcomeScreenView(
                        settingsController: settingsController,
                      );
                  }
                },
              );
            },
            // Toast notification global configuration
            builder: (
              context,
              child,
            ) {
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
