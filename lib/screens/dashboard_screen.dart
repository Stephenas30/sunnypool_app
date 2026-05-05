import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sunnypool_app/models/pool_model.dart';
import 'package:sunnypool_app/models/user_model.dart';
import 'package:sunnypool_app/screens/add_product.dart';
import 'package:sunnypool_app/screens/analyse_screen.dart';
import 'package:sunnypool_app/screens/chat_sunny_screen.dart';
import 'package:sunnypool_app/screens/historique_analyses.dart';
import 'package:sunnypool_app/screens/information_piscine_screen.dart';
import 'package:sunnypool_app/screens/login_screen.dart';
import 'package:sunnypool_app/screens/mypiscine_screen.dart';
import 'package:sunnypool_app/screens/photos_screen.dart';
import 'package:sunnypool_app/screens/planning_entretien_screen.dart';
import 'package:sunnypool_app/screens/product_sreen.dart';
import 'package:sunnypool_app/screens/tutorals_screen.dart';
import 'package:sunnypool_app/services/meteo_service.dart';
import 'package:sunnypool_app/services/planning_service.dart';
import 'package:sunnypool_app/services/pool_service.dart';
import 'package:sunnypool_app/utils/list_piscine.dart';
import 'package:sunnypool_app/utils/poolId_storage.dart';
import 'package:sunnypool_app/utils/token_storage.dart';
import 'package:sunnypool_app/widget/skeleton_loasding.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Pool? pool;
  const DashboardScreen({super.key, this.pool});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PlanningService _planningService = PlanningService();
  late Future<Map<String, dynamic>> weatherFuture;
  //late Future<dynamic> allPool;
  Pool? checkPool;
  Timer? timer;
  bool loading = true;
  bool _planningLoading = true;
  String? _planningError;
  final List<_DashboardPlanningItem> _planningItems = [];
  final Set<String> _planningUpdatingIds = {};
  final DateFormat _planningDateFormat = DateFormat('dd/MM • HH:mm', 'fr_FR');

  @override
  void initState() {
    super.initState();
    checkPool = widget.pool ?? listPiscines.first;
    if (widget.pool != null) {
      PoolIdStorage.savePoolId(widget.pool!.id!);
      print(widget.pool!.id.toString());
      checkPool = widget.pool;
      loading = false;
      _loadPlanningForCurrentPool();
    } else {
      TokenStorage.getToken().then((tokenValue) {
        print(tokenValue);
        PoolService()
            .getAllPool(tokenValue.toString())
            .then((Map<String, dynamic> pools) {
              PoolIdStorage.savePoolId(pools['data'][0]['id'].toString());
              print(pools['data'][0]['id'].toString());
              Pool pool = Pool(
                id: pools['data'][0]['id'].toString(),
                name: pools['data'][0]['titre'] ?? 'not name',
                type: TypePoolExtension.fromString(
                  pools['data'][0]['caracteristiques']['type']?.toString() ??
                      'coque',
                ),
                /* pools['data'][0]['caracteristiques']['type'] ?? */
                //TypePool.beton,
                dimension: Dimension(
                  length: parseDouble(
                    pools['data'][0]['caracteristiques']['longueur'],
                  ),
                  width: parseDouble(
                    pools['data'][0]['caracteristiques']['largeur'],
                  ),
                  depth: parseDouble(
                    pools['data'][0]['caracteristiques']['profondeur'],
                  ),
                ),
                location: Location(
                  latitude: parseDouble(
                    pools['data'][0]['localisation']['latitude'],
                  ),
                  longitude: parseDouble(
                    pools['data'][0]['localisation']['longitude'],
                  ),
                ),
                photoPool: PhotoPool(
                  photoBassin:
                      pools['data'][0]['photos']?[0]?['url'] ??
                      'assets/piscine.png',
                  photoEnvironnement:
                      pools['data'][0]['photos']?[0]?['full'] ?? '',
                  photoLocalTechn:
                      pools['data'][0]['photos']?[0]?['thumbnail'] ?? '',
                ),
              );
              setState(() {
                checkPool = pool;
                loading = false;
              });
              _loadPlanningForCurrentPool();
            })
            .catchError((error) {
              if (error is ApiException && error.statusCode == 401) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Session expirée. Veuillez vous reconnecter.',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                TokenStorage.clearToken().then((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Une erreur est survenue. $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            });
      });
    }

    /* .whenComplete(() {
          setState(() {
            loading = false;
          });
        }); */

    //checkPool = widget.pool ?? ;
    weatherFuture = getWeather(
      checkPool!.location.latitude,
      checkPool!.location.longitude,
    );

    timer = Timer.periodic(Duration(seconds: 30), (timer) {
      setState(() {
        weatherFuture = getWeather(
          checkPool!.location.latitude,
          checkPool!.location.longitude,
        );
      });
    });
  }

  /* Pool pool = Pool(
    id: '1',
    name: 'Ma Piscine',
    type: TypePool.coque,
    dimension: Dimension(length: 8, width: 4, depth: 1.5),
    description: 'Piscine familiale dans le jardin',
  ); */

  List<String> pools = [];

  Map<String, dynamic> traitement = {'product': 'Chlore', 'percent': 0.7};
  double temperature = 29;
  List temps = ['Ensoleillé', 'Vent faible'];

  Future<void> _loadPlanningForCurrentPool() async {
    setState(() {
      _planningLoading = true;
      _planningError = null;
    });

    try {
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      }

      final poolId = int.tryParse((checkPool?.id ?? '').toString());
      final response = await _planningService.getAllPlanning(
        token,
        poolId: poolId,
      );

      final data = response['data'];
      final List<_DashboardPlanningItem> fetched = [];
      if (data is List) {
        for (final item in data) {
          final parsed = _DashboardPlanningItem.fromApi(item);
          if (parsed != null) fetched.add(parsed);
        }
      }

      fetched.sort((a, b) {
        if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
        return a.startTime.compareTo(b.startTime);
      });

      if (!mounted) return;
      setState(() {
        _planningItems
          ..clear()
          ..addAll(fetched);
        _planningLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _planningLoading = false;
        _planningError = e.toString();
      });
    }
  }

  Future<void> _togglePlanningDone(_DashboardPlanningItem item) async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expirée. Reconnectez-vous.')),
      );
      return;
    }

    if (_planningUpdatingIds.contains(item.id)) return;
    setState(() => _planningUpdatingIds.add(item.id));

    try {
      final response = await _planningService.updatePlanning(
        token,
        int.parse(item.id),
        isDone: !item.isDone,
      );
      final updated = _DashboardPlanningItem.fromApi(response['data']);

      if (!mounted) return;
      setState(() {
        final index = _planningItems.indexWhere((it) => it.id == item.id);
        if (index >= 0) {
          _planningItems[index] =
              updated ?? item.copyWith(isDone: !item.isDone);
          _planningItems.sort((a, b) {
            if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
            return a.startTime.compareTo(b.startTime);
          });
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Mise à jour impossible: $e')));
    } finally {
      if (mounted) {
        setState(() => _planningUpdatingIds.remove(item.id));
      }
    }
  }

  Future<void> _openPlanningScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlanningEntretienScreen()),
    );
    if (!mounted) return;
    _loadPlanningForCurrentPool();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: const Color(0xFF050505), // couleur de la barre de notif
        statusBarIconBrightness: Brightness.light, // icônes visibles
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF050505),
        appBar: AppBar(
          backgroundColor: const Color(0xFF090909),
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/logo.png", height: 32),
              SizedBox(width: 8),
              Text(
                "Sunny",
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          iconTheme: IconThemeData(color: Colors.amber),
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
        drawer: Drawer(
          backgroundColor: const Color(0xFF111111),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(height: 40),
              Image.asset("assets/logo.png", height: 150),
              _buildMenuItem(Icons.pool, "Mes piscines", MypiscineScreen()),
              _buildMenuItem(
                Icons.science,
                "Analyse de l'eau",
                AnalyseScreen(),
              ),
              _buildMenuItem(
                Icons.camera_alt,
                "Diagnostic photo",
                PhotosScreen(),
              ),
              _buildMenuItem(
                Icons.history,
                "Historique des analyses",
                HistoriqueAnalyses(),
              ),
              _buildMenuItem(Icons.chat, "Parler à Sunny", ChatSunnyScreen()),
              _buildMenuItem(Icons.inventory, "Mes produits", ProductScreen()),
              _buildMenuItem(
                Icons.calendar_today,
                "Planning d'entretien",
                PlanningEntretienScreen(),
              ),
              _buildMenuItem(Icons.school, "Tutoriels", TutoralsScreen()),
            ],
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
          child: loading
              ? SkeletonLoading()
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 16,
                      children: [
                        Container(
                          width: double.infinity,
                          //margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                          // height: 150,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(
                                checkPool?.photoPool?.photoBassin ??
                                    'assets/piscine.png',
                              ),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.1),
                                BlendMode.darken,
                              ),
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => InformationPiscineScreen(
                                    pool: checkPool,
                                    traitementChecked: [traitement['product']],
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              alignment: Alignment.centerLeft,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 16,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      checkPool?.name ?? "Nom de la piscine",
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                          255,
                                          255,
                                          255,
                                          255,
                                        ),
                                        fontSize: screenWidth * 0.08,
                                        // fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${checkPool?.volume} m³",
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                          255,
                                          255,
                                          255,
                                          255,
                                        ),
                                        fontSize: screenWidth * 0.07,
                                        // fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                                /* Container(
                        child: */
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Traitement: ${traitement['product']}",
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                          255,
                                          255,
                                          255,
                                          255,
                                        ),
                                      ),
                                    ),
                                    LinearProgressIndicator(
                                      value: traitement['percent'],
                                      backgroundColor: Colors.white24,
                                      color: Colors.amber,
                                      minHeight: 8,
                                    ),
                                  ],
                                ),
                                // ),
                              ],
                            ),
                          ),
                        ),

                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.15),
                            ),
                          ),
                          padding: EdgeInsets.all(16),
                          // margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                spacing: 10,
                                children: [
                                  Icon(
                                    Icons.wb_sunny,
                                    color: Colors.amber,
                                    size: screenHeight * 0.05,
                                  ),
                                  FutureBuilder(
                                    future: weatherFuture,
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return CircularProgressIndicator();
                                      }

                                      final weather =
                                          snapshot.data!['current_weather'];

                                      return Text(
                                        '${weather['temperature']}°C',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: screenWidth * 0.07,
                                          // fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                spacing: 10,
                                children: [
                                  Text(
                                    temps[0],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.03,
                                    ),
                                  ),
                                  Text(
                                    ".",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.03,
                                    ),
                                  ),
                                  Text(
                                    temps[1],
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                        255,
                                        153,
                                        153,
                                        153,
                                      ),
                                      fontSize: screenWidth * 0.03,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          spacing: 16,
                          children: [
                            _buildContainerRow(
                              Icons.science,
                              "Analyse de l'eau",
                              AnalyseScreen(),
                            ),
                            _buildContainerRow(
                              Icons.photo,
                              "Photo piscine",
                              PhotosScreen(),
                            ),
                          ],
                        ),
                        Row(
                          spacing: 16,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildContainerRow(
                              Icons.message,
                              "Parler à Sunny",
                              ChatSunnyScreen(),
                            ),
                            _buildContainerRow(
                              Icons.add,
                              "Ajouter produit",
                              AddProduct(),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.15),
                            ),
                          ),
                          height: 350,
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          // margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Planning d\'entretien',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: _openPlanningScreen,
                                    icon: const Icon(
                                      Icons.open_in_new,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                    label: const Text(
                                      'Voir tout',
                                      style: TextStyle(color: Colors.amber),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                color: Colors.white54,
                                height: screenWidth * 0.05,
                              ),
                              SizedBox(height: 10),
                              Expanded(
                                child: _buildPlanningSectionList(screenWidth),
                              ),
                              if (_planningError != null) ...[
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: _loadPlanningForCurrentPool,
                                  icon: const Icon(
                                    Icons.refresh,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'Réessayer',
                                    style: TextStyle(color: Colors.amber),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        /* pools.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Aucune piscine disponible",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                        ),
                        onPressed: _addPool,
                        child: Text("Ajouter une piscine"),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: pools.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: Colors.grey[900],
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: Icon(Icons.pool, color: Colors.amber),
                          title: Text(
                            pools[index],
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ), */
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildPlanningSectionList(double screenWidth) {
    if (_planningLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_planningItems.isEmpty) {
      return Center(
        child: Text(
          'Aucun planning pour cette piscine.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: screenWidth * 0.032,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _planningItems.length,
      separatorBuilder: (_, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final item = _planningItems[index];
        final isUpdating = _planningUpdatingIds.contains(item.id);
        return CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
            item.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.033,
              decoration: item.isDone ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            '${_planningDateFormat.format(item.startTime)} - ${DateFormat('HH:mm', 'fr_FR').format(item.endTime)}'
            '${item.notes.isEmpty ? '' : '\n${item.notes}'}',
            style: const TextStyle(color: Colors.white70),
          ),
          isThreeLine: item.notes.isNotEmpty,
          value: item.isDone,
          checkColor: Colors.black,
          activeColor: const Color.fromARGB(255, 137, 255, 139),
          onChanged: isUpdating ? null : (_) => _togglePlanningDone(item),
          secondary: isUpdating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  item.isDone
                      ? Icons.check_circle_outline
                      : Icons.radio_button_unchecked,
                  color: item.isDone ? Colors.greenAccent : Colors.amber,
                ),
        );
      },
    );
  }

  Widget _buildMenuItem(IconData icon, String title, [Widget? destination]) {
    return ListTile(
      leading: Icon(icon, color: Colors.amber),
      title: Text(
        title,
        style: TextStyle(color: Colors.white.withOpacity(0.9)),
      ),
      onTap: () {
        Navigator.pop(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  destination ??
                  Scaffold(
                    appBar: AppBar(title: Text(title)),
                    body: Center(child: Text("Page $title en construction")),
                  ),
            ),
          );
        });
      },
    );
  }

  Widget _buildContainerRow(
    IconData icon,
    String title, [
    Widget? destination,
  ]) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Expanded(
      child: Container(
        // padding: EdgeInsets.all(16),
        // margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber.withOpacity(0.15)),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            alignment: Alignment.centerLeft,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    destination ??
                    Scaffold(
                      appBar: AppBar(title: Text(title)),
                      body: Center(child: Text("Page $title en construction")),
                    ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.amber, size: screenWidth * 0.08),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardPlanningItem {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String notes;
  final bool isDone;

  _DashboardPlanningItem({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.notes,
    required this.isDone,
  });

  _DashboardPlanningItem copyWith({
    String? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
    bool? isDone,
  }) {
    return _DashboardPlanningItem(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
      isDone: isDone ?? this.isDone,
    );
  }

  static _DashboardPlanningItem? fromApi(dynamic item) {
    if (item is! Map) return null;
    final rawId = item['id']?.toString();
    if (rawId == null || rawId.isEmpty) return null;

    final title = (item['title'] ?? '').toString().trim();
    final start = _parseDate(item['startTime']) ?? DateTime.now();
    final end =
        _parseDate(item['endTime']) ?? start.add(const Duration(hours: 1));

    return _DashboardPlanningItem(
      id: rawId,
      title: title.isEmpty ? 'Nouvelle tâche' : title,
      startTime: start,
      endTime: end,
      notes: (item['notes'] ?? '').toString().trim(),
      isDone: _parseBool(item['isDone']),
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final v = value.toLowerCase();
      return v == '1' || v == 'true';
    }
    return false;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    final raw = value.toString().trim();
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw.replaceFirst(' ', 'T'));
  }
}
