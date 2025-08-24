import 'package:flutter/material.dart';
import '../models/event.dart';
import '../data/static_events.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final Widget? trailing; // ícones/ações (favoritar, chat, checkin)
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.event, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(formatDay(event.date) + (event.endDate != null ? ' — ${formatDay(event.endDate!)}' : '')),
                    if (event.location != null) ...[
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.place, size: 16),
                        const SizedBox(width: 4),
                        Flexible(child: Text(event.location!)),
                      ]),
                    ],
                    if (event.description != null) ...[
                      const SizedBox(height: 8),
                      Text(event.description!),
                    ]
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}