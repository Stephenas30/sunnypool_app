class MessageModel {
  final String message;
  final String? image;
  final DateTime? timestamp;

  MessageModel({
    required this.message,
    this.image,
    this.timestamp,
  });
}
