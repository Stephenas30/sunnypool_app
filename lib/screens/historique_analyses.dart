import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:sunnypool_app/screens/analyse_screen.dart';
import 'package:sunnypool_app/services/analyse_service.dart';
import 'package:sunnypool_app/utils/poolId_storage.dart';
import 'package:sunnypool_app/utils/token_storage.dart';

final formatter = DateFormat('d MMM');

class EvolutionData {
  final DateTime date;
  final double value;

  EvolutionData({required this.date, required this.value});
}

class HistoriqueAnalyses extends StatefulWidget {
  const HistoriqueAnalyses({super.key});

  @override
  State<HistoriqueAnalyses> createState() {
    return _HistoriqueAnalysesState();
  }
}

class _HistoriqueAnalysesState extends State<HistoriqueAnalyses> {
  List<Map<String, dynamic>> analyses = [];
  bool isLoading = true;
  String? _errorMessage;

  void _loadAnalyses() async {
    var token = await TokenStorage.getToken();
    var poolId = await PoolIdStorage.getPoolId();

    if (token == null || token.isEmpty || poolId == null || poolId.isEmpty) {
      setState(() {
        _errorMessage = 'Session invalide. Reconnectez-vous puis réessayez.';
        isLoading = false;
      });
      return;
    }

    final parsedPoolId = int.tryParse(poolId);
    if (parsedPoolId == null) {
      setState(() {
        _errorMessage = 'Identifiant de piscine invalide.';
        isLoading = false;
      });
      return;
    }

    await AnalyseService()
        .getAllAnalyse(token, parsedPoolId)
        .then((data) {
          print(data);
          setState(() {
            analyses = List<Map<String, dynamic>>.from(data['data'] ?? []);
          });
        })
        .catchError((error) {
          setState(() {
            _errorMessage = 'Erreur lors du chargement des analyses : $error';
          });
          //print("Erreur lors du chargement des analyses : $error");
        })
        .whenComplete(() {
          setState(() {
            isLoading = false;
          });
        });
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final cleaned = value.trim().replaceAll(',', '.');
      if (cleaned.isEmpty || cleaned.toLowerCase() == 'null') return null;
      return double.tryParse(cleaned);
    }
    return null;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    final raw = value.toString().trim();
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw.replaceFirst(' ', 'T'));
  }

  String _formatMetric(dynamic value) {
    final v = _toDouble(value);
    return v == null ? '-' : v.toString();
  }

  List<FlSpot> _spotsForMetric(String key) {
    final spots = <FlSpot>[];
    for (var i = 0; i < analyses.length; i++) {
      final analyse = analyses[i]['analyse'];
      if (analyse is! Map) continue;
      final y = _toDouble(analyse[key]);
      if (y == null) continue;
      spots.add(FlSpot(i.toDouble(), y));
    }
    return spots;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadAnalyses();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des analyses'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: isLoading
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
                    ],
                  ),
                )
              : Column(
                  children: [
                    _buildChart(),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Historique des analyses',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.separated(
                        itemCount: analyses.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) => Card(
                          child: ListTile(
                            title: Text(
                              'Analyse ${ /* formatter.format( */ analyses[index]['updated_at'] /* ) */}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'pH ${_formatMetric(analyses[index]['analyse']?['ph'])} • Chlore ${_formatMetric(analyses[index]['analyse']?['chlore'])} • TAC ${_formatMetric(analyses[index]['analyse']?['tac'])} • Stabilisants ${_formatMetric(analyses[index]['analyse']?['stabilisant'])}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: const Icon(
                              Icons.search,
                              color: Colors.amber,
                            ),
                            onTap: () {},
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => AnalyseScreen()),
                  );
                        },
                        child: Text(
                          'Nouvelle analyse',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.only(top: 16, right: 20, bottom: 8, left: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: Border.all(color: Colors.amber.withOpacity(0.25)),
      ),
      child: Column(
        spacing: 12,
        children: [
          const Text(
            'Évolution de la qualité de l\'eau',
            style: TextStyle(
              fontSize: 18,
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                backgroundColor: Colors.transparent,
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.round();

                        if (index < 0 || index >= analyses.length) {
                          return const SizedBox();
                        }

                        final date =
                            _parseDate(analyses[index]['updated_at']) ??
                            DateTime.now();
                        final day = date.day.toString().padLeft(2, '0');
                        final month = date.month.toString().padLeft(2, '0');
                        return Text(
                          '$day/$month',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                /* minX: 0,
                maxX: (analyses.length - 1).toDouble(),
                minY:
                    analyses
                        .map((p) => p['analyse']['ph'])
                        .reduce((a, b) => a < b ? a : b) -
                    5,
                maxY:
                    analyses
                        .map((p) => p['analyse']['ph'])
                        .reduce((a, b) => a > b ? a : b) +
                    5, */
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    spots: _spotsForMetric('chlore'),
                    barWidth: 4,
                    dotData: FlDotData(show: true),
                    color: Colors.amber,
                  ),
                  LineChartBarData(
                    isCurved: true,
                    spots: _spotsForMetric('tac'),
                    barWidth: 4,
                    dotData: FlDotData(show: true),
                    color: Colors.green,
                  ),
                  LineChartBarData(
                    isCurved: true,
                    spots: _spotsForMetric('stabilisant'),
                    barWidth: 4,
                    dotData: FlDotData(show: true),
                    color: Colors.blue,
                  ),
                  LineChartBarData(
                    isCurved: true,
                    spots: _spotsForMetric('ph'),
                    barWidth: 4,
                    dotData: FlDotData(show: true),
                    color: Colors.deepOrangeAccent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
