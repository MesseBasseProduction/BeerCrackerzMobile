import 'package:beercrackerz/src/map/marker/marker_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '/src/map/marker/marker_data.dart';
import '/src/map/marker/marker_enums.dart';
import '/src/utils/size_config.dart';

class ModalHelper {
  static Widget markerEditor(
    BuildContext context,
    GlobalKey<FormState> formKey,
    MarkerData markerData,
    Function formValidation,
  ) {
    SizeConfig().init(context);

    String? nameErrorMsg;
    String? descErrorMsg;

    List<String> types = SpotTypes.values.map((e) => e.name).toList();
    if (markerData.type == 'shop') {
      types = ShopTypes.values.map((e) => e.name).toList();
    } else if (markerData.type == 'bar') {
      types = BarTypes.values.map((e) => e.name).toList();
    }

    List<String> modifiers = SpotModifiers.values.map((e) => e.name).toList();
    if (markerData.type == 'shop') {
      modifiers = ShopModifiers.values.map((e) => e.name).toList();
    } else if (markerData.type == 'bar') {
      modifiers = BarModifiers.values.map((e) => e.name).toList();
    }

    return StatefulBuilder(
      builder: (
        BuildContext context,
        StateSetter setModalState,
      ) {
        return Form(
          key: formKey,
          child: Container(
            padding: EdgeInsets.only(
              top: (SizeConfig.defaultSize * 2),
              bottom: (SizeConfig.defaultSize * 2),
              left: (SizeConfig.defaultSize * 2),
              right: (SizeConfig.defaultSize * 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  (markerData.type == 'spot')
                    ? AppLocalizations.of(context)!.newSpotInformation
                    : (markerData.type == 'shop')
                      ? AppLocalizations.of(context)!.newShopInformation
                      : AppLocalizations.of(context)!.newBarInformation,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: (SizeConfig.defaultSize * 2),
                ),
                // POI name
                TextFormField(
                  decoration: InputDecoration(
                    labelText: (markerData.type == 'spot')
                      ? AppLocalizations.of(context)!.newSpotNameInput
                      : (markerData.type == 'shop')
                        ? AppLocalizations.of(context)!.newShopNameInput
                        : AppLocalizations.of(context)!.newBarNameInput,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    filled: true,
                    prefixIcon: Icon(
                      Icons.label,
                      size: (SizeConfig.defaultSize * 2),
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    errorText: nameErrorMsg,
                  ),
                  initialValue: markerData.name,
                  inputFormatters: [
                    // See https://github.com/MesseBasseProduction/BeerCrackerz backend for this char limitation
                    LengthLimitingTextInputFormatter(50),
                  ],
                  onSaved: (String? value) => markerData.name = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      if (markerData.type == 'spot') {
                        return AppLocalizations.of(context)!.emptyInput(AppLocalizations.of(context)!.newSpotNameInputEmpty);
                      } else if (markerData.type == 'shop') {
                        return AppLocalizations.of(context)!.emptyInput(AppLocalizations.of(context)!.newShopNameInputEmpty);
                      } else if (markerData.type == 'bar') {
                        return AppLocalizations.of(context)!.emptyInput(AppLocalizations.of(context)!.newBarNameInputEmpty);
                      }
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: (SizeConfig.defaultSize * 2),
                ),
                Text(
                  (markerData.type == 'spot')
                      ? AppLocalizations.of(context)!.newSpotTypesTitle
                      : (markerData.type == 'shop')
                        ? AppLocalizations.of(context)!.newShopTypesTitle
                        : AppLocalizations.of(context)!.newBarTypesTitle,
                  textAlign: TextAlign.center,
                ),
                // POI types
                Wrap(
                  alignment: WrapAlignment.center,
                  // We must replace $ char from Shop enum
                  children: MarkerView.buildListElements(context, markerData.type, types, false, markerData.types, setModalState),
                ),
                SizedBox(
                  height: (SizeConfig.defaultSize * 2),
                ),
                // POI description
                TextFormField(
                  minLines: 3,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: (markerData.type == 'spot')
                      ? AppLocalizations.of(context)!.newSpotDescriptionInput
                      : (markerData.type == 'shop')
                        ? AppLocalizations.of(context)!.newShopDescriptionInput
                        : AppLocalizations.of(context)!.newBarDescriptionInput,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    filled: true,
                    prefixIcon: Icon(
                      Icons.edit,
                      size: (SizeConfig.defaultSize * 2),
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    errorText: descErrorMsg,
                  ),
                  initialValue: markerData.description,
                  inputFormatters: [
                    // See https://github.com/MesseBasseProduction/BeerCrackerz backend for this char limitation
                    LengthLimitingTextInputFormatter(500),
                  ],
                  onSaved: (String? value) => markerData.description = value!,
                  // No validator as this fiel is optionnal
                ),
                SizedBox(
                  height: (SizeConfig.defaultSize * 2),
                ),
                Text(
                  (markerData.type == 'spot')
                      ? AppLocalizations.of(context)!.newSpotModifiersTitle
                      : (markerData.type == 'shop')
                        ? AppLocalizations.of(context)!.newShopModifiersTitle
                        : AppLocalizations.of(context)!.newBarModifiersTitle,
                  textAlign: TextAlign.center,
                ),
                // POI Modifiers
                Wrap(
                  alignment: WrapAlignment.center,
                  children: MarkerView.buildListElements(context, markerData.type, modifiers, false, markerData.modifiers, setModalState),
                ),
                SizedBox(
                  height: (SizeConfig.defaultSize * 2),
                ),
                Row(
                  mainAxisAlignment: (markerData.type == 'spot')
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          (markerData.type == 'spot')
                            ? AppLocalizations.of(context)!.newSpotRatingTitle
                            : (markerData.type == 'shop')
                              ? AppLocalizations.of(context)!.newShopRatingTitle
                              : AppLocalizations.of(context)!.newBarRatingTitle,
                          textAlign: TextAlign.center,
                        ),
                        RatingBar.builder(
                          initialRating: markerData.rate + 1,
                          direction: Axis.horizontal,
                          itemCount: 5,
                          itemSize: SizeConfig.iconSize,
                          itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            markerData.rate = rating;
                          },
                        ),
                      ],
                    ),
                    // Only add price if not spot
                    (markerData.type != 'spot')
                      ? Column(
                          children: [
                            Text(
                              (markerData.type == 'shop')
                                ? AppLocalizations.of(context)!.newShopPriceTitle
                                : AppLocalizations.of(context)!.newBarPriceTitle,
                              textAlign: TextAlign.center,
                            ),
                            RatingBar.builder(
                              initialRating: markerData.price!.toDouble() + 1,
                              direction: Axis.horizontal,
                              itemCount: 3,
                              itemSize: SizeConfig.iconSize,
                              itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                              itemBuilder: (context, _) => const Icon(
                                Icons.attach_money,
                                color: Colors.green,
                              ),
                              onRatingUpdate: (rating) {
                                markerData.price = rating.toInt();
                              },
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                  ],
                ),
                SizedBox(
                  height: (SizeConfig.defaultSize * 2),
                ),
                // Submit new spot
                ButtonTheme(
                  height: (SizeConfig.defaultSize * 5),
                  minWidth: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    onPressed: () => formValidation(),
                    child: Text(
                      (markerData.type == 'spot')
                        ? AppLocalizations.of(context)!.newSpotSubmit
                        : (markerData.type == 'shop')
                          ? AppLocalizations.of(context)!.newShopSubmit
                          : AppLocalizations.of(context)!.newBarSubmit,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );    
  }
}
