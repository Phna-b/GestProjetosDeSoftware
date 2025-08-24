import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/static_events.dart';
import '../models/event.dart';
import '../services/firestore_service.dart';
import '../widgets/event_card.dart';
import 'event_detail_page.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final fs = context.read<FirestoreService>();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: kStaticEvents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final Event ev = kStaticEvents[index];
        return StreamBuilder<bool>(
          stream: fs.isFavoriteStream(uid: uid, eventId: ev.id),
          builder: (context, snap) {
            final isFav = snap.data ?? false;
            return EventCard(
              event: ev,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EventDetailPage(event: ev)),
              ),
              trailing: Column(
                children: [
                  IconButton(
                    tooltip: isFav ? 'Remover dos Favoritos' : 'Adicionar aos Favoritos',
                    onPressed: () => fs.toggleFavorite(uid: uid, eventId: ev.id, makeFavorite: !isFav),
                    icon: Icon(isFav ? Icons.star : Icons.star_border),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}