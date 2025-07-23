import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _events = [];

  Future<void> fetchEvents(DateTime date) async {
    final formattedDate = "${date.year.toString().padLeft(4, '0')}-"
                          "${date.month.toString().padLeft(2, '0')}-"
                          "${date.day.toString().padLeft(2, '0')}";
    final uri = Uri.parse('http://localhost:5000/calendar/$formattedDate');


    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _events = List<Map<String, dynamic>>.from(data);
        });
      } else {
        throw Exception("Erro ao carregar eventos: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _events = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e')),
      );
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
      appBar: AppBar(title: const Text('Calendário de Eventos')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2025, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month', // <- só deixa disponível esse formato
            },           
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              fetchEvents(selectedDay);
            },
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _events.isEmpty
                ? const Center(child: Text('Nenhum evento para este dia.'))
                : ListView.builder(
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      final e = _events[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: ListTile(
                          title: Text(e['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (e['time'] != null && e['time'].toString().isNotEmpty)
                                Text('Horário: ${e['time']}'),
                              const SizedBox(height: 4),
                              Text(e['description']),
                            ],
                          ),
                          trailing: Text(e['date']),
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