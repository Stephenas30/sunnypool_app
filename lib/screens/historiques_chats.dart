import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat('d MMM');

class EvolutionData {
  final DateTime date;
  final double value;

  EvolutionData({required this.date, required this.value});
}

class HistoriquesChats extends StatefulWidget {
  const HistoriquesChats({Key? key}) : super(key: key);

  @override
  State<HistoriquesChats> createState() {
    return _HistoriquesChatsState();
  }
}

class _HistoriquesChatsState extends State<HistoriquesChats> {
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
          'Historique Sunny',
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
          padding: EdgeInsetsGeometry.symmetric(horizontal: 12, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Rechercher dans les commentaires'
                ),
              ),
              Column(
                spacing: 8,
                children: [
                  // Text(
                  //   'Historique des analyses',
                  //   style: TextStyle(fontSize: screenWidth * 0.05),
                  // ),
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
                ],
              ),
              Column(children: [
                ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      'Nouvelle question à Sunny',
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
                  ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            99,
                            99,
                            99,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.1,
                            vertical: screenHeight * 0.01,
                          ),
                        ),
                        child: Text(
                          'Annuler',
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ],)
              
            ],
          ),
        ),
      ),
    );
  }
}
