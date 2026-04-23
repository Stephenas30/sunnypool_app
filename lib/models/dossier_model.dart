class DossierModel {
  final String id;
  final String name;

  DossierModel({required this.id, required this.name});

  set name(String newName) {
    // Logique pour renommer le dossier
    name = newName;
  }
}