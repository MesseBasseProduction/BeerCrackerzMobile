// Class made to hold for Spot, Shop and Bar types,
// all internal data to be consumed by application.
class MarkerData {
  int id;
  String type;
  String name;
  String description;
  double lat;
  double lng;
  double rating;
  double? price;
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
    required this.rating,
    this.price = 0, // Optionnal because not relevant for spot model
    required this.types,
    required this.modifiers,
    required this.user,
    required this.userId,
    required this.creationDate,
  });
  // Factory method to build MarkerData from JSON received from server
  factory MarkerData.fromJson(
    Map<String, dynamic> json,
  ) {
    // Parse mark types
    var rawTypes = json['types'];
    List<String> parsedTypes = List<String>.from(rawTypes);
    // Parse mark modifiers
    var rawModifiers = json['modifiers'];
    List<String> parsedModifiers = List<String>.from(rawModifiers);
    // Mark rating to avoid null exception
    double sanitizedRating = 1;
    if (json['rating'] != null) {
      sanitizedRating = json['rating'];
    }
    // Mark price to avoid null exception (only relevant for shops and bars)
    double sanitizedPrice = 1;
    if (json['price'] != null) {
      sanitizedPrice = json['price'];
    }
    // Build MarkerData
    return switch (json) {
      {
        'id': int id,
        'type': String type,
        'name': String name,
        'description': String description,
        'lat': double lat,
        'lng': double lng,
        'user': String user,
        'userId': int userId,
        'creationDate': String creationDate,
      } => MarkerData(
        id: id,
        type: type,
        name: name,
        description: description,
        lat: lat,
        lng: lng,
        rating: sanitizedRating,
        price: sanitizedPrice,
        types: parsedTypes,
        modifiers: parsedModifiers,
        user: user,
        userId: userId,
        creationDate: creationDate,
      ), (_) => throw const FormatException('Unable to load MarkerData fromJson'),
    };
  }
}
