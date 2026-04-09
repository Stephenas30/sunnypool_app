import 'package:flutter/material.dart';
import '../utils/token_storage.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Profil"),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050505), Color(0xFF111111)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage("assets/icon.png"),
            ),
            SizedBox(height: 20),
            Text("Thomas Dupont", style: theme.textTheme.headlineSmall?.copyWith(color: Colors.amber)),
            Text("thomas.dup***@email.com", style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
            SizedBox(height: 30),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.person, color: Colors.amber),
                    title: Text("Informations personnelles", style: TextStyle(color: Colors.white)),
                  ),
                  ListTile(
                    leading: Icon(Icons.lock, color: Colors.amber),
                    title: Text("Modifier le mot de passe", style: TextStyle(color: Colors.white)),
                  ),
                  SwitchListTile(
                    value: true,
                    onChanged: (_) {},
                    activeThumbColor: Colors.amber,
                    title: Text("Notifications reçues", style: TextStyle(color: Colors.white)),
                  ),
                  ListTile(
                    leading: Icon(Icons.history, color: Colors.amber),
                    title: Text("Historique des analyses", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
              onPressed: () async {
                // Effacer le token
                await TokenStorage.clearToken();

                // Rediriger vers LoginScreen
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (route) => false,
                );
              },
              child: Text("Se déconnecter"),
            )

            ],
          ),
        ),
      ),
    );
  }
}