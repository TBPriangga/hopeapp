import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../models/event/event_model.dart';
import '../../../../viewsModels/event/event_viewmodel.dart';
import '../../../widgets/eventCard.dart';

class EventListSection extends StatelessWidget {
  const EventListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventViewModel>(
      builder: (context, viewModel, child) {
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
                      // Langsung navigasi ke EventScreen
                      Navigator.pushNamed(context, AppRoutes.event);

                      // Atau jika ingin check menggunakan stream
                      // viewModel.getAllEvents().first.then((events) {
                      //   Navigator.pushNamed(
                      //     context,
                      //     events.isNotEmpty ? AppRoutes.event : AppRoutes.emptyEvent,
                      //   );
                      // });
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
                child: StreamBuilder<List<EventModel>>(
                  stream: viewModel.getUpcomingEvents(limit: 3),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final events = snapshot.data!;
                    if (events.isEmpty) {
                      return const Center(
                        child: Text('Tidak ada agenda kegiatan'),
                      );
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        return EventCard(event: events[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
