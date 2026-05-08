import 'package:flutter/material.dart';
import 'package:sunnypool_app/screens/profile_screen.dart';

class AnalyseResult {
  final String remark;
  final double hint;
  final String message;
  final String? unit;

  AnalyseResult({
    required this.remark,
    required this.hint,
    required this.message,
    this.unit,
  });
}

class ResultAnalyseScreen extends StatefulWidget {
  const ResultAnalyseScreen({super.key});

  @override
  State<ResultAnalyseScreen> createState() {
    return _ResultAnalyseScreenState();
  }
}

class _ResultAnalyseScreenState extends State<ResultAnalyseScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    const alert = 'Eau à corriger !';
    final result = <AnalyseResult>[
      AnalyseResult(
        remark: 'pH trop haut',
        hint: 8.0,
        message: 'Ajouter 200 g de pH-',
      ),
      AnalyseResult(
        remark: 'Chlore trop bas',
        hint: 0.5,
        unit: 'ppm',
        message: 'Ajouter 50 g de chlore choc.',
      ),
    ];

    final advices = <String>[
      'Augmenter le temps de filtration à 10h par jour',
      'Brossez les parois et le fond de la piscine',
      'Refaites un test dans 24h pour vérifier l\'équilibre',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat d\'analyse d\'eau'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundImage: AssetImage('assets/icon.png'),
              radius: 16,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.85),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      child: Text(
                        alert,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: screenWidth < 430 ? 1 : 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: screenWidth < 430 ? 2.4 : 1.35,
                      children: [...result.map((r) => _buildCardContainer(r))],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.22),
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 14,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vos conseils :',
                            style: TextStyle(
                              fontSize: (screenWidth * 0.05).clamp(17.0, 22.0),
                              color: Colors.amber,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (advices.isEmpty)
                            Text(
                              'Aucun conseil à donner pour le moment',
                              style: TextStyle(
                                fontSize: (screenWidth * 0.034).clamp(
                                  12.0,
                                  16.0,
                                ),
                                color: Colors.white70,
                              ),
                            )
                          else
                            ...advices.map(
                              (advice) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '• ',
                                      style: TextStyle(color: Colors.amber),
                                    ),
                                    Expanded(
                                      child: Text(
                                        advice,
                                        style: TextStyle(
                                          fontSize: (screenWidth * 0.034).clamp(
                                            12.0,
                                            16.0,
                                          ),
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Text(
                          'Parler à Sunny',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
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
                          'Enregistrer cette analyse',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContainer(AnalyseResult result) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: const BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Text(
              result.remark,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: (screenWidth * 0.042).clamp(13.0, 18.0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${result.hint} ${result.unit ?? ''}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: (screenWidth * 0.06).clamp(20.0, 28.0),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  result.message,
                  style: TextStyle(
                    fontSize: (screenWidth * 0.034).clamp(12.0, 15.0),
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
