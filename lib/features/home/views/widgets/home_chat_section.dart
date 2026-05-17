// Flutter imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_utility/master_utility.dart';
// Project imports:
import 'package:project_aether/features/home/controllers/home_state_notifier.dart';

class HomeChatSection extends ConsumerStatefulWidget {
  const HomeChatSection({super.key});

  @override
  ConsumerState<HomeChatSection> createState() => _HomeChatSectionState();
}

class _HomeChatSectionState extends ConsumerState<HomeChatSection> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final String text = _chatController.text;
    _chatController.clear();

    await ref.read(homeStateNotifierProvider.notifier).sendChatMessage(text);

    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<QuerySnapshot<Map<String, dynamic>>> chatAsync = ref.watch(homeChatMessagesProvider);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(12),
            child: AutoText(
              text: '💬 Global Chat',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: chatAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, _) => Center(
                child: AutoText(
                  text: 'Failed to load messages',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ),
              data: (QuerySnapshot<Map<String, dynamic>> snapshot) {
                final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = snapshot.docs;

                if (docs.isEmpty) {
                  return const Center(
                    child: AutoText(
                      text: 'No messages yet. Say hello!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Map<String, dynamic> data = docs[index].data();
                    final String text = (data['text'] as String?) ?? '';
                    final String userId = (data['userId'] as String?) ?? '';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          AutoText(
                            text: '$userId: ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Expanded(
                            child: AutoText(
                              text: text,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                GestureDetector(
                  onTap: _sendMessage,
                  child: const Icon(Icons.send, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
