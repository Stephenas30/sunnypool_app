import 'package:flutter/material.dart';
import 'package:sunnypool_app/screens/configurationPiscine_screen.dart';

class UserlocationScreen extends StatefulWidget {
  const UserlocationScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _UserlocationScreen();
  }
}

class _UserlocationScreen extends State<UserlocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final adresseController = TextEditingController();
  final codePostalController = TextEditingController();
  final villeController = TextEditingController();
  final paysController = TextEditingController();

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
                            Icons.local_activity,
                            'Ville',
                            villeController,
                          ),
                          _buildTextField(
                            Icons.local_atm,
                            'Pays',
                            paysController,
                          ),
                          _buildTextField(
                            Icons.local_atm,
                            'Utiliser ma localisation GPS',
                            paysController,
                          ),
                          SizedBox(height: 20,),
                          ElevatedButton(
                            onPressed: () {
                              print('Adresse: ${adresseController.text}');
                              print(
                                'Code Postal: ${codePostalController.text}',
                              );
                              print('Ville: ${villeController.text}');
                              print('Pays: ${paysController.text}');
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ConfigurationpiscineScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Continuer',
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
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
