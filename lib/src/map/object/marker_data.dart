class MarkerData {
  int id;
  String type;
  String name;
  String description;
  double lat;
  double lng;
  double rate;
  List<String> types;
  List<String> modifiers;
  String user;
  int userId;
  String creationDate;

  MarkerData({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.lat,
    required this.lng,
    required this.rate,
    required this.types,
    required this.modifiers,
    required this.user,
    required this.userId,
    required this.creationDate,    
  });

  factory MarkerData.fromJson(Map<String, dynamic> json) {
    var rawTypes = json['types'];
    List<String> parsedTypes = List<String>.from(rawTypes);
    var rawModifiers = json['modifiers'];
    List<String> parsedModifiers = List<String>.from(rawModifiers);

    return switch (json) {
      {
        'id': int id,
        'type': String type,
        'name': String name,
        'description': String description,
        'lat': double lat,
        'lng': double lng,
        'rate': double rate,
        'user': String user,
        'userId': int userId,
        'creationDate': String creationDate,
      } =>
        MarkerData(
          id: id,
          type: type,
          name: name,
          description: description,
          lat: lat,
          lng: lng,
          rate: rate,
          types: parsedTypes,
          modifiers: parsedModifiers,
          user: user,
          userId: userId,
          creationDate: creationDate,
        ),
      _ => throw const FormatException('Failed to load spot.'),
    };
  }
}

/* Marker types and modifiers enums */

enum SpotTypes {
  forest, river, cliff, mountain, beach, sea, city, pov, lake
}

enum SpotModifiers {
  bench, covered, toilet, store, trash, parking
}

enum ShopTypes {
  store, $super, hyper, cellar
}

enum ShopModifiers {
  bio, craft, fresh, card, choice
}

enum BarTypes {
  regular, snack, cellar, rooftop
}

enum BarModifiers {
  tobacco, food, card, choice, outdoor
}
