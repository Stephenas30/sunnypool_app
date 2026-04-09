class HistoriqueAnalyseModel {
  final DateTime date;
  final String parametres;
  final String? photo;

  HistoriqueAnalyseModel({
    required this.date,
    required this.parametres,
    this.photo
  });
}
