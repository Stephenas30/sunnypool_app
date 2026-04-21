import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sunnypool_app/models/pool_model.dart';
import 'package:sunnypool_app/models/product_model.dart';
import 'package:sunnypool_app/models/user_model.dart';
import 'package:sunnypool_app/screens/dashboard_screen.dart';
import 'package:sunnypool_app/screens/login_screen.dart';
import 'package:sunnypool_app/screens/profile_screen.dart';
import 'package:sunnypool_app/services/pool_service.dart';
import 'package:sunnypool_app/services/product_service.dart';
import 'package:sunnypool_app/utils/token_storage.dart';
import 'package:sunnypool_app/utils/user_location.dart';
import 'package:sunnypool_app/widget/custom_stepper.dart';
import 'package:sunnypool_app/widget/pick_image.dart';

class AddPiscineScreen extends StatefulWidget {
  final Function(Pool)? onAddPool;
  final bool isFirstTime;

  const AddPiscineScreen({super.key, this.onAddPool, this.isFirstTime = false});

  @override
  State<AddPiscineScreen> createState() {
    return _AddPiscineScreen();
  }
}

class _AddPiscineScreen extends State<AddPiscineScreen> {

  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  static const _surfaceColor = Color(0xFF161616);
  static const _surfaceSoftColor = Color(0xFF1E1E1E);
  static const _borderColor = Color(0x33FFD54F);

  int _currentStep = 0;
  bool _isSubmitting = false;
  bool _isLoadingLocation = false;
  bool _locationChecked = false;
  bool _isAddingProduct = false;

  final nameController = TextEditingController();
  final lengthController = TextEditingController();
  final widthController = TextEditingController();
  final depthController = TextEditingController();

  final nbrSkimmersController = TextEditingController();
  final nbrRefoulementController = TextEditingController();
  final puissancePompeController = TextEditingController();

  final adresseController = TextEditingController();
  final codePostalController = TextEditingController();
  final villeController = TextEditingController();
  final paysController = TextEditingController();

  final _productNameController = TextEditingController();
  final _productBrandController = TextEditingController();
  final _productQuantityController = TextEditingController();
  final _productUnitController = TextEditingController();

  Pool? pool;

  TypePool typePool = TypePool.beton;
  double volumePool = 0;

  bool priseBalai = false;
  BondeFond bondeFond = BondeFond.non;
  Pompe pompe = Pompe.standard;
  TypeFiltre typeFiltre = TypeFiltre.sable;
  Categorie? _selectedCategory;

  List<Traitement> traitementChecked = [Traitement.chlore];

  File? imageEnsemble;
  File? imageEau;
  File? imageLocal;
  File? imageEquipements;

  Location? location;

  File? photoFace;
  File? photoNoticeDosage;
  final List<ProductModel> _addedProducts = [];

  @override
  void initState() {
    super.initState();
    _updateVolume();
    _syncLocationCompletion();
    _loadLocation();
  }

  @override
  void dispose() {
    nameController.dispose();
    lengthController.dispose();
    widthController.dispose();
    depthController.dispose();
    nbrSkimmersController.dispose();
    nbrRefoulementController.dispose();
    puissancePompeController.dispose();
    adresseController.dispose();
    codePostalController.dispose();
    villeController.dispose();
    paysController.dispose();
    _productNameController.dispose();
    _productBrandController.dispose();
    _productQuantityController.dispose();
    _productUnitController.dispose();
    super.dispose();
  }

  double _parseDecimal(String input) {
    return double.tryParse(input.trim().replaceAll(',', '.')) ?? 0;
  }

  void _updateVolume() {
    final nextVolume =
        _parseDecimal(lengthController.text) *
        _parseDecimal(widthController.text) *
        _parseDecimal(depthController.text);

    if (nextVolume != volumePool) {
      setState(() {
        volumePool = nextVolume;
      });
    }
  }

  void _syncLocationCompletion() {
    final isComplete =
        adresseController.text.trim().isNotEmpty &&
        codePostalController.text.trim().isNotEmpty &&
        villeController.text.trim().isNotEmpty &&
        paysController.text.trim().isNotEmpty;

    if (_locationChecked != isComplete) {
      setState(() {
        _locationChecked = isComplete;
      });
    }
  }

