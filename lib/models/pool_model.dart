class Dimension {
  final double length;
  final double width;
  final double depth;

  Dimension({required this.length, required this.width, required this.depth});
}

enum TypePool {
  coque,
  beton,
  liner,
  membrane,
  horsSol,
}

enum Traitement {
  chlore,
  brome,
  sel,
  uv,
}

class Pool {
  final String id;
  final String name;
  final TypePool type;
  final Dimension dimension;
  final String? description;
  final List<Traitement> traitements;

  Pool({
    required this.id,
    required this.name,
    required this.type,
    required this.dimension,
    this.description,
    this.traitements = const [],
  });

  double get volume => dimension.length * dimension.width * dimension.depth;
}