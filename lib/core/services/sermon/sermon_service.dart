import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/sermon/sermon_model.dart';
import '../../../models/sermon/sermon_series_model.dart';

class SermonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get latest video sermons
  Future<List<SermonModel>> getLatestVideoSermons({int limit = 5}) async {
    try {
      final snapshot = await _firestore
          .collection('sermons')
          .where('isActive', isEqualTo: true)
          .where('youtubeUrl', isNotEqualTo: '')
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => SermonModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to load video sermons: $e');
    }
  }

// Get sermon with series data
  Future<Map<String, dynamic>> getSermonWithSeries(String sermonId) async {
    try {
      final sermonDoc =
          await _firestore.collection('sermons').doc(sermonId).get();
      if (!sermonDoc.exists) {
        throw Exception('Sermon not found');
      }

      final sermon = SermonModel.fromMap(sermonDoc.id, sermonDoc.data()!);

      // Get series data
      final seriesDoc = await _firestore
          .collection('sermon_series')
          .doc(sermon.seriesId)
          .get();

      final series = seriesDoc.exists
          ? SermonSeries.fromMap(seriesDoc.id, seriesDoc.data()!)
          : null;

      return {
        'sermon': sermon,
        'series': series,
      };
    } catch (e) {
      throw Exception('Failed to load sermon detail: $e');
    }
  }

  // Get active sermon series
  Future<List<SermonSeries>> getActiveSermonSeries() async {
    try {
      final snapshot = await _firestore
          .collection('sermon_series')
          .where('isActive', isEqualTo: true)
          .orderBy('startDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SermonSeries.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to load sermon series: $e');
    }
  }

// Get sermons by series ID
  Future<List<SermonModel>> getSermonsBySeriesId(String seriesId) async {
    try {
      final snapshot = await _firestore
          .collection('sermons')
          .where('seriesId', isEqualTo: seriesId)
          .where('isActive', isEqualTo: true)
          .orderBy('date', descending: true)
          .get();

      final sermons = snapshot.docs
          .map((doc) => SermonModel.fromMap(doc.id, doc.data()))
          .toList();

      // Urutkan: video dulu, baru yang tidak ada video
      sermons.sort((a, b) {
        if (a.hasVideo && !b.hasVideo) return -1;
        if (!a.hasVideo && b.hasVideo) return 1;
        return 0;
      });

      return sermons;
    } catch (e) {
      throw Exception('Failed to load sermons: $e');
    }
  }

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
    try {
      final doc = await _firestore.collection('sermons').doc(id).get();
      if (!doc.exists) return null;
      return SermonModel.fromMap(doc.id, doc.data()!);
    } catch (e) {
      throw Exception('Failed to load sermon: $e');
    }
  }

// Get related sermons from the same series
// Get related sermons from the same series
  Future<List<SermonModel>> getRelatedSermons({
    required String seriesId,
    required String currentSermonId,
    int limit = 3,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('sermons')
          .where('seriesId', isEqualTo: seriesId)
          .where('isActive', isEqualTo: true)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      // Filter currentSermonId setelah mendapatkan data
      return snapshot.docs
          .where((doc) => doc.id != currentSermonId)
          .map((doc) => SermonModel.fromMap(doc.id, doc.data()))
          .take(limit)
          .toList();
    } catch (e) {
      throw Exception('Failed to load related sermons: $e');
    }
  }

  // Get series by ID
  Future<SermonSeries?> getSeriesById(String id) async {
    try {
      final doc = await _firestore.collection('sermon_series').doc(id).get();
      if (!doc.exists) return null;
      return SermonSeries.fromMap(doc.id, doc.data()!);
    } catch (e) {
      throw Exception('Failed to load series: $e');
    }
  }

  // Stream series changes
  Stream<SermonSeries?> watchSeriesById(String id) {
    return _firestore.collection('sermon_series').doc(id).snapshots().map(
        (doc) => doc.exists ? SermonSeries.fromMap(doc.id, doc.data()!) : null);
  }

  // Get latest series with their sermons
  Future<Map<SermonSeries, List<SermonModel>>> getLatestSeriesWithSermons(
      {int limit = 5}) async {
    try {
      // Get latest series
      final seriesSnapshot = await _firestore
          .collection('sermon_series')
          .where('isActive', isEqualTo: true)
          .orderBy('startDate', descending: true)
          .limit(limit)
          .get();

      // Create map to store results
      final Map<SermonSeries, List<SermonModel>> results = {};

      // For each series, get its sermons
      for (var seriesDoc in seriesSnapshot.docs) {
        final series = SermonSeries.fromMap(seriesDoc.id, seriesDoc.data());
        final sermons = await getSermonsBySeriesId(series.id);
        results[series] = sermons;
      }

      return results;
    } catch (e) {
      throw Exception('Failed to load series with sermons: $e');
    }
  }

  // Search sermons across series
  Future<List<SermonModel>> searchSermons(String query) async {
    try {
      // Note: This is a simple implementation. For better search,
      // consider using a service like Algolia or implementing
      // full-text search in your backend
      final snapshot = await _firestore
          .collection('sermons')
          .where('isActive', isEqualTo: true)
          .orderBy('date', descending: true)
          .get();

      final allSermons = snapshot.docs
          .map((doc) => SermonModel.fromMap(doc.id, doc.data()))
          .toList();

      // Filter sermons based on query
      return allSermons.where((sermon) {
        final lowercaseQuery = query.toLowerCase();
        return sermon.title.toLowerCase().contains(lowercaseQuery) ||
            sermon.description.toLowerCase().contains(lowercaseQuery) ||
            sermon.preacher.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search sermons: $e');
    }
  }
}
