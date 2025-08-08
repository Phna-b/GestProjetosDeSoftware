// lib/calendar_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'api_service.dart';
import 'event_detail_page.dart';
import 'main.dart'; // AuthProvider para logout (se existir)

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final ValueNotifier<List<dynamic>> _selectedEvents = ValueNotifier([]);
  bool _isLoading = true;

  // armazenar ids dos eventos que o usuário já está inscrito
  final Set<int> _subscribedEventIds = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadForDay(_focusedDay);
    _loadSubscriptions();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  Future<void> _loadSubscriptions() async {
    try {
      final list = await ApiService.getMyAgenda();
      final ids = <int>{};
      for (final e in list) {
        if (e is Map && e.containsKey('id')) {
          ids.add((e['id'] as num).toInt());
        }
      }
      if (mounted) {
        setState(() {
          _subscribedEventIds.clear();
          _subscribedEventIds.addAll(ids);
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar subscriptions: $e');
      // não falhar o fluxo, apenas manter vazio
    }
  }

  Future<void> _loadForDay(DateTime date) async {
    setState(() {
      _isLoading = true;
    });

    final formattedDate = "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";

    try {
      final respGlobal =
          await ApiService.fetchEvents(formattedDate, onlyMyEvents: false);
      final globalBody = (respGlobal['status'] == 200)
          ? List<Map<String, dynamic>>.from(respGlobal['body'] as List)
          : <Map<String, dynamic>>[];

      final respMy =
          await ApiService.fetchEvents(formattedDate, onlyMyEvents: true);
      final myBody = (respMy['status'] == 200)
          ? List<Map<String, dynamic>>.from(respMy['body'] as List)
          : <Map<String, dynamic>>[];

      final merged = <Map<String, dynamic>>[];
      for (final e in [...globalBody, ...myBody]) {
        final mapE = Map<String, dynamic>.from(e);
        final key = "${mapE['id']}_${mapE['title']}_${mapE['date']}_${mapE['time']}";
        if (!merged.any((m) =>
            "${m['id']}_${m['title']}_${m['date']}_${m['time']}" == key)) {
          merged.add(mapE);
        }
      }

      _selectedEvents.value = merged;
      // atualizar subscribed ids (para refletir inscricoes novas)
      await _loadSubscriptions();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar eventos: $e')),
        );
      }
      _selectedEvents.value = [];
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _loadForDay(selectedDay);
    }
  }

  Future<void> _toggleSubscription(int eventId) async {
    if (_subscribedEventIds.contains(eventId)) {
      final res = await ApiService.unsubscribeEvent(eventId);
      final ok = res['status'] == 200;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Removido da sua agenda' : (res['body']['error'] ?? 'Erro'))),
      );
      if (ok) {
        _subscribedEventIds.remove(eventId);
      }
    } else {
      final res = await ApiService.subscribeEvent(eventId);
      final ok = res['status'] == 201;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Adicionado à sua agenda' : (res['body']['error'] ?? 'Erro'))),
      );
      if (ok) {
        _subscribedEventIds.add(eventId);
      }
    }
    // atualizar lista do dia para refletir estado
    _loadForDay(_selectedDay ?? DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Programação'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              // chama o logout do provider (se existir) e limpa token
              if (Provider.of<AuthProvider?>(context, listen: false) != null) {
                await Provider.of<AuthProvider>(context, listen: false).logout();
              } else {
                await ApiService.logout();
              }
              // recarregar subscriptions vazias
              setState(() {
                _subscribedEventIds.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'pt_BR',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.orangeAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.indigo,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ValueListenableBuilder<List<dynamic>>(
                    valueListenable: _selectedEvents,
                    builder: (context, events, _) {
                      if (events.isEmpty) {
                        return const Center(child: Text('Nenhum evento para este dia.'));
                      }
                      return ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index] as Map<String, dynamic>;
                          final eventId = (event['id'] as num?)?.toInt();
                          final isSubscribed = eventId != null && _subscribedEventIds.contains(eventId);
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                            child: ListTile(
                              leading: const Icon(Icons.event_available, color: Colors.indigo),
                              title: Text(event['title'] ?? 'Sem título'),
                              subtitle: Text(event['time']?.toString() ?? 'Horário não definido'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(isSubscribed ? Icons.bookmark : Icons.bookmark_border),
                                    tooltip: isSubscribed ? 'Remover da Minha Agenda' : 'Adicionar à Minha Agenda',
                                    onPressed: eventId == null ? null : () => _toggleSubscription(eventId),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => EventDetailPage(event: event)),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/my_agenda');
        },
        label: const Text('Minha Agenda'),
        icon: const Icon(Icons.event_note),
      ),
    );
  }
}
