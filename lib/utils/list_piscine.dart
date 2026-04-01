import 'package:sunnypool_app/models/pool_model.dart';

Pool pool1 = Pool(
  name: "Piscine 1",
  type: TypePool.coque,
  dimension: Dimension(length: 5, width: 3, depth: 1.5),
);

Pool pool2 = Pool(
  name: "Piscine 2",
  type: TypePool.horsSol,
  dimension: Dimension(length: 4, width: 2.5, depth: 1.2),
);

Pool pool3 = Pool(
  name: "Piscine 3",
  type: TypePool.beton,
  dimension: Dimension(length: 6, width: 4, depth: 1.8),
);

List<Pool> listPiscines = [pool1, pool2, pool3];