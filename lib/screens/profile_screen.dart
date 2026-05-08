import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunnypool_app/services/user_service.dart';
import 'historique_analyses.dart';
import 'personal_info_screen.dart';
import 'change_password_screen.dart';
import '../utils/token_storage.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const int _fallbackUserId = 1;
  bool _notificationsEnabled = true;
  String _displayName = 'Thomas Dupont';
  String _displayEmail = 'thomas.dup***@email.com';
  var _avatar = "assets/icon.png";
  bool _isLoading = true;
    int _userId = _fallbackUserId;
    final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadProfilePreferences();
  }

  Future<void> _loadProfilePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id') ?? _fallbackUserId;

    try {
      final user = await _userService.getUser(_userId);

      //print(user);
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _displayName =
          (user['full_name'] ?? user['name'] ?? user['display_name'] ?? '').toString().trim();
      _displayEmail = (user['email'] ?? '').toString().trim();
      _avatar = user['avatar'] ?? '' ?? _avatar;
      });
      
      var _phone = (user['phone'] ?? '').toString().trim();

      await prefs.setString('profile_full_name', _displayName);
      await prefs.setString('profile_email', _displayEmail);
      await prefs.setString('profile_phone', _phone);
      //await prefs.setString('avatar', );
    } catch (_) {
      _displayName =
          prefs.getString('profile_full_name') ?? 'Thomas Dupont';
      _displayEmail =
          prefs.getString('profile_email') ?? 'thomas.dup***@email.com';
      //_phone = prefs.getString('profile_phone') ?? '';

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
  }

  Future<void> _setNotificationValue(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    if (!mounted) return;
    setState(() => _notificationsEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Profil")),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050505), Color(0xFF111111)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: (_avatar == "assets/icon.png")
                          ? AssetImage(_avatar)
                          : NetworkImage(_avatar),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _displayName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.amber,
                      ),
                    ),
                    Text(
                      _displayEmail,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.person,
                              color: Colors.amber,
                            ),
                            title: const Text(
                              "Informations personnelles",
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PersonalInfoScreen(),
                                ),
                              );
                              _loadProfilePreferences();
                            },
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.lock,
                              color: Colors.amber,
                            ),
                            title: const Text(
                              "Modifier le mot de passe",
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ChangePasswordScreen(),
                                ),
                              );
                            },
                          ),
                          SwitchListTile(
                            value: _notificationsEnabled,
                            onChanged: _setNotificationValue,
                            activeThumbColor: Colors.amber,
                            title: const Text(
                              "Notifications reçues",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.history,
                              color: Colors.amber,
                            ),
                            title: const Text(
                              "Historique des analyses",
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HistoriqueAnalyses(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () async {
                          await TokenStorage.clearToken();
                          if (!context.mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text("Se déconnecter"),
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
}
