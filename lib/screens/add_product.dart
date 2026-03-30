import 'package:flutter/material.dart';
import 'package:sunnypool_app/screens/profile_screen.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({Key? key}) : super(key: key);

  @override
  State<AddProduct> createState() {
    // TODO: implement createState
    return _AddProductState();
  }
}

class _AddProductState extends State<AddProduct> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajouter un produit',
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
                  Text(
                    'Scanner un produit',
                    style: TextStyle(fontSize: screenWidth * 0.05),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    child: Column(
                      children: [
                        Icon(Icons.photo_camera),
                        ElevatedButton(
                          onPressed: () {},
                          child: Row(
                            children: [
                              Icon(Icons.photo_camera),
                              Text('Photographier l\'étiquette'),
                            ],
                          ),
                        ),
                        Text(
                          'Sunny analysera automatiquement les dosages et la composition.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text('Photo de produit'),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: Row(
                            children: [Icon(Icons.add), Text('ajouter photo')],
                          ),
                        ),
                      ),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: Row(
                            children: [Icon(Icons.add), Text('ajouter photo')],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  Text('Informations produit'),
                  Container(
                    child: Column(
                      children: [
                        Text('Nom du produit'),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Marque',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        Text('Catégorie'),
                        Text('Concentration'),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      'Ajouter ce produit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.03,
                      ),
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
                      backgroundColor: const Color.fromARGB(255, 99, 99, 99),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1,
                        vertical: screenHeight * 0.01,
                      ),
                    ),
                    child: Text(
                      'Annuler',
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
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
          Text(title, style: TextStyle(fontSize: screenWidth * 0.03)),
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
                  Text(
                    'Ajouter une photo',
                    style: TextStyle(fontSize: screenWidth * 0.03),
                  ),
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
