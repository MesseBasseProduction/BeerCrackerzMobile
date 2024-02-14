import 'dart:ffi';

class Spots {
  final List<Spot> spots;

  const Spots({
    required this.spots,    
  });

  factory Spots.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'spots': List<Spot> spots,
      } =>
        Spots(
          spots: spots,
        ),
      _ => throw const FormatException('Failed to load album.'),
    };
  }
}

class Spot {
  final int id;
  final String name;
  final String description;
  final Float lat;
  final Float lng;
  final Int rate;
  final List<String> types;
  final List<String> modifiers;
  final String user;
  final Int userId;
  final DateTime creationDate;

  const Spot({
    required this.id,
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

  factory Spot.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'name': String name,
        'description': String description,
        'lat': Float lat,
        'lng': Float lng,
        'rate': Int rate,
        'types': List<String> types,
        'modifiers': List<String> modifiers,
        'user': String user,
        'userId': Int userId,
        'creationDate': DateTime creationDate,
      } =>
        Spot(
          id: id,
          name: name,
          description: description,
          lat: lat,
          lng: lng,
          rate: rate,
          types: types,
          modifiers: modifiers,
          user: user,
          userId: userId,
          creationDate: creationDate,
        ),
      _ => throw const FormatException('Failed to load album.'),
    };
  }
}