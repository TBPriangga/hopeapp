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
}
