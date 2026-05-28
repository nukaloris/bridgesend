class MessageModel {
  final String id;
  final String text;
  final bool isSent;
  final DateTime timestamp;
  final dynamic attachedFile;

  MessageModel({
    required this.id,
    required this.text,
    required this.isSent,
    required this.timestamp,
    this.attachedFile,
  });

  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
