import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/token_storage.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      try {
        final token = await AuthService()
            .login(_usernameController.text, _passwordController.text);

        if (token != null) {
          await TokenStorage.saveToken(token);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Connexion réussie !"),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => DashboardScreen()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Identifiant ou mot de passe incorrect"),
            backgroundColor: Colors.red,
          ),
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
                Image.asset("assets/logo.png", height: 200),
                SizedBox(height: 20),

                SizedBox(height: 30),

                // Username
                _buildTextField(_usernameController, "Nom d’utilisateur", Icons.person,
                    validator: (val) =>
                        val!.isEmpty ? "Entrez votre nom d’utilisateur" : null),

                SizedBox(height: 15),

                // Password
                _buildTextField(_passwordController, "Mot de passe", Icons.lock,
                    obscure: true,
                    validator: (val) =>
                        val!.isEmpty ? "Entrez votre mot de passe" : null),

                SizedBox(height: 30),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? CircularProgressIndicator(color: Colors.black)
                      : Text("Se connecter"),
                ),

                SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => RegisterScreen()));
                  },
                  child: Text("Pas encore de compte ? Créer un compte",
                      style: TextStyle(color: Colors.amber)),
                ),

                SizedBox(height: 10),
                Text(
                  "Mot de passe oublié ?",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
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