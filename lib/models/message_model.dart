class MessageModel {
  final String message;
  final String? image_base64;
  final DateTime? timestamp;

  MessageModel({
    required this.message,
    this.image_base64,
    this.timestamp,
  });
}
