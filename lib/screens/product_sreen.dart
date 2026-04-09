import 'package:flutter/material.dart';
import 'profile_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

List<Map<String, dynamic>> listProduct = [
  {
    'nameProduct': 'Chlore multifonctions',
    'init_quantity': 5,
    'quantity': 5,
    'unity': 'litres',
  },
  {
    'nameProduct': 'Ph moins',
    'init_quantity': 5,
    'quantity': 5,
    'unity': 'litres',
  },
  {
    'nameProduct': 'Ph plus',
    'init_quantity': 5,
    'quantity': 5,
    'unity': 'litres',
  },
  {
    'nameProduct': 'Sel pour électrolyseur',
    'init_quantity': 25,
    'quantity': 25,
    'unity': 'kg',
  },
];

class _ProductScreenState extends State<ProductScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes produits'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: screenWidth * 0.08),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Image.asset('assets/logo.png', height: screenHeight / 7),
                    const SizedBox(height: 10),
                    Text(
                      'Sélectionnez vos produits d\'entretien piscine pour que Sunny vous donne des recommandations précises et optimisées.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView(
                  children: listProduct.map((item) => _buildListProduct(item)).toList(),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    print('Continuer');
                    print(listProduct);
                  },
                  child: Text(
                    'Continuer',
                    style: theme.textTheme.labelLarge?.copyWith(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white38),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'Passer',
                    style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListProduct(Map<String, dynamic> product) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: Colors.amber.withOpacity(0.25)),
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
                    '${product['init_quantity']} ${product['unity']}',
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
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            if (product['quantity'] > 0) {
                              product['quantity'] -= product['init_quantity'];
                            } else {
                              product['quantity'] = 0;
                            }
                          });
                        },
                        icon: Icon(Icons.remove, color: Colors.amber, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ),
                    Text(
                      '${product['quantity']} ${product['unity']}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.03,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            product['quantity'] += product['init_quantity'];
                          });
                        },
                        icon: Icon(Icons.add, color: Colors.amber, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ),
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
