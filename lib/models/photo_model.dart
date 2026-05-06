import 'dart:io';

class PhotoModel {
  final String title;
  final String? imageType;
  final File file;

  const PhotoModel({
    required this.title,
    this.imageType,
    required this.file
  });

}
