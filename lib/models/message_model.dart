class MessageModel {
  final String message;
  final String? image;
  final dynamic data_options;
  final DateTime? timestamp;

  MessageModel({
    required this.message,
    this.image,
    this.data_options,
    this.timestamp,
  });
}
