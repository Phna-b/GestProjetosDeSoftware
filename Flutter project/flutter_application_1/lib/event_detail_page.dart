// lib/event_detail_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EventDetailPage extends StatefulWidget {
  final int eventId;
  const EventDetailPage({super.key, required this.eventId});

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  Map<String, dynamic>? _eventDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
  }

  Future<void> _fetchEventDetails() async {
    final uri = Uri.parse('http://10.0.2.2:5000/event/${widget.eventId}'); // Use 10.0.2.2 para emulador Android
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        setState(() {
          _eventDetails = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      // Tratar erro
    }
  }

  Future<void> _subscribeToEvent() async {
    final uri = Uri.parse('http://10.0.2.2:5000/subscribe/${widget.eventId}');
    try {
        await http.post(uri); // Adicionar tratamento de cookies/sessão se necessário
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inscrito com sucesso!'))
        );
    } catch (e) {
        // Tratar erro
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_eventDetails?['title'] ?? 'Carregando...')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_eventDetails!['title'], style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text("${_eventDetails!['date']} às ${_eventDetails!['time']}"),
                  const SizedBox(height: 16),
                  Text(_eventDetails!['description']),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _subscribeToEvent,
                    child: const Text('Inscrever-se na minha agenda'),
                  ),
                  const Divider(height: 40),
                  Text('Perguntas', style: Theme.of(context).textTheme.titleLarge),
                  // Adicionar aqui a lógica para enviar perguntas
                  // ...
                  // E para listar as perguntas existentes
                  ...(_eventDetails!['questions'] as List).map((q) => ListTile(
                        title: Text(q['content']),
                        subtitle: Text('por: ${q['author']}'),
                      )),
                ],
              ),
            ),
    );
  }
}