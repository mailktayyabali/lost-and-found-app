abstract class ChatRepository {
  Future<List<Map<String, dynamic>>> getConversations();
  Future<List<Map<String, dynamic>>> getMessages(String chatPartnerUid);
  Future<void> sendMessage(String chatPartnerUid, String text);
}
