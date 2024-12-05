import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/home/daily_word_model.dart';

class DailyWordService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DailyWordModel?> getTodayDailyWord() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection('daily_words')
          .where('date', isGreaterThanOrEqualTo: today)
          .where('date', isLessThan: tomorrow)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return DailyWordModel.fromMap(
        snapshot.docs.first.id,
        snapshot.docs.first.data(),
      );
    } catch (e) {
      throw Exception('Failed to load daily word: $e');
    }
  }

  Future<List<DailyWordModel>> getPastDailyWords({
    DailyWordModel? lastDocument,
    int limit = 15,
  }) async {
    try {
      Query query = _firestore
          .collection('daily_words')
          .where('isActive', isEqualTo: true)
          .orderBy('date', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(
          await _firestore.collection('daily_words').doc(lastDocument.id).get(),
        );
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => DailyWordModel.fromMap(
              doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load daily words: $e');
    }
  }

  Future<List<DailyWordModel>> searchDailyWords(String query) async {
    try {
      final snapshot = await _firestore
          .collection('daily_words')
          .where('isActive', isEqualTo: true)
          .orderBy('date', descending: true)
          .get();

      final results = snapshot.docs
          .map((doc) => DailyWordModel.fromMap(
              doc.id, doc.data() as Map<String, dynamic>))
          .where((dailyWord) {
        final verse = dailyWord.verse.toLowerCase();
        final content = dailyWord.content.toLowerCase();
        final searchQuery = query.toLowerCase();
        return verse.contains(searchQuery) || content.contains(searchQuery);
      }).toList();

      return results;
    } catch (e) {
      throw Exception('Failed to search daily words: $e');
    }
  }
}
