import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../models/home/daily_word_model.dart';

class DailyWordPopup extends StatelessWidget {
  final DailyWordModel dailyWord;

  const DailyWordPopup({
    super.key,
    required this.dailyWord,
  });

  Future<void> _launchBibleUrl() async {
    if (await canLaunchUrl(Uri.parse(dailyWord.bibleUrl))) {
      await launchUrl(
        Uri.parse(dailyWord.bibleUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF132054),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_book,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Firman Hari Ini',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bible Verse
                InkWell(
                  onTap: _launchBibleUrl,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                dailyWord.verse,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                            Icon(
                              Icons.open_in_new,
                              size: 16,
                              color: Colors.blue[700],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dailyWord.content,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Description
                Text(
                  'Renungan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dailyWord.description,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 20),

                // Date
                Center(
                  child: Text(
                    DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                        .format(dailyWord.date),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
