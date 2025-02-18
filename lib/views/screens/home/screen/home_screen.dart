import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../viewsModels/home/carousel_viewmodel.dart';
import '../../../widgets/customAppBar.dart';
import '../../../widgets/customBottomNav.dart';
import '../widget/DailyWordSection.dart';
import '../widget/birthdaySection.dart';
import '../widget/eventListSection.dart';
import '../widget/homeCarousel.dart';
import '../widget/menuGridSection.dart';

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
    // Add refresh for other sections if needed
  }

  @override
  Widget build(BuildContext context) {
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
          ),
        ),
        child: Column(
          children: [
            const CustomAppBar(
              onMenuPressed: null,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Consumer<CarouselViewModel>(
                builder: (context, carouselViewModel, child) {
                  return RefreshIndicator(
                    onRefresh: () => _refreshHome(context),
                    child: const SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HomeCarousel(),
                          DailyWordSection(),
                          BirthdaySection(),
                          SizedBox(height: 16),
                          MenuGridSection(),
                          SizedBox(height: 08),
                          EventListSection(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
