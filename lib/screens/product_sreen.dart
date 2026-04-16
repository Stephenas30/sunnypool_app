import 'package:flutter/material.dart';
import 'package:sunnypool_app/models/product_model.dart';
import 'package:sunnypool_app/screens/login_screen.dart';
import 'package:sunnypool_app/services/pool_service.dart';
import 'package:sunnypool_app/services/product_service.dart';
import 'package:sunnypool_app/utils/token_storage.dart';
import 'profile_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<ProductModel> listProduct = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    TokenStorage.getToken().then((tokenValue) {
      ProductService()
          .getAllProducts(tokenValue!)
          .then((data) {
            List<ProductModel> products = [];
            List.generate(data['data'].length, (index) {
              final item = data['data'][index];
              print(item['categorie']);
              products.add(
                ProductModel(
                  id: item['id']!.toString(),
                  categorie: CategorieExtension.fromString(item['categorie']),
                  marque: item['marque'] ?? '',
                  name: item['nom_produit'] ?? '',
                  quantity:
                      int.tryParse(item['quantite']?.toString() ?? '0') ?? 0,
                  unit: item['unite'] ?? '',
                  photoFace: item['photo_face'] ?? '',
                  commentaire: item['commentaire'] ?? '',
                  photoNoticeDosage: item['photo_notice'] ?? '',
                  dateAjout: DateTime.tryParse(item['date_ajout'] ?? ''),
                  dateMiseAJour: DateTime.tryParse(
                    item['date_mise_a_jour'] ?? '',
                  ),
                ),
              );
            });
            setState(() {
              listProduct = products;
              _isLoading = false;
            });
            // Traitez les données des produits ici
          })
          .catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erreur lors du chargement des produits.'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              _isLoading = false;
              _errorMessage =
                  'Erreur lors du chargement des produits. ${error.toString()}';
            });
            if (error is ApiException && error.statusCode == 401) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Session expirée. Veuillez vous reconnecter.'),
                  backgroundColor: Colors.red,
                ),
              );
              TokenStorage.clearToken().then((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              });
            }
          });
    });
  }

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.withOpacity(0.22)),
                ),
                child: Column(
                  children: [
                    Image.asset('assets/logo.png', height: screenHeight * 0.1),
                    const SizedBox(height: 8),
                    Text(
                      'Sélectionnez vos produits d\'entretien piscine pour que Sunny vous donne des recommandations précises et optimisées.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                          fontSize: screenWidth * 0.03
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.amber),
                      )
                    : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _errorMessage!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.redAccent,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _loadProducts,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      )
                    : listProduct.isEmpty
                    ? Center(
                        child: Text(
                          'Aucun produit disponible pour le moment.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : RefreshIndicator(
                        color: Colors.amber,
                        onRefresh: _loadProducts,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          itemCount: listProduct.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) =>
                              _buildListProduct(listProduct[index]),
                        ),
                      ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    print(listProduct);
                  },
                  child: Text(
                    'Continuer',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              /* const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Passer',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ), */
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListProduct(ProductModel product) {
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
          Image.network(
            product.photoFace!,
            width: screenWidth * 0.10,
            height: screenWidth * 0.10,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: screenWidth * 0.10,
              height: screenWidth * 0.10,
              color: Colors.white12,
              child: Icon(Icons.broken_image, color: Colors.white30),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.opacity_outlined,
                      color: Colors.amber,
                      size: screenWidth * 0.05,
                    ),
                    Text(
                      '${product.quantity} ${product.unit}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.03,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
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
                            if (product.quantity > 1) {
                              product.quantity -= 1;
                            } else {
                              product.quantity = 1;
                            }
                          });
                        },
                        icon: Icon(Icons.remove, color: Colors.amber, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ),
                    Text(
                      '${product.quantity} ${product.unit}',
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
                            product.quantity += 1;
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
