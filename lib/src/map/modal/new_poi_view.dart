import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'package:beercrackerz/src/map/map_service.dart';
import 'package:beercrackerz/src/settings/settings_controller.dart';

class NewPOIView extends StatefulWidget {
  const NewPOIView({
    super.key,
    required this.controller
  });

  final SettingsController controller;

  @override
  NewPOIViewState createState() {
    return NewPOIViewState();
  }
}

class NewPOIViewState extends State<NewPOIView> {
  String poiType = 'spot';

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);

    return Container(
      height: (80 * mediaQueryData.size.height) / 100, // Taking 80% of screen height
      color: Theme.of(context).colorScheme.background,
      child: SingleChildScrollView(
        //reverse: true,
        child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                ),
                Text(
                  (poiType == 'spot')
                  ? 'Spot'
                  : (poiType == 'shop')
                    ? 'Shop'
                    : 'Bar',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                ),
                // POI type switch
                ToggleSwitch(
                  customWidths: [mediaQueryData.size.width / 4, mediaQueryData.size.width / 4, mediaQueryData.size.width / 4],
                  initialLabelIndex: (poiType == 'spot') ? 0 : (poiType == 'shop') ? 1 : 2,
                  totalSwitches: 3,
                  labels: const ['Spot', 'Shop', 'Bar'],
                  onToggle: (index) {
                    if (index == 0) {
                      setState(() => poiType = 'spot');
                    } else if (index == 1) {
                      setState(() => poiType = 'shop');
                    } else {
                      setState(() => poiType = 'bar');
                    }
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                ),
                // BottomModal content built depending on switch value
                Container(
                  child: (poiType == 'spot')
                  ? MapService.buildNewSpotModal(context, poiType)
                  : (poiType == 'shop')
                    ? MapService.buildNewShopModal(context, poiType)
                    : Text('Bar'),
                ),
            ],
          ),
        ),
      ),
/*
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Test',
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  filled: true,
                  prefixIcon: Icon(
                    Icons.account_circle,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                inputFormatters: [
                  // See https://github.com/MesseBasseProduction/BeerCrackerz backend for this char limitation
                  //LengthLimitingTextInputFormatter(100),
                ],
                onSaved: (String? value) => {},
                validator: (value) {
                  return null;
                },
              ),
      
      SingleChildScrollView(
        child: Center(
          child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                ),
                Text(
                  (poiType == 'spot')
                  ? 'Spot'
                  : (poiType == 'shop')
                    ? 'Shop'
                    : 'Bar',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                ),
                ToggleSwitch(
                  customWidths: [mediaQueryData.size.width / 4, mediaQueryData.size.width / 4, mediaQueryData.size.width / 4],
                  initialLabelIndex: (poiType == 'spot') ? 0 : (poiType == 'shop') ? 1 : 2,
                  totalSwitches: 3,
                  labels: const ['Spot', 'Shop', 'Bar'],
                  onToggle: (index) {
                    if (index == 0) {
                      setState(() => poiType = 'spot');
                    } else if (index == 1) {
                      setState(() => poiType = 'shop');
                    } else {
                      setState(() => poiType = 'bar');
                    }
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                ),
                Column(
                  children: (poiType == 'spot')
                  ? MapService.buildNewSpotModal(context, poiType)
                  : (poiType == 'shop')
                    ? MapService.buildNewShopModal(context, poiType)
                    : [Text('Bar')],
                ),
              ],
            ),
        ),
      ),
      */
    );
  }
}
