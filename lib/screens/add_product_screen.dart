// filepath: /home/sylvqno/Projet SmartDev/sunnypool_app/lib/screens/add_product_screen.dart
import 'package:flutter/material.dart';
import 'profile_screen.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

List<Map<String, dynamic>> availableProducts = [
  {
    'nameProduct': 'Chlore multifonctions',
    'description': 'Désinfectant et algicide',
    'unity': 'litres',
    'selected': false,
  },
  {
    'nameProduct': 'Ph moins',
    'description': 'Diminue le pH de l\'eau',
    'unity': 'litres',
    'selected': false,
  },
  {
    'nameProduct': 'Ph plus',
    'description': 'Augmente le pH de l\'eau',
    'unity': 'litres',
    'selected': false,
  },
  {
    'nameProduct': 'Sel pour électrolyseur',
    'description': 'Sel cristallisé purifié',
    'unity': 'kg',
    'selected': false,
  },
  {
    'nameProduct': 'Algicide',
    'description': 'Élimine les algues',
    'unity': 'litres',
    'selected': false,
  },
];

class _AddProductScreenState extends State<AddProductScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un produit'),
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
                      'Ajoutez les produits d\'entretien que vous utilisez dans votre piscine.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView(
                  children: availableProducts.map((item) => _buildProductItem(item)).toList(),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final selected = availableProducts.where((p) => p['selected'] == true).toList();
                    print('Produits ajoutés: $selected');
                    Navigator.pop(context, selected);
                  },
                  child: Text(
                    'Ajouter',
                    style: theme.textTheme.labelLarge?.copyWith(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white38),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'Annuler',
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

  Widget _buildProductItem(Map<String, dynamic> product) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(
          color: product['selected'] ? Colors.amber : Colors.amber.withOpacity(0.25),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
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
                ),
                const SizedBox(height: 4),
                Text(
                  product['description'],
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: screenWidth * 0.03,
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: product['selected'],
            onChanged: (value) {
              setState(() {
                product['selected'] = value ?? false;
              });
            },
            activeColor: Colors.amber,
            checkColor: Colors.black,
          ),
        ],
      ),
    );
  }
}