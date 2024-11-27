// lib/views/screens/home/screen/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../viewsModels/home/carousel_viewmodel.dart';
import '../../../widgets/customAppBar.dart';
import '../../../widgets/customSearchBar.dart';
import '../../../widgets/customBottomNav.dart';
import '../widget/DailyWordSection.dart';
import '../widget/birthdaySection.dart';
import '../widget/eventListSection.dart';
import '../widget/homeCarousel.dart';
import '../widget/menuGridSection.dart';
import '../widget/serviceSection.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load carousel data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CarouselViewModel>().loadCarousels();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _refreshHome(BuildContext context) async {
    // Refresh carousel data
    await context.read<CarouselViewModel>().loadCarousels();
    // Tambahkan refresh untuk section lain jika diperlukan
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onMenuPressed: () {},
      ),
      body: Consumer<CarouselViewModel>(
        builder: (context, carouselViewModel, child) {
          return RefreshIndicator(
            onRefresh: () => _refreshHome(context),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: CustomSearchBar(
                      hintText: 'Cari...',
                    ),
                  ),
                  // Carousel section with loading/error handling
                  if (carouselViewModel.isLoading)
                    const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (carouselViewModel.error != null)
                    Container(
                      height: 200,
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(height: 8),
                            Text(
                              carouselViewModel.error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            TextButton(
                              onPressed: () =>
                                  carouselViewModel.loadCarousels(),
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const HomeCarousel(),
                  const DailyWordSection(),
                  const BirthdaySection(),
                  const MenuGridSection(),
                  const ServiceGridSection(),
                  const EventListSection(),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
