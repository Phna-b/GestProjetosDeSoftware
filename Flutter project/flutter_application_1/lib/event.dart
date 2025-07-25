// lib/models/event.dart

class Event {
  final int id;
  final String title;
  final String description;
  final DateTime date;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'] ?? 'Sem título',
      description: json['description'] ?? 'Sem descrição',
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
    };
  }
}