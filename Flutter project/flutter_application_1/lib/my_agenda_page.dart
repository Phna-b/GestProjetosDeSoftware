// lib/my_agenda_page.dart
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
      final events = await ApiService.getMyAgenda();
      return events;
    } catch (e) {
      debugPrint('Erro MyAgenda _fetchSubscribedEvents: $e');
      throw Exception('Falha ao carregar sua agenda. Tente novamente.');
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _subscribedEventsFuture = _fetchSubscribedEvents();
    });
    await _subscribedEventsFuture;
  }

  void _showCreateEventDialog() {
    final _titleCtl = TextEditingController();
    DateTime? pickedDate;
    TimeOfDay? pickedTime;
    final _descCtl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: const Text('Criar evento (apenas para você)'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _titleCtl, decoration: const InputDecoration(labelText: 'Título')),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(pickedDate == null ? 'Selecione a data' : pickedDate!.toIso8601String().split('T')[0]),
                    ),
                    TextButton(
                      onPressed: () async {
                        final now = DateTime.now();
                        final d = await showDatePicker(
                          context: context,
                          initialDate: now,
                          firstDate: DateTime(now.year - 2),
                          lastDate: DateTime(now.year + 5),
                        );
                        if (d != null) {
                          setInnerState(() {
                            pickedDate = d;
                          });
                        }
                      },
                      child: const Text('Escolher'),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(pickedTime == null ? 'Selecione o horário' : '${pickedTime!.hour.toString().padLeft(2, '0')}:${pickedTime!.minute.toString().padLeft(2, '0')}'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 10, minute: 0),
                          builder: (context, widget) {
                            return MediaQuery(
                              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                              child: widget ?? const SizedBox.shrink(),
                            );
                          },
                        );
                        if (t != null) {
                          setInnerState(() {
                            pickedTime = t;
                          });
                        }
                      },
                      child: const Text('Escolher'),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                TextField(controller: _descCtl, decoration: const InputDecoration(labelText: 'Descrição')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final title = _titleCtl.text.trim();
                final date = pickedDate?.toIso8601String().split('T').first;
                final time = pickedTime == null
                    ? ''
                    : '${pickedTime!.hour.toString().padLeft(2, '0')}:${pickedTime!.minute.toString().padLeft(2, '0')}';
                final desc = _descCtl.text.trim();

                if (title.isEmpty || date == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Título e data são obrigatórios')));
                  return;
                }

                final payload = {'title': title, 'date': date, 'time': time, 'description': desc};
                final res = await ApiService.createEvent(payload);
                if (res['status'] == 201) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evento criado')));
                  _refresh();
                } else {
                  final msg = res['body'] is Map && res['body']['error'] != null ? res['body']['error'] : 'Erro ao criar evento';
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                }
              },
              child: const Text('Criar'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndDelete(int eventId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir este evento? Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Excluir')),
        ],
      ),
    );

    if (ok == true) {
      try {
        final res = await ApiService.deleteEvent(eventId);
        if (res['status'] == 200) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evento excluído')));
          _refresh();
        } else {
          final msg = res['body'] is Map && res['body']['error'] != null ? res['body']['error'] : 'Erro ao excluir';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
      }
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
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Você ainda não se inscreveu em nenhum evento.')),
                ],
              ),
            );
          }

          final events = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index] as Map<String, dynamic>;
                final eventId = (event['id'] as num?)?.toInt();
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  child: ListTile(
                    leading: const Icon(Icons.bookmark_added, color: Colors.indigo),
                    title: Text(event['title'] ?? 'Sem título'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if ((event['date'] ?? '').toString().isNotEmpty) Text(event['date']),
                        if ((event['time'] ?? '').toString().isNotEmpty) Text(event['time']),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EventDetailPage(event: event)),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          tooltip: 'Excluir evento',
                          onPressed: eventId == null ? null : () => _confirmAndDelete(eventId),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateEventDialog,
        icon: const Icon(Icons.add),
        label: const Text('Criar Evento'),
      ),
    );
  }
}
