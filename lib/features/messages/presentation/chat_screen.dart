import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../data/repositories/firebase_chat_repository.dart';

class ChatScreen extends StatefulWidget {
  final String userName;
  final String partnerUid;
  final String avatarUrl;
  final bool isOnline;
  final String? itemId;
  final String? itemTitle;
  final String? itemImageUrl;

  const ChatScreen({
    super.key,
    required this.userName,
    required this.partnerUid,
    required this.avatarUrl,
    this.isOnline = true,
    this.itemId,
    this.itemTitle,
    this.itemImageUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseChatRepository _chatRepository = FirebaseChatRepository();
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  StreamSubscription? _messagesSub;

  String? _itemId;
  String? _itemTitle;
  String? _itemImageUrl;

  @override
  void initState() {
    super.initState();
    _itemId = widget.itemId;
    _itemTitle = widget.itemTitle;
    _itemImageUrl = widget.itemImageUrl;
    _loadChatRoomMetadata();
    _subscribeMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messagesSub?.cancel();
    super.dispose();
  }

  Future<void> _loadChatRoomMetadata() async {
    if (_itemTitle == null) {
      final chatDoc = await _chatRepository.getChatRoomByPartnerUid(widget.partnerUid);
      if (chatDoc != null && chatDoc.exists) {
        final data = chatDoc.data() as Map<String, dynamic>?;
        if (mounted) {
          setState(() {
            _itemId = data?['relatedItemId'];
            _itemTitle = data?['relatedItemTitle'];
            _itemImageUrl = data?['relatedItemImageUrl'];
          });
        }
      }
    }
  }

  void _subscribeMessages() {
    _messagesSub = _chatRepository.getMessagesStream(widget.partnerUid).listen((list) {
      if (mounted) {
        setState(() {
          _messages = list;
          _isLoading = false;
        });
      }
    }, onError: (err) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  Future<void> _handleSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    await _chatRepository.sendMessage(
      widget.partnerUid,
      text,
      itemId: _itemId,
      itemTitle: _itemTitle,
      itemImageUrl: _itemImageUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: AppBar(
          backgroundColor: context.colors.surfaceWhite,
          elevation: 0,
          leadingWidth: 40,
          leading: IconButton(
            padding: const EdgeInsets.only(left: 16),
            icon: Icon(Icons.arrow_back_ios_new, color: context.colors.textDark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: widget.avatarUrl.isNotEmpty
                    ? NetworkImage(widget.avatarUrl)
                    : null,
                backgroundColor: context.colors.primaryTeal.withValues(alpha: 0.1),
                child: widget.avatarUrl.isEmpty
                    ? Text(
                        widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.userName,
                    style: TextStyle(
                      color: context.colors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.isOnline)
                    const Text(
                      'Online',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.more_vert, color: context.colors.textDark),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Post reference banner
          if (_itemTitle != null && _itemTitle!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.colors.background,
                border: Border(
                  top: BorderSide(color: context.colors.dividerColor),
                  bottom: BorderSide(color: context.colors.dividerColor),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.colors.surfaceWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: context.colors.dividerColor),
                      image: DecorationImage(
                        image: NetworkImage(_itemImageUrl ?? 'https://images.unsplash.com/photo-1627123424574-724758594e9f?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'REGARDING LISTING',
                          style: TextStyle(
                            color: AppColors.primaryTeal,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _itemTitle!,
                          style: TextStyle(
                            color: context.colors.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.info, color: AppColors.primaryTeal, size: 20),
                ],
              ),
            ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    itemCount: _messages.length + 1, // +1 for the today separator
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: context.colors.dividerColor.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'TODAY',
                              style: TextStyle(
                                color: context.colors.textLight,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        );
                      }
                      
                      final msg = _messages[index - 1];
                      final isMe = msg['isMe'] ?? false;
                      
                      if (isMe) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                           child: _buildOutgoingMessage(
                            context,
                            text: msg['text'] ?? '',
                            time: msg['time'] ?? 'Just now',
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: _buildIncomingMessage(
                            context,
                            text: msg['text'] ?? '',
                            time: msg['time'] ?? 'Just now',
                            avatarUrl: widget.avatarUrl,
                          ),
                        );
                      }
                    },
                  ),
          ),
          
          // Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: context.colors.surfaceWhite,
              border: Border(top: BorderSide(color: context.colors.dividerColor)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: context.colors.textLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add, color: context.colors.surfaceWhite, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: context.colors.background,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: TextStyle(color: context.colors.textDark),
                        onSubmitted: (_) => _handleSendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: context.colors.textLight, fontSize: 15),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _handleSendMessage,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryTeal,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingMessage(BuildContext context, {
    required String text,
    required String time,
    required String avatarUrl,
    String? imageUrl,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
          backgroundColor: context.colors.primaryTeal.withValues(alpha: 0.1),
          child: avatarUrl.isEmpty
              ? Text(
                  widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.surfaceWhite,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(4),
                  ),
                  border: Border.all(color: context.colors.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        color: context.colors.textDark,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    if (imageUrl != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          height: 160,
                          width: double.infinity,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  color: context.colors.textLight,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildOutgoingMessage(BuildContext context, {
    required String text,
    required String time,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(width: 40),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.primaryTeal,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      color: context.colors.textLight,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all, color: AppColors.primaryTeal, size: 14),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.primaryTeal,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              'ME',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
