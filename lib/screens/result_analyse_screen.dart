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
  const ResultAnalyseScreen({Key? key}) : super(key: key);

  @override
  State<ResultAnalyseScreen> createState() {
    // TODO: implement createState
    return _ResultAnalyseScreenState();
  }
}

class _ResultAnalyseScreenState extends State<ResultAnalyseScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    String alert = 'Eau à corriger !';
    List<AnalyseResult> result = [
      AnalyseResult(
        remark: 'pH trop haut',
        hint: 8.0,
        message: 'Ajouter 200 g de pH-',
      ),
      AnalyseResult(
        remark: 'Chlores trop bas',
        hint: 0.5,
        unit: 'ppm',
        message: 'Ajouter 50g de chlore choc.',
      ),
    ];
    List<String>? advices = [
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
            padding: EdgeInsetsGeometry.symmetric(horizontal: 12),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                margin: EdgeInsets.only(left: 8, top: 20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.85),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Text(
                  alert,
                  style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
                  textAlign: TextAlign.start,
                ),
              ),
              ConstrainedBox(
                
                constraints: BoxConstraints(
                  minHeight: screenHeight / 5,
                  minWidth: screenWidth / 5,
                  maxWidth: screenWidth / 1.2,
                  maxHeight: screenHeight / 3,
                ),
                child: GridView.count(
                  crossAxisCount: 2,
                  children: [
                    ...result.map((r) => _buildCardContainer(r)).toList(),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 20,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      border: Border.all(color: Colors.amber.withOpacity(0.22)),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12,
                      children: [
                        Text(
                          'Voc à vos mesures :',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: screenWidth * 0.05, color: Colors.amber),
                        ),
                        advices.isEmpty
                            ? Text(
                                'Aucun conseil à donner pour le moment',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: screenWidth * 0.03),
                              )
                            : Column(
                                spacing: 8,
                                children: [
                                  ...advices
                                      .map(
                                        (advice) => Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              advice,
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.03,
                                                color: Colors.white70,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      )
                                      .toList(),
                                ],
                              ),
                      ],
                    ),
                  ),
                  Column(
                    spacing: 8,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                        onPressed: () {},
                        child: Text(
                          'Parler à Sunny',
                          style: theme.textTheme.labelLarge?.copyWith(color: Colors.black),
                        ),
                      ),
                      ),
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
                          'Enregistrer cette analyse',
                          style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                        ),
                      ),
                      ),
                    ],
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

  Widget _buildCardContainer(AnalyseResult result) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Text(
              result.remark,
              style: TextStyle(fontSize: screenWidth * 0.05),
            ),
          ),
          Column(
            children: [
              Text(
                '${result.hint} ${result.unit ?? ''}',
                style: TextStyle(fontSize: screenWidth * 0.08),
              ),
              Text(
                result.message,
                style: TextStyle(fontSize: screenWidth * 0.03),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
