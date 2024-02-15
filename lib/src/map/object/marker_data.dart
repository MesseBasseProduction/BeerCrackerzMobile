class MarkerData {
  final int id;
  final String type;
  final String name;
  final String description;
  final double lat;
  final double lng;
  final double rate;
  final List<String> types;
  final List<String> modifiers;
  final String user;
  final int userId;
  final String creationDate;

  const MarkerData({
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
