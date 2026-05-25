abstract class ChatRepository {
  Future<List<Map<String, dynamic>>> getConversations();
  Future<List<Map<String, dynamic>>> getMessages(String chatPartnerName);
  Future<void> sendMessage(String chatPartnerName, String text);
}
