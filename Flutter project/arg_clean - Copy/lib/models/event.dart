class Event {
  final String id; // estático/estável p/ referenciar no Firestore
  final String title;
  final DateTime date; // data/hora do começo
  final DateTime? endDate; // opcional
  final String? location;
  final String? description;

  const Event({
    required this.id,
    required this.title,
    required this.date,
    this.endDate,
    this.location,
    this.description,
  });
}