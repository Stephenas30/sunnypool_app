import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
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
  const HistoriqueAnalyses({Key? key}) : super(key: key);

  @override
  State<HistoriqueAnalyses> createState() {
    return _HistoriqueAnalysesState();
  }
}

class _HistoriqueAnalysesState extends State<HistoriqueAnalyses> {
  /* List<EvolutionData> phEvolution = [
    EvolutionData(date: DateTime(2026, 1, 1), value: 7.2),
    EvolutionData(date: DateTime(2026, 1, 15), value: 7.5),
    EvolutionData(date: DateTime(2026, 2, 1), value: 7.8),
    EvolutionData(date: DateTime(2026, 2, 15), value: 8.0),
    EvolutionData(date: DateTime(2026, 3, 1), value: 7.9),
  ];

  List<EvolutionData> chloreEvolution = [
    EvolutionData(date: DateTime(2026, 1, 1), value: 4.2),
    EvolutionData(date: DateTime(2026, 1, 15), value: 5.5),
    EvolutionData(date: DateTime(2026, 2, 1), value: 9.2),
    EvolutionData(date: DateTime(2026, 2, 15), value: 8.0),
    EvolutionData(date: DateTime(2026, 3, 1), value: 6.9),
  ];

  List<EvolutionData> tacEvolution = [
    EvolutionData(date: DateTime(2026, 1, 1), value: 3.2),
    EvolutionData(date: DateTime(2026, 1, 15), value: 8.5),
    EvolutionData(date: DateTime(2026, 2, 1), value: 4.2),
    EvolutionData(date: DateTime(2026, 2, 15), value: 5.0),
    EvolutionData(date: DateTime(2026, 3, 1), value: 6.9),
  ];

  List<EvolutionData> stabilisantEvolution = [
    EvolutionData(date: DateTime(2026, 1, 1), value: 5.2),
    EvolutionData(date: DateTime(2026, 1, 15), value: 4.5),
    EvolutionData(date: DateTime(2026, 2, 1), value: 7.2),
    EvolutionData(date: DateTime(2026, 2, 15), value: 8.0),
    EvolutionData(date: DateTime(2026, 3, 1), value: 5.9),
  ]; */

  List<Map<String, dynamic>> analyses = [];

  void _loadAnalyses() async {
    var token = await TokenStorage.getToken();
    var poolId = await PoolIdStorage.getPoolId();
    await AnalyseService().getAllAnalyse(token!, int.tryParse(poolId!)!).then((data) {
      print(data);
      setState(() {
        analyses = List<Map<String, dynamic>>.from(data['data'] ?? []);
      });
    }).catchError((error) {
      print("Erreur lors du chargement des analyses : $error");
    });
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
          child: Column(
            children: [
              _buildChart(),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Historique des analyses',
                    style: theme.textTheme.titleLarge?.copyWith(color: Colors.amber),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: analyses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => Card(
                    child: ListTile(
                      title: Text(
                        'Analyse ${/* formatter.format( */analyses[index]['updated_at']/* ) */}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'pH ${analyses[index]['analyse']['ph']} • Chlore ${analyses[index]['analyse']['chlore']} • TAC ${analyses[index]['analyse']['tac']} • Stabilisants ${analyses[index]['analyse']['stabilisant'] }',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: const Icon(Icons.search, color: Colors.amber),
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
                  onPressed: () {},
                  child: Text(
                    'Nouvelle analyse',
                    style: theme.textTheme.labelLarge?.copyWith(color: Colors.black),
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
            style: TextStyle(fontSize: 18, color: Colors.amber, fontWeight: FontWeight.bold),
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

                        final date = DateTime.parse(analyses[index]['updated_at']);
                        final day = date.day.toString().padLeft(2, '0');
                        final month = date.month.toString().padLeft(2, '0');
                        return Text('$day/$month', style: const TextStyle(color: Colors.white70, fontSize: 11));
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
                    spots: List.generate(
                      analyses.length,
                      (index) => FlSpot(
                        index.toDouble(),
                        double.parse(analyses[index]['analyse']['chlore'].toString()),
                      ),
                    ),
                    barWidth: 4,
                    dotData: FlDotData(show: true),
                    color: Colors.amber,
                  ),
                  LineChartBarData(
                    isCurved: true,
                    spots: List.generate(
                      analyses.length,
                      (index) =>
                          FlSpot(index.toDouble(), double.parse(analyses[index]['analyse']['tac'].toString()) ),
                    ),
                    barWidth: 4,
                    dotData: FlDotData(show: true),
                    color: Colors.green,
                  ),
                  LineChartBarData(
                    isCurved: true,
                    spots: List.generate(
                      analyses.length,
                      (index) => FlSpot(
                        index.toDouble(),
                        double.parse(analyses[index]['analyse']['stabilisant'].toString()),
                      ),
                    ),
                    barWidth: 4,
                    dotData: FlDotData(show: true),
                    color: Colors.blue,
                  ),
                  LineChartBarData(
                    isCurved: true,
                    spots: List.generate(
                      analyses.length,
                      (index) =>
                          FlSpot(index.toDouble(), double.parse(analyses[index]['analyse']['ph'].toString())),
                    ),
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
