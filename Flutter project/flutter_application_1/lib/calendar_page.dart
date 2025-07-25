// lib/calendar_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'api_service.dart';
import 'event_detail_page.dart';
import 'main.dart'; // Para acessar o AuthProvider
import 'my_agenda_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic> _allEvents = [];
  final ValueNotifier<List<dynamic>> _selectedEvents = ValueNotifier([]);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchAllUserEvents();
  }

  Future<void> _fetchAllUserEvents() async {
    setState(() => _isLoading = true);
    try {
      final events = await ApiService.get('/events');
      if (mounted) {
        setState(() {
          _allEvents = events;
        });
        _filterEventsForDay(_selectedDay!);
      }
    } catch (e) {
      debugPrint("Erro ao buscar eventos: $e");
      if (mounted) {
        if (e.toString().contains('401')) {
          Provider.of<AuthProvider>(context, listen: false).logout();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Erro ao buscar seus eventos.'),
                backgroundColor: Colors.red),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterEventsForDay(DateTime day) {
    final eventsForDay = _allEvents.where((event) {
      final eventDateString = event['date'] as String?;
      if (eventDateString == null) {
        return false;
      }

      try {
        final eventDate = DateTime.parse(eventDateString);
        return eventDate.year == day.year &&
            eventDate.month == day.month &&
            eventDate.day == day.day;
      } catch (e) {
        debugPrint("Erro ao converter data do evento: $e");
        return false;
      }
    }).toList();

    _selectedEvents.value = eventsForDay;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _filterEventsForDay(selectedDay);
    }
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
              await Provider.of<AuthProvider>(context, listen: false).logout();
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
                        return const Center(
                            child: Text('Nenhum evento para este dia.'));
                      }
                      return ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 4.0),
                            child: ListTile(
                              leading: const Icon(Icons.event_available,
                                  color: Colors.indigo),
                              title: Text(event['title']),
                              subtitle: Text(event['time']?.toString() ??
                                  'Horário não definido'),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EventDetailPage(event: event),
                                  ),
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
