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

class ProductModel {
  final String categorie;
  final String marque;
  final String name;
  final String? photoFace;
  final String? photoNoticeDosage;
  final String? commentaire;

  ProductModel({
    required this.categorie,
    required this.marque,
    required this.name,
    this.photoFace,
    this.commentaire,
    this.photoNoticeDosage
  });
}
