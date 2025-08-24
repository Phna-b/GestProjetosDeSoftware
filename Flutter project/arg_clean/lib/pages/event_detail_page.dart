import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/static_events.dart';
import '../models/event.dart';
import '../services/firestore_service.dart';
import 'chat_page.dart';

class EventDetailPage extends StatelessWidget {
  final Event event;
  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final user = FirebaseAuth.instance.currentUser!;
    final fs = context.read<FirestoreService>();

    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(formatDay(event.date) + (event.endDate != null ? ' — ${formatDay(event.endDate!)}' : '')),
            if (event.location != null) ...[
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.place, size: 18),
                const SizedBox(width: 6),
                Flexible(child: Text(event.location!)),
              ]),
            ],
            if (event.description != null) ...[
              const SizedBox(height: 12),
              Text(event.description!),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                StreamBuilder<bool>(
                  stream: fs.hasCheckedInStream(uid: uid, eventId: event.id),
                  builder: (context, snap) {
                    final checked = snap.data ?? false;
                    return ElevatedButton.icon(
                      onPressed: checked
                          ? null
                          : () async {
                              await fs.checkIn(uid: uid, eventId: event.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Check‑in realizado!')));
                              }
                            },
                      icon: Icon(checked ? Icons.verified : Icons.login),
                      label: Text(checked ? 'Check‑in feito' : 'Fazer check‑in'),
                    );
                  },
                ),
                const SizedBox(width: 12),
                StreamBuilder<bool>(
                  stream: fs.isFavoriteStream(uid: uid, eventId: event.id),
                  builder: (context, snap) {
                    final fav = snap.data ?? false;
                    return OutlinedButton.icon(
                      onPressed: () => fs.toggleFavorite(uid: uid, eventId: event.id, makeFavorite: !fav),
                      icon: Icon(fav ? Icons.star : Icons.star_border),
                      label: Text(fav ? 'Favorito' : 'Favoritar'),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            StreamBuilder<bool>(
              stream: fs.hasCheckedInStream(uid: uid, eventId: event.id),
              builder: (context, snap) {
                final canChat = snap.data ?? false;
                return SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: canChat
                        ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatPage(eventId: event.id, eventTitle: event.title, currentUserName: user.displayName ?? 'Usuário'),
                              ),
                            )
                        : null,
                    icon: const Icon(Icons.forum),
                    label: Text(canChat ? 'Abrir chat do evento' : 'Faça check‑in para acessar o chat'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}