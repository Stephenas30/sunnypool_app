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
  bool _displayPassword = false;

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
        //print("Erreur de connexion: ${e}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$e"),
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final theme = Theme.of(context);
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.amber.withOpacity(0.2)),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset("assets/logo.png", height: 120),
                    const SizedBox(height: 12),
                    Text(
                      'Connexion',
                      style: theme.textTheme.headlineSmall?.copyWith(color: Colors.amber),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      _usernameController,
                      "Nom d’utilisateur",
                      Icons.person,
                      validator: (val) => val!.isEmpty ? "Entrez votre nom d’utilisateur" : null,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      _passwordController,
                      "Mot de passe",
                      Icons.lock,
                      obscure: true,
                      validator: (val) => val!.isEmpty ? "Entrez votre mot de passe" : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        child: _loading
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text("Se connecter"),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterScreen()),
                        );
                      },
                      child: Text("Pas encore de compte ? Créer un compte", textAlign: TextAlign.center, style: TextStyle(fontSize: screenWidth * 0.03),),
                    ),
                    Text(
                      "Mot de passe oublié ?",
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
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

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon,
      {bool obscure = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure && !_displayPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.amber),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.amber),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.amber),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.amber),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.amber, width: 2),
        ),
        suffixIcon: obscure
            ? IconButton(
                icon: Icon(
                  _displayPassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.amber,
                ),
                onPressed: () {
                  setState(() {
                    _displayPassword = !_displayPassword;
                  });
                },
              )
            : null,
      ),
      validator: validator,
    );
  }
}