import 'package:flutter/material.dart';
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onMenuPressed: () {},
      ),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: CustomSearchBar(
                hintText: 'Cari...',
              ),
            ),
            HomeCarousel(),
            DailyWordSection(),
            BirthdaySection(),
            MenuGridSection(),
            ServiceGridSection(),
            EventListSection(),
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
