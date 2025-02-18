import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/event/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get upcoming events
  Stream<List<EventModel>> getUpcomingEvents({int limit = 3}) {
    return _firestore
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: DateTime.now())
        .where('isActive', isEqualTo: true)
        .orderBy('date')
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get all events
  Stream<List<EventModel>> getAllEvents() {
    return _firestore
        .collection('events')
        .where('isActive', isEqualTo: true)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get single event
  Future<EventModel?> getEventById(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (!doc.exists) return null;
      return EventModel.fromMap(doc.id, doc.data()!);
    } catch (e) {
      print('Error getting event detail: $e');
      throw Exception('Failed to load event detail');
    }
  }
}
