import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getWeather(double lat, double lon) async {
  final url = Uri.parse(
    'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    print(response.body);
    return json.decode(response.body);
  } else {
    throw Exception('Erreur API météo');
  }
}