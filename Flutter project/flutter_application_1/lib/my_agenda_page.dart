// lib/my_agenda_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'event_detail_page.dart';

class MyAgendaPage extends StatefulWidget {
  const MyAgendaPage({super.key});

  @override
  _MyAgendaPageState createState() => _MyAgendaPageState();
}

class _MyAgendaPageState extends State<MyAgendaPage> {
  List<Map<String, dynamic>> _subscribedEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyAgenda();
  }

  Future<void> _fetchMyAgenda() async {
    final uri = Uri.parse('http://10.0.2.2:5000/my_agenda');
    try {
      final response = await http.get(uri); // Adicionar tratamento de cookies/sessão
      if (response.statusCode == 200) {
        setState(() {
          _subscribedEvents = List<Map<String, dynamic>>.from(jsonDecode(response.body));
          _isLoading = false;
        });
      }
    } catch (e) {
      // Tratar erro
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minha Agenda')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _subscribedEvents.length,
              itemBuilder: (context, index) {
                final e = _subscribedEvents[index];
                return ListTile(
                  title: Text(e['title'] ?? ''),
                  subtitle: Text(e['date'] ?? ''),
                  onTap: () {
                     Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EventDetailPage(eventId: e['id']),
                        ),
                    );
                  },
                );
              },
            ),
    );
  }
}