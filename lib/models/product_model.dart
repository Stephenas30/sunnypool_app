import 'dart:io';

enum Categorie{
  chlore_choc,
  chlore_lent,
  ph_plus,
  ph_moins,
  anti_algues,
  clarifiant,
  floculant,
  sequestrant_calcaire,
  sequestrant_metaux
}

extension CategorieExtension on Categorie {
  String get label {
    switch (this) {
      case Categorie.chlore_choc:
        return "Chlore choc";
      case Categorie.chlore_lent:
        return "Chlore lent";
      case Categorie.ph_plus:
        return "pH +";
      case Categorie.ph_moins:
        return "pH -";
      case Categorie.anti_algues:
        return "Anti-algues";
      case Categorie.clarifiant:
        return "Clarifiant";
      case Categorie.floculant:
        return "Floculant";
      case Categorie.sequestrant_calcaire:
        return "Séquestrant calcaire";
      case Categorie.sequestrant_metaux:
        return "Séquestrant métaux";
    }
  }

  static Categorie fromString(String value) {
    final normalizedValue = value.trim().toLowerCase();

    /* for (final categorie in Categorie.values) {
      if (categorie.name.toLowerCase() == normalizedValue ||
          categorie.label.toLowerCase() == normalizedValue) {
        return categorie;
      }
    } */

    switch (normalizedValue) {
      case 'anti_algues':
        return Categorie.anti_algues;
      case 'chlore_choc':
        return Categorie.chlore_choc;
      case 'chlore_lent':
        return Categorie.chlore_lent;
      case 'ph_plus':
        return Categorie.ph_plus;
      case 'ph_moins':
        return Categorie.ph_moins;
      case 'clarifiant':
        return Categorie.clarifiant;
      case 'floculant':
        return Categorie.floculant;
      case 'sequestrant_calcaire':
        return Categorie.sequestrant_calcaire;
      case 'sequestrant_metaux':
        return Categorie.sequestrant_metaux;
      default:
        throw ArgumentError('Categorie inconnue: $value');
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
  final String? photoFace;
  final String? photoNoticeDosage;
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
