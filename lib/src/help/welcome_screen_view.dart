import 'package:beercrackerz/src/auth/auth_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/src/map/map_view.dart';
import '/src/settings/settings_controller.dart';
import '/src/utils/size_config.dart';
// This view handle the startup helper which describes the app features
class WelcomeScreenView extends StatefulWidget {
  const WelcomeScreenView({
    super.key,
    required this.settingsController,
  });

  static const routeName = '/welcome';
  final SettingsController settingsController;

  @override
  WelcomeScreenViewState createState() => WelcomeScreenViewState();
}

class WelcomeScreenViewState extends State<WelcomeScreenView> {
  double currentPage = 0.0;
  final _pageViewController = PageController();
  List<Widget> slides = [];
  bool showWelcomeScreen = true;

  @override
  void initState() {
    super.initState();
    showWelcomeScreen = false; // Always disable show welcome screen, must be restored in settings
    // Otherwise listen to pages update
    _pageViewController.addListener(() {
      setState(() {
        currentPage = _pageViewController.page!;
      });
    });
  }
  // Help slide items
  List<Widget> buildSlides(
    BuildContext context,
  ) {
    return [
      // First slide is welcome text and BeerCrackerz bio
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.padding,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.fitWidth,
              width: 128.0,
            ),
            SizedBox(
              height: SizeConfig.paddingLarge,
            ),
            Text(
              AppLocalizations.of(context)!.helpWelcomeSlideTitle,
              style: TextStyle(
                fontSize: SizeConfig.fontTextTitleSize,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: SizeConfig.padding,
            ),
            Text(
              AppLocalizations.of(context)!.helpWelcomeSlideDescription,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: SizeConfig.fontTextSize,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      // Second slide on general view (describes spots, shops ands bars)
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.padding,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/help/map.png',
              fit: BoxFit.fitWidth,
              height: (2 * SizeConfig.screenHeight) / 3,
            ),
            SizedBox(
              height: SizeConfig.padding,
            ),
            Text(
              AppLocalizations.of(context)!.helpWelcomeMapSlideDescription,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: SizeConfig.fontTextSize,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      // Third one is about mark modal and info found on it
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.padding,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/help/mark.png',
              fit: BoxFit.fitWidth,
              height: (2 * SizeConfig.screenHeight) / 3,
            ),
            SizedBox(
              height: SizeConfig.padding,
            ),
            Text(
              AppLocalizations.of(context)!.helpWelcomeMarkSlideDescription,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: SizeConfig.fontTextSize,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      // Fourth is about register to create marks
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.padding,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/help/new.png',
              fit: BoxFit.fitWidth,
              height: (2 * SizeConfig.screenHeight) / 3,
            ),
            SizedBox(
              height: SizeConfig.padding,
            ),
            Text(
              AppLocalizations.of(context)!.helpWelcomeNewMarkSlideDescription,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: SizeConfig.fontTextSize,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      // Fifth and final slide is call to actions for user
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.padding,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.fitWidth,
              width: 128.0,
            ),
            SizedBox(
              height: SizeConfig.paddingLarge,
            ),
            Text(
              AppLocalizations.of(context)!.helpWelcomeCTASlideDescription,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: SizeConfig.fontTextSize,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: SizeConfig.padding,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                color: Theme.of(context).colorScheme.surface,
              ),
              padding: EdgeInsets.all(
                SizeConfig.padding,
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.helpWelcomeCTASlideShowWelcomeScreen,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: SizeConfig.fontTextSize,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          right: SizeConfig.paddingSmall,
                        ),
                      ),
                      Switch(
                        value: showWelcomeScreen,
                        onChanged: (
                          value,
                        ) {
                          showWelcomeScreen = !showWelcomeScreen;
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.padding,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Go to auth
                      ElevatedButton(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person,
                            ),
                            SizedBox(
                              width: SizeConfig.paddingSmall,
                            ),
                            Text(
                              AppLocalizations.of(context)!.helpWelcomeCTASlideAuth,
                            ),
                          ],
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            MapView.routeName,
                          );
                          Navigator.pushNamed(
                            context,
                            AuthView.routeName,
                          );
                        },
                      ),
                      SizedBox(
                        width: SizeConfig.padding,
                      ),
                      // Close to map
                      ElevatedButton(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.map,
                            ),
                            SizedBox(
                              width: SizeConfig.paddingSmall,
                            ),
                            Text(
                              AppLocalizations.of(context)!.helpWelcomeCTASlideMap,
                            ),
                          ],
                        ),
                        onPressed: () {
                          widget.settingsController.updateShowWelcomeScreen(showWelcomeScreen);
                          Navigator.pushReplacementNamed(
                            context,
                            MapView.routeName,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }
  // Current page indicator
  List<Widget> pageIndicator() {
    SizeConfig().init(context);
    return List<Widget>.generate(
      slides.length,
      (index) => Container(
        margin: EdgeInsets.symmetric(
          horizontal: SizeConfig.paddingTiny,
        ),
        height: SizeConfig.paddingSmall,
        width: SizeConfig.paddingSmall,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            SizeConfig.paddingSmall,
          ),
          color: (currentPage.round() == index)
            ? Theme.of(context).colorScheme.onSurface
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context
  ) {
    SizeConfig().init(context);
    slides = buildSlides(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.helpWelcomeTitle,
        ),
        shadowColor: Theme.of(context).colorScheme.shadow,
        actions: [
          // Open application SettingsView
          IconButton(
            icon: const Icon(
              Icons.close,
            ),
            onPressed: () => Navigator.pushReplacementNamed(
              context,
              MapView.routeName,
            ),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          PageView.builder(
            controller: _pageViewController,
            itemCount: slides.length,
            itemBuilder: (
              BuildContext context,
              int index,
            ) {
              _pageViewController.addListener(() {
                setState(() {
                  currentPage = _pageViewController.page!;
                });
              });
              return slides[index];
            },
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: SizeConfig.paddingLarge,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: pageIndicator(),
                ),
              )
            ),
        ],
      ),
    );
  }
}
