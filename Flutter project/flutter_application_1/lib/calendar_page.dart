// lib/calendar_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import 'event_detail_page.dart';
import 'my_agenda_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;

  Future<void> fetchEvents(DateTime date) async {
    setState(() {
      _isLoading = true;
    });
    
    final formattedDate = "${date.year.toString().padLeft(4, '0')}-"
                          "${date.month.toString().padLeft(2, '0')}-"
                          "${date.day.toString().padLeft(2, '0')}";
                          
    final uri = Uri.parse('http://localhost:5000/calendar/$formattedDate');

    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _events = List<Map<String, dynamic>>.from(data);
        });
      } else {
        setState(() { _events = []; });
      }
    } catch (e) {
      setState(() { _events = []; });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    fetchEvents(_focusedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário de Eventos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_pin_rounded, semanticLabel: "Minha Agenda"),
            tooltip: "Minha Agenda",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyAgendaPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'pt_BR',
            firstDay: DateTime.utc(2025, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                fetchEvents(selectedDay);
              }
            },
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _events.isEmpty
                    ? const Center(child: Text('Nenhum evento para este dia.'))
                    : ListView.builder(
                        itemCount: _events.length,
                        itemBuilder: (context, index) {
                          final event = _events[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              title: Text(event['title'] ?? 'Evento'),
                              onTap: () {
                                final eventId = event['id'];
                                if (eventId != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EventDetailPage(eventId: eventId),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}