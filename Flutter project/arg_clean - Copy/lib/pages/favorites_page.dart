import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/static_events.dart';
import '../models/event.dart';
import '../services/firestore_service.dart';
import '../widgets/event_card.dart';
import 'event_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final fs = context.read<FirestoreService>();

    return FutureBuilder<List<String>>(
      future: fs.getFavorites(uid: uid),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final favIds = snap.data!;
        final favEvents = kStaticEvents.where((e) => favIds.contains(e.id)).toList();
        if (favEvents.isEmpty) {
          return const Center(child: Text('Nenhum favorito ainda. Adicione pelo calendário.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: favEvents.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final Event ev = favEvents[index];
            return EventCard(
              event: ev,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EventDetailPage(event: ev)),
              ),
            );
          },
        );
      },
    );
  }
}