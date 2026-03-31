class Location {
  final String latitude;
  final String longitude;

  Location({
    required this.latitude,
    required this.longitude
  });
}


class UserModel {
  final String id;
  final String username;
  final String? firstname;
  final String? lastname;
  final String email;
  final String? phone;
  final String address;
  final String? city;
  final String? postalCode;
  final String? country;
  final String password;
  final Location location;

  UserModel({
    required this.id,
    required this.username,
    this.firstname,
    this.lastname,
    required this.email,
    this.phone,
    required this.address,
    this.city,
    this.postalCode,
    this.country,
    required this.password,
    required this.location,
  });
}