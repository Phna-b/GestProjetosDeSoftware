import 'package:flutter/material.dart';
import 'api_service.dart';
import 'event_detail_page.dart';

class MyAgendaPage extends StatefulWidget {
  const MyAgendaPage({super.key});

  @override
  State<MyAgendaPage> createState() => _MyAgendaPageState();
}

class _MyAgendaPageState extends State<MyAgendaPage> {
  late Future<List<dynamic>> _subscribedEventsFuture;

  @override
  void initState() {
    super.initState();
    _subscribedEventsFuture = _fetchSubscribedEvents();
  }

  Future<List<dynamic>> _fetchSubscribedEvents() async {
    try {
      final events = await ApiService.get('/my_agenda');
      if(events is List) {
        return events;
      } else {
        throw Exception('Formato de resposta inesperado.');
      }
    } catch (e) {
      throw Exception('Falha ao carregar sua agenda. Tente novamente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Agenda'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _subscribedEventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Você ainda não se inscreveu em nenhum evento.'),
            );
          }

          final events = snapshot.data!;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                child: ListTile(
                  leading: const Icon(Icons.bookmark_added, color: Colors.indigo),
                  title: Text(event['title']),
                  subtitle: Text(event['date']),
                   onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailPage(event: event),
                        ),
                      );
                   },
                ),
              );
            },
          );
        },
      ),
    );
  }
}