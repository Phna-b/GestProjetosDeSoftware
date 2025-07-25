// lib/event_detail_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDetailPage extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String formattedDate = 'Data não informada';
    String formattedTime = 'Hora não informada';

    if (event['date'] != null) {
      try {
        final dateTime = DateTime.parse(event['date']);
        formattedDate = DateFormat('dd/MM/yyyy', 'pt_BR').format(dateTime);
        formattedTime = DateFormat('HH:mm').format(dateTime);
      } catch (e) {
        debugPrint("Erro ao formatar data do evento: $e");
      }
    } else if (event['time'] != null) {
      formattedTime = event['time'];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Evento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              event['title'] ?? 'Título indisponível',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildDetailRow(
              theme,
              icon: Icons.calendar_today_outlined,
              title: 'Data',
              content: formattedDate,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              theme,
              icon: Icons.access_time_outlined,
              title: 'Horário',
              content: formattedTime,
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Descrição',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              event['description'] ?? 'Nenhuma descrição fornecida.',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme,
      {required IconData icon,
      required String title,
      required String content}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 2),
            Text(content, style: theme.textTheme.titleMedium),
          ],
        )
      ],
    );
  }
}
