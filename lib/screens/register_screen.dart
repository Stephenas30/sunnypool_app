import 'package:flutter/material.dart';
import 'package:sunnypool_app/screens/userlocation_screen.dart';
import '../services/auth_service.dart';
import '../utils/token_storage.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      try {
        final token = await AuthService()
            .register(_usernameController.text, _passwordController.text);

        if (token != null) {
          await TokenStorage.saveToken(token);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => UserlocationScreen()));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e")),
        );
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset("assets/logo.png", height: 80),
                SizedBox(height: 20),
                Text("Créer un compte",
                    style: TextStyle(color: Colors.amber, fontSize: 24)),

                SizedBox(height: 30),

                // Username
                _buildTextField(_usernameController, "Nom d’utilisateur", Icons.person,
                    validator: (val) =>
                        val!.isEmpty ? "Entrez un nom d’utilisateur" : null),

                SizedBox(height: 15),

                // Prénom
                _buildTextField(_firstNameController, "Prénom", Icons.badge),

                SizedBox(height: 15),

                // Nom
                _buildTextField(_lastNameController, "Nom", Icons.badge_outlined),

                SizedBox(height: 15),

                // Email
                _buildTextField(_emailController, "Adresse email", Icons.email,
                    validator: (val) =>
                        val!.isEmpty ? "Entrez une adresse email" : null),

                SizedBox(height: 15),

                // Téléphone
                _buildTextField(_phoneController, "Téléphone", Icons.phone),

                SizedBox(height: 15),

                // Mot de passe
                _buildTextField(_passwordController, "Mot de passe", Icons.lock,
                    obscure: true,
                    validator: (val) =>
                        val!.length < 6 ? "Mot de passe trop court" : null),

                SizedBox(height: 15),

                // Confirmer mot de passe
                _buildTextField(_confirmPasswordController,
                    "Confirmer mot de passe", Icons.lock_outline,
                    obscure: true,
                    validator: (val) => val != _passwordController.text
                        ? "Les mots de passe ne correspondent pas"
                        : null),

                SizedBox(height: 30),

                // Bouton
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                  onPressed: _loading ? null : _register,
                  child: _loading
                      ? CircularProgressIndicator(color: Colors.black)
                      : Text("Créer mon compte"),
                ),

                SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => LoginScreen()));
                  },
                  child: Text("Déjà un compte ? Se connecter",
                      style: TextStyle(color: Colors.amber)),
                ),

                SizedBox(height: 10),
                Text(
                  "En continuant, vous acceptez nos Conditions générales d'utilisation.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon,
      {bool obscure = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.amber),
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.amber),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.amber, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}