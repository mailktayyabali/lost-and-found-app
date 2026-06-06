abstract class ChatRepository {
  Future<List<Map<String, dynamic>>> getConversations();
  Future<List<Map<String, dynamic>>> getMessages(String chatPartnerUid);
  Stream<List<Map<String, dynamic>>> getMessagesStream(String chatPartnerUid);
  Future<void> sendMessage(
    String chatPartnerUid,
    String text, {
    String? itemId,
    String? itemTitle,
    String? itemImageUrl,
  });
}
