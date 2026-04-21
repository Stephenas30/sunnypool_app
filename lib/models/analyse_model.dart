import 'dart:io';

class AnalyseModel {
  final int? pool_id;
  final dynamic analyse;
  final File? photo_bandelette_base64;
  

  AnalyseModel({
    this.pool_id,
    this.analyse,
    this.photo_bandelette_base64,
  });
}