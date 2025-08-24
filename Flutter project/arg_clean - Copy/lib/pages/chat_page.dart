import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';

class ChatPage extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final String currentUserName;
  const ChatPage({super.key, required this.eventId, required this.eventTitle, required this.currentUserName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final fs = context.read<FirestoreService>();

    return Scaffold(
      appBar: AppBar(title: Text('Chat – ${widget.eventTitle}')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: fs.chatStream(widget.eventId),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs; // ordem: mais recentes primeiro
                if (docs.isEmpty) {
                  return const Center(child: Text('Ainda não há mensagens.'));
                }
                return ListView.builder(
                  reverse: true, // para mais recentes ficarem no topo visual
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final m = docs[i].data();
                    final isMe = m['uid'] == uid;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m['name'] ?? 'Usuário', style: Theme.of(context).textTheme.labelMedium),
                            const SizedBox(height: 4),
                            Text(m['text'] ?? ''),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(fs, uid),
                      decoration: const InputDecoration(hintText: 'Escreva sua pergunta...'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _send(fs, uid),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _send(FirestoreService fs, String uid) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await fs.sendMessage(
      eventId: widget.eventId,
      uid: uid,
      displayName: widget.currentUserName,
      text: text,
    );
    _controller.clear();
  }
}