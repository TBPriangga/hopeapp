import 'package:flutter/material.dart';

import '../../../../app/routes/app_routes.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> events = [
      {
        'image': 'assets/dummy/sermon_thumb.png',
        'date': 'Minggu, Apr 28 • 07:30 WIB',
        'title': 'Ibadah Raya',
        'location': 'GBI Pengharapan Surabaya',
      },
      {
        'image': 'assets/dummy/sermon_thumb.png',
        'date': 'Rabu, May 1 • 06:30 WIB',
        'title': 'Doa Rabu',
        'location': 'GBI Pengharapan Surabaya',
      },
    ];

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
              // AppBar
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  'Event',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                centerTitle: true,
                actions: const [
                  IconButton(
                    icon: Icon(
                      Icons.bookmark_border_outlined,
                      color: Colors.white,
                    ),
                    onPressed: null,
                  ),
                ],
              ),
              // List Events
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return GestureDetector(
                      // Tambahkan ini
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.eventDetail);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFE5DC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              // Thumbnail
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                                child: Image.asset(
                                  event['image'],
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Content
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event['date'],
                                        style: TextStyle(
                                          color: Colors.blue[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        event['title'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on_outlined,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            event['location'],
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
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
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
