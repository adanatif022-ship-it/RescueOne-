enum ChatSender { assistant, user }

class ChatMessage {
  final ChatSender sender;
  final String text;
  final List<String>? quickOptions;

  const ChatMessage({
    required this.sender,
    required this.text,
    this.quickOptions,
  });
}
