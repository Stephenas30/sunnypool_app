import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sunnypool_app/models/product_model.dart';
import 'package:sunnypool_app/screens/profile_screen.dart';
import 'package:sunnypool_app/services/product_service.dart';
import 'package:sunnypool_app/utils/token_storage.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() {
    return _AddProductState();
  }
}

class _AddProductState extends State<AddProduct> {
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? photoFace;
  File? photoNoticeDosage;

  Categorie? _selectedCategory;

  bool _isSubmitting = false;

  Future<void> _takePhoto(String imageType) async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        switch (imageType) {
          case 'Face avant':
            photoFace = File(photo.path);
            break;
          case 'Étiquette':
            photoNoticeDosage = File(photo.path);
            break;
        }
      });
    }
  }

  _AddProduct() {
    if (_isSubmitting) return;
    print("AddProduct constructor called");
    print("Name product: ${_nameController.text}");
    print("Brand product: ${_brandController.text}");
    print("Selected category: $_selectedCategory");

    setState(() {
      _isSubmitting = true;
    });

    final quantity = int.tryParse(_quantityController.text.trim());
    final unit = _unitController.text.trim();

    if (_nameController.text.isEmpty ||
        _brandController.text.isEmpty ||
        _selectedCategory == null ||
        quantity == null ||
        quantity < 0 ||
        unit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir tous les champs obligatoires."),
        ),
      );
      return;
    }

    var product = ProductModel(
      categorie: _selectedCategory!,
      marque: _brandController.text,
      name: _nameController.text,
      quantity: quantity,
      unit: unit,
      photoFace: photoFace?.path,
      photoNoticeDosage: photoNoticeDosage?.path,
    );

    TokenStorage.getToken().then((tokenValue) {
      ProductService().addProduct(tokenValue!, product).then((response) {
        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Produit ajouté avec succès !")),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur : ${response['message']}")),
          );
        }
      }).catchError((error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de connexion : $error")),
        );
      }).whenComplete((){
        if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

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
            tooltip: 'Mon profil',
            icon: const CircleAvatar(
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ajout guidé d\'un produit',
                  style: theme.textTheme.headlineSmall?.copyWith(color: Colors.amber),
                ),
                const SizedBox(height: 8),
                Text(
                  '1) Scannez l\'étiquette  2) Ajoutez les photos  3) Vérifiez les informations.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 16),

                _buildSectionCard(
                  title: 'Scanner automatiquement',
                  child: Column(
                    children: [
                      const Icon(Icons.document_scanner, color: Colors.amber, size: 30),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.photo_camera, color: Colors.black),
                          label: const Text('Photographier l\'étiquette'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sunny remplit automatiquement les dosages et la composition.',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                _buildSectionCard(
                  title: 'Informations produit',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputLabel(theme, 'Nom du produit'),
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration('Ex: Chlore choc 5kg'),
                      ),
                      const SizedBox(height: 10),
                      _buildInputLabel(theme, 'Marque'),
                      TextField(
                        controller: _brandController,
                        style: const TextStyle(color: Colors.white),
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration('Ex: Bayrol'),
                      ),
                      const SizedBox(height: 10),
                      _buildInputLabel(theme, 'Catégorie'),
                      DropdownButtonFormField<Categorie>(
                        value: _selectedCategory,
                        dropdownColor: const Color(0xFF1A1A1A),
                        iconEnabledColor: Colors.amber,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Sélectionnez une catégorie'),
                        items: Categorie.values
                            .map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category.label),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),

                      _buildInputLabel(theme, 'Quantité'),
                      TextField(
                        controller: _quantityController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration('Ex: 5'),
                      ),
                      const SizedBox(height: 10),

                      _buildInputLabel(theme, 'Unité'),
                      TextField(
                        controller: _unitController,
                        style: const TextStyle(color: Colors.white),
                        textInputAction: TextInputAction.done,
                        decoration: _inputDecoration('Ex: kg, g, L'),
                      ),
                      const SizedBox(height: 10),

                      //_buildInputLabel(theme, 'Concentration'),
                      /* TextField(
                        controller: _concentrationController,
                        style: const TextStyle(color: Colors.white),
                        textInputAction: TextInputAction.done,
                        decoration: _inputDecoration('Ex: 56%'),
                      ), */
                    ],
                  ),
                ),

                _buildSectionCard(
                  title: 'Photos du produit',
                  child: Row(
                    children: [
                      Expanded(
                        child:  _buildPhotoButton(
                          icon: Icons.add_a_photo,
                          label: 'Face avant',
                          onPressed: () => _takePhoto('Face avant'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildPhotoButton(
                          icon: Icons.text_snippet,
                          label: 'Étiquette',
                          onPressed: () => _takePhoto('Étiquette'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _AddProduct,
                    icon: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Icon(Icons.check_circle),
                    label: Text(
                      (_isSubmitting ? 'Ajout...' : 'Ajouter ce produit'),
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
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildPhotoButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 100,
      child: Column(
        children: [
          label == 'Face avant' && photoFace != null
              ? Image.file(photoFace!, height: 30, width: 50, fit: BoxFit.cover)
              : label == 'Étiquette' && photoNoticeDosage != null
                  ? Image.file(photoNoticeDosage!, height: 30, width: 50, fit: BoxFit.cover)
                  : const SizedBox(height: 30),
          ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.black),
        label: Text(label),
      ),
        ],
      ) 
    );
  }

  Widget _buildInputLabel(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: theme.textTheme.bodyLarge),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: const Color(0xFF222222),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white24),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.amber),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}
