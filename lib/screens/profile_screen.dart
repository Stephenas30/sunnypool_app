import 'package:flutter/material.dart';
import '../utils/token_storage.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true, 
        title: Text("Profil", style: TextStyle(color: Colors.amber)),
        iconTheme: IconThemeData(color: Colors.amber),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage("assets/icon.png"),
            ),
            SizedBox(height: 20),
            Text("Thomas Dupont",
                style: TextStyle(color: Colors.amber, fontSize: 22)),
            Text("thomas.dup***@email.com",
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            SizedBox(height: 30),
            ListTile(
              leading: Icon(Icons.person, color: Colors.amber),
              title: Text("Informations personnelles",
                  style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: Icon(Icons.lock, color: Colors.amber),
              title: Text("Modifier le mot de passe",
                  style: TextStyle(color: Colors.white)),
            ),
            SwitchListTile(
              value: true,
              onChanged: (_) {},
              activeColor: Colors.amber,
              title: Text("Notifications reçues",
                  style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: Icon(Icons.history, color: Colors.amber),
              title: Text("Historique des analyses",
                  style: TextStyle(color: Colors.white)),
            ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
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
    );
  }
}