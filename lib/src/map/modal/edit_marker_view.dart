import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '/src/map/map_service.dart';
import '/src/map/map_view.dart';
import '/src/map/marker/marker_data.dart';
import '/src/map/marker/marker_enums.dart';
import '/src/map/marker/marker_view.dart';
import '/src/utils/size_config.dart';

class EditMarkerView extends StatefulWidget {
  const EditMarkerView({
    super.key,
    required this.mapView,
    required this.data
  });

  final MapView mapView;
  final MarkerData data;

  @override
  EditMarkerViewState createState() {
    return EditMarkerViewState();
  }
}

class EditMarkerViewState extends State<EditMarkerView> {
  // Must be defined in here instead of MarkerView to avoid reset each build call
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);

    int screenHeightRatio = 66;

    return Container(
      height: (screenHeightRatio * mediaQueryData.size.height) / 100, // Taking screenHeightRatio % of screen height
      width: mediaQueryData.size.width,
      padding: const EdgeInsets.all(4),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              (widget.data.type == 'spot')
              ? AppLocalizations.of(context)!.editSpotTitle
              : (widget.data.type == 'shop')
                ? AppLocalizations.of(context)!.editShopTitle
                : AppLocalizations.of(context)!.editBarTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
            ),
            // BottomModal content built depending on switch value
            SingleChildScrollView(
              child: (widget.data.type == 'spot')
                ? buildEditSpotModal(context, widget.mapView, _formKey, widget.data)
                : (widget.data.type == 'shop')
                  ? buildEditShopModal(context, widget.mapView, _formKey, widget.data)
                  : buildEditBarModal(context, widget.mapView, _formKey, widget.data),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildEditSpotModal(
    BuildContext context,
    MapView mapView,
    GlobalKey<FormState> formKey,
    MarkerData data
  ) {
    SizeConfig().init(context);

    String? nameErrorMsg;
    String? descErrorMsg;

    void formValidation(StateSetter setModalState) async {
      setModalState(() {
        nameErrorMsg = null;
        descErrorMsg = null;
      });
      formKey.currentState!.save();
      if (formKey.currentState!.validate()) {
        // Start loading overlay during server call
        context.loaderOverlay.show();
        MapService.patchSpot(await mapView.controller.getAuthToken(), data).then((response) async {
          if (response.statusCode == 200) {
            Navigator.pop(context);
          }
        }).catchError((handleError) {
          print(handleError);
        }).whenComplete(() {
          // Hide overlay loader anyway
          context.loaderOverlay.hide();
        });
      }
    }

    return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
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
                AppLocalizations.of(context)!.newSpotInformation,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              // POI name
              TextFormField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.newSpotNameInput,
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
                initialValue: data.name,
                inputFormatters: [
                  // See https://github.com/MesseBasseProduction/BeerCrackerz backend for this char limitation
                  LengthLimitingTextInputFormatter(50),
                ],
                onSaved: (String? value) => data.name = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.emptyInput(AppLocalizations.of(context)!.newSpotNameInputEmpty);
                  }
                  return null;
                },
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              Text(
                AppLocalizations.of(context)!.newSpotTypesTitle,
                textAlign: TextAlign.center,
              ),
              // POI types
              Wrap(
                alignment: WrapAlignment.center,
                children: MarkerView.buildListElements(context, data.type, SpotTypes.values.map((e) => e.name).toList(), false, data.types, setModalState),
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              // POI description
              TextFormField(
                minLines: 3,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.newSpotDescriptionInput,
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
                initialValue: data.description,
                inputFormatters: [
                  // See https://github.com/MesseBasseProduction/BeerCrackerz backend for this char limitation
                  LengthLimitingTextInputFormatter(500),
                ],
                onSaved: (String? value) => data.description = value!,
                // No validator as this fiel is optionnal
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              Text(
                AppLocalizations.of(context)!.newSpotModifiersTitle,
                textAlign: TextAlign.center,
              ),
              // POI Modifiers
              Wrap(
                alignment: WrapAlignment.center,
                children: MarkerView.buildListElements(context, data.type, SpotModifiers.values.map((e) => e.name).toList(), false, data.modifiers, setModalState),
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              Text(
                AppLocalizations.of(context)!.newSpotRatingTitle,
                textAlign: TextAlign.center,
              ),
              RatingBar.builder(
                initialRating: data.rate + 1,
                direction: Axis.horizontal,
                itemCount: 5,
                itemSize: SizeConfig.iconSize,
                itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  data.rate = rating;
                },
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              // Submit new spot
              ButtonTheme(
                height: (SizeConfig.defaultSize * 5),
                minWidth: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () => formValidation(setModalState),
                  child: Text(AppLocalizations.of(context)!.newSpotSubmit),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  static Widget buildEditShopModal(
    BuildContext context,
    MapView mapView,
    GlobalKey<FormState> formKey,
    MarkerData data
  ) {
    SizeConfig().init(context);

    String? nameErrorMsg;
    String? descErrorMsg;

    void formValidation(StateSetter setModalState) async {
      setModalState(() {
        nameErrorMsg = null;
        descErrorMsg = null;
      });
      formKey.currentState!.save();
      if (formKey.currentState!.validate()) {
        // Start loading overlay during server call
        context.loaderOverlay.show();
        MapService.patchShop(await mapView.controller.getAuthToken(), data).then((response) async {
          if (response.statusCode == 200) {
            Navigator.pop(context);
          }
        }).catchError((handleError) {
          print(handleError);
        }).whenComplete(() {
          // Hide overlay loader anyway
          context.loaderOverlay.hide();
        });
      }
    }

    return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
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
                AppLocalizations.of(context)!.newShopInformation,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              // POI name
              TextFormField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.newShopNameInput,
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
                inputFormatters: [
                  // See https://github.com/MesseBasseProduction/BeerCrackerz backend for this char limitation
                  LengthLimitingTextInputFormatter(50),
                ],
                onSaved: (String? value) => data.name = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.emptyInput(AppLocalizations.of(context)!.newShopNameInputEmpty);
                  }
                  return null;
                },
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              Text(
                AppLocalizations.of(context)!.newShopTypesTitle,
                textAlign: TextAlign.center,
              ),
              // POI types
              Wrap(
                alignment: WrapAlignment.center,
                // We must replace $ char from Shop enum
                children: MarkerView.buildListElements(context, data.type, ShopTypes.values.map((e) => e.name).toList(), false, data.types, setModalState),
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              // POI description
              TextFormField(
                minLines: 3,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.newShopDescriptionInput,
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
                inputFormatters: [
                  // See https://github.com/MesseBasseProduction/BeerCrackerz backend for this char limitation
                  LengthLimitingTextInputFormatter(500),
                ],
                onSaved: (String? value) => data.description = value!,
                // No validator as this fiel is optionnal
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              Text(
                AppLocalizations.of(context)!.newShopModifiersTitle,
                textAlign: TextAlign.center,
              ),
              // POI Modifiers
              Wrap(
                alignment: WrapAlignment.center,
                children: MarkerView.buildListElements(context, data.type, ShopModifiers.values.map((e) => e.name).toList(), false, data.modifiers, setModalState),
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.newShopRatingTitle,
                        textAlign: TextAlign.center,
                      ),
                      RatingBar.builder(
                        initialRating: data.rate,
                        direction: Axis.horizontal,
                        itemCount: 5,
                        itemSize: SizeConfig.iconSize,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          data.rate = rating;
                        },
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.newShopPriceTitle,
                        textAlign: TextAlign.center,
                      ),
                      RatingBar.builder(
                        initialRating: data.price!.toDouble(),
                        direction: Axis.horizontal,
                        itemCount: 3,
                        itemSize: SizeConfig.iconSize,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.attach_money,
                          color: Colors.green,
                        ),
                        onRatingUpdate: (rating) {
                          data.price = rating.toInt();
                        },
                      ),
                    ],
                  ),
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
                  onPressed: () => formValidation(setModalState),
                  child: Text(AppLocalizations.of(context)!.newShopSubmit),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  static Widget buildEditBarModal(
    BuildContext context,
    MapView mapView,
    GlobalKey<FormState> formKey,
    MarkerData data
  ) {
    SizeConfig().init(context);

    String? nameErrorMsg;
    String? descErrorMsg;

    void formValidation(StateSetter setModalState) async {
      setModalState(() {
        nameErrorMsg = null;
        descErrorMsg = null;
      });
      formKey.currentState!.save();
      if (formKey.currentState!.validate()) {
        // Start loading overlay during server call
        context.loaderOverlay.show();
        MapService.patchBar(await mapView.controller.getAuthToken(), data).then((response) async {
          if (response.statusCode == 200) {
            Navigator.pop(context);
          }
        }).catchError((handleError) {
          print(handleError);
        }).whenComplete(() {
          // Hide overlay loader anyway
          context.loaderOverlay.hide();
        });
      }
    }

    return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
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
                AppLocalizations.of(context)!.newBarInformation,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              // POI name
              TextFormField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.newBarNameInput,
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
                inputFormatters: [
                  // See https://github.com/MesseBasseProduction/BeerCrackerz backend for this char limitation
                  LengthLimitingTextInputFormatter(50),
                ],
                onSaved: (String? value) => data.name = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.emptyInput(AppLocalizations.of(context)!.newBarNameInputEmpty);
                  }
                  return null;
                },
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              Text(
                AppLocalizations.of(context)!.newBarTypesTitle,
                textAlign: TextAlign.center,
              ),
              // POI types
              Wrap(
                alignment: WrapAlignment.center,
                // We must replace $ char from Shop enum
                children: MarkerView.buildListElements(context, data.type, BarTypes.values.map((e) => e.name).toList(), false, data.types, setModalState),
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              // POI description
              TextFormField(
                minLines: 3,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.newBarDescriptionInput,
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
                inputFormatters: [
                  // See https://github.com/MesseBasseProduction/BeerCrackerz backend for this char limitation
                  LengthLimitingTextInputFormatter(500),
                ],
                onSaved: (String? value) => data.description = value!,
                // No validator as this fiel is optionnal
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              Text(
                AppLocalizations.of(context)!.newBarModifiersTitle,
                textAlign: TextAlign.center,
              ),
              // POI Modifiers
              Wrap(
                alignment: WrapAlignment.center,
                children: MarkerView.buildListElements(context, data.type, BarModifiers.values.map((e) => e.name).toList(), false, data.modifiers, setModalState),
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.newBarRatingTitle,
                        textAlign: TextAlign.center,
                      ),
                      RatingBar.builder(
                        initialRating: data.rate,
                        direction: Axis.horizontal,
                        itemCount: 5,
                        itemSize: 24,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          data.rate = rating;
                        },
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.newBarPriceTitle,
                        textAlign: TextAlign.center,
                      ),
                      RatingBar.builder(
                        initialRating: data.price!.toDouble(),
                        direction: Axis.horizontal,
                        itemCount: 3,
                        itemSize: SizeConfig.iconSize,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.attach_money,
                          color: Colors.green,
                        ),
                        onRatingUpdate: (rating) {
                          data.price = rating.toInt();
                        },
                      ),
                    ],
                  ),
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
                  onPressed: () => formValidation(setModalState),
                  child: Text(AppLocalizations.of(context)!.newBarSubmit),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
