import 'dart:io';

import 'package:sunnypool_app/models/photo_model.dart';

class AnalyseModel {
  final int? pool_id;
  final dynamic analyse;
  final File? photo_bandelette_base64;
  final String? type;
  final List<PhotoModel>? images;
  

  AnalyseModel({
    this.pool_id,
    this.analyse,
    this.photo_bandelette_base64,
    this.type,
    this.images
  });
}