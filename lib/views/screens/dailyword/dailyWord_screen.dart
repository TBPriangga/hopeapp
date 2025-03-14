import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/home/daily_word_model.dart';

class DailyWordScreen extends StatefulWidget {
  final DailyWordModel? dailyWord;

  const DailyWordScreen({
    super.key,
    this.dailyWord,
  });

  @override
  State<DailyWordScreen> createState() => _DailyWordScreenState();
}

class _DailyWordScreenState extends State<DailyWordScreen> {
  // Kontrol ukuran teks
  double _textScaleFactor = 1.0;
  static const double _minTextScale = 0.8;
  static const double _maxTextScale = 2.0;

  @override
  Widget build(BuildContext context) {
    // Get dailyWord from widget or from arguments
    final dailyWord = widget.dailyWord ??
        (ModalRoute.of(context)?.settings.arguments as DailyWordModel);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF132054),
              Color(0xFF2B478A),
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  'Firman Hari Ini',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                centerTitle: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bible Verse Card
                      GestureDetector(
                        onTap: () => _launchBibleUrl(dailyWord.bibleUrl),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.menu_book,
                                    color: Color(0xFF132054),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      dailyWord.verse,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF132054),
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.open_in_new,
                                    color: Color(0xFF132054),
                                    size: 20,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SelectableText(
                                dailyWord.content,
                                style: TextStyle(
                                  fontSize: 16 * _textScaleFactor,
                                  height: 1.6,
                                  color: Colors.grey[800],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Meditation Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Icon dan judul renungan
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.lightbulb_outline,
                                      color: Color(0xFF132054),
                                      size: 24,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Renungan',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF132054),
                                      ),
                                    ),
                                  ],
                                ),
                                // Kontrol ukuran teks
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        setState(() {
                                          _textScaleFactor =
                                              (_textScaleFactor - 0.1).clamp(
                                                  _minTextScale, _maxTextScale);
                                        });
                                      },
                                      iconSize: 20,
                                      color: Colors.grey[600],
                                      tooltip: 'Perkecil teks',
                                    ),
                                    Text(
                                      'Ukuran Teks',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        setState(() {
                                          _textScaleFactor =
                                              (_textScaleFactor + 0.1).clamp(
                                                  _minTextScale, _maxTextScale);
                                        });
                                      },
                                      iconSize: 20,
                                      color: Colors.grey[600],
                                      tooltip: 'Perbesar teks',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SelectableText(
                              dailyWord.description,
                              style: TextStyle(
                                fontSize: 16 * _textScaleFactor,
                                height: 1.6,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Share Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Implement share functionality
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF132054),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.share),
                          label: const Text(
                            'Bagikan Firman',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchBibleUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
