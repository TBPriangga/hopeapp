import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../viewsModels/home/birthday_viewmodel.dart';

class BirthdaySection extends StatefulWidget {
  const BirthdaySection({super.key});

  @override
  State<BirthdaySection> createState() => _BirthdaySectionState();
}

class _BirthdaySectionState extends State<BirthdaySection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BirthdayViewModel>().loadWeeklyBirthdays();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BirthdayViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.error != null) {
          return SizedBox(
            height: 150,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  TextButton(
                    onPressed: () => viewModel.loadWeeklyBirthdays(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        if (viewModel.birthdays.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Jemaat Yang Berulang Tahun Minggu Ini :',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Tidak ada yang berulang tahun minggu ini',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jemaat Yang Berulang Tahun Minggu Ini :',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: viewModel.birthdays.length,
                  itemBuilder: (context, index) {
                    final person = viewModel.birthdays[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 0 : 16,
                        right: index == viewModel.birthdays.length - 1 ? 0 : 16,
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: person.photoUrl != null
                                ? NetworkImage(person.photoUrl!)
                                : const AssetImage(
                                    'assets/images/default_avatar.png',
                                  ) as ImageProvider,
                            backgroundColor: Colors.grey[200],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 60,
                            child: Text(
                              person.name,
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
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
