import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/sermon/sermon_model.dart';

class SermonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get latest sermons
  Stream<List<SermonModel>> getLatestSermons() {
    return _firestore
        .collection('sermons')
        .where('isActive', isEqualTo: true)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SermonModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get sermon by ID
  Future<SermonModel?> getSermonById(String id) async {
    final doc = await _firestore.collection('sermons').doc(id).get();
    if (!doc.exists) return null;
    return SermonModel.fromMap(doc.id, doc.data()!);
  }

  Stream<List<SermonModel>> getRelatedSermons(String currentSermonId) {
    return _firestore
        .collection('sermons')
        .where('isActive', isEqualTo: true)
        .where(FieldPath.documentId, isNotEqualTo: currentSermonId)
        .orderBy(FieldPath.documentId)
        .limit(3)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SermonModel.fromMap(doc.id, doc.data()))
            .toList());
  }
}
