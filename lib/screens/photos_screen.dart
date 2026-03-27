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

class _PhotosScreenState extends State<PhotosScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
        centerTitle: true,
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
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Image.asset('assets/logo.png', width: screenWidth * 0.3),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Ajoutez des photos  de votre piscine pour une analyse précise.',
                      style: TextStyle(fontSize: screenWidth * 0.03),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: screenWidth,
                  maxHeight: screenHeight / 3,
                ),
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
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(20))
                ),
                padding: EdgeInsets.symmetric(vertical: 8),
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Conseil', textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Prenez des photos nettes et lumineuses',
                          style: TextStyle(
                            fontSize: screenWidth * 0.03
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Montrez la pompe, le skimmer, le robot',
                          style: TextStyle(
                            fontSize: screenWidth * 0.03
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'L\'IA analusera votre piscine automatiquement',
                          style: TextStyle(
                            fontSize: screenWidth * 0.03
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text(
                  'Confirmer et continuer',
                  style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.03),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.1,
                    vertical: screenHeight * 0.01,
                  ),
                ),
              ),
              ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            99,
                            99,
                            99,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.1,
                            vertical: screenHeight * 0.01,
                          ),
                        ),
                        child: Text(
                          'Passer cette étape',
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.white,
                          ),
                        ),
                      ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardPhoto(String title) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: screenWidth*0.03),),
          Stack(
            children: [
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.amber),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/piscine.png',
                        fit: BoxFit.cover,
                        height: screenHeight * 0.08,
                        width: screenWidth * 0.5,
                      ),
                    ),
                  ),
                  Text('Ajouter une photo', style: TextStyle(fontSize: screenWidth*0.03)),
                ],
              ),

              Align(
                alignment: Alignment(0, 1), // relatif
                child: Container(
                  padding: EdgeInsets.all(5),
                  // color: Colors.black.withOpacity(0.5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    color: const Color.fromARGB(216, 255, 211, 50),
                  ),
                  child: Icon(
                    Icons.photo_camera,
                    color: const Color.fromARGB(255, 154, 116, 0),
                    size: screenWidth * 0.07,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
