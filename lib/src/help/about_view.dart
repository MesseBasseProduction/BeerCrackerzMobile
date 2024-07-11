import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '/src/settings/settings_controller.dart';
import '/src/utils/app_const.dart';
import '/src/utils/size_config.dart';
// Provide users info on the app and its data
class AboutView extends StatelessWidget {
  const AboutView({
    super.key,
    required this.settingsController,
  });

  static const routeName = '/about';
  final SettingsController settingsController;

  @override
  Widget build(
    BuildContext context
  ) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.helpAboutTitle,
        ),
        shadowColor: Theme.of(context).colorScheme.shadow,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          SizeConfig.padding,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: SizeConfig.paddingLarge,
            ),
            Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.fitWidth,
              width: 128.0,
            ),
            SizedBox(
              height: SizeConfig.paddingLarge,
            ),
            Text(
              AppLocalizations.of(context)!.helpAboutPar1,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: SizeConfig.fontTextSize,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: SizeConfig.padding,
            ),
            Text(
              AppLocalizations.of(context)!.helpAboutPar2,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: SizeConfig.fontTextSize,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: SizeConfig.padding,
            ),
            // Check source code
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.code,
                      ),
                      SizedBox(
                        width: SizeConfig.paddingSmall,
                      ),
                      Text(
                        AppLocalizations.of(context)!.helpAboutSourceCode,
                      ),
                    ],
                  ),
                  onPressed: () => launchUrl(
                    Uri.parse('https://github.com/MesseBasseProduction/BeerCrackerz'),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: SizeConfig.padding,
            ),
            Text(
              AppLocalizations.of(context)!.helpAboutPar3,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: SizeConfig.fontTextSize,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: SizeConfig.padding,
            ),
            Text(
              AppLocalizations.of(context)!.helpAboutPar4,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: SizeConfig.fontTextSize,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: SizeConfig.padding,
            ),
            // Check source code
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.mail,
                      ),
                      SizedBox(
                        width: SizeConfig.paddingSmall,
                      ),
                      Text(
                        AppLocalizations.of(context)!.helpAboutReachUs,
                      ),
                    ],
                  ),
                  onPressed: () => launchUrl(
                    Uri.parse('mailto:contact@messe-basse-production.com'),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: SizeConfig.padding,
            ),
            Text(
              AppLocalizations.of(context)!.helpAboutDisclaimer,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: SizeConfig.fontTextSize,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: SizeConfig.padding,
            ),
            Text(
              AppLocalizations.of(context)!.helpAboutVersion(AppConst.appVersion, AppConst.serverVersion),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: SizeConfig.fontTextSize,
              ),
              textAlign: TextAlign.center,
            ),
            Image.asset(
              'assets/images/mbp.png',
              fit: BoxFit.fitWidth,
            ),
            SizedBox(
              height: SizeConfig.paddingLarge,
            ),
          ],
        ),
      ),
    );
  }
}
