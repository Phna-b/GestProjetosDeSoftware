import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Favoritos (por usuário)
  Future<void> toggleFavorite({required String uid, required String eventId, required bool makeFavorite}) async {
    final ref = _db.collection('users').doc(uid).collection('favorites').doc(eventId);
    if (makeFavorite) {
      await ref.set({'eventId': eventId, 'createdAt': FieldValue.serverTimestamp()});
    } else {
      await ref.delete();
    }
  }

  Stream<bool> isFavoriteStream({required String uid, required String eventId}) {
    final ref = _db.collection('users').doc(uid).collection('favorites').doc(eventId);
    return ref.snapshots().map((d) => d.exists);
  }

  Future<List<String>> getFavorites({required String uid}) async {
    final snap = await _db.collection('users').doc(uid).collection('favorites').get();
    return snap.docs.map((d) => d.id).toList();
  }

  // Check‑in (gate do chat)
  Future<void> checkIn({required String uid, required String eventId}) async {
    final ref = _db.collection('events').doc(eventId).collection('attendees').doc(uid);
    await ref.set({'uid': uid, 'checkedAt': FieldValue.serverTimestamp()});
  }

  Stream<bool> hasCheckedInStream({required String uid, required String eventId}) {
    final ref = _db.collection('events').doc(eventId).collection('attendees').doc(uid);
    return ref.snapshots().map((d) => d.exists);
  }

  // Chat por evento (somente para quem tem check-in)
  Stream<QuerySnapshot<Map<String, dynamic>>> chatStream(String eventId) {
    return _db
        .collection('events')
        .doc(eventId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(100)
        .snapshots();
  }

  Future<void> sendMessage({
    required String eventId,
    required String uid,
    required String displayName,
    required String text,
  }) async {
    final ref = _db.collection('events').doc(eventId).collection('messages');
    await ref.add({
      'uid': uid,
      'name': displayName,
      'text': text.trim(),
      'sentAt': FieldValue.serverTimestamp(),
    });
  }
}