import 'package:flutter/material.dart';

class SaveSermonScreen extends StatelessWidget {
  const SaveSermonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF132054),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Simpan Sermon',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Thumbnail
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: const DecorationImage(
                          image: AssetImage('assets/dummy/sermon_thumb.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '24 Oktober 2023',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Hikmat Dalam Berbagai Persoalan Pernikahan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: const [
                              Text(
                                '1 minggu yang lalu',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.remove_red_eye,
                                  size: 16, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(
                                '1045',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Bookmark Icon
                    IconButton(
                      icon: const Icon(Icons.bookmark, size: 24),
                      onPressed: () {
                        // Handle unsave sermon
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
