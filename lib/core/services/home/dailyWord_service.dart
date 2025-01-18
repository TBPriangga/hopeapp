import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/home/daily_word_model.dart';

class DailyWordService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DailyWordModel?> getTodayDailyWord() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      print('Fetching daily word for date: $today');

      final snapshot = await _firestore
          .collection('daily_words')
          .where('date', isGreaterThanOrEqualTo: today)
          .where('date', isLessThan: tomorrow)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No daily word found for today');
        return null;
      }

      final doc = snapshot.docs.first;
      print('Found daily word with ID: ${doc.id}');

      try {
        final dailyWord = DailyWordModel.fromMap(doc.id, doc.data());
        print('Successfully parsed daily word: ${dailyWord.verse}');
        return dailyWord;
      } catch (parseError) {
        print('Error parsing daily word: $parseError');
        print('Raw data: ${doc.data()}');
        return null;
      }
    } catch (e) {
      print('Error in getTodayDailyWord: $e');
      return null;
    }
  }

  Future<List<DailyWordModel>> getPastDailyWords({
    DailyWordModel? lastDocument,
    int limit = 15,
  }) async {
    try {
      print(
          'Fetching past daily words. Limit: $limit, Last doc ID: ${lastDocument?.id}');

      Query query = _firestore
          .collection('daily_words')
          .where('isActive', isEqualTo: true)
          .orderBy('date', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        final lastDoc = await _firestore
            .collection('daily_words')
            .doc(lastDocument.id)
            .get();
        if (!lastDoc.exists) {
          print('Last document not found: ${lastDocument.id}');
          throw Exception('Last document reference not found');
        }
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();
      print('Retrieved ${snapshot.docs.length} documents');

      final List<DailyWordModel> dailyWords = [];
      for (var doc in snapshot.docs) {
        try {
          final dailyWord = DailyWordModel.fromMap(
              doc.id, doc.data() as Map<String, dynamic>);
          dailyWords.add(dailyWord);
        } catch (parseError) {
          print('Error parsing document ${doc.id}: $parseError');
          print('Raw data: ${doc.data()}');
          continue;
        }
      }

      print('Successfully parsed ${dailyWords.length} daily words');
      return dailyWords;
    } catch (e) {
      print('Error in getPastDailyWords: $e');
      return [];
    }
  }

  Future<List<DailyWordModel>> searchDailyWords(String query) async {
    try {
      print('Searching daily words with query: $query');

      if (query.trim().isEmpty) {
        print('Empty search query, returning empty list');
        return [];
      }

      final snapshot = await _firestore
          .collection('daily_words')
          .where('isActive', isEqualTo: true)
          .orderBy('date', descending: true)
          .get();

      print('Retrieved ${snapshot.docs.length} documents for search');

      final List<DailyWordModel> results = [];
      final searchQuery = query.toLowerCase();

      for (var doc in snapshot.docs) {
        try {
          final dailyWord = DailyWordModel.fromMap(
              doc.id, doc.data() as Map<String, dynamic>);

          final verse = dailyWord.verse.toLowerCase();
          final content = dailyWord.content.toLowerCase();

          if (verse.contains(searchQuery) || content.contains(searchQuery)) {
            results.add(dailyWord);
          }
        } catch (parseError) {
          print('Error parsing document ${doc.id} during search: $parseError');
          print('Raw data: ${doc.data()}');
          continue;
        }
      }

      print('Found ${results.length} matching results');
      return results;
    } catch (e) {
      print('Error in searchDailyWords: $e');
      return [];
    }
  }

  // Helper method untuk validasi data
  bool _isValidDailyWord(Map<String, dynamic> data) {
    return data.containsKey('verse') &&
        data.containsKey('content') &&
        data.containsKey('description') &&
        data.containsKey('date') &&
        data.containsKey('bibleUrl') &&
        data.containsKey('isActive');
  }
}
