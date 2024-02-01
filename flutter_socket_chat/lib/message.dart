class Message {
  final String senderId;
  final String text;

  Message({required this.senderId, required this.text});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderId: json['senderId'],
      text: json['text'],
    );
  }
}
