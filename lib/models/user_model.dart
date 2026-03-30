class UserModel {
  final String id;
  final String username;
  final String? firstname;
  final String? lastname;
  final String email;
  final String? phone;
  final String address;
  final String city;
  final String postalCode;
  final String country;
  final String password;
  final String location;

  UserModel({
    required this.id,
    required this.username,
    this.firstname,
    this.lastname,
    required this.email,
    this.phone,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.country,
    required this.password,
    required this.location,
  });
}