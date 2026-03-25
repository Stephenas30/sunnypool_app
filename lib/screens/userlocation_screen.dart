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
    return Scaffold(
      body: /* Center(
        child:  */ Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 30),
          Image.asset('assets/icon.png', height: 250),
          Text(
            'Votre Localisation',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Expanded(
            child: /* FormField(
                builder: (field) {F
                  return */ Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTextField(Icons.home, 'Adresse', adresseController),
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
                    _buildTextField(Icons.local_atm, 'Pays', paysController),
                    _buildTextField(
                      Icons.local_atm,
                      'Utiliser ma localisation GPS',
                      paysController,
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 16,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          print('Adresse: ${adresseController.text}');
                          print('Code Postal: ${codePostalController.text}');
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
                          style: TextStyle(fontSize: 25, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: EdgeInsets.symmetric(
                            horizontal: 100,
                            vertical: 20,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'En continuant, vous acceptez nos Conditions générales d\'utilisation',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String title,
    TextEditingController? controller,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: title,
          prefixIcon: Icon(icon, color: Colors.amber),
          hintStyle: TextStyle(color: const Color.fromARGB(255, 181, 181, 181)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
        style: TextStyle(color: Colors.white),
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