  String _formatEnumLabel(String value) {
    final normalized = value
        .replaceAll('_', ' ')
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .trim();

    if (normalized.isEmpty) return value;

    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  InputDecoration _fieldDecoration({
    required String label,
    String? hint,
    IconData? icon,
    String? suffixText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: suffixText,
      prefixIcon: icon != null ? Icon(icon, color: Colors.amber) : null,
      labelStyle: const TextStyle(color: Colors.amber),
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: _surfaceSoftColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.amber, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /* Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
          const SizedBox(height: 14), */
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextInputAction textInputAction = TextInputAction.next,
    String? suffixText,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      onChanged: onChanged,
      decoration: _fieldDecoration(
        label: label,
        hint: hint,
        icon: icon,
        suffixText: suffixText,
      ),
    );
  }

  Widget _buildFormFieldShell({
    required Widget child,
    double minWidth = 220,
    double maxWidth = 360,
  }) {
    final normalizedMaxWidth = maxWidth < minWidth ? minWidth : maxWidth;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth,
        maxWidth: normalizedMaxWidth,
      ),
      child: child,
    );
  }

  Future<void> _takePhoto(String imageType) async {

    PickImage(onImagePicked: (File photo) {
      setState(() {
        switch (imageType) {
          case 'Vue d\'ensemble':
            imageEnsemble = photo;
            break;
          case 'Eau de la piscine':
            imageEau = photo;
            break;
          case 'Local technique':
            imageLocal = photo;
            break;
          case 'Equipements':
          imageEquipements = File(photo.path);
          break;
        }
      });
    }, context: context).showImageSourceSheet();

    /* final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

    setState(() {
      switch (imageType) {
        case 'Vue d\'ensemble':
          imageEnsemble = File(photo.path);
          break;
        case 'Eau de la piscine':
          imageEau = File(photo.path);
          break;
        case 'Local technique':
          imageLocal = File(photo.path);
          break;
        case 'Equipements':
          imageEquipements = File(photo.path);
          break;
      }
    }); */
  }

  Future<void> _takePhotoProd(String imageType) async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

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

  Future<void> _loadLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final address = await getFullAddress();

      if (address.isEmpty) {
        _showStepError('Impossible de récupérer votre position GPS.');
        return;
      }

      final latitude = double.tryParse(address['latitude'] ?? '') ?? 0;
      final longitude = double.tryParse(address['longitude'] ?? '') ?? 0;
      final postalCode = int.tryParse(address['postalCode'] ?? '') ?? 0;

      setState(() {
        location = Location(
          latitude: latitude,
          longitude: longitude,
          adresse: address['street'] ?? '',
          codePostal: postalCode,
          ville: address['locality'] ?? '',
          pays: address['country'] ?? '',
        );

        adresseController.text = address['street'] ?? '';
        codePostalController.text = address['postalCode'] ?? '';
        villeController.text = address['locality'] ?? '';
        paysController.text = address['country'] ?? '';
      });

      _syncLocationCompletion();
    } catch (_) {
      _showStepError('Erreur lors de la récupération de la localisation.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _addProduct() async {
    if (_isAddingProduct) return;

    final quantity = int.tryParse(_productQuantityController.text.trim());

    if (_productNameController.text.trim().isEmpty ||
        _productBrandController.text.trim().isEmpty ||
        _selectedCategory == null ||
        quantity == null ||
        quantity <= 0 ||
        _productUnitController.text.trim().isEmpty) {
      _showStepError('Complétez les champs produit obligatoires.');
      return;
    }

    setState(() {
      _isAddingProduct = true;
    });

    try {
      final product = ProductModel(
        categorie: _selectedCategory!,
        marque: _productBrandController.text.trim(),
        name: _productNameController.text.trim(),
        quantity: quantity,
        unit: _productUnitController.text.trim(),
        photoFace: photoFace?.path,
        photoNoticeDosage: photoNoticeDosage?.path,
      );

      if (!mounted) return;

      setState(() {
        _addedProducts.add(product);
        _productNameController.clear();
        _productBrandController.clear();
        _productQuantityController.clear();
        _productUnitController.clear();
        _selectedCategory = null;
        photoFace = null;
        photoNoticeDosage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produit ajouté à la liste.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {
      _showStepError('Erreur de connexion lors de l\'ajout du produit.');
    } finally {
      if (mounted) {
        setState(() {
          _isAddingProduct = false;
        });
      }
    }
  }

  Widget _buildProductListItem(ProductModel product, int index) {
    final hasFacePhoto = (product.photoFace ?? '').isNotEmpty;
    final hasNoticePhoto = (product.photoNoticeDosage ?? '').isNotEmpty;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceSoftColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${product.marque} • ${product.categorie.label}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  'Quantité: ${product.quantity} ${product.unit}',
                  style: const TextStyle(color: Colors.amber, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildProductPhotoChip(
                      label: 'Face',
                      enabled: hasFacePhoto,
                      icon: Icons.add_a_photo,
                    ),
                    _buildProductPhotoChip(
                      label: 'Étiquette',
                      enabled: hasNoticePhoto,
                      icon: Icons.text_snippet,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Supprimer ce produit',
            onPressed: () {
              setState(() {
                _addedProducts.removeAt(index);
              });
            },
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildProductPhotoChip({
    required String label,
    required bool enabled,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: enabled ? const Color(0x1AFFD54F) : Colors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: enabled ? Colors.amber : Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: enabled ? Colors.amber : Colors.white54),
          const SizedBox(width: 4),
          Text(
            '$label ${enabled ? "OK" : "N/A"}',
            style: TextStyle(
              color: enabled ? Colors.amber : Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddedProductsList() {
    if (_addedProducts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: _surfaceSoftColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor),
        ),
        child: const Text(
          'Aucun produit ajouté pour le moment.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Column(
      children: List.generate(
        _addedProducts.length,
        (index) => _buildProductListItem(_addedProducts[index], index),
      ),
    );
  }

  Future<void> _submitPool() async {
    if (!_validateCurrentStep(showError: true)) return;
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final newPool = Pool(
      name: nameController.text.trim(),
      type: typePool,
      dimension: Dimension(
        length: _parseDecimal(lengthController.text),
        width: _parseDecimal(widthController.text),
        depth: _parseDecimal(depthController.text),
      ),
      traitements: traitementChecked,
      hydraulique: Hydraulique(
        skimmers: int.tryParse(nbrSkimmersController.text.trim()) ?? 0,
        refoulement: int.tryParse(nbrRefoulementController.text.trim()) ?? 0,
        priseBalai: priseBalai,
        bondeFond: bondeFond,
      ),
      filtration: Filtration(
        pompe: pompe,
        puissance: _parseDecimal(puissancePompeController.text),
        type: typeFiltre,
      ),
      photoPool: PhotoPool(
        photoBassin: imageEnsemble?.path ?? '',
        photoEnvironnement: imageEau?.path ?? '',
        photoLocalTechn: imageLocal?.path ?? '',
      ),
      location: Location(
        latitude: location?.latitude ?? 0,
        longitude: location?.longitude ?? 0,
        adresse: adresseController.text.trim(),
        codePostal: int.tryParse(codePostalController.text.trim()) ?? 0,
        pays: paysController.text.trim(),
        ville: villeController.text.trim(),
      ),
    );

    try {
      final token = await TokenStorage.getToken();
      var response = await PoolService().addPool(token.toString(), newPool);

      for (var product in _addedProducts) {
        await ProductService().addProduct(token.toString(), product, idPool: response['data']['id'].toString());
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Piscine ajoutée avec succès.'),
          backgroundColor: Colors.green,
        ),
      );

      if (widget.isFirstTime) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardScreen()),
        );
      } else {
        widget.onAddPool?.call(newPool);
        Navigator.pop(context);
      }
    } on ApiException catch (error) {
      if (!mounted) return;

      if (error.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expirée. Veuillez vous reconnecter.'),
            backgroundColor: Colors.red,
          ),
        );
        await TokenStorage.clearToken();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Échec de l\'ajout. Veuillez réessayer. $error'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Échec de l\'ajout. Veuillez réessayer. $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showStepError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  bool _validateCurrentStep({bool showError = false}) {
    if (_currentStep == 0) {
      final length = _parseDecimal(lengthController.text);
      final width = _parseDecimal(widthController.text);
      final depth = _parseDecimal(depthController.text);

      if (nameController.text.trim().isEmpty) {
        if (showError) _showStepError('Renseignez le nom de la piscine.');
        return false;
      }
      if (length <= 0 || width <= 0 || depth <= 0) {
        if (showError) {
          _showStepError(
            'Renseignez des dimensions valides (longueur, largeur, profondeur).',
          );
        }
        return false;
      }
    }

    if (_currentStep == 1 && traitementChecked.isEmpty) {
      if (showError) _showStepError('Sélectionnez au moins un traitement.');
      return false;
    }

    if (_currentStep == 3) {
      final hasAddress =
          adresseController.text.trim().isNotEmpty &&
          codePostalController.text.trim().isNotEmpty &&
          villeController.text.trim().isNotEmpty &&
          paysController.text.trim().isNotEmpty;
      final validPostal =
          int.tryParse(codePostalController.text.trim()) != null;

      if (!hasAddress || !validPostal) {
        if (showError) {
          _showStepError(
            'Complétez la localisation avec un code postal valide.',
          );
        }
        return false;
      }
    }

    return true;
  }

  void _nextStep() {
    if (!_validateCurrentStep(showError: true)) return;
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWideScreen = MediaQuery.of(context).size.width >= 960;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une piscine'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundImage: AssetImage('assets/icon.png'),
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1220),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWideScreen ? 32 : 14,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    _buildSectionCard(
                      title: 'Configuration de votre piscine',
                      subtitle:
                          'Renseignez les informations essentielles pour un suivi précis et personnalisé.',
                      child: Row(
                        children: [
                          Image.asset('assets/logo.png', height: screenWidth * 0.05),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Complétez les 5 étapes pour finaliser votre espace.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                                fontSize: screenWidth * 0.03
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(child: _buildStepper()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormPool() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 8),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: 'Informations générales',
              child: Column(
                children: [
                  _buildTextField(
                    controller: nameController,
                    label: 'Nom de la piscine',
                    hint: 'Ex: Piscine familiale',
                    icon: Icons.pool,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TypePool>(
                    initialValue: typePool,
                    dropdownColor: _surfaceSoftColor,
                    style: const TextStyle(color: Colors.white),
                    decoration: _fieldDecoration(
                      label: 'Type de piscine',
                      icon: Icons.category,
                    ),
                    items: TypePool.values
                        .map(
                          (value) => DropdownMenuItem<TypePool>(
                            value: value,
                            child: Text(_formatEnumLabel(value.name)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        typePool = value ?? TypePool.beton;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildSectionCard(
              title: 'Dimensions',
              subtitle: 'Indiquez les mesures en mètres.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxWidth < 760;
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildFormFieldShell(
                            minWidth: isCompact ? constraints.maxWidth : 220,
                            child: _buildTextField(
                              controller: lengthController,
                              label: 'Longueur',
                              hint: 'Ex: 8',
                              suffixText: 'm',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.,]'),
                                ),
                              ],
                              onChanged: (_) => _updateVolume(),
                            ),
                          ),
                          _buildFormFieldShell(
                            minWidth: isCompact ? constraints.maxWidth : 220,
                            child: _buildTextField(
                              controller: widthController,
                              label: 'Largeur',
                              hint: 'Ex: 4',
                              suffixText: 'm',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.,]'),
                                ),
                              ],
                              onChanged: (_) => _updateVolume(),
                            ),
                          ),
                          _buildFormFieldShell(
                            minWidth: isCompact ? constraints.maxWidth : 220,
                            child: _buildTextField(
                              controller: depthController,
                              label: 'Profondeur',
                              hint: 'Ex: 1.5',
                              suffixText: 'm',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.,]'),
                                ),
                              ],
                              onChanged: (_) => _updateVolume(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101010),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _borderColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calculate, color: Colors.amber),
                        const SizedBox(width: 10),
                        Text(
                          'Volume estimé: ${volumePool.toStringAsFixed(2)} m³',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormTraitement() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          _buildSectionCard(
            title: 'Hydraulique',
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 760;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildFormFieldShell(
                          minWidth: isCompact ? constraints.maxWidth : 280,
                          child: _buildTextField(
                            controller: nbrSkimmersController,
                            label: 'Nombre de skimmers',
                            hint: 'Ex: 2',
                            icon: Icons.rectangle_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        _buildFormFieldShell(
                          minWidth: isCompact ? constraints.maxWidth : 280,
                          child: _buildTextField(
                            controller: nbrRefoulementController,
                            label: 'Buses de refoulement',
                            hint: 'Ex: 3',
                            icon: Icons.restart_alt,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<bool>(
                  initialValue: priseBalai,
                  dropdownColor: _surfaceSoftColor,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration(
                    label: 'Prise balai',
                    icon: Icons.radio_button_checked_rounded,
                  ),
                  items: const [
                    DropdownMenuItem(value: true, child: Text('Oui')),
                    DropdownMenuItem(value: false, child: Text('Non')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      priseBalai = value ?? false;
                    });
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<BondeFond>(
                  initialValue: bondeFond,
                  dropdownColor: _surfaceSoftColor,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration(
                    label: 'Bonde de fond',
                    icon: Icons.blur_circular,
                  ),
                  items: BondeFond.values
                      .map(
                        (value) => DropdownMenuItem<BondeFond>(
                          value: value,
                          child: Text(
                            value == BondeFond.horizontale
                                ? 'Horizontale'
                                : value == BondeFond.verticale
                                ? 'Verticale'
                                : 'Aucune',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      bondeFond = value ?? BondeFond.non;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildSectionCard(
            title: 'Filtration',
            child: Column(
              children: [
                DropdownButtonFormField<Pompe>(
                  initialValue: pompe,
                  dropdownColor: _surfaceSoftColor,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration(
                    label: 'Type de pompe',
                    icon: Icons.tune,
                  ),
                  items: Pompe.values
                      .map(
                        (value) => DropdownMenuItem<Pompe>(
                          value: value,
                          child: Text(_formatEnumLabel(value.name)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      pompe = value ?? Pompe.standard;
                    });
                  },
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: puissancePompeController,
                  label: 'Puissance pompe',
                  hint: 'Ex: 1.5',
                  suffixText: 'CV',
                  icon: Icons.bolt,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<TypeFiltre>(
                  initialValue: typeFiltre,
                  dropdownColor: _surfaceSoftColor,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration(
                    label: 'Type de filtre',
                    icon: Icons.filter_alt,
                  ),
                  items: TypeFiltre.values
                      .map(
                        (value) => DropdownMenuItem<TypeFiltre>(
                          value: value,
                          child: Text(_formatEnumLabel(value.name)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      typeFiltre = value ?? TypeFiltre.sable;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildSectionCard(
            title: 'Traitements utilisés',
            subtitle: 'Sélectionnez un ou plusieurs traitements.',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              children: Traitement.values.map((item) {
                final selected = traitementChecked.contains(item);
                return FilterChip(
                  label: Text(_formatEnumLabel(item.name)),
                  selected: selected,
                  selectedColor: Colors.amber,
                  checkmarkColor: Colors.black,
                  labelStyle: TextStyle(
                    color: selected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  side: const BorderSide(color: _borderColor),
                  onSelected: (_) {
                    setState(() {
                      if (selected) {
                        traitementChecked.remove(item);
                      } else {
                        traitementChecked.add(item);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormPhoto() {
    final photos = [
      {'title': 'Vue d\'ensemble', 'image': imageEnsemble},
      {'title': 'Eau de la piscine', 'image': imageEau},
      {'title': 'Local technique', 'image': imageLocal},
      {'title': 'Equipements', 'image': imageEquipements},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 8),
      child: _buildSectionCard(
        title: 'Photos de la piscine',
        subtitle: 'Ajoutez des photos nettes pour faciliter le diagnostic.',
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth < 700 ? 1 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.55,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final item = photos[index];
                return _buildCardPhoto(
                  item['title'] as String,
                  item['image'] as File?,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardPhoto(String title, File? image) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _takePhoto(title),
        child: Container(
          decoration: BoxDecoration(
            color: _surfaceSoftColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(13),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      image != null
                          ? Image.file(image, fit: BoxFit.cover)
                          : Image.asset(
                              'assets/piscine.png',
                              fit: BoxFit.cover,
                            ),
                      Container(color: Colors.black.withValues(alpha: 0.35)),
                      const Center(
                        child: Icon(
                          Icons.photo_camera,
                          color: Colors.amber,
                          size: 34,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      image != null ? 'Modifiée' : 'Ajouter',
                      style: const TextStyle(color: Colors.amber, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormLocation() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 8),
      child: Form(
        key: _formKey2,
        child: _buildSectionCard(
          title: 'Localisation',
          subtitle: 'Vous pouvez saisir manuellement ou utiliser le GPS.',
          child: Column(
            children: [
              _buildTextField(
                controller: adresseController,
                label: 'Adresse',
                icon: Icons.home,
                onChanged: (_) => _syncLocationCompletion(),
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: codePostalController,
                label: 'Code postal',
                icon: Icons.markunread_mailbox,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => _syncLocationCompletion(),
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: villeController,
                label: 'Ville',
                icon: Icons.location_city,
                onChanged: (_) => _syncLocationCompletion(),
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: paysController,
                label: 'Pays',
                icon: Icons.public,
                onChanged: (_) => _syncLocationCompletion(),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoadingLocation ? null : _loadLocation,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.amber),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: Colors.white,
                  ),
                  icon: _isLoadingLocation
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.amber,
                          ),
                        )
                      : const Icon(Icons.gps_fixed),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Utiliser ma localisation GPS'),
                      const SizedBox(width: 8),
                      if (_locationChecked && !_isLoadingLocation)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 18,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAddProduct() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          _buildSectionCard(
            title: 'Informations produit',
            subtitle: 'Ajout facultatif pour suivre vos stocks.',
            child: Column(
              children: [
                _buildTextField(
                  controller: _productNameController,
                  label: 'Nom du produit',
                  hint: 'Ex: Chlore choc 5kg',
                  icon: Icons.inventory_2,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _productBrandController,
                  label: 'Marque',
                  hint: 'Ex: Bayrol',
                  icon: Icons.sell,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<Categorie>(
                  initialValue: _selectedCategory,
                  dropdownColor: _surfaceSoftColor,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration(
                    label: 'Catégorie',
                    icon: Icons.category,
                  ),
                  items: Categorie.values
                      .map(
                        (category) => DropdownMenuItem<Categorie>(
                          value: category,
                          child: Text(category.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 760;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildFormFieldShell(
                          minWidth: isCompact ? constraints.maxWidth : 260,
                          child: _buildTextField(
                            controller: _productQuantityController,
                            label: 'Quantité',
                            hint: 'Ex: 5',
                            icon: Icons.numbers,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        _buildFormFieldShell(
                          minWidth: isCompact ? constraints.maxWidth : 260,
                          child: _buildTextField(
                            controller: _productUnitController,
                            label: 'Unité',
                            hint: 'Ex: kg, g, L',
                            icon: Icons.straighten,
                            textInputAction: TextInputAction.done,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildSectionCard(
            title: 'Photos produit',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _takePhotoProd('Face avant'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.amber),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.add_a_photo),
                        label: Text(
                          photoFace == null ? 'Face avant' : 'Face capturée',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _takePhotoProd('Étiquette'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.amber),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.text_snippet),
                        label: Text(
                          photoNoticeDosage == null
                              ? 'Étiquette'
                              : 'Étiquette capturée',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isAddingProduct ? null : _addProduct,
                    icon: _isAddingProduct
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      _isAddingProduct
                          ? 'Ajout en cours...'
                          : 'Ajouter ce produit',
                    ),
                  ),
                ),
          const SizedBox(height: 12),
          _buildSectionCard(
            title: 'Produits ajoutés (${_addedProducts.length})',
            subtitle: 'Vérifiez votre liste avant de finaliser la piscine.',
            child: _buildAddedProductsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    return switch (_currentStep) {
      0 => _buildFormPool(),
      1 => _buildFormTraitement(),
      2 => _buildFormPhoto(),
      3 => _buildFormLocation(),
      4 => buildAddProduct(),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildStepper() {
    final screenWidth = MediaQuery.of(context).size.width;
    final List<String> steps = [
      'Piscine',
      'Traitements',
      'Photos',
      'Localisation',
      'Produit',
    ];
    final isLastStep = _currentStep == steps.length - 1;

    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Étape ${_currentStep + 1} / ${steps.length} • ${steps[_currentStep]}',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                  fontSize: screenWidth * 0.03
                ),
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / steps.length,
                minHeight: 2,
                backgroundColor: Colors.white12,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 8),
            CustomStepper(
              currentStep: _currentStep,
              steps: steps,
              onStepTapped: (index) {
                if (index <= _currentStep) {
                  setState(() => _currentStep = index);
                  return;
                }
                if (_validateCurrentStep(showError: true)) {
                  setState(() => _currentStep = index);
                }
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: KeyedSubtree(
                  key: ValueKey(_currentStep),
                  child: _buildStepContent(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (_currentStep > 0) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _prevStep,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.amber),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Retour'),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLastStep
                        ? (_isSubmitting ? null : _submitPool)
                        : _nextStep,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: isLastStep
                        ? (_isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Icon(Icons.check_circle))
                        : const Icon(Icons.arrow_forward),
                    label: Text(
                      isLastStep
                          ? (_isSubmitting ? 'Ajout...' : 'Ajouter la piscine')
                          : 'Suivant',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
