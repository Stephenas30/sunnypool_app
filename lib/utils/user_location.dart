import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

Future<Map<String, String?>> getFullAddress() async {
  try {
    // 1️⃣ Récupérer la position
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // 2️⃣ Convertir coordonnées en adresse
    List<Placemark> placemarks = await placemarkFromCoordinates(
      pos.latitude,
      pos.longitude,
    );

    if (placemarks.isEmpty) {
      print("Adresse introuvable");
      return {};
    }

    Placemark place = placemarks.first;

    return {
      "street": place.street,
      "postalCode": place.postalCode,
      "locality": place.locality,
      "country": place.country,
      "latitude": pos.latitude.toString(),
      "longitude": pos.longitude.toString(),
    };
    /* print("Adresse complète: ${place.street}");
    print("Code postal: ${place.postalCode}");
    print("Ville: ${place.locality}");
    print("Pays: ${place.country}"); */
  } catch (e) {
    print("Erreur: $e");
    return {};
  }
}

Future<void> checkPermission() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    throw Exception('GPS désactivé');
  }

  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Permission refusée définitivement');
  }
}

Future<Position> getLocation() async {
  await checkPermission();

  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}