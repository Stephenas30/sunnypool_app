import 'package:flutter/material.dart';
import 'package:sunnypool_app/screens/configurationPiscine_screen.dart';
import 'package:sunnypool_app/utils/user_location.dart';

class PiscinelocationScreen extends StatefulWidget {
  const PiscinelocationScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _PiscinelocationScreen();
  }
}

class _PiscinelocationScreen extends State<PiscinelocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final adresseController = TextEditingController();
  final codePostalController = TextEditingController();
  final villeController = TextEditingController();
  final paysController = TextEditingController();

  bool isLoadingLocation = false;
  bool locationChecked = false;

  void loadLocation() async {
    try {
      setState(() {
        isLoadingLocation = true;
      });
      Map<String, String?> address = await getFullAddress();

      if (address.isNotEmpty) {
        setState(() {
          isLoadingLocation = false;
          locationChecked = true;
        });
      }

      adresseController.text = address['street'] ?? '';
      codePostalController.text = address['postalCode'] ?? '';
      villeController.text = address['locality'] ?? '';
      paysController.text = address['country'] ?? '';
    } catch (e) {
      print(e);
    }
  }

  void listenerInput() {
    if (adresseController.text.isNotEmpty &&
        codePostalController.text.isNotEmpty &&
        villeController.text.isNotEmpty &&
        paysController.text.isNotEmpty) {
      setState(() {
        locationChecked = true;
      });
    } else {
      setState(() {
        locationChecked = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050505), Color(0xFF111111)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/icon.png',
                      height: (screenHeight / 4.4).clamp(90.0, 160.0),
                    ),
                    Text(
                      'Votre Localisation',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: (screenWidth * 0.08).clamp(24.0, 34.0),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            Icons.home,
                            'Adresse',
                            adresseController,
                          ),
                          _buildTextField(
                            Icons.post_add,
                            'Code postal',
                            codePostalController,
                          ),
                          _buildTextField(
                            Icons.location_city,
                            'Ville',
                            villeController,
                          ),
                          _buildTextField(Icons.public, 'Pays', paysController),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: loadLocation,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Colors.amber,
                                  width: 1,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.gps_fixed,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Utiliser ma localisation GPS',
                                      style: TextStyle(
                                        fontSize: (screenWidth * 0.034).clamp(
                                          12.0,
                                          15.0,
                                        ),
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  if (isLoadingLocation)
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.amber,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  else if (locationChecked)
                                    Icon(
                                      Icons.check_circle_sharp,
                                      color: Colors.green[600],
                                      size: (screenWidth * 0.05).clamp(
                                        16.0,
                                        22.0,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          /*                     _buildTextField(
                            Icons.gps_fixed,
                            'Utiliser ma localisation GPS',
                            paysController,
                          ), */
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: locationChecked
                                  ? () {
                                      print(
                                        'Adresse: ${adresseController.text}',
                                      );
                                      print(
                                        'Code Postal: ${codePostalController.text}',
                                      );
                                      print('Ville: ${villeController.text}');
                                      print('Pays: ${paysController.text}');
                                      print('Location: $locationChecked');
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ConfigurationpiscineScreen(),
                                        ),
                                      );
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: locationChecked
                                    ? Colors.amber
                                    : Colors.grey,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: Text(
                                'Continuer',
                                style: TextStyle(
                                  fontSize: (screenWidth * 0.034).clamp(
                                    12.0,
                                    16.0,
                                  ),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            children: [
                              Text(
                                'En continuant, vous acceptez nos',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                'Conditions générales d\'utilisation',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String title,
    TextEditingController? controller, {
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.amber),
          labelText: title,
          labelStyle: const TextStyle(color: Colors.amber),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber, width: 2),
          ),
        ),
        onChanged: (value) => listenerInput(),
        validator: validator,
        /* validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            }, */
      ),
    );
  }
}
