import 'package:flutter/material.dart';
import 'package:sunnypool_app/screens/configurationPiscine_screen.dart';
import 'package:sunnypool_app/utils/user_location.dart';

class PiscinelocationScreen  extends StatefulWidget {
  const PiscinelocationScreen({Key? key}) : super(key: key);

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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Image.asset('assets/icon.png', height: screenHeight / 4),
                      Text(
                        'Votre Localisation',
                        style: TextStyle(
                          fontSize: screenWidth * 0.08,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 60,
                              vertical: 8,
                            ),
                            child: ElevatedButton(
                              onPressed: loadLocation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                                side: BorderSide(color: Colors.amber, width: 1),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Icon(Icons.gps_fixed, color: Colors.white),
                                  // SizedBox(width: 10),
                                  Text(
                                    'Utiliser ma localisation GPS',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      color: Colors.white,
                                    ),
                                  ),
                                  isLoadingLocation ?
                                  CircularProgressIndicator(
                                    color: Colors.amber,
                                    strokeWidth: 1,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.amber,
                                    ),
                                  ) : locationChecked ? Icon(Icons.check_circle_sharp, color: Colors.green[600], size: screenWidth * 0.05) : SizedBox.shrink()
                                ],
                              ),
                            ),
                          ),

                          /*                     _buildTextField(
                            Icons.gps_fixed,
                            'Utiliser ma localisation GPS',
                            paysController,
                          ), */
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: locationChecked ? () {
                              print('Adresse: ${adresseController.text}');
                              print(
                                'Code Postal: ${codePostalController.text}',
                              );
                              print('Ville: ${villeController.text}');
                              print('Pays: ${paysController.text}');
                              print('Location: $locationChecked');
                              Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ConfigurationpiscineScreen(),
                              ),
                              );
                            } : null,
                            child: Text(
                              'Continuer',
                              style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: locationChecked ? Colors.amber : Colors.grey,
                              padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.2,
                              vertical: screenHeight * 0.01,
                              ),
                            ),
                            ),
                          SizedBox(height: screenHeight * 0.01),
                          Column(
                            children: [
                              Text(
                                'En continuant, vous acceptez nos',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Conditions générales d\'utilisation',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // ),
                  ),
                ],
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.amber),
          labelText: title,
          labelStyle: TextStyle(color: Colors.amber),
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
