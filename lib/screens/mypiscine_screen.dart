import 'package:flutter/material.dart';
import 'package:sunnypool_app/models/pool_model.dart';
import 'package:sunnypool_app/models/user_model.dart';
import 'package:sunnypool_app/screens/add_piscine_screen.dart';
import 'package:sunnypool_app/screens/dashboard_screen.dart';
import 'package:sunnypool_app/services/pool_service.dart';
import 'package:sunnypool_app/utils/list_piscine.dart';
import 'package:sunnypool_app/utils/token_storage.dart';

double parseDouble(dynamic value) {
  if (value == null) return 0.0; // ou null selon ton besoin
  if (value is num) return value.toDouble(); // déjà un int/double
  if (value is String) return double.tryParse(value) ?? 0.0; // parse String
  return 0.0; // valeur par défaut si autre type inattendu
}

class MypiscineScreen extends StatefulWidget {
  const MypiscineScreen({super.key});

  @override
  State<MypiscineScreen> createState() => _MypiscineScreen();
}

class _MypiscineScreen extends State<MypiscineScreen> {
  List<Pool> piscines = listPiscines;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPools();
  }

  Future<void> _loadPools() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tokenValue = await TokenStorage.getToken();
      if (tokenValue == null || tokenValue.isEmpty) {
        setState(() {
          _errorMessage = 'Session expirée. Veuillez vous reconnecter.';
          _isLoading = false;
        });
        return;
      }

      final pools = await PoolService().getAllPool(tokenValue.toString());
      final fetchPool = <Pool>[];

      if (pools['data'] is List) {
        for (final item in pools['data']) {
          fetchPool.add(
            Pool(
              name: item['titre'] ?? 'Piscine sans nom',
              type: TypePool.beton,
              dimension: Dimension(
                length: parseDouble(item['caracteristiques']?['length']),
                width: parseDouble(item['caracteristiques']?['width']),
                depth: parseDouble(item['caracteristiques']?['depth']),
              ),
              location: Location(
                latitude: parseDouble(item['localisation']?['latitude']),
                longitude: parseDouble(item['localisation']?['longitude']),
              ),
            ),
          );
        }
      }

      setState(() {
        piscines = fetchPool;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'Impossible de charger vos piscines pour le moment.';
        _isLoading = false;
      });
    }
  }

  void addArticle(Pool pool) {
    setState(() {
      piscines.add(pool);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Piscines'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.amber.withOpacity(0.22)),
                  ),
                  child: Column(
                    children: [
                      Image.asset('assets/logo.png', height: 120),
                      const SizedBox(height: 14),
                      Text(
                        'Liste de vos piscines',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Naviguez facilement entre vos piscines et accédez aux détails de chacune.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                      : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _errorMessage!,
                                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _loadPools,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        )
                      : piscines.isEmpty
                      ? Center(
                          child: Text(
                            'Aucune piscine disponible pour le moment.',
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white54),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : RefreshIndicator(
                          color: Colors.amber,
                          onRefresh: _loadPools,
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            itemCount: piscines.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) => _buildListPool(piscines[index]),
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddPiscineScreen(onAddPool: addArticle),
                        ),
                      );
                      _loadPools();
                    },
                    icon: const Icon(Icons.add),
                    label: Text(
                      'Ajouter une piscine',
                      style: theme.textTheme.labelLarge?.copyWith(color: Colors.black),
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

  Widget _buildListPool(Pool pool) {
    final theme = Theme.of(context);
    final typeLabel = pool.type.toString().split('.').last;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => DashboardScreen(pool: pool)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  'assets/piscine.png',
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pool.name,
                      style: theme.textTheme.titleLarge?.copyWith(color: Colors.amber),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Type • $typeLabel',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Dim: ${pool.dimension.length} x ${pool.dimension.width} x ${pool.dimension.depth} m',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.amber),
            ],
          ),
        ),
      ),
    );
  }
}
