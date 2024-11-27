import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../models/home/birthday_model.dart';

class BirthdayService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<BirthdayModel>> getWeeklyBirthdays() async {
    try {
      // Get current week's date range
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 7));

      // Query users collection tanpa where clause
      final userSnapshots = await _firestore.collection('users').get();

      List<BirthdayModel> birthdays = [];

      for (var doc in userSnapshots.docs) {
        final data = doc.data();
        if (data['birthDate'] != null) {
          try {
            // Parse birthDate dari string format
            final DateTime birthDate =
                DateFormat('dd/MM/yyyy').parse(data['birthDate']);

            // Check if birthday is this week
            final birthDateThisYear = DateTime(
              now.year,
              birthDate.month,
              birthDate.day,
            );

            if (birthDateThisYear.isAfter(startOfWeek) &&
                birthDateThisYear.isBefore(endOfWeek)) {
              birthdays.add(BirthdayModel.fromMap(doc.id, {
                ...data,
                'userId': doc.id,
                'birthDate': data['birthDate'], // Gunakan string birthDate
                'createdAt': data['createdAt'] ?? Timestamp.now(),
              }));
            }
          } catch (e) {
            print('Error processing birthday for user ${doc.id}: $e');
            continue; // Skip this user if there's an error
          }
        }
      }

      // Sort by birth date
      birthdays.sort((a, b) {
        final aDate = DateTime(0, a.birthDate.month, a.birthDate.day);
        final bDate = DateTime(0, b.birthDate.month, b.birthDate.day);
        return aDate.compareTo(bDate);
      });

      return birthdays;
    } catch (e) {
      print('Error getting weekly birthdays: $e');
      throw Exception('Failed to load birthdays: $e');
    }
  }
}
