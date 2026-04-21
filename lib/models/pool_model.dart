import 'package:sunnypool_app/models/user_model.dart';

enum Pompe { standard, variable }

enum TypeFiltre { sable, verre, cartouche, diatomee }

enum BondeFond { verticale, horizontale, non }

enum TypePool { coque, beton, liner, membrane, horsSol, enterree }

extension TypePoolExtension on TypePool {
  String get label {
    switch (this) {
      case TypePool.coque:
        return "Coque";
      case TypePool.beton:
        return "Béton";
      case TypePool.liner:
        return "Liner";
      case TypePool.membrane:
        return "Membrane";
      case TypePool.horsSol:
        return "Hors-sol";
      case TypePool.enterree:
        return "Enterrée";
      default:
        return this.toString().split('.').last;
    }
  }

  static TypePool fromString(String value) {
    final normalizedValue = value.trim().toLowerCase();

    /* for (final categorie in Categorie.values) {
      if (categorie.name.toLowerCase() == normalizedValue ||
          categorie.label.toLowerCase() == normalizedValue) {
        return categorie;
      }
    } */

    switch (normalizedValue) {
      case 'coque':
        return TypePool.coque;
      case 'beton':
        return TypePool.beton;
      case 'liner':
        return TypePool.liner;
      case 'membrane':
        return TypePool.membrane;
      case 'hors_sol':
        return TypePool.horsSol;
      case 'enterree':
        return TypePool.enterree;
      default:
        throw ArgumentError('TypePool inconnu: $value');
    }
  }
}

enum Traitement { chlore, brome, sel, uv }

enum Equipement { pac, robot, spotsLed, volet, bache }

enum Automation { regulationPh, regulationChlore, automatePiscine, domotique }

class Dimension {
  final double length;
  final double width;
  final double depth;

  Dimension({required this.length, required this.width, required this.depth});
}

class Hydraulique {
  final int skimmers;
  final int refoulement;
  final bool priseBalai;
  final BondeFond bondeFond;

  Hydraulique({
    required this.skimmers,
    required this.refoulement,
    required this.priseBalai,
    required this.bondeFond,
  });
}

class Filtration {
  final Pompe pompe;
  final double puissance;
  final TypeFiltre type;

  Filtration({
    required this.pompe,
    required this.puissance,
    required this.type,
  });
}

class PhotoPool {
  final String photoBassin;
  final String photoEnvironnement;
  final String photoLocalTechn;

  PhotoPool({
    required this.photoBassin,
    required this.photoEnvironnement,
    required this.photoLocalTechn,
  });
}

class Pool {
  final String? id;
  final String name;
  final TypePool type;
  final Dimension dimension;
  final String? description;
  final List<Traitement> traitements;
  final Hydraulique? hydraulique;
  final Filtration? filtration;
  final Automation? automation;
  final Equipement? equipement;
  final PhotoPool? photoPool;
  final Location location;

  Pool({
    this.id,
    required this.name,
    required this.type,
    required this.dimension,
    this.description,
    this.traitements = const [],
    this.hydraulique,
    this.automation,
    this.equipement,
    this.filtration,
    this.photoPool,
    required this.location,
  });

  double get volume => dimension.length * dimension.width * dimension.depth;
  String get getPool =>
      '\nNom: $name \nType: $type \nDimension: ${dimension.width} * ${dimension.length} * ${dimension.depth} \nTraitement: $traitements \nHydraulique: Skim - ${hydraulique?.skimmers} \t Refoul - ${hydraulique?.refoulement} \t Prise balai - ${hydraulique?.priseBalai} \tBonde de Fond - ${hydraulique?.bondeFond} \nFiltration: Pompe - ${filtration?.pompe} \tPuissance - ${filtration?.puissance} \tType - ${filtration?.type} \nPhoto: Bassin - ${photoPool?.photoBassin} \tEnv - ${photoPool?.photoEnvironnement} \tLocal - ${photoPool?.photoLocalTechn} \nLocation: lat - ${location.latitude} \tlong - ${location.longitude}';
}
