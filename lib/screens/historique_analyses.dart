import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

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
  List<EvolutionData> phEvolution = [
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
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historique des analyses',
          style: TextStyle(color: Colors.yellow),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.yellow),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildChart(),
              Column(
                spacing: 8,
                children: [
                  Text(
                    'Historique des analyses',
                    style: TextStyle(fontSize: screenWidth * 0.05),
                  ),
                  ...List.generate(
                    phEvolution.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                      padding: EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        border: Border.all(color: Colors.white),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Analyse ${phEvolution[index].date.toString()}',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                    ),
                                  ),
                                  Text(
                                    'ph ${phEvolution[index].value} . chlore ${chloreEvolution[index].value} . TAC ${tacEvolution[index].value}',
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.search,
                                size: screenWidth * 0.05,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      'Nouvelle analyse',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.03,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1,
                        vertical: screenHeight * 0.01,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.only(top: 16, right: 20, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        spacing: 12,
        children: [
          Text('Evolution de la qualité de l\'eau', style: TextStyle(fontSize: screenWidth * 0.05),),
          SizedBox(
            width: double.infinity,
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
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

                        if (index < 0 || index >= phEvolution.length) {
                          return const SizedBox();
                        }

                        final date = phEvolution[index].date;
                        final day = date.day.toString().padLeft(2, '0');
                        final month = date.month.toString().padLeft(2, '0');
                        return Text('$day $month');
                      },
                    ),
                  ),
                ),
                minX: 0,
                maxX: (phEvolution.length - 1).toDouble(),
                minY:
                    phEvolution
                        .map((p) => p.value)
                        .reduce((a, b) => a < b ? a : b) -
                    5,
                maxY:
                    phEvolution
                        .map((p) => p.value)
                        .reduce((a, b) => a > b ? a : b) +
                    5,
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    spots: List.generate(
                      chloreEvolution.length,
                      (index) => FlSpot(
                        index.toDouble(),
                        chloreEvolution[index].value,
                      ),
                    ),
                    barWidth: 4,
                    dotData: FlDotData(show: true),
                  ),
                  LineChartBarData(
                    isCurved: true,
                    spots: List.generate(
                      tacEvolution.length,
                      (index) =>
                          FlSpot(index.toDouble(), tacEvolution[index].value),
                    ),
                    barWidth: 4,
                    dotData: FlDotData(show: true),
                    color: Colors.green,
                  ),
                  LineChartBarData(
                    isCurved: true,
                    spots: List.generate(
                      stabilisantEvolution.length,
                      (index) => FlSpot(
                        index.toDouble(),
                        stabilisantEvolution[index].value,
                      ),
                    ),
                    barWidth: 4,
                    dotData: FlDotData(show: true),
                    color: Colors.blue,
                  ),
                  LineChartBarData(
                    isCurved: true,
                    spots: List.generate(
                      phEvolution.length,
                      (index) =>
                          FlSpot(index.toDouble(), phEvolution[index].value),
                    ),
                    barWidth: 4,
                    dotData: FlDotData(show: true),
                    color: Colors.red,
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
