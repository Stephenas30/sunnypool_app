import 'dart:io';

enum Categorie{
  chloreChoc,
  chloreLent,
  phPlus,
  phMoins,
  antiAlgues,
  clarifiant,
  floculant,
  sequestrantCalcaire,
  sequestrantMetaux
}

extension CategorieExtension on Categorie {
  String get label {
    switch (this) {
      case Categorie.chloreChoc:
        return "Chlore choc";
      case Categorie.chloreLent:
        return "Chlore lent";
      case Categorie.phPlus:
        return "pH +";
      case Categorie.phMoins:
        return "pH -";
      case Categorie.antiAlgues:
        return "Anti-algues";
      case Categorie.clarifiant:
        return "Clarifiant";
      case Categorie.floculant:
        return "Floculant";
      case Categorie.sequestrantCalcaire:
        return "Séquestrant calcaire";
      case Categorie.sequestrantMetaux:
        return "Séquestrant métaux";
    }
  }
}

class ProductModel {
  final String? id;
  final Categorie categorie;
  final String marque;
  final String name;
  int quantity;
  final String unit;
  final File? photoFace;
  final File? photoNoticeDosage;
  final String? commentaire;
  final DateTime? dateAjout;
  final DateTime? dateMiseAJour;

  ProductModel({
    this.id,
    required this.categorie,
    required this.marque,
    required this.name,
    required this.quantity,
    required this.unit,
    this.photoFace,
    this.commentaire,
    this.photoNoticeDosage,
    this.dateAjout,
    this.dateMiseAJour,
  });
}
