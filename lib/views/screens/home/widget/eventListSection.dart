import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../widgets/eventCard.dart';

class EventListSection extends StatelessWidget {
  const EventListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AGENDA KEGIATAN',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Cek apakah ada event atau tidak
                  bool hasEvents =
                      true; // Ini nanti bisa diganti dengan pengecekan real data

                  if (hasEvents) {
                    Navigator.pushNamed(
                        context, AppRoutes.event); // Navigasi ke EventScreen
                  } else {
                    Navigator.pushNamed(context,
                        AppRoutes.emptyEvent); // Navigasi ke EmptyEventScreen
                  }
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Lihat Semua',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return const EventCard();
              },
            ),
          ),
        ],
      ),
    );
  }
}
