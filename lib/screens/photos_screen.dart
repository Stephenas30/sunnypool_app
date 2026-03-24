import 'package:flutter/material.dart';
import 'package:sunnypool_app/screens/profile_screen.dart';

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({Key? key}) : super(key: key);

  @override
  State<PhotosScreen> createState() {
    // TODO: implement createState
    return _PhotosScreenState();
  }
}

Widget _buildCardPhoto(String title) {
  return Column(
    children: [
      Text(title),
      Image.asset('assets/piscine.png'),
      Text('Ajouter une photo'),
    ],
  );
}

class _PhotosScreenState extends State<PhotosScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Photos Piscine',
          style: TextStyle(color: Colors.yellow),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.yellow),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundImage: AssetImage("assets/icon.png"),
              radius: 16,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Image.asset('assets/logo.png', width: 150, height: 150),
            Text(
              'Ajoutez des photos  de votre piscine pour une analyse précise',
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children: [
                  _buildCardPhoto('Vue d\'ensemble'),
                  _buildCardPhoto('Eau de la piscine'),
                  _buildCardPhoto('Local technique'),
                  _buildCardPhoto('Equipements'),
                ],
              ),
            ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    Text('Prenez des photos nettes et lumineuses', textAlign: TextAlign.center,),
                    
                  ],),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    Text('Montrez la pompe, le skimmer, le robot', textAlign: TextAlign.center),
                    
                  ],),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    Text('L\'IA analusera votre piscine automatiquement', textAlign: TextAlign.center)
                    
                  ],)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
