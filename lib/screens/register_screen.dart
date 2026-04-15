import 'package:flutter/material.dart';
import 'package:sunnypool_app/screens/add_piscine_screen.dart';
import '../services/auth_service.dart';
import '../utils/token_storage.dart';
import 'login_screen.dart';
import 'userlocation_screen.dart';

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
              context, MaterialPageRoute(builder: (_) => AddPiscineScreen(isFirstTime: true)));
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
                    Image.asset("assets/logo.png", height: 80),
                    const SizedBox(height: 12),
                    Text(
                      "Créer un compte",
                      style: theme.textTheme.headlineSmall?.copyWith(color: Colors.amber),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      _usernameController,
                      "Nom d’utilisateur",
                      Icons.person,
                      validator: (val) => val!.isEmpty ? "Entrez un nom d’utilisateur" : null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(_firstNameController, "Prénom", Icons.badge),
                    const SizedBox(height: 12),
                    _buildTextField(_lastNameController, "Nom", Icons.badge_outlined),
                    const SizedBox(height: 12),
                    _buildTextField(
                      _emailController,
                      "Adresse email",
                      Icons.email,
                      validator: (val) => val!.isEmpty ? "Entrez une adresse email" : null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(_phoneController, "Téléphone", Icons.phone),
                    const SizedBox(height: 12),
                    _buildTextField(
                      _passwordController,
                      "Mot de passe",
                      Icons.lock,
                      obscure: true,
                      validator: (val) => val!.length < 6 ? "Mot de passe trop court" : null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      _confirmPasswordController,
                      "Confirmer mot de passe",
                      Icons.lock_outline,
                      obscure: true,
                      validator: (val) =>
                          val != _passwordController.text ? "Les mots de passe ne correspondent pas" : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _register,
                        child: _loading
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text("Créer mon compte"),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      },
                      child: const Text("Déjà un compte ? Se connecter"),
                    ),
                    Text(
                      "En continuant, vous acceptez nos Conditions générales d'utilisation.",
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
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
      obscureText: obscure,
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
      ),
      validator: validator,
    );
  }
}