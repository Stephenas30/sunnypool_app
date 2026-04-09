import 'package:flutter/material.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique Sunny'),
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            children: [
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Rechercher dans les commentaires',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.amber),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.amber),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.amber),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: phEvolution.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => Card(
                    child: ListTile(
                      title: Text(
                        'Analyse ${formatter.format(phEvolution[index].date)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'pH ${phEvolution[index].value} • Chlore ${chloreEvolution[index].value} • TAC ${tacEvolution[index].value}',
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
                    'Nouvelle question à Sunny',
                    style: theme.textTheme.labelLarge?.copyWith(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
                    'Annuler',
                    style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
