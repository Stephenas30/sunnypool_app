import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunnypool_app/services/user_service.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  static const int _fallbackUserId = 1;
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final UserService _userService = UserService();
  bool _isSaving = false;
  bool _isLoading = true;
  int _userId = _fallbackUserId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id') ?? _fallbackUserId;

    if (!mounted) return;
    setState(() {
      _fullNameController.text = prefs.getString('profile_full_name') ?? 'Thomas Dupont';
      _emailController.text =
          prefs.getString('profile_email') ?? 'thomas.dup***@email.com';
      _phoneController.text = prefs.getString('profile_email') ?? 'thomas.dup***@email.com';
      _isLoading = false;
    });
  }

  /* Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id') ?? _fallbackUserId;

    try {
      final user = await _userService.getUser(_userId);

      //print(user);

      _fullNameController.text =
          (user['full_name'] ?? user['name'] ?? user['display_name'] ?? '').toString().trim();
      _emailController.text = (user['email'] ?? '').toString().trim();
      _phoneController.text = (user['phone'] ?? '').toString().trim();

      await prefs.setString('profile_full_name', _fullNameController.text);
      await prefs.setString('profile_email', _emailController.text);
      await prefs.setString('profile_phone', _phoneController.text);
      await prefs.setString('avatar', user['avatar'] ?? '');
    } catch (_) {
      _fullNameController.text =
          prefs.getString('profile_full_name') ?? 'Thomas Dupont';
      _emailController.text =
          prefs.getString('profile_email') ?? 'thomas.dup***@email.com';
      _phoneController.text = prefs.getString('profile_phone') ?? '';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Impossible de charger le profil distant, affichage des données locales.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  } */

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    try {
      await _userService.updateUser(_userId, {
        'full_name': fullName,
        'name': fullName,
        'email': email,
        'phone': phone,
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_full_name', fullName);
      await prefs.setString('profile_email', email);
      await prefs.setString('profile_phone', phone);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informations enregistrées')),
      );
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Échec de l'enregistrement des informations sur le serveur.",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Informations personnelles'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050505), Color(0xFF111111)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildField(
                      controller: _fullNameController,
                      label: 'Nom complet',
                      icon: Icons.person,
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Entrez votre nom complet'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return 'Entrez votre email';
                        if (!v.contains('@')) return 'Email invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      controller: _phoneController,
                      label: 'Téléphone',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : Text(
                                'Enregistrer',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: Colors.black,
                                ),
                              ),
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.amber),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.amber),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
