import 'package:flutter/material.dart';
import 'package:sunnypool_app/screens/profile_screen.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() {
    // TODO: implement createState
    return _AddProductState();
  }
}

class _AddProductState extends State<AddProduct> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        child: Center(
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              Column(
                children: [
                  Text(
                    'Scanner un produit',
                    style: theme.textTheme.headlineSmall?.copyWith(color: Colors.amber),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.withOpacity(0.22)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.photo_camera, color: Colors.amber, size: 30),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {},
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.photo_camera, color: Colors.black),
                              const SizedBox(width: 8),
                              const Text('Photographier l\'étiquette'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sunny analysera automatiquement les dosages et la composition.',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text('Photo de produit', style: theme.textTheme.titleMedium),
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
                  Text('Informations produit', style: theme.textTheme.titleMedium),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.withOpacity(0.22)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nom du produit', style: theme.textTheme.bodyLarge),
                        TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Marque',
                            hintStyle: const TextStyle(color: Colors.white54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.amber),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Catégorie', style: theme.textTheme.bodyLarge),
                        Text('Concentration', style: theme.textTheme.bodyLarge),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      'Ajouter ce produit',
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
                      'Annuler',
                      style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                    ),
                  ),
                  ),
                ],
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
