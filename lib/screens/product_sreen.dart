import 'package:flutter/material.dart';
import 'profile_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

List<Map<String, dynamic>> listProduct = [
  {'nameProduct': 'Chlore multifonctions', 'quantity': 5, 'unity': 'litres'},
  {'nameProduct': 'Ph moins', 'quantity': 5, 'unity': 'litres'},
  {'nameProduct': 'Ph plus', 'quantity': 5, 'unity': 'litres'},
  {'nameProduct': 'Sel pour électrolyseur', 'quantity': 25, 'unity': 'kg'},
];

class _ProductScreenState extends State<ProductScreen> {
  late List<bool> buttonSelected = [true, false];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Équipements',
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
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 20,
          horizontal: screenWidth * 0.08,
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            spacing: 20,
            children: [
              Column(
                children: [
                  Image.asset('assets/logo.png', height: screenHeight / 6),
                  Text(
                    'Sélectionnez vos produits d\'entretien piscine pour que Sunny vous donne des recommandations précises et optimisées.',
                    style: TextStyle(fontSize: screenWidth * 0.03),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ],
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: screenHeight * 0.4),
                child: SingleChildScrollView(child:  ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: listProduct
                      .map((item) => _buildListProduct(item))
                      .toList(),
                ),
                ),
              ),
              Column(
                spacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      'Continuer',
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
                      'Passer',
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

  Widget _buildListProduct(Map<String, dynamic> product) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product['nameProduct'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.opacity_outlined,
                    color: Colors.amber,
                    size: screenWidth * 0.05,
                  ),
                  Text(
                    '${product['quantity']} ${product['unity']}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.03,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 12,
            children: [
              Icon(Icons.info, color: Colors.amber),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.amber),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                padding: EdgeInsets.all(8),
                child: Row(
                  spacing: 12,
                  children: [
                    Icon(Icons.remove, color: Colors.amber),
                    Text(
                      '${product['quantity']} ${product['unity']}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.03,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Icon(Icons.add, color: Colors.amber),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
