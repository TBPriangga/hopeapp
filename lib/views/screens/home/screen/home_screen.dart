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
                  const HomeCarousel(),
                  const DailyWordSection(),
                  const BirthdaySection(),
                  const MenuGridSection(),
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
